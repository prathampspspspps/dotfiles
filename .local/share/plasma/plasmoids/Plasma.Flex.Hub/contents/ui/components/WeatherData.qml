import QtQuick
import QtQuick.Controls
import "../js/utilities.js" as Utils
import org.kde.plasma.plasmoid
import "../js/getAPIs.js" as GetApis

Item {
  id: root

  signal dataChanged

  property bool active: true //plasmoid.configuration.weatheCardActive
  property bool useCoordinatesIp: Plasmoid.configuration.ipLocation

  property bool loadingComplete: false
  property int latitudeC: parseFloat(Plasmoid.configuration.latitudeLocalized)
  property int longitudeC: parseFloat(Plasmoid.configuration.longitudeLocalized)
  property string longitudIP
  property string latitudeIP
  property int oldLongitud: Plasmoid.configuration.oldLongitude
  property int oldLatitude: Plasmoid.configuration.oldLatitude
  property string fullCoordinates: latitudeIP + longitudIP
  property string latitude: useCoordinatesIp ? latitudeIP : (latitudeC === "0") ? latitudeIP : latitudeC
  property string longitud: useCoordinatesIp ? longitudIP : (longitudeC === "0") ? longitudIP : longitudeC

  property string codeleng: Qt.locale().name

  property var observerCoordenates: latitudeC + longitudeC

  property bool updateWeather: false
  //property int indexTime

  property int currenWeatherCode
  property string currentIconWeather
  property int currentWeather
  property int currentHumidity
  property int cloudCover
  property int apparentTemperature
  property int windSpeed
  property string currentUvIndexText
  property string currentTextWeather
  property string currentShortTextWeather

  property var hourlyTimes: []
  property var hourlyWeather: []
  property var hourlyWeatherCodes: []
  property var hourlyPrecipitationProbability: []
  property var hourlyUvIndex: []
  property var hourlyIsDay: [] //1 is day, 0 is Night
  property var iconsHourlyWeather: []

  property var dailyTime: []
  property var dailyWeatherCode: []
  property var dailyWeatherMax: []
  property var dailyWeatherMin: []
  property var dailyPrecipitationProbabilityMax: []

  property var iconsDailyWather: []
  property bool isUpdate: true//false
  property int retrysCity: 0
  property bool exeGetApi: false
  property bool updateRecent: Plasmoid.configuration.updateRecent
  property string city
  property string cityUbication: Plasmoid.configuration.textUbication

  onLatitudeCChanged: checkCoords()
  onLongitudeCChanged: checkCoords()

  Component.onCompleted: {
    loadingComplete = true
    starComponent()
  }

  function retry(a) {
    retryFunction.function = a
    retryFunction.start()
  }
  function starComponent() {
    if (useCoordinatesIp) {
      getCoordinatesWithIp()
    } else {
      if (latitudeC !== 0 && longitudeC !== 0) {
        getWeatherApi()
        if (cityUbication !== null || cityUbication !== "") {
          city = cityUbication
        } else {
          getCityFuncion()
        }
      }
    }
  }



  function getCoordinatesWithIp() {
    GetApis.obtenerCoordenadas(function(result) {
      if (result) {
        longitudIP = result.lon
        latitudeIP = result.lat

        if (latitudeIP) {
          getCityFuncion();
          getWeatherApi()
        } else {
            retryCoordinate.start()
        }
      } else {
        retryCoordinate.start()
      }

    });
  }


  function getCityFuncion() {

    if (!latitude || !longitud || latitude === "0" || longitud === "0") {
        return;
    } else {
      GetApis.getNameCity(latitude, longitud, codeleng, function(result) {
        city = result;
        if (!result) {
          retrycity.start()
        }
        console.log(city)
      });
    }
  }

  function getWeatherApi() {
    GetApis.obtenerDatosClimaticos(latitude, longitud, function(result) {
      if (result) {

        hourlyTimes = []
        hourlyWeather = []
        hourlyIsDay = []
        hourlyWeatherCodes = []
        hourlyPrecipitationProbability = []
        hourlyUvIndex = []
        iconsHourlyWeather = []
        iconsDailyWather = []

        dailyTime = []
        dailyWeatherCode = []
        dailyWeatherMax = []
        dailyWeatherMin = []
        dailyPrecipitationProbabilityMax = []
        iconsDailyWather= []

        updateWeather = !(result.current.weather_code === null)

        currenWeatherCode = result.current.weather_code
        currentHumidity = result.current.relative_humidity_2m
        currentWeather = result.current.temperature_2m
        cloudCover = result.current.cloud_cover
        apparentTemperature = result.current.apparent_temperature
        windSpeed = result.current.wind_speed_10m
        currentTextWeather = Utils.textWeather(currenWeatherCode)
        currentShortTextWeather = Utils.shortTextWeather(currenWeatherCode)

        for (var a = 0; a < result.hourly.time.length; a++) {

          hourlyTimes.push(result.hourly.time[a]);
          hourlyWeather.push(result.hourly.temperature_2m[a]);
          hourlyIsDay.push(result.hourly.is_day[a])
          hourlyWeatherCodes.push(result.hourly.weather_code[a]);
          hourlyPrecipitationProbability.push(result.hourly.precipitation_probability[a].toString());
          hourlyUvIndex.push(Math.round(result.hourly.uv_index[a]));

          iconsHourlyWeather.push(Utils.asingicon(result.hourly.weather_code[a], "preciso", result.hourly.is_day[a]))

        }

        currentIconWeather = Utils.asingicon(result.current.weather_code, "preciso", hourlyIsDay[1])

        for (var b = 0; b < 6; b++) {

          dailyTime.push(result.daily.time[b]);
          console.log(result.daily.time[b], result.daily.time[0])
          dailyWeatherCode.push(result.daily.weather_code[b]);
          dailyWeatherMax.push(result.daily.temperature_2m_max[b]);
          dailyWeatherMin.push(result.daily.temperature_2m_min[b]);
          dailyPrecipitationProbabilityMax.push(result.daily.precipitation_probability_max[b]);
          iconsDailyWather.push(Utils.asingicon(result.daily.weather_code[b]))
        }
        currentUvIndexText =  Utils.uvIndexLevelAssignment(hourlyUvIndex[0])

        if (currentUvIndexText) {
          dataChanged()
          exeGetApi = false
        } else {
          retry.start()
        }
      } else {
        retry.start()
      }

    });
  }


  Timer {
    id: retryCoordinate
    interval: 5000
    running: false
    repeat: false
    onTriggered: {
      if (latitudeIP && longitudIP) {
        getCityFuncion();
        getWeatherApi()
      } else {
        getCoordinatesWithIp()
        }
      }

    }
  Timer {
    id: retrycity
    interval: 6000
    running: false
    repeat: false
    onTriggered: {
      if (city === "unk" && retrysCity < 5) {
        retrysCity = retrysCity + 1
        getCityFuncion();
      }
    }
  }

  Timer {
    id: retry
    interval: 1000
    running: false
    repeat: false
    onTriggered: {
      getWeatherApi();
  }
  }

  Timer {
    id: weatherupdate
    interval: 900000
    running: true
    repeat: true
    onTriggered: {
     if (updateWeather) {
       getWeatherApi();
    }
    }
  }

  onUseCoordinatesIpChanged: {
    if (active) {
      if (useCoordinatesIp) {
        city = null
        getCoordinatesWithIp()
      }
    }
  }

  Timer {
    id: tim
    running: false
    interval: 1300
    repeat: false
    onTriggered: {
      city = cityUbication
      getWeatherApi()
      updateRecent = false
    }
  }
  function checkCoords() {

    console.log("intento", updateRecent, cityUbication, latitudeC, longitudeC)
    if (active && !useCoordinatesIp && latitudeC !== "0" && longitudeC !== "0" && loadingComplete && updateRecent) {
      tim.start()
    }
  }

}

