function textWeather(x) {
    let text = {
        0: "Clear",
        1: "Mainly clear",
        2: "Partly cloudy",
        3: "Overcast",
        51: "Drizzle light intensity",
        53: "Drizzle moderate intensity",
        55: "Drizzle dense intensity",
        56: "Freezing Drizzle light intensity",
        57: "Freezing Drizzle dense intensity",
        61: "Rain slight intensity",
        63: "Rain moderate intensity",
        65: "Rain heavy intensity",
        66: "Freezing Rain light intensity",
        67: "Freezing Rain heavy intensity",
        71: "Snowfall slight intensity",
        73: "Snowfall moderate intensity",
        75: "Snowfall heavy intensity",
        77: "Snow grains",
        80: "Rain showers slight",
        81: "Rain showers moderate",
        82: "Rain showers violent",
        85: "Snow showers slight",
        86: "Snow showers heavy",
        95: "Thunderstorm",
        96: "Thunderstorm with slight hail"
    };
    return i18n(text[x])
}

function asingicon(x, b, c) {
    let wmocodes = {
        0: "clear",
        1: "few-clouds",
        2: "few-clouds",
        3: "clouds",
        51: "showers-scattered",
        53: "showers-scattered",
        55: "showers-scattered",
        56: "showers-scattered",
        57: "showers-scattered",
        61: "showers",
        63: "showers",
        65: "showers",
        66: "showers-scattered",
        67: "showers",
        71: "snow-scattered",
        73: "snow",
        75: "snow",
        77: "hail",
        80: "showers",
        81: "showers",
        82: "showers",
        85: "snow-scattered",
        86: "snow",
        95: "storm",
        96: "storm",
        99: "storm",
    };
    var prefixIcon = c === 0 ? "-night" : ""
    var iconName = "weather-" + (wmocodes[x] || "unknown");
    var iconNamePresicion = iconName + prefixIcon
    return b === "preciso" ? iconNamePresicion : iconName ;

}

function shortTextWeather(x) {
    let text = {
        0: "Clear",
        1: "Clear",
        2: "Cloudy",
        3: "Cloudy",
        51: "Drizzle",
        53: "Drizzle",
        55: "Drizzle",
        56: "Drizzle",
        57: "Drizzle",
        61: "Rain",
        63: "Rain",
        65: "Rain",
        66: "Rain",
        67: "Rain",
        71: "Snow",
        73: "Snow",
        75: "Snow",
        77: "Hail",
        80: "Showers",
        81: "Showers",
        82: "Showers",
        85: "Showers",
        86: "Showers",
        95: "Storm",
        96: "Storm",
        99: "Storm"
    };
    return i18n(text[x])
}

function uvIndexLevelAssignment(nivel) {
    var levels = ["Low","Moderate","High","Very High","Extreme"]
    if (nivel < 3) {
        return i18n(levels[0])
    } else {
        if (nivel < 6) {
            return i18n(levels[1])
        } else {
            if (nivel < 8) {
                return i18n(levels[2])
            } else {
                if (nivel < 11) {
                    return i18n(levels[3])
                } else {
                    return i18n(levels[4])
                }
            }
        }
    }
}

function fahrenheit(temp) {
    if (temperatureUnit == 0) {
        return temp;
    } else {
        return Math.round((temp * 9 / 5) + 32);
    }
}
