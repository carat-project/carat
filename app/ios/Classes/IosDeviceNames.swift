// IosDeviceNames.swift
// Gets the device name of the current device based on modelIdentifier
// from a periodically fetched list stored at carat-web / ios-devices.csv.

import Foundation
import os.log

class IosDeviceNames: NSObject, NSCoding {

  //MARK: Properties

  static let url = "http://carat.cs.helsinki.fi/ios-devices.csv"

  var cache:DeviceCache = nil
  // Need a separate data model class because the last fetch time also needs to come from disk.
  // [String: String]() // Empty dictionary to be filled
  
  var uiDev: UIDeviceHardware = UIDeviceHardware()
  
  //MARK: Archiving Paths
     
  static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
  static let ArchiveURL = DocumentsDirectory.appendingPathComponent("devicecache")
  
  //MARK: Types
  
  // Keys for persisted data.
  struct PropertyKey{
    static let lastUpdated = UInt64(0)
    static let devices = "devices"
  }
  
  init() {}

  // Fetch device list asynchronously to not block main thread.
  func fetchDeviceListAsync() {
    // download data from url
    // split it to lines and parse it using semicolons
    // fill cache
    
    DispatchQueue.global().async {
      fetchDeviceList()
    }
  }
  
  // Fetch and store device list on disk.
  private func fetchDeviceList() {
    let list = try? String(contentsOf: URL(string: "https://example.com/file.txt")!)
    let lines = list.split(separator: "\n")
    for line in lines {
      let parts = line.split(separator: ";")
      if parts.length > 1 {
        cache[parts[0]] = parts[1]
      }
    }
    saveCache()
  }
  
  func getDeviceName() -> String {
  // If the list in cache is nil or empty, try to loadCache().
  //TODO: Check how long it has been since last list update,
  // And update the list if it has been too long.

    return cache[uiDev.platform()]
  }
  
  

  //MARK: NSCoding

  func encode(with aCoder: NSCoder) {
    aCoder.encode(cache, forKey: PropertyKey.devices)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    guard let cache = aDecoder.decodeObject(forKey: PropertyKey.devices) as? String else {
      os_log("Unable to decode stored device list.", log: OSLog.default, type: .debug)
      return nil
    }
    
    self.init(cache:cache)
  }
  
  //MARK: Private methods
  
  

  private func saveCache() {
    let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(cache, toFile: IosDeviceNames.ArchiveURL.path)
    if isSuccessfulSave {
      os_log("Cached Devices successfully saved.", log: OSLog.default, type: .debug)
    } else {
      os_log("Failed to save cached devices.", log: OSLog.default, type: .error)
    }
  }



  private func loadCache() -> [String: String]?  {
    return NSKeyedUnarchiver.unarchiveObject(withFile: IosDeviceNames.ArchiveURL.path) as? [String: String]
  }


}

