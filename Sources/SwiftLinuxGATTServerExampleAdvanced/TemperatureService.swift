//
//  ServiceController.swift
//  swift-bluetooth
//
//  Created by Kevin Brewster on 9/3/19.
//

import Foundation
import Bluetooth
import GATT
import BluetoothLinux
import SwiftLinuxBLE


extension TemperatureService {
    static let temperatureUUID = BluetoothUUID(rawValue: "88d738cc-bdd0-485b-b197-b7186ff534e4")!
    static let txUUID = BluetoothUUID(rawValue: "88d738cc-bdd0-485b-b197-b7186ff534e5")!
    static let rxUUID = BluetoothUUID(rawValue: "88d738cc-bdd0-485b-b197-b7186ff534e6")!
}

final class TemperatureService : SwiftLinuxBLE.Service {
    let uuid = BluetoothUUID(rawValue: "88d738cc-bdd0-485b-b197-b7186ff534e4")!
    
    
    // Characteristics
    @SwiftLinuxBLE.Characteristic(uuid: TemperatureService.temperatureUUID, [.read, .notify])
    var temperature = 7.0
       
    @SwiftLinuxBLE.Characteristic(uuid: TemperatureService.txUUID, [.write])
    var tx = Data()
    
    @SwiftLinuxBLE.Characteristic(uuid: TemperatureService.rxUUID, [.read, .notify])
    var rx = Data()
    
    
    
    init() {
        setupFakeTemperatureDataTimer()
    }
    
    var fakeTemperatureDataTimer: DispatchSourceTimer?
    func setupFakeTemperatureDataTimer() {
        // Every 2 seconds, increment the timer by 1
        let queue = DispatchQueue(label: "com.domain.app.timer")
        fakeTemperatureDataTimer = DispatchSource.makeTimerSource(queue: queue)
        fakeTemperatureDataTimer?.schedule(deadline: .now(), repeating: 2.0)
        fakeTemperatureDataTimer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.temperature = self.temperature + 1
            //NSLog("Changing temperature = \(self.temperature) (\(self._temperature.data))")
        }
        fakeTemperatureDataTimer?.resume()
    }
}




