import QtQuick
import "../lib" as Lib
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import "../js/fahrenheitFormatt.js" as FahrenheitFormatt

Item {

    property var iconsHourlyForecast: []
    property var weatherHourlyForecast: []
    property var rainHourlyForecast: []
    property var timesDatesForecast
    property string unitTemp: temperatureUnit
    property bool hours12Format: true //Plasmoid.configuration.UseFormat12hours
    property string prefixHoursFormatt: hours12Format ? "h ap" : "h:mm"

    Lib.Card {
        width: parent.width
        height: parent.height - 4
        anchors.bottom: parent.bottom
       Row {
           anchors.fill: parent
           spacing: 4
           Repeater {
               model: 5
               delegate: Item {
                   width: (parent.width - (parent.spacing * 4))/5
                   height: parent.height
                   Column {
                       width: parent.width
                       height: hours.implicitHeight + icon.implicitHeight + temperature.implicitHeight + rain.implicitHeight + spacing*3
                       anchors.centerIn: parent
                       spacing: 4
                       Kirigami.Heading {
                           id: hours
                           width: parent.width
                           horizontalAlignment: Text.AlignHCenter
                           text: timesDatesForecast[modelData + 1] === undefined ? "--" : timesDatesForecast[modelData + 1]
                           level: 5
                       }
                       Kirigami.Icon {
                           id: icon
                           source: iconsHourlyForecast[modelData + 1]
                           width: 24
                           anchors.horizontalCenter: parent.horizontalCenter
                           height: width
                       }
                       Kirigami.Heading {
                           id: temperature
                           width: parent.width
                           horizontalAlignment: Text.AlignHCenter
                           text: weatherHourlyForecast[modelData + 1] === undefined ? "--" : weatherHourlyForecast[modelData + 1] + "°"
                           level: 5
                       }
                       Kirigami.Heading {
                           id: rain
                           width: parent.width
                           horizontalAlignment: Text.AlignHCenter
                           text: rainHourlyForecast[modelData + 1] === undefined ? "--" : "💧" +  rainHourlyForecast[modelData + 1]
                           level: 5
                       }

                   }
                   Rectangle {
                       anchors.right: parent.right
                       anchors.rightMargin: -parent.parent.spacing / 2  // Esto no es exacto, porque el spacing es entre items, y el rectángulo está dentro del item.
                       width: 1
                       height: parent.height * 0.4
                       anchors.verticalCenter: parent.verticalCenter
                       color: Kirigami.Theme.textColor
                       opacity: 0.2
                       visible: modelData < 4
                   }
               }
           }
       }
    }
    function updateDatesWeather(){
        var newArrayWeatherHourlyForecast = []
        timesDatesForecast = weatherData.hourlyTimes.map(function(iso) {
            var dateTime = new Date(iso)
            return Qt.formatDateTime(dateTime, prefixHoursFormatt)
        })
        iconsHourlyForecast = weatherData.iconsHourlyWeather
        for (var e = 0; e < weatherData.hourlyWeather.length; e++) {
            newArrayWeatherHourlyForecast.push(temperatureUnit === "Celsius" ? weatherData.hourlyWeather[e] : FahrenheitFormatt.fahrenheit(weatherData.hourlyWeather[e]))
        }
        weatherHourlyForecast = newArrayWeatherHourlyForecast
        rainHourlyForecast = weatherData.hourlyPrecipitationProbability
    }

    Connections {
        target: weatherData
        function onDataChanged() {
           updateDatesWeather()
        }
    }
    onUnitTempChanged: {
        updateDatesWeather()
    }

    Component.onCompleted: {
        var newArrayWeatherHourlyForecast = []
        updateDatesWeather()
    }
}
