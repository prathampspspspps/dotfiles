import QtQuick
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid
import org.kde.plasma.core 2.0 as PlasmaCore
import "components" as Components
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

PlasmoidItem {

    id: wrapper

    anchors.fill: parent

    Components.WeatherData {
        id: weatherData
    }

    signal reset

    //property bool dashWindowIsFocus: true
    property string currentTemp: weatherData.currentTemperature
    property string unitsTemperature: plasmoid.configuration.temperatureUnit
    //property string textUnitsTemper: ? "C" : "F"
    property string location: weatherData.city
    property string weather: weatherData.weatherShottext
    property string currentIcon: weatherData.iconWeatherCurrent
    property string currentMaxMin: weatherData.maxweatherCurrent + "°/" + weatherData.minweatherCurrent + "°"
    property var temps: weatherData.tempHours
    property var icons: weatherData.iconHours
    property alias forecastHours: hoursWeatherModel
    property alias forecastFullModel: forecastModel
    property bool isUpdate: false
    property date currentDateTime: new Date()

    readonly property int currentDayOfWeek: currentDateTime.getDay()

    ListModel {
        id: hoursWeatherModel
    }
    ListModel {
        id: forecastModel
    }

    function getTranslatedDayInitial(dayIndex) {
        var tempDate = new Date(currentDateTime);
        tempDate.setDate(tempDate.getDate() + dayIndex);
        return tempDate.toLocaleString(Qt.locale(), "dddd");
    }



    function hoursForModel(v) {
        const now = new Date();
        const hoursC = now.getHours(); // Horas (0-23)
        const minutes = now.getMinutes(); // Minutos (0-59)
        const currentTime =  minutes > 44 ? hoursC + 2 : hoursC + 1;

        var hoursForecast = [currentTime, currentTime + 1, currentTime + 2, currentTime + 3, currentTime + 4]
        return hoursForecast[v]
    }

    function hoursForecast() {

        hoursWeatherModel.clear()
        for (var i = 0; i < 5; i++) {
            hoursWeatherModel.append({
                icon: icons[i],
                temp: temps[i],
                hours: hoursForModel(i)
            });
        }
    }
    function hoursForecastUpdate() {
        for (var o = 0; o < hoursWeatherModel.count; o++) {
            hoursWeatherModel.set(o, { "icon": icons[o] });
            hoursWeatherModel.set(o, { "temp": String(parseFloat(temps[o])) });
            hoursWeatherModel.set(o, { "hours": hoursForModel(o) });
        }
    }

    function updateUnitsTempe() {

        let Maxs = {
            0: weatherData.oneMax,
            1: weatherData.twoMax,
            2: weatherData.threeMax,
            3: weatherData.fourMax,
            4: weatherData.fiveMax,
        }
        let Mins = {
            0: weatherData.oneMin,
            1: weatherData.twoMin,
            2: weatherData.threeMin,
            3: weatherData.fourMin,
            4: weatherData.fiveMin,
        }


        for (var z = 0; z < forecastModel.count; z++) {
            forecastModel.set(z, { "maxTemp": Maxs[z], "minTemp": Mins[z] })
        }
        for (var e = 0; e < hoursWeatherModel.count; e++) {
            var roles = hoursWeatherModel.get(e);
            console.log("Roles for index " + e + ":", JSON.stringify(roles));

            // Convierte temps[e] a cadena antes de asignarlo
            var gy = String(parseFloat(temps[e]));
            hoursWeatherModel.set(e, { "temp": gy });
        }


    }

    Timer {
        id: checkUpdateTimer
        interval: 5000 // 20 segundos
        repeat: true
        running: true
        onTriggered: {
            if (weatherData.lastUpdate !== "") {
                let now = new Date()
                let lastUpdateDate = new Date(weatherData.lastUpdate) // Crear objeto Date desde la cadena almacenada
                let diffMinutes = (now - lastUpdateDate) / 60000 // Convertir la diferencia a minutos
                if (diffMinutes > 17) {
                    forms()
                }
            }
        }
    }

    function updateForecastModel() {

        let icons = {
            0: weatherData.oneIcon,
            1: weatherData.twoIcon,
            2: weatherData.threeIcon,
            3: weatherData.fourIcon,
            4: weatherData.fiveIcon,
        }
        let Maxs = {
            0: weatherData.oneMax,
            1: weatherData.twoMax,
            2: weatherData.threeMax,
            3: weatherData.fourMax,
            4: weatherData.fiveMax,
        }
        let Mins = {
            0: weatherData.oneMin,
            1: weatherData.twoMin,
            2: weatherData.threeMin,
            3: weatherData.fourMin,
            4: weatherData.fiveMin,
        }
        forecastModel.clear();
        for (var i = 1; i < 4; i++) {
            var icon = icons[i]
            var maxTemp = Maxs[i]
            var minTemp = Mins[i]
            var date = getTranslatedDayInitial(i)

            forecastModel.append({
                date: date,
                icon: icon,
                maxTemp: maxTemp,
                minTemp: minTemp
            });


        }
    }

    function forms() {
        if (isUpdate) {
            currentDateTime = new Date()
            hoursForecastUpdate()
            updateForecastModel()
        } else {
            currentDateTime = new Date()
            hoursForecast()
            updateForecastModel()
            isUpdate = true
        }
    }

    onUnitsTemperatureChanged: {
        //hoursForecast()
        updateUnitsTempe()
    }

    Component.onCompleted: {
        weatherData.dataChanged.connect(() => {
            Qt.callLater(forms); // Asegura que la función se ejecute al final del ciclo de eventos
        });
    }

    preferredRepresentation: compactRepresentation
    compactRepresentation: compactRepresentation
    fullRepresentation: compactRepresentation



    Component {
        id: compactRepresentation
        CompactRepresentation {}
    }


}
