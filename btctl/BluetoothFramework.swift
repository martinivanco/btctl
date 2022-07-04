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
            return [BluetoothDevice(device: d)]
        }.flatMap { $0 }
    }

    static var connectedDevices: [BluetoothDevice]? {
        guard let paired = pairedDevices else { return nil }
        return paired.filter { $0.connected }
    }

    @discardableResult
    static func connect(device: BluetoothDevice, timeout: TimeInterval?) async -> Bool {
        guard let timeout = timeout else {
            return device.device.openConnection() == kIOReturnSuccess
        }

        let timeoutTask = getTimeoutTask(timeout)
        let connectTask = Task { () -> Bool in
            let result = device.device.openConnection() == kIOReturnSuccess
            timeoutTask.cancel()
            return result
        }

        guard await timeoutTask.value else { return false }
        return await connectTask.value
    }

    @discardableResult
    static func pair(device: BluetoothDevice, timeout: TimeInterval?) async -> Bool {
        let pair = IOBluetoothDevicePair(device: device.device)
        let delegate = PairDelegate()
        pair?.delegate = delegate

        guard let timeout = timeout else {
            let finished: Bool = await withCheckedContinuation { continuation in
                delegate.callback = { continuation.resume(returning: true) }
                if pair?.start() != kIOReturnSuccess { continuation.resume(returning: false) }
            }

            return finished && device.paired
        }

        let timeoutTask = getTimeoutTask(timeout)
        delegate.callback = { timeoutTask.cancel() }
        if pair?.start() != kIOReturnSuccess { return false }

        guard await timeoutTask.value else { return false }
        return device.paired
    }

    @discardableResult
    static func unpair(device: BluetoothDevice) -> Bool {
        // There is no public API for unpairing, so we need this ugly hack with a custom selector
        let selector = Selector(("remove"))
        if device.device.responds(to: selector) { device.device.perform(selector) }
        return !device.paired
    }

    @objcMembers
    private class PairDelegate: NSObject, IOBluetoothDevicePairDelegate {
        public var callback: (() -> Void)?
        func devicePairingFinished(_ sender: Any!, error: IOReturn) { callback?() }
    }

    private static func getTimeoutTask(_ timeout: TimeInterval) -> Task<Bool, Never> {
        return Task { () -> Bool in
            do {
                try await Task.sleep(nanoseconds: UInt64(round(timeout * 1_000_000_000)))
            } catch { return true }
            return false
        }
    }
}
