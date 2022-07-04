//
//  BluetoothControl.swift
//  btctl
//
//  Created by Martin Ivančo on 25/06/2022.
//

import ArgumentParser
import Foundation

@main
struct BluetoothControl: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "btctl",
        abstract: "Bluetooth control utility",
        version: "0.1",
        subcommands: [
            Connected.self, Paired.self, Connect.self, Pair.self, Unpair.self, Repair.self,
        ])

    struct Connected: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Get list of connected devices")

        func run() {
            guard let devices = BluetoothFramework.connectedDevices else {
                return print("Error: Couldn't fetch connected devices!")
            }

            for d in devices { print("\(d.address)\t\(d.name)") }
        }
    }

    struct Paired: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Get list of paired devices")

        func run() {
            guard let devices = BluetoothFramework.pairedDevices else {
                return print("Error: Couldn't fetch paired devices!")
            }

            for d in devices { print("\(d.address)\t\(d.name)") }
        }
    }

    struct Connect: AsyncParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Connect a bluetooth device")

        @Argument(help: "The address of the device to connect")
        var address: String

        @Option(
            name: .shortAndLong,
            help:
                "Optional timeout for the call in seconds (system will timeout the call after certain time automatically - this is just to make it shorter)"
        )
        var timeout: TimeInterval?

        func run() async {
            guard let device = BluetoothDevice(address: address) else {
                return print("Error: Couldn't create device \(address)!")
            }

            if await BluetoothFramework.connect(device: device, timeout: timeout) {
                print("Successfully connected device \(address).")
            } else {
                print("Error: Couldn't connect device \(address)!")
            }
        }
    }

    struct Pair: AsyncParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Pair a bluetooth device")

        @Argument(help: "The address of the device to pair")
        var address: String

        @Option(name: .shortAndLong, help: "Optional timeout for the call in seconds")
        var timeout: TimeInterval?

        func run() async {
            guard let device = BluetoothDevice(address: address) else {
                return print("Error: Couldn't create device \(address)!")
            }

            if await BluetoothFramework.pair(device: device, timeout: timeout) {
                print("Successfully paired device \(address).")
            } else {
                print("Error: Couldn't pair device \(address)!")
            }
        }
    }

    struct Unpair: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Unpair a bluetooth device")

        @Argument(help: "The address of the device to unpair")
        var address: String

        func run() {
            guard let device = BluetoothDevice(address: address) else {
                return print("Error: Couldn't create device \(address)!")
            }

            if BluetoothFramework.unpair(device: device) {
                print("Successfully unpaired device \(address).")
            } else {
                print("Error: Couldn't unpair device \(address)!")
            }
        }
    }

    struct Repair: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Re-pair a bluetooth device",
            discussion:
                "This command is intended to connect a bluetooth device that can only be paired to one Mac but you want to use it on multiple ones. It first checks if the device is connected. If it's not connected, it goes in a loop, unpairing the device, trying to pair it and connect to it with a reasonable timeout, until the device is not connected."
        )

        @Argument(help: "The address of the device to re-pair")
        var address: String

        func run() async {
            guard let device = BluetoothDevice(address: address) else {
                return print("Error: Couldn't create device \(address)!")
            }

            while !device.connected {
                print("Unpairing device \(address)...")
                while device.paired { BluetoothFramework.unpair(device: device) }
                print("Trying to pair device \(address)...")
                if !(await BluetoothFramework.pair(device: device, timeout: 5)) { continue }
                print("Trying to connect device \(address)...")
                await BluetoothFramework.connect(device: device, timeout: 5)
            }

            print("Successfully connected device \(address).")
        }
    }
}
