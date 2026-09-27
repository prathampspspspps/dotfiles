/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *   Copyright 2012 Viranch Mehta <viranch.mehta@gmail.com>
 *   Copyright 2014-2016 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

function stringForBatteryState(batteryData) {
    if (batteryData.PluggedIn) {
        // BatteryControlModel.ChargeStateEnum: 0: NoCharge, 1: Charging, 2: Discharging, 3: FullyCharged
        switch(batteryData.ChargeState) {
            case 2: return i18n("Discharging");
            case 3: return i18n("Fully Charged");
            case 1: return i18n("Charging");
            default: return i18n("Not Charging");
        }
    } else {
        return i18nc("Battery is currently not present in the bay","Not present");
    }
}

function batteryDetails(batteryData, remainingTime) {
    var data = []

    // ChargeState 1: Charging, 2: Discharging
    if (remainingTime > 0 && batteryData.IsPowerSupply && (batteryData.ChargeState == 2 || batteryData.ChargeState == 1)) {
        var hours = Math.floor(remainingTime / 3600000);
        var minutes = Math.floor((remainingTime % 3600000) / 60000);
        var timeStr = (hours > 0 ? hours + "h " : "") + minutes + "m";
        data.push({label: (batteryData.ChargeState == 1 ? i18n("Time To Full:") : i18n("Time To Empty:")) })
        data.push({value: timeStr })
    }

    if (batteryData.IsPowerSupply && batteryData.Capacity != "" && typeof batteryData.Capacity == "number") {
        data.push({label: i18n("Capacity:") })
        data.push({value: i18nc("Placeholder is battery capacity", "%1%", batteryData.Capacity) })
    }

    // Non-powersupply batteries have a name consisting of the vendor and model already
    if (batteryData.IsPowerSupply) {
        if (batteryData.Vendor != "" && typeof batteryData.Vendor == "string") {
            data.push({label: i18n("Vendor:") })
            data.push({value: batteryData.Vendor })
        }

        if (batteryData.Product != "" && typeof batteryData.Product == "string") {
            data.push({label: i18n("Model:") })
            data.push({value: batteryData.Product })
        }
    }

    return data
}

function updateBrightness(rootItem, source) {
    // This is now handled by bindings in main.qml
}

function updateInhibitions(rootItem, source) {
    // This should be updated to use PowerDevil.InhibitionModel if needed
}
