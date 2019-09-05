import Foundation
import Bluetooth
import GATT
import BluetoothLinux


public final class FermentPeripheral : Peripheral {
    
    enum Error : Swift.Error {
        case bluetoothUnavailible
    }
    
    // MARK: - Properties
    let peripheral: GATTPeripheral<HostController, L2CAPSocket>
    let peripheralName: GAPCompleteLocalName = "Ferment"
    let beaconUUID = UUID(rawValue: "1DC24957-9DDA-46C4-88D4-3D3640CB3FDA")!
    
    var services: [Service] = []
    var characteristicsByHandle = [UInt16: CharacteristicType]()
    

    public init() throws {
        guard let hostController = HostController.default else {
            throw Error.bluetoothUnavailible
        }
        
        // Setup peripheral
        let address = try hostController.readDeviceAddress()
        let serverSocket = try L2CAPSocket.lowEnergyServer(controllerAddress: address, isRandom: false, securityLevel: .low)
        
        peripheral = GATTPeripheral<HostController, L2CAPSocket>(controller: hostController)
        peripheral.log = { print("Peripheral Log: \($0)") }
        peripheral.newConnection = {
           let socket = try serverSocket.waitForConnection()
           let central = Central(identifier: socket.address)
           print("BLE Peripheral: new connection")
           return (socket, central)
        }
        
        add(service: TemperatureService(peripheral: self))
                
        // Start peripheral
        try peripheral.start()
        print("BLE Peripheral started")
                
        // Setup iBeacon
        /*let rssi: Int8 = 30
        let beacon = AppleBeacon(uuid: beaconUUID, rssi: rssi)
        let flags: GAPFlags = [.lowEnergyGeneralDiscoverableMode, .notSupportedBREDR]
        try hostController.iBeacon(beacon, flags: flags, interval: .min, timeout: .default)
         */
        
        // Advertise services and peripheral name
        let serviceUUIDs = GAPIncompleteListOf128BitServiceClassUUIDs(uuids: services.map { UUID(bluetooth: $0.uuid) })
        let encoder = GAPDataEncoder()
        let data = try encoder.encodeAdvertisingData(peripheralName, serviceUUIDs)
        try hostController.setLowEnergyScanResponse(data, timeout: .default)
        print("BLE Advertising started")
 
        // Setup callbacks
        peripheral.didWrite = didWrite
    }
}
