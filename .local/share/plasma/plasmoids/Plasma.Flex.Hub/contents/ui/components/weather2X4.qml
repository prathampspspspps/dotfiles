import QtQuick
import "../lib" as Lib
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami as Kirigami
import "../js/fahrenheitFormatt.js" as FahrenheitFormatt

Item {
    property string temperatureUnit: "Celsius"
    property var sections: [mainWeatherView, hourlyForecastView, dailyForecastView]
    property int currentIndex: 0
    property string temps
    property bool mouseAreaActive:  false

    Connections {
        target: weatherData
        function onDataChanged() {
            temps = (temperatureUnit === "Celsius"
            ? weatherData.dailyWeatherMax[0]
            : FahrenheitFormatt.fahrenheit(weatherData.dailyWeatherMax[0])) +
            "° | " +
            (temperatureUnit === "Celsius"
            ? weatherData.dailyWeatherMin[0]
            : FahrenheitFormatt.fahrenheit(weatherData.dailyWeatherMin[0])) + "°"
        }
    }

    Lib.Card {
        anchors.fill: parent

        // ── Header: ciudad + navegación por puntos ───────────────────────
        Item {
            id: header
            height: Kirigami.Units.gridUnit
            //width: 30
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: Kirigami.Units.smallSpacing
                leftMargin: Kirigami.Units.smallSpacing*3
                rightMargin: Kirigami.Units.smallSpacing*3
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: activeWeather ? weatherData.city ? weatherData.city : i18n("UNK") : i18n("City")
                color: Kirigami.Theme.textColor
                opacity: 0.45
                font.capitalization: Font.AllUppercase
                font.pixelSize: 10
                font.letterSpacing: 1.4
                font.weight: Font.Medium
            }

            Row {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                spacing: 5

                Repeater {
                    model: 3
                    Rectangle {
                        width: modelData === currentIndex ? 14 : 5
                        height: 5
                        radius: 3
                        color: Kirigami.Theme.textColor
                        opacity: modelData === currentIndex ? 0.7 : 0.2
                        Behavior on width  { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                        MouseArea {
                            enabled: mouseAreaActive
                            anchors.fill: parent
                            onClicked: currentIndex = modelData
                        }
                    }
                }
            }
        }

        // ── Vista activa ──────────────────────────────────────────────────
        Loader {
            id: sectionLoader
            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: Kirigami.Units.smallSpacing
                leftMargin: Kirigami.Units.smallSpacing
                rightMargin: Kirigami.Units.smallSpacing
                bottomMargin: Kirigami.Units.smallSpacing
            }
            sourceComponent: sections[currentIndex]

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                enabled: mouseAreaActive
                onWheel: function(wheel) {
                    if (wheelDebounce.running) return
                        if (wheel.angleDelta.y < 0) {
                            currentIndex = (currentIndex + 1) % sections.length
                        } else {
                            currentIndex = (currentIndex - 1 + sections.length) % sections.length
                        }
                        wheelDebounce.start()
                }
            }

            Timer {
                id: wheelDebounce
                interval: 600
                repeat: false
            }
        }

        Component { id: mainWeatherView;    MainView {} }
        Component { id: hourlyForecastView; HourlyForecast {} }
        Component { id: dailyForecastView;  DailyForecast {} }
    }
}
