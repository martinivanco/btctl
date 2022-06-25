//
//  BluetoothControl.swift
//  btctl
//
//  Created by Martin Ivančo on 25/06/2022.
//

import ArgumentParser

struct BluetoothControl: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Bluetooth control utility.",
        subcommands: [Connected.self, Paired.self])
    
    struct Connected: ParsableCommand {
        func run() {
            guard let devices = BluetoothFramework.connectedDevices else {
                return print("Error: Couldn't fetch connected devices!")
            }

            for d in devices { print("\(d.address)\t\(d.name)") }
        }
    }
    
    struct Paired: ParsableCommand {
        func run() {
            guard let devices = BluetoothFramework.pairedDevices else {
                return print("Error: Couldn't fetch paired devices!")
            }

            for d in devices { print("\(d.address)\t\(d.name)") }
        }
    }
}
