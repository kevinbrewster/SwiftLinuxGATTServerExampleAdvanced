//
//  File.swift
//  swift-bluetooth
//
//  Created by Kevin Brewster on 9/4/19.
//

import Foundation
import Bluetooth
import GATT
import BluetoothLinux

// MARK: Peripheral

protocol Peripheral : class {
    var peripheral: GATTPeripheral<HostController, L2CAPSocket> { get }
    var services: [Service] { get set }
    func updateCharacteristicData(_ data: Data, forHandle handle: UInt16)
    var characteristicsByHandle: [UInt16: CharacteristicType] { get set }
}
extension Peripheral {
    func add(service: Service) {
        do {
            let characteristics = service.characteristics.map {
                GATT.Characteristic(uuid: $0.uuid, value: $0.data, permissions: $0.permissions, properties: $0.properties, descriptors: $0.descriptors)
            }
            let gattService = GATT.Service(uuid: service.uuid, primary: true, characteristics: characteristics)
            let _ = try peripheral.add(service: gattService)
            
            for var characteristic in service.characteristics {
                print("Characteristic \(characteristic.uuid) with permissions \(characteristic.permissions) and \(characteristic.descriptors.count) descriptors")
                if let handle = peripheral.characteristics(for: characteristic.uuid).last {
                    characteristic.handle = handle
                    characteristicsByHandle[handle] = characteristic
                }
            }
            services += [service]
            
        } catch let error {
            print("Error adding service: \(error)")
        }
    }
    func updateCharacteristicData(_ data: Data, forHandle handle: UInt16) {
        peripheral[characteristic: handle] = data
    }
    func didWrite(_ confirmation: GATTWriteConfirmation<Central>) {
        if var characteristic = characteristicsByHandle[confirmation.handle] {
            characteristic.data = confirmation.value
        }
    }
}

// MARK: Service

protocol Service : class {
    var peripheral: Peripheral { get }
    var uuid: BluetoothUUID { get }
    var characteristics: [CharacteristicType] { get }
    var characteristicKeyPaths: [AnyKeyPath] { get }
}

extension Service {
    var characteristics: [CharacteristicType] {
        return characteristicKeyPaths.compactMap {
            if let characteristic = self[keyPath: $0] as? CharacteristicType {
                characteristic.observeData {
                    print("characteristic.didWrite")
                    if let handle = characteristic.handle {
                        self.peripheral.updateCharacteristicData($0, forHandle: handle)
                    }
                }
                return characteristic
            } else {
                return nil
            }
        }
    }
}

// MARK: Characteristic

protocol CharacteristicType {
    var uuid: BluetoothUUID { get }
    var properties: BitMaskOptionSet<GATT.Characteristic.Property> { get }
    var permissions: BitMaskOptionSet<GATT.Permission> { get }
    var descriptors: [GATT.Characteristic.Descriptor] { get }
    var data: Data { get set }
    var handle: UInt16? { get set }
    func observeData(_ callback: @escaping (Data) -> Void)
}

class Characteristic<T: DataConvertible> : CharacteristicType {
    var value: T {
        didSet {
            for observer in observers {
                observer(value)
            }
            for observer in dataObservers {
                observer(value.data)
            }
        }
    }
    
    let uuid: BluetoothUUID
    var properties: BitMaskOptionSet<GATT.Characteristic.Property> = [.read, .write]
    var permissions: BitMaskOptionSet<GATT.Permission> = [.read, .write]
    let descriptors: [GATT.Characteristic.Descriptor]
    var handle: UInt16?
    
    private var observers: [(T) -> Void] = []
    private var dataObservers: [(Data) -> Void] = []
    
    init(_ value: T, _ uuid: BluetoothUUID, _ properties: BitMaskOptionSet<GATT.Characteristic.Property>, _ permissions: BitMaskOptionSet<GATT.Permission>? = nil, _ descriptors: [GATT.Characteristic.Descriptor]? = nil) {
        self.value = value
        self.uuid = uuid
        self.properties = properties
        self.permissions = permissions ?? properties.inferredPermissions
        // we need this special descriptor to enable notifications!
        self.descriptors = descriptors ?? (properties.contains(.notify) ? [GATTClientCharacteristicConfiguration().descriptor] : [])
    }
    var data: Data {
        get {
            return value.data
        }
        set {
            if let newValue = T(data: newValue) {
                value = newValue
            }
        }
    }
    func observe(_ callback: @escaping (T) -> Void) {
        observers += [callback]
    }
    func observeData(_ callback: @escaping (Data) -> Void) {
        dataObservers += [callback]
    }
}

extension BitMaskOptionSet where Element == GATT.Characteristic.Property {
    var inferredPermissions: BitMaskOptionSet<GATT.Permission> {
        let mapping: [GATT.Characteristic.Property: ATTAttributePermission] = [
            .read: .read,
            .notify: .read,
            .write: .write
        ]
        var permissions = BitMaskOptionSet<GATT.Permission>()
        for (property, permission) in mapping {
            if contains(property) {
                permissions.insert(permission)
            }
        }
        return permissions
    }
}


// MARK: DataConvertible

protocol DataConvertible {
    init?(data: Data)
    var data: Data { get }
}
extension DataConvertible where Self: ExpressibleByIntegerLiteral{
    init?(data: Data) {
        var value: Self = 0
        guard data.count == MemoryLayout.size(ofValue: value) else { return nil }
        _ = withUnsafeMutableBytes(of: &value, { data.copyBytes(to: $0)} )
        self = value
    }

    var data: Data {
        return withUnsafeBytes(of: self) { Data($0) }
    }
}
extension Int : DataConvertible { }
extension Float : DataConvertible { }
extension Double : DataConvertible { }
// add more types here ...



extension String: DataConvertible {
    init?(data: Data) {
        self.init(data: data, encoding: .utf8)
    }
    var data: Data {
        // Note: a conversion to UTF-8 cannot fail.
        return Data(self.utf8)
    }
}

extension Data : DataConvertible {
    init?(data: Data) {
        self.init(data)
    }
    var data: Data {
        return self
    }
}
