# SwiftLinuxGATTServerExampleAdvanced

This is a simple example of how to create a Bluetooth 4.0 (BLE) peripheral (aka GATT server) on Linux (e.g. on a Raspberry Pi) using Swift and the [SwiftLinuxBLE](https://github.com/kevinbrewster/SwiftLinuxBLE) wrapper for the [PureSwift BluetoothLinux library](https://github.com/PureSwift/BluetoothLinux).

This example sets up a single BLE peripheral with a single service.

For a bare bones example without the SwiftLinuxBLE wrapper, take a look at [SwiftLinuxGATTServerExample](https://github.com/kevinbrewster/SwiftLinuxGATTServerExample)

# Installation for Raspberry Pi

1. Install Raspbian or Ubuntu on Raspberry Pi
2. [Install Swift 5 on Raspberry Pi](https://github.com/uraimo/buildSwiftOnARM) using the prebuilt binary
3. Checkout the SwiftLinuxGATTServerExampleAdvanced project
4. Navigate to project directory and run: `sudo /home/pi/usr/bin/swift run`

# Testing

* On mac: [BlueSee BLE Debugger](https://apps.apple.com/us/app/bluesee-ble-debugger/id1336679524?mt=12)
* On iPhone: [nRF Connect](https://apps.apple.com/us/app/nrf-connect/id1054362403)

*The nRF Connect app is nice because you can subscribe to notifications*

# Dependencies

* [PureSwift/BluetoothLinux](https://github.com/PureSwift/BluetoothLinux) - Pure Swift Linux Bluetooth Stack
* [PureSwift/GATT](https://github.com/PureSwift/GATT) - Bluetooth Generic Attribute Profile (GATT) for Swift
* [SwiftLinuxBLE](https://github.com/kevinbrewster/SwiftLinuxBLE) - Convenience wrapper for above

# Helpful Links

### BLE API Design

  * [GATT Profile Design](https://blog.kstechnologies.com/gatt-profile-design/)
 
### BLE Advertising

  * [Bluetooth advertising data basics](https://www.silabs.com/community/wireless/bluetooth/knowledge-base.entry.html/2017/02/10/bluetooth_advertisin-hGsf)
  * [PureSwift/GAPDataType](http://pureswift.github.io/Bluetooth/docs/Structs/GAPDataType.html)
  * [PureSwift/GAPDataEncoder](http://pureswift.github.io/Bluetooth/docs/Structs/GAPDataEncoder.html)
