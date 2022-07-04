# btctl
A simple command line bluetooth control utility for macOS.

## Features
* Get list of connected devices
* Get list of paired devices
* Connect a bluetooth device
* Pair a bluetooth device
* Unpair a bluetooth device
* Re-pair a bluetooth device

## Motivation
I have two Macs at home - one personal, and one for work. But I only have one mouse and one keyboard. And they are the Apple ones, which are not able to pair to two devices at once. I could buy another set but that would further clutter up my desk, plus it's quite costly.

So I decided to make this simple command line utility which can do basic management of bluetooth devices, plus it contains a special re-pair command which can connect a bluetooth device, that has been previously paired to computer A, but then has been paired to computer B, and now it won't automatically connect to computer A.

I then created a simple [launch daemon](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html) that runs this re-pair command on both my mouse and my keyboard on computer startup automatically.

While there already is a similar utility called [blueutil](https://github.com/toy/blueutil), it doesn't seem to be developed anymore and it is written in Objective-C and was a bit unreliable when I tried it (especially timeouts were not working). There is also [BluetoothConnector](https://github.com/lapfelix/BluetoothConnector), which, however, as the name suggests, is only focused on connecting and disconnecting devices.

## Getting started
### Getting btctl
Currently, the only way to get btctl is to build it yourself using Xcode. See [Development](#development) for details.

### Using btctl
Run `btctl help` to display a list of available commands and their brief descriptions, then run `btctl help <command>` to get info on a specific command and how to use it.

## Development
### Dependencies
* Xcode 13+ with developer tools installed

### Getting sources
Run `git clone https://github.com/apple/swift-argument-parser.git`

### Building
Building should be straight forward, just open up the Xcode project and build. The built binary should then be located here:
`./DerivedData/btctl/Build/Products/Debug/btctl`

### Contributing
Currently not possible.

## Credits
Most of the code working with Apple's [IOBluetooth framework](https://developer.apple.com/documentation/iobluetooth) is heavily inspired by [blueutil](https://github.com/toy/blueutil), which has been an invaluable resource when creating this utility.
