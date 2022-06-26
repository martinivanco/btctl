//
//  BluetoothFramework.swift
//  btctl
//
//  Created by Martin Ivančo on 25/06/2022.
//

import Dispatch
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
    
    static func connect(address: String, timeout: TimeInterval?) -> Bool {
        let device = IOBluetoothDevice(addressString: address)
        guard let t = timeout else {
            return device?.openConnection() == kIOReturnSuccess
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        var result = false

        DispatchQueue.main.async {
            result = device?.openConnection() == kIOReturnSuccess
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: .now() + t)
        return result
    }
}
