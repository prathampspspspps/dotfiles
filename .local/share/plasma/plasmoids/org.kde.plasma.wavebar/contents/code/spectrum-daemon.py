#!/usr/bin/env python3
"""Wavebar spectrum daemon.

Captures audio from a PulseAudio/PipeWire monitor source via `parec`,
computes an FFT, condenses the result into N logarithmic-frequency bars,
and serves the latest snapshot over a tiny localhost HTTP endpoint that
the Plasma widget polls. The chosen ephemeral port is written to
`<output>.port` so the widget can discover it.

Exits when the heartbeat file (`<output>.alive`) is older than 30 s, so a
removed widget won't leave a stale daemon running.
"""

import argparse
import http.server
import os
import signal
import struct
import subprocess
import sys
import threading
import time

import numpy as np


_state_lock = threading.Lock()
_state = {"payload": ""}


class _SpectrumHandler(http.server.BaseHTTPRequestHandler):
    # HTTP/1.1 enables keep-alive, so QNetworkAccessManager reuses the same
    # TCP connection across the QML poller's 30 Hz requests instead of doing
    # a fresh connect()/close() on each tick.
    protocol_version = "HTTP/1.1"

    def do_GET(self):
        with _state_lock:
            body = _state["payload"].encode("ascii")
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *_a, **_kw):
        pass


def start_http_server(output_path):
    httpd = http.server.ThreadingHTTPServer(("127.0.0.1", 0), _SpectrumHandler)
    port = httpd.server_address[1]
    port_path = output_path + ".port"
    tmp = port_path + ".tmp"
    with open(tmp, "w") as f:
        f.write(str(port))
    os.replace(tmp, port_path)
    threading.Thread(target=httpd.serve_forever, daemon=True).start()
    return httpd, port, port_path


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--device", required=True, help="pulse monitor source name")
    p.add_argument("--bars", type=int, default=32)
    p.add_argument("--rate", type=int, default=44100)
    p.add_argument("--chunk", type=int, default=256,
                   help="audio hop size in samples (FFT update rate)")
    p.add_argument("--fft-size", type=int, default=2048,
                   help="FFT window size; larger = better low-frequency "
                        "resolution but slightly higher latency")
    p.add_argument("--smoothing", type=float, default=0.75,
                   help="0 = no smoothing, 0.95 = very smooth")
    p.add_argument("--sensitivity", type=float, default=1.0)
    p.add_argument("--output", required=True)
    p.add_argument("--daemonize", action="store_true",
                   help="double-fork into the background, redirecting stdio")
    p.add_argument("--log", default=None,
                   help="when daemonized, redirect stdout/stderr here")
    return p.parse_args()


def daemonize(log_path):
    """Classic Unix double-fork. Parent exits immediately; the grandchild is
    detached from the controlling terminal and lives independently of any
    shell/QProcess that spawned us."""
    if os.fork() > 0:
        os._exit(0)
    os.setsid()
    if os.fork() > 0:
        os._exit(0)
    os.chdir("/")
    os.umask(0o077)
    sys.stdout.flush()
    sys.stderr.flush()
    devnull = os.open(os.devnull, os.O_RDONLY)
    os.dup2(devnull, 0)
    os.close(devnull)
    if log_path:
        log_fd = os.open(log_path, os.O_WRONLY | os.O_CREAT | os.O_APPEND, 0o644)
    else:
        log_fd = os.open(os.devnull, os.O_WRONLY)
    os.dup2(log_fd, 1)
    os.dup2(log_fd, 2)
    os.close(log_fd)


def build_band_indices(freqs, n_bars, fmin=30.0, fmax=16000.0):
    edges = np.logspace(np.log10(fmin), np.log10(fmax), n_bars + 1)
    out = []
    for i in range(n_bars):
        lo = int(np.searchsorted(freqs, edges[i], side="left"))
        hi = int(np.searchsorted(freqs, edges[i + 1], side="left"))
        if hi <= lo:
            hi = lo + 1
        out.append((lo, min(hi, len(freqs))))
    return out


