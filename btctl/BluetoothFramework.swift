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
    
    static func connect(address: String, timeout: TimeInterval?) async -> Bool {
        let device = IOBluetoothDevice(addressString: address)
        guard let timeout = timeout else {
            return device?.openConnection() == kIOReturnSuccess
        }
        
        let timeoutTask = Task { () -> Bool in
            do {
                try await Task.sleep(nanoseconds: UInt64(round(timeout * 1000000000)))
            } catch { return true }
            return false
        }
        
        let connectTask = Task { () -> Bool in
            let result = device?.openConnection() == kIOReturnSuccess
            timeoutTask.cancel()
            return result
        }
        
        guard await timeoutTask.value else { return false }
        return await connectTask.value
    }
}
