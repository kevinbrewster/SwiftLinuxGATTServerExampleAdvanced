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


extension TemperatureService {
    static let temperatureUUID = BluetoothUUID(rawValue: "88d738cc-bdd0-485b-b197-b7186ff534e4")!
    static let txUUID = BluetoothUUID(rawValue: "88d738cc-bdd0-485b-b197-b7186ff534e5")!
    static let rxUUID = BluetoothUUID(rawValue: "88d738cc-bdd0-485b-b197-b7186ff534e6")!
}

final class TemperatureService : Service {
    let peripheral: Peripheral

    let uuid = BluetoothUUID(rawValue: "88d738cc-bdd0-485b-b197-b7186ff534e4")!
    
    // Characteristics
    var temperature = Characteristic(0.0, TemperatureService.temperatureUUID, [.read, .notify])
    var tx = Characteristic(Data(), TemperatureService.txUUID, [.write])
    var rx = Characteristic(Data(), TemperatureService.rxUUID, [.read, .notify])
    
    var characteristicKeyPaths: [AnyKeyPath] {
        return [\TemperatureService.temperature, \TemperatureService.tx, \TemperatureService.rx]
    }
    
    var fakeTemperatureDataTimer: DispatchSourceTimer?
    
    init(peripheral: Peripheral) {
        self.peripheral = peripheral
        
        tx.observe {
            // This is a completely useless example: When tx is written to, the rx value is set
            self.rx.value = $0
        }
        
        setupFakeTemperatureDataTimer()
    }
    
    func setupFakeTemperatureDataTimer() {
        // Every 2 seconds, increment the timer by 1
        let queue = DispatchQueue(label: "com.domain.app.timer")
        fakeTemperatureDataTimer = DispatchSource.makeTimerSource(queue: queue)
        fakeTemperatureDataTimer?.schedule(deadline: .now(), repeating: 2.0)
        fakeTemperatureDataTimer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.temperature.value = self.temperature.value + 1
        }
        fakeTemperatureDataTimer?.resume()
    }
}




