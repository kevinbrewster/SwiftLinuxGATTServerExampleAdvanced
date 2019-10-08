import Bluetooth
import GATT
import BluetoothLinux

if let hostController = HostController.default {
    do {
        _ = try ThermometerPeripheral(hostController: hostController)
        while true { }
    } catch let error {
        print("Error initializing peripheral: \(error)")
    }
       
} else {
    print("No bluetooth")
}