def main():
    args = parse_args()
    if args.daemonize:
        daemonize(args.log)
    print(f"[spectrum-daemon] starting pid={os.getpid()} device={args.device}",
          flush=True)
    chunk = max(256, 1 << (args.chunk - 1).bit_length())
    # FFT window must be a power of two and >= chunk. The default 2048 gives
    # ~21 Hz bin resolution at 44.1 kHz — fine enough to separate the bass
    # bars, which were collapsing into one bin at chunk=256 (172 Hz/bin).
    fft_size = max(chunk, 1 << (args.fft_size - 1).bit_length())
    bytes_per_frame = chunk * 4  # float32 mono

    # `stdbuf -o0` forces parec's stdout to be unbuffered. Without this the
    # libc default block-buffering on a pipe batches up tens of milliseconds
    # of audio per write, making the visualizer feel sluggish.
    cmd = [
        "stdbuf", "-o0",
        "parec",
        "--device", args.device,
        "--format=float32le",
        "--rate", str(args.rate),
        "--channels=1",
        "--latency-msec=5",
        "--raw",
    ]

    _httpd, http_port, port_path = start_http_server(args.output)
    print(f"[spectrum-daemon] http listening on 127.0.0.1:{http_port}", flush=True)

    proc_holder = {"proc": None}

    def cleanup(*_):
        p = proc_holder["proc"]
        if p:
            try:
                p.terminate()
            except Exception:
                pass
        for path in (args.output, port_path):
            try:
                os.unlink(path)
            except OSError:
                pass
        sys.exit(0)

    signal.signal(signal.SIGTERM, cleanup)
    signal.signal(signal.SIGINT, cleanup)

    window = np.hanning(fft_size).astype(np.float32)
    freqs = np.fft.rfftfreq(fft_size, 1.0 / args.rate)
    bands = build_band_indices(freqs, args.bars,
                               fmin=30.0, fmax=min(16000.0, args.rate / 2))
    # Sliding window: read `chunk` new samples per iteration but FFT the
    # full `fft_size` history. Gives high frequency resolution AND a fast
    # update rate (no need to wait for a full fft_size buffer per frame).
    ring = np.zeros(fft_size, dtype=np.float32)

    smooth = np.zeros(args.bars, dtype=np.float32)
    decay = float(np.clip(args.smoothing, 0.0, 0.98))
    sens = float(max(0.05, args.sensitivity))

    alive_path = args.output + ".alive"
    # Touch alive file at start so the heartbeat check has a baseline.
    try:
        open(alive_path, "a").close()
        os.utime(alive_path, None)
    except OSError:
        pass

    def heartbeat_alive():
        try:
            return time.time() - os.path.getmtime(alive_path) <= 30
        except OSError:
            return False

    # Outer loop: respawn parec if it dies (typical after PipeWire restart on
    # system suspend/resume, sink hot-swap, source disappearing, etc.).
    while True:
        try:
            proc = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                                    stderr=subprocess.DEVNULL)
            proc_holder["proc"] = proc
        except Exception as e:
            print(f"[spectrum-daemon] failed to spawn parec: {e}", flush=True)
            time.sleep(1.0)
            if not heartbeat_alive():
                cleanup()
            continue

        last_alive_check = time.monotonic()

        while True:
            raw = proc.stdout.read(bytes_per_frame)
            if not raw or len(raw) < bytes_per_frame:
                break

            samples = np.frombuffer(raw, dtype=np.float32)
            if samples.size != chunk:
                continue
            ring[:-chunk] = ring[chunk:]
            ring[-chunk:] = samples
            windowed = ring * window
            spec = np.abs(np.fft.rfft(windowed)) / fft_size

            # Use the peak bin per band rather than the mean. With fft_size
            # large enough to resolve the bass, the treble bands now span
            # 100+ bins each, and most bins are at the noise floor — taking
            # the mean diluted real spectral peaks into nothing.
            bars = np.fromiter(
                (spec[lo:hi].max() for lo, hi in bands),
                dtype=np.float32,
                count=args.bars,
            )

            # Convert to dBFS-ish then map to 0..1.
            db = 20.0 * np.log10(bars + 1e-9)
            norm = np.clip((db + 60.0) / 60.0, 0.0, 1.0) * sens
            norm = np.clip(norm, 0.0, 1.0)

            # Asymmetric smoothing: rise fast, fall slowly.
            smooth = np.maximum(norm, smooth * decay)

            line = " ".join(f"{v:.3f}" for v in smooth)
            with _state_lock:
                _state["payload"] = line

            # Heartbeat check every ~2 s.
            now = time.monotonic()
            if now - last_alive_check > 2.0:
                last_alive_check = now
                if not heartbeat_alive():
                    cleanup()

        # parec ended — clean up and retry.
        print("[spectrum-daemon] parec stream ended; respawning",
              flush=True)
        try:
            proc.terminate()
            proc.wait(timeout=1.0)
        except Exception:
            pass
        proc_holder["proc"] = None

        # Drop the spectrum so the widget falls back to its idle animation
        # while we recover.
        smooth[:] = 0
        ring[:] = 0
        with _state_lock:
            _state["payload"] = ""

        time.sleep(1.0)
        if not heartbeat_alive():
            cleanup()


if __name__ == "__main__":
    main()
