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
        subcommands: [Connected.self, Paired.self, Connect.self, Pair.self])
    
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
        static let configuration = CommandConfiguration(abstract: "Connect to a bluetooth device")

        @Argument(help: "The address of the device to connect")
        var address: String
        
        @Option(name: .shortAndLong, help: "Optional timeout for the call in seconds (system will timeout the call after certain time automatically - this is just to make it shorter)")
        var timeout: TimeInterval?

        func run() async {
            if await BluetoothFramework.connect(address: address, timeout: timeout) {
                print("Successfully connected \(address).")
            } else {
                print("Error: Couldn't connect \(address)!")
            }
        }
    }
    
    struct Pair: AsyncParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Pair with a bluetooth device")

        @Argument(help: "The address of the device to pair")
        var address: String
        
        @Option(name: .shortAndLong, help: "Optional timeout for the call in seconds (default is 10 seconds)")
        var timeout: TimeInterval?

        func run() async {
            if await BluetoothFramework.pair(address: address, timeout: timeout) {
                print("Successfully paired \(address).")
            } else {
                print("Error: Couldn't pair \(address)!")
            }
        }
    }
}
