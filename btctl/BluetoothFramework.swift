//
//  BluetoothFramework.swift
//  btctl
//
//  Created by Martin Ivančo on 25/06/2022.
//

import IOBluetooth

struct BluetoothFramework {
    static var pairedDevices: [BluetoothDevice]? {
        guard let paired = IOBluetoothDevice.pairedDevices() else { return nil }
        return paired.map { device -> [BluetoothDevice] in
            guard let d = device as? IOBluetoothDevice else { return [] }
            return [BluetoothDevice(name: d.name ?? "", address: d.addressString ?? "<no address>", paired: true, connected: d.isConnected())]
        }.flatMap { $0 }
    }
    
    static var connectedDevices: [BluetoothDevice]? {
        guard let paired = pairedDevices else { return nil }
        return paired.filter { $0.connected }
    }
}
