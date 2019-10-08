# SwiftLinuxGATTServerExampleAdvanced

This is a simple example of how to create a Bluetooth 4.0 (BLE) peripheral (aka GATT server) on Linux (e.g. on a Raspberry Pi) using Swift and the [PureSwift BluetoothLinux library](https://github.com/PureSwift/BluetoothLinux).

This includes a lightweight convenience wrapper for the PureSwift Bluetooth API, tentatively called "EZBLE", which defines a few protocols to quickly setup services and characteristics using properties and keypaths.

This example sets up a single BLE peripheral with a single service.

For a bare bones example without the EZBLE wrapper, take a look at [SwiftLinuxGATTServerExample](https://github.com/kevinbrewster/SwiftLinuxGATTServerExample)

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


# EZBLE Usage

Basically, you just need to create a `Peripheral` class and one or more `Service` classes. 

In the `Service` class you create properties for each characteristic you support and then you include the keyPath for each characteristic in the `characteristicKeyPaths` property. 

The EZBLE extensions will take care of the rest.

```
let uuid = BluetoothUUID(rawValue: "88d738cc-bdd0-485b-b197-b7186ff534e4")!

// Characteristics
var temperature = Characteristic(0.0, TemperatureService.temperatureUUID, [.read, .notify])
var tx = Characteristic(Data(), TemperatureService.txUUID, [.write])
var rx = Characteristic(Data(), TemperatureService.rxUUID, [.read, .notify])

var characteristicKeyPaths: [AnyKeyPath] {
    return [\TemperatureService.temperature, \TemperatureService.tx, \TemperatureService.rx]
}
```

# Helpful Links

### BLE API Design

  * [GATT Profile Design](https://blog.kstechnologies.com/gatt-profile-design/)
 
### BLE Advertising

  * [Bluetooth advertising data basics](https://www.silabs.com/community/wireless/bluetooth/knowledge-base.entry.html/2017/02/10/bluetooth_advertisin-hGsf)
  * [PureSwift/GAPDataType](http://pureswift.github.io/Bluetooth/docs/Structs/GAPDataType.html)
  * [PureSwift/GAPDataEncoder](http://pureswift.github.io/Bluetooth/docs/Structs/GAPDataEncoder.html)
