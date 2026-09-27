
# Kamalen Shell: Vi key bindings
bindkey -v

# Kamalen Shell: Starship prompt
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi
