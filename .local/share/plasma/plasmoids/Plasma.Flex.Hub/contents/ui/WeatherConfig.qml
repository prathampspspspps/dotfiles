import QtQuick
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

Item {
    id: root

    signal metricsUpdated

    QtObject {
        id: units
        property var wind
        property var temperatureUnit
    }
    QtObject {
        id: coordinates
        property var latitude
        property var longitude
        property bool updateRecent
    }

    QtObject {
        id: ubication
        property string textUbication
    }

    FindCity {
        id: findCity
        onReady: {
            console.log("se esta ejecutando", findCity.cityPhoton)
            ubication.textUbication = findCity.cityPhoton
            coordinates.updateRecent = true
            console.log(coordinates.updateRecent, "gggggg", ubication.textUbication)
            coordinates.latitude = findCity.selectedLatitude
            coordinates.longitude = findCity.selectedLongitude
        }
    }

    property var windUnits: ["km/h","mph", "m/s"]
    property var temperatureUnits: ["Celsius","Fahrenheit"]

    property alias cfg_windUnit: units.wind
    property alias cfg_temperatureUnit: units.temperatureUnit
    property alias cfg_ipLocation: ipLocation.checked
    property alias cfg_longitudeLocalized: coordinates.longitude
    property alias cfg_latitudeLocalized: coordinates.latitude
    property alias cfg_selectedMetrics: metricsLayout.selectedMetricNames
    property alias cfg_textUbication: ubication.textUbication
    property alias cfg_updateRecent: coordinates.updateRecent

    QtObject {
        id: metricsLayout

        // modelo observable
        property alias allMetrics: allMetrics
        property int currentSelected: 0
        property int maxSelected: 6

        // esta lista se rellena con los nombres de seleccionados
        property var selectedMetricNames: []

        // inicializar desde cfg_selectedMetrics
        Component.onCompleted: {
            for (var i = 0; i < allMetrics.count; i++) {
                if (metricsLayout.selectedMetricNames.indexOf(allMetrics.get(i).name) !== -1) {
                    allMetrics.setProperty(i, "selected", true)
                    currentSelected++
                }
            }
        }
    }

    // Modelo reactivo
    ListModel {
        id: allMetrics
        ListElement { name: "Wind Speed"; selected: false }
        ListElement { name: "Feels Like"; selected: false }
        ListElement { name: "UV Level"; selected: false }
        ListElement { name: "Humidity"; selected: false }
        ListElement { name: "Rain"; selected: false }
        ListElement { name: "Max/Min"; selected: false }
        ListElement { name: "Sunrise / Sunset"; selected: false }
        ListElement { name: "Cloud Cover"; selected: false }
    }

    onMetricsUpdated: {
        metricsLayout.selectedMetricNames = []
        for (var i = 0; i < allMetrics.count; i++) {
            if (allMetrics.get(i).selected) {
                metricsLayout.selectedMetricNames.push(allMetrics.get(i).name)
            }
        }
        console.log("Selected metrics:", metricsLayout.selectedMetricNames)
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true // asegura que el contenido no se salga

        Kirigami.FormLayout {
            width: scrollView.width
            //spacing: Kirigami.Units.smallSpacing

            CheckBox {
                id: ipLocation
                Kirigami.FormData.label: i18n("Use Location of your ip")
                onCheckedChanged: {
                    if (checked) {
                        coordinates.latitude = 0
                        coordinates.longitude = 0
                    }
                }
            }

            Item { Kirigami.FormData.isSection: true }

            Button {
                text: i18n("Search Coordinates")
                enabled: !ipLocation.checked
                onClicked: findCity.open()
            }

            TextField {
                Kirigami.FormData.label: i18n("Latitude")
                text: coordinates.latitude === 0 ? "unknown" : coordinates.latitude
                enabled: false
                visible: !ipLocation.checked
            }

            TextField {
                Kirigami.FormData.label: i18n("Longitude")
                text: coordinates.longitude === 0 ? "unknown" : coordinates.longitude
                enabled: false
                visible: !ipLocation.checked
            }

            Item { Kirigami.FormData.isSection: true }

            ComboBox {
                id: windUnitBox
                Kirigami.FormData.label: i18n("Wind Unit:")
                model: windUnits
                onActivated: units.wind = currentValue
                Component.onCompleted: {
                    var idx = windUnits.indexOf(units.wind)
                    currentIndex = idx >= 0 ? idx : 0
                }
            }

            ComboBox {
                id: unitsBox
                Kirigami.FormData.label: i18n("Temperature Unit:")
                model: temperatureUnits
                onActivated: units.temperatureUnit = currentValue
                Component.onCompleted: {
                    var idx = temperatureUnits.indexOf(units.temperatureUnit)
                    currentIndex = idx >= 0 ? idx : 0
                }
            }

            Item { Kirigami.FormData.isSection: true }
            Item { Kirigami.FormData.isSection: true }

            Kirigami.Heading {
                width: parent.width
                font.weight: Font.DemiBold
                text: i18n("Weather Metrics")
                anchors.horizontalCenter: parent.horizontalCenter
                color: Kirigami.Theme.textColor
                level: 4
            }

            Repeater {
                model: allMetrics
                CheckBox {
                    checked: model.selected
                    Kirigami.FormData.label: i18n(model.name)
                    onClicked: {
                        if (checked) {
                            if (metricsLayout.currentSelected < metricsLayout.maxSelected) {
                                metricsLayout.currentSelected++
                                allMetrics.setProperty(index, "selected", true)
                            } else {
                                checked = false
                            }
                        } else {
                            metricsLayout.currentSelected--
                            allMetrics.setProperty(index, "selected", false)
                        }
                        metricsUpdated()
                    }
                }
            }
        }
    }

}
