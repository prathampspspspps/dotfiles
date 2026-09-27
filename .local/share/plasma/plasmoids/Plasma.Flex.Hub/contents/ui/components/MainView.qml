import QtQuick
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami as Kirigami
import "../js/fahrenheitFormatt.js" as FahrenheitFormatt

Item {

    property string formatTime: Plasmoid.configuration.UseFormat12hours ? "h:mm ap" : "h:mm"
    property var titles
    property var namesTitles

    property string titlesBeading: Plasmoid.configuration.selectedMetrics
    property string temperatureUnitUpdate: temperatureUnit
    property string windUnitUpdate: Plasmoid.configuration.windUnit

    property string formattTime: ""
    property var valuesMainView: []

    property var listMetrics: [
        { name: "Feels Like", nameText: "Feels Like", value: (temperatureUnit === "Celsius" ? weatherData.apparentTemperature : FahrenheitFormatt.fahrenheit(weatherData.apparentTemperature)) + "°"},
        { name: "UV Level", nameText: "UV", value: weatherData.currentUvIndexText },
        { name: "Humidity", nameText: "Humidity", value: weatherData.currentWeather + "%" },
        { name: "Max/Min", nameText: "Max/Min", value: (temperatureUnit === "Celsius" ? weatherData.dailyWeatherMax[0] : FahrenheitFormatt.fahrenheit(weatherData.dailyWeatherMax[0])) + `|` + (temperatureUnit === "Celsius" ? weatherData.dailyWeatherMin[0] : FahrenheitFormatt.fahrenheit(weatherData.dailyWeatherMin[0])) },
        { name: "Rain", nameText: "Rain", value: weatherData.dailyWeatherMax[0] + "%"},
        { name: "Wind Speed", nameText: "Wind", value: roundMax2Number((windUnitsUpdate(weatherData.windSpeed, Plasmoid.configuration.windUnit))) + " " + Plasmoid.configuration.windUnit},
        { name: "Sunrise / Sunset", nameText: "Sunrise / Sunset", value: sunriseOrSunset() },
        { name: "Cloud Cover", nameText: "Cloudiness", value: weatherData.cloudCover + "%"}
    ]

    function updateValues() {
        var newValues = [];
        var newNames = [];
        for (var i = 0; i < titles.length; i++) {
            for (var o = 0; o < listMetrics.length; o++){
                if (titles[i] === listMetrics[o].name) {
                    newNames.push(listMetrics[o].nameText);
                    newValues.push(listMetrics[o].value);
                }
            }
        }
        valuesMainView = newValues;
        namesTitles = newNames
    }

    function sunriseOrSunset() {
        if (weatherData.hourlyIsDay[0] === 1) {
            return Qt.formatDateTime(weatherData.hourlyTimes[weatherData.hourlyIsDay.indexOf(0)], formatTime);
        } else {
            return Qt.formatDateTime(weatherData.hourlyTimes[weatherData.hourlyIsDay.indexOf(1)], formatTime);
        }
    }

    function windUnitsUpdate(kmh, x) {
        const metresPerSecond = kmh * (5 / 18);
        const milesPerHour = kmh * 0.621371;

        return x === "m/s"
        ? metresPerSecond
        : x === "mph"
        ? milesPerHour
        : kmh;
    }

    function roundMax2Number(val) {
        var n = Number(val);
        if (!isFinite(n)) return val;
        return Math.round(n * 100) / 100;
    }

    function formatMax2(val) {
        var n = Number(val);
        if (!isFinite(n)) return "";
        var s = n.toFixed(2).replace(/\.?0+$/, "");
        return s;
    }

    Connections {
        target: weatherData
        function onDataChanged() {
            updateValues()
        }
    }

    onTitlesBeadingChanged: {
        titles = [].concat(Plasmoid.configuration.selectedMetrics)
        updateValues()
    }
    onWindUnitUpdateChanged: {
        titles = [].concat(Plasmoid.configuration.selectedMetrics)
        updateValues()
    }

    onTemperatureUnitUpdateChanged: {
        titles = [].concat(Plasmoid.configuration.selectedMetrics)
        updateValues()
    }

    Component.onCompleted: {
        titles = [].concat(Plasmoid.configuration.selectedMetrics)
        if (weatherData.updateWeather) {
            updateValues()
        }
    }

    Column {
        anchors {
            fill: parent
            margins: Kirigami.Units.smallSpacing*2
        }
        spacing: Kirigami.Units.smallSpacing

        // ── Temperatura actual + icono ──────────────────────────────────────
        Item {
            id: currentConditionsSection
            width: parent.width
            height: Kirigami.Units.gridUnit * 2
            Kirigami.Icon {
                id: weatherIcon
                width: parent.height
                height: width
                source: activeWeather ? weatherData.currentIconWeather : "weather"
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                id: currentTemp
                height: parent.height
                anchors.left: weatherIcon.right
                anchors.leftMargin: Kirigami.Units.smallSpacing
                text: activeWeather ? (temperatureUnit === "Celsius" ? weatherData.currentWeather : FahrenheitFormatt.fahrenheit(weatherData.currentWeather)) : 18
                color: Kirigami.Theme.textColor
                font.pixelSize: height
            }

            Text {
                id: tempUnit
                anchors {
                    left: currentTemp.right
                    leftMargin: Kirigami.Units.smallSpacing
                    bottom: weatherDesc.top
                }
                text: temperatureUnit === "Celsius" ? "°C" : "°F"
                color: Kirigami.Theme.textColor
                verticalAlignment: Text.AlignVCenter
                height: currentConditionsSection.height - weatherDesc.implicitHeight - Kirigami.Units.smallSpacing
                font.pixelSize: height
                opacity: 0.4
            }

            Kirigami.Heading {
                id: weatherDesc
                anchors {
                    left: currentTemp.right
                    leftMargin: Kirigami.Units.smallSpacing
                    bottom: parent.bottom
                }
                text: activeWeather ? weatherData.currentTextWeather ? weatherData.currentTextWeather : "--" : "--"
                //font.weight: Font.DemiBold
                opacity: 0.6
                level: 5
            }
        }

        // ── Métricas detalladas ─────────────────────────────────────────────
        Item {
            width: parent.width
            height: parent.height - currentConditionsSection.height - parent.spacing

            Flow {
                id: detailFlow
                anchors.fill: parent

                Repeater {
                    model: titles.length

                    Column {
                        width: detailFlow.width / 3
                        height: detailFlow.height / 2
                        spacing: Kirigami.Units.smallSpacing / 2

                        Kirigami.Heading {
                            width: parent.width
                            text: namesTitles[modelData] === "Sunrise / Sunset"
                            ? (weatherData.hourlyIsDay[0] === 1 ? i18n("Sunset") : i18n("Sunrise"))
                            : i18n(namesTitles[modelData])
                            horizontalAlignment: Text.AlignHCenter
                            font.weight: Font.DemiBold
                            level: 5
                        }

                        Kirigami.Heading {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: valuesMainView[modelData] ? valuesMainView[modelData] : "--"
                            opacity: 0.7
                            level: 5
                        }
                    }
                }
            }
        }
    }
}
