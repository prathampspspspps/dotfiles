import QtQuick
import org.kde.plasma.plasmoid

QtObject {
	readonly property color defaultNormalColor: "#ffffff"
	readonly property color normalColor: Plasmoid.configuration.normalColor || defaultNormalColor

	readonly property color defaultChargingColor: '#1e1'
	readonly property color chargingColor: Plasmoid.configuration.chargingColor || defaultChargingColor

	readonly property color defaultLowBatteryColor: '#e33'
	readonly property color lowBatteryColor: Plasmoid.configuration.lowBatteryColor || defaultLowBatteryColor

	readonly property int defaultFontSize: 16
	readonly property int fontSize: Plasmoid.configuration.fontSize || defaultFontSize

	readonly property int defaultPadding: 8
	readonly property int padding: Plasmoid.configuration.padding || defaultPadding

	readonly property int defaultIconWidth: 26
	readonly property int iconWidth: Plasmoid.configuration.iconWidth || defaultIconWidth

	readonly property int defaultIconHeight: 15
	readonly property int iconHeight: Plasmoid.configuration.iconHeight || defaultIconHeight
}
