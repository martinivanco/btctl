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
        
        let timeoutTask = getTimeoutTask(timeout)
        let connectTask = Task { () -> Bool in
            let result = device?.openConnection() == kIOReturnSuccess
            timeoutTask.cancel()
            return result
        }
        
        guard await timeoutTask.value else { return false }
        return await connectTask.value
    }
    
    static func pair(address: String, timeout: TimeInterval?) async -> Bool {
        let device = IOBluetoothDevice(addressString: address)
        let pair = IOBluetoothDevicePair(device: device)
        let delegate = PairDelegate()
        pair?.delegate = delegate

        guard let timeout = timeout else {
            let finished: Bool = await withCheckedContinuation { continuation in
                delegate.callback = { continuation.resume(returning: true) }
                if pair?.start() != kIOReturnSuccess { continuation.resume(returning: false) }
            }
            
            return finished && device?.isPaired() ?? false
        }

        let timeoutTask = getTimeoutTask(timeout)
        delegate.callback = { timeoutTask.cancel() }
        if pair?.start() != kIOReturnSuccess { return false }

        guard await timeoutTask.value else { return false }
        return device?.isPaired() ?? false
    }
    
    @objcMembers
    private class PairDelegate: NSObject, IOBluetoothDevicePairDelegate {
        public var callback: (() -> Void)?
        func devicePairingFinished(_ sender: Any!, error: IOReturn) { callback?() }
    }
    
    private static func getTimeoutTask(_ timeout: TimeInterval) -> Task<Bool, Never> {
        return Task { () -> Bool in
            do {
                try await Task.sleep(nanoseconds: UInt64(round(timeout * 1000000000)))
            } catch { return true }
            return false
        }
    }
}
