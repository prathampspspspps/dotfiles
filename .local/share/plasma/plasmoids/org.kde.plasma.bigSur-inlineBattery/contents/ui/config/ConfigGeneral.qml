import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

import ".."
import "../lib"

ConfigPage {
	id: page
	showAppletVersion: true

	AppletConfig { id: config }

	ConfigSection {
		label: i18n("Mac Inline Battery")

		ConfigCheckBox {
			text: i18n("Enabled")
			configKey: 'showBatteryIcon'
		}

		RowLayout {
			ConfigSpinBox {
				before: i18n("Dimensions")
				suffix: 'px'
				configKey: 'iconWidth'
				value: config.iconWidth
				from: 0
				to: 100
			}
			Label {
				text: "x"
			}
			ConfigSpinBox {
				suffix: 'px'
				configKey: 'iconHeight'
				value: config.iconHeight
				from: 0
				to: 100
			}
		}

		ConfigColor {
			label: i18n("Normal")
			configKey: 'normalColor'
			defaultColor: config.defaultNormalColor
		}

		ConfigColor {
			label: i18n("Charging")
			configKey: 'chargingColor'
			defaultColor: config.defaultChargingColor
		}
		RowLayout {
			ConfigSpinBox {
				before: i18n("Low Battery")
				suffix: '%'
				configKey: 'lowBatteryPercent'
				from: 0
				to: 100
			}
			ConfigColor {
				label: ''
				configKey: 'lowBatteryColor'
				defaultColor: config.defaultLowBatteryColor
			}
		}
	}

	ButtonGroup { id: percentageAlign }
	ConfigSection {
		label: i18n("Percentage")

		ConfigCheckBox {
			id: percentageCheckbox
			text: i18n("Enabled")
			configKey: 'showPercentage'
		}

		Label {
			text: i18n("Position relative to battery icon")
		}

		RowLayout {
			RadioButton {
				text: i18n("Left")
				ButtonGroup.group: percentageAlign
				checked: Plasmoid.configuration.alignLeft
				enabled: Plasmoid.configuration.showPercentage
				onClicked: Plasmoid.configuration.alignLeft = true
			}
			RadioButton {
				text: i18n("Right")
				ButtonGroup.group: percentageAlign
				checked: !Plasmoid.configuration.alignLeft
				enabled: Plasmoid.configuration.showPercentage
				onClicked: Plasmoid.configuration.alignLeft = false
			}
		}
		ConfigSpinBox {
			before: i18n("Padding")
			suffix: 'px'
			enabled: Plasmoid.configuration.showPercentage
			configKey: 'padding'
			value: config.padding
			from: 0
			to: 100
		}
	}

	ConfigSection {
		label: i18n("Font")

		ConfigSpinBox {
			before: i18n("Font Size")
			suffix: 'px'
			configKey: 'fontSize'
			value: config.fontSize
			from: 0
			to: 100
		}
	}
}
