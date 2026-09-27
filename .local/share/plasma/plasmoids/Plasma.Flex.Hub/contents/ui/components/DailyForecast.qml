import QtQuick
import "../lib" as Lib
import org.kde.kirigami as Kirigami
import "../js/fahrenheitFormatt.js" as FahrenheitFormatt

Item {

    property var iconsDaysForecast: []
    property var weatherMaxDaysForecast: []
    property var weatherMinDaysForecast: []
    property var rainDaysForecast: []
    property var timesDaysForecast: []

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
                        height: days.implicitHeight + icon.implicitHeight + max.implicitHeight + min.implicitHeight + rain.implicitHeight + spacing*3
                        anchors.centerIn: parent
                        spacing: 4
                        Kirigami.Heading {
                            id: days
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: timesDaysForecast[modelData +  1] === undefined ? "--" : timesDaysForecast[modelData +  1]
                            level: 5
                        }
                        Kirigami.Icon {
                            id: icon
                            source: iconsDaysForecast[modelData +  1]
                            width: 24
                            anchors.horizontalCenter: parent.horizontalCenter
                            height: width
                        }

                        Item {
                            width: parent.width
                            height: max.implicitHeight + min.implicitHeight + spacing

                            property int spacing: 2

                            Kirigami.Heading {
                                id: max
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                text: weatherMaxDaysForecast[modelData +  1] === undefined ? "--" : weatherMaxDaysForecast[modelData +  1] + "°"
                                level: 5
                            }
                            Kirigami.Heading {
                                id: min
                                width: parent.width
                                anchors.top: max.bottom
                                anchors.topMargin: 2
                                opacity: 0.6
                                horizontalAlignment: Text.AlignHCenter
                                text: weatherMinDaysForecast[modelData +  1] === undefined ? "--" : weatherMinDaysForecast[modelData +  1] + "°"
                                level: 5
                            }
                        }

                        Kirigami.Heading {
                            id: rain
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: rainDaysForecast[modelData +  1] === undefined ? "--" : "💧" +  rainDaysForecast[modelData +  1]
                            level: 5
                        }

                    }
                    Rectangle {
                        anchors.right: parent.right
                        anchors.rightMargin: -parent.parent.spacing / 2
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


    Connections {
        target: weatherData
        function onDataChanged() {

            var newArrayMaxDaysForecast = []
            var newArrayMinDaysForecast = []

            timesDaysForecast = weatherData.dailyTime.map(function(iso) {
                var dateDayTime = new Date((iso + "T00:00:00"))
                console.log(dateDayTime, iso)
                return dateDayTime.toLocaleString(Qt.locale(), "ddd");
            })

            iconsDaysForecast = weatherData.iconsDailyWather

            for (var e = 0; e < weatherData.dailyWeatherMax.length; e++) {
                newArrayMaxDaysForecast.push(temperatureUnit === "Celsius" ? weatherData.dailyWeatherMax[e] : FahrenheitFormatt.fahrenheit(weatherData.dailyWeatherMax[e]))

                newArrayMinDaysForecast.push(temperatureUnit === "Celsius" ? weatherData.dailyWeatherMin[e] : FahrenheitFormatt.fahrenheit(weatherData.dailyWeatherMin[e]))
            }
            weatherMaxDaysForecast = newArrayMaxDaysForecast
            weatherMinDaysForecast = newArrayMinDaysForecast

            rainDaysForecast = weatherData.dailyPrecipitationProbabilityMax
        }
    }


    Component.onCompleted: {
        var newArrayMaxDaysForecast = []
        var newArrayMinDaysForecast = []

        timesDaysForecast = weatherData.dailyTime.map(function(iso) {
            var dateDayTime = new Date((iso + "T00:00:00"))
            console.log(dateDayTime, iso)
            return dateDayTime.toLocaleString(Qt.locale(), "ddd");
        })

        iconsDaysForecast = weatherData.iconsDailyWather

        for (var e = 0; e < weatherData.dailyWeatherMax.length; e++) {
            newArrayMaxDaysForecast.push(temperatureUnit === "Celsius" ? weatherData.dailyWeatherMax[e] : FahrenheitFormatt.fahrenheit(weatherData.dailyWeatherMax[e]))

            newArrayMinDaysForecast.push(temperatureUnit === "Celsius" ? weatherData.dailyWeatherMin[e] : FahrenheitFormatt.fahrenheit(weatherData.dailyWeatherMin[e]))
        }
        weatherMaxDaysForecast = newArrayMaxDaysForecast
        weatherMinDaysForecast = newArrayMinDaysForecast

        rainDaysForecast = weatherData.dailyPrecipitationProbabilityMax
    }
}
