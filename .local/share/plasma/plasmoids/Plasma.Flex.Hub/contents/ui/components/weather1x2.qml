import QtQuick
import "../lib" as Lib
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

Item {
    property bool mouseAreaActive:  false


    Lib.Card {
        width: parent.width
        height: parent.height

        property bool mouseAreaActive:  parent.mouseAreaActive

        Lib.Item {
            id: item
            width: parent.width
            height: parent.height
            activeSub: true
            smallMode: false
            bubble: false
            isMaskIcon: false
            circleMask: false
            sizeIcon: Plasmoid.configuration.sizeGeneralIcons + Plasmoid.configuration.sizeMarginlIcons
            title: weatherData.currentTextWeather ? weatherData.currentTextWeather : "--"
            sub: activeWeather ? temperatureUnit === "Celsius" ? weatherData.currentWeather : FahrenheitFormatt.fahrenheit(weatherData.currentWeather) : 18
            itemIcon: activeWeather ? weatherData.currentIconWeather : "weather"
        }
    }
}
