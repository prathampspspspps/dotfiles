import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.Dialog {
    id: dialog
    width: 400
    height: Kirigami.Units.gridUnit*6

    property double selectedLatitude: 0
    property double selectedLongitude: 0

    property string cityPhoton

    signal ready

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        TextField {
            id: searchField
            placeholderText: i18n("Busca una ubicación...")
            Layout.fillWidth: true
            onTextChanged: {
                if (text.length > 2) {
                    searchLocations(text)
                } else {
                    resultsModel.clear()
                    dialog.height = Kirigami.Units.gridUnit*6
                }
            }
        }

        ListView {
            id: resultsView
            Layout.fillWidth: true
            // No usar fillHeight para que la lista no colapse
            height: Math.min(resultsModel.count * Kirigami.Units.gridUnit*2, Kirigami.Units.gridUnit*16)
            model: resultsModel
            clip: true
            delegate: ItemDelegate {
                width: parent.width
                height: Kirigami.Units.gridUnit*2
                text: display_name
                onClicked: {
                    dialog.selectedLatitude = parseFloat(lat)
                    dialog.selectedLongitude = parseFloat(lon)
                    dialog.cityPhoton = ubication
                    ready()
                    dialog.close()
                }
            }
        }
    }

    ListModel { id: resultsModel }

    function searchLocations(query) {
        var url = "https://photon.komoot.io/api/?q=" + encodeURIComponent(query)
        var xhr = new XMLHttpRequest()
        xhr.open("GET", url)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var data = JSON.parse(xhr.responseText)
                    resultsModel.clear()
                    for (var i = 0; i < data.features.length; i++) {
                        var feature = data.features[i]
                        var city = feature.properties.city || ""
                        var textUbication = feature.properties.city || feature.properties.county || feature.properties.state || feature.properties.name
                        console.log(textUbication)
                        var country = feature.properties.country || ""
                        resultsModel.append({
                            display_name: feature.properties.name + (city ? ", " + city : "") + (country ? ", " + country : ""),
                                            lat: feature.geometry.coordinates[1],
                                            lon: feature.geometry.coordinates[0],
                                            ubication: textUbication
                        })
                    }

                    // Ajusta altura del diálogo según cantidad de resultados
                    resultsView.height = Math.min(resultsModel.count * Kirigami.Units.gridUnit*2, Kirigami.Units.gridUnit*16)
                    dialog.height = resultsView.height + searchField.implicitHeight + 16
                } else {
                    console.log("Error al consultar la API:", xhr.status)
                }
            }
        }
        xhr.send()
    }
}


