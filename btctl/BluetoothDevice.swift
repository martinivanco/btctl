//
//  BluetoothDevice.swift
//  btctl
//
//  Created by Martin Ivančo on 25/06/2022.
//

import IOBluetooth

struct BluetoothDevice {
    let device: IOBluetoothDevice
    var name: String { device.name ?? "" }
    var address: String { device.addressString ?? "<no address>" }
    var paired: Bool { device.isPaired() }
    var connected: Bool { device.isConnected() }

    init(device: IOBluetoothDevice) {
        self.device = device
    }

    init?(address: String) {
        guard let d = IOBluetoothDevice(addressString: address) else { return nil }
        self.init(device: d)
    }
}
