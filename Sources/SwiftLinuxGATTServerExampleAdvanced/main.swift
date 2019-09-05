do {
    
    //let x = TemperatureService(peripheral: TestPeripheral())
    //print("x characteristics = \(x.characteristics)")
    
    _ = try FermentPeripheral()
    while true { }
    
} catch let error {
    print("Error initializing peripheral: \(error)")
}



