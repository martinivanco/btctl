//
//  main.swift
//  btctl
//
//  Created by Martin Ivančo on 25/06/2022.
//

import ArgumentParser
import Foundation
import IOBluetooth

struct BluetoothControl: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Bluetooth control utility.",
        subcommands: [Paired.self])
    
    struct Paired: ParsableCommand {
        func run() {
            guard let paired = IOBluetoothDevice.pairedDevices() else {
                return print("Error: Couldn't fetch paired devices!")
            }
            
            print("Address              Name")
            for p in paired {
                guard let device = p as? IOBluetoothDevice else {
                    return print("Error: Couldn't fetch paired devices!")
                }
                
                let address = device.addressString ?? "<no address>     "
                let name = device.name ?? "<no name>"
                print("\(address)    \(name)")
            }
        }
    }
}

BluetoothControl.main()
