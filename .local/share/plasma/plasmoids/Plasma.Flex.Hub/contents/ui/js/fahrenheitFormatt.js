function fahrenheit(temp) {
    if (temperatureUnit == 0) {
        return temp;
    } else {
        return Math.round((temp * 9 / 5) + 32);
    }
}
