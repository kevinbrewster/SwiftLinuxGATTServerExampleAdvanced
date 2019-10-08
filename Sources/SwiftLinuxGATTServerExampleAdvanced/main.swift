import Bluetooth
import GATT
import BluetoothLinux

if let hostController = HostController.default {
    do {
        
        //let x = TemperatureService(peripheral: TestPeripheral())
        //print("x characteristics = \(x.characteristics)")
       
        _ = try FermentPeripheral(hostController: hostController)
        while true { }
        
        
    } catch let error {
        print("Error initializing peripheral: \(error)")
    }
       
} else {
    print("No bluetooth")
}




