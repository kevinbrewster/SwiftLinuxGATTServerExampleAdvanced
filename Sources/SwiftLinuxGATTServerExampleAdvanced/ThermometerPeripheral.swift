import Foundation
import SwiftLinuxBLE
import Bluetooth
import GATT
import BluetoothLinux

public final class ThermometerPeripheral : SwiftLinuxBLE.Peripheral {
    
    public let peripheral: GATTPeripheral<HostController, L2CAPSocket>
    let name: GAPCompleteLocalName = "Thermometer"
    let iBeaconUUID = UUID(rawValue: "1DC24957-9DDA-46C4-88D4-3D3640CB3FDA")!
    
    public var services: [SwiftLinuxBLE.Service] = []
    public var characteristicsByHandle = [UInt16: CharacteristicType]()
    
    public init(hostController: HostController) throws {
        peripheral = try hostController.newPeripheral()
        
        try add(service: TemperatureService())
                
        // Start peripheral
        try peripheral.start()
        print("BLE Peripheral started")
                       
        try advertise(name: name, services: services, iBeaconUUID: iBeaconUUID)
        
        peripheral.didWrite = didWrite
    }
    
}
