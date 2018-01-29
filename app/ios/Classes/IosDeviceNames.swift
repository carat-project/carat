// IosDeviceNames.swift
// Gets the device name of the current device based on modelIdentifier
// from a periodically fetched list stored at carat-web / ios-devices.csv.

import Foundation

class IosDeviceNames: NSObject {

  let url = "http://carat.cs.helsinki.fi/ios-devices.csv"

  let cache = [String: String]() // Empty dictionary to be filled
  
  var uiDev: UIDeviceHardware = UIDeviceHardware()
  
  init() {}

  func fetchDeviceList() {
    // download data from url
    // split it to lines and parse it using semicolons
    // fill cache
    
    DispatchQueue.global().async {
      let list = try? String(contentsOf: URL(string: "https://example.com/file.txt")!)
      let lines = list.split(separator: "\n")
      for line in lines {
        let parts = line.split(separator: ";")
        if parts.length > 1 {
          cache[parts[0]] = parts[1]
        }
      }
    }
  }
  
  func getDeviceName() -> String {
    return cache[uiDev.platform()]
  }
}

