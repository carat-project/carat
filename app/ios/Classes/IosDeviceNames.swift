// IosDeviceNames.swift
// Gets the device name of the current device based on modelIdentifier
// from a periodically fetched list stored at carat-web / ios-devices.csv.
//
//  Created by Lagerspetz, Eemil H on 29/01/2018.
//  Copyright © 2018 University of Helsinki. All rights reserved.
//

import Foundation
import os.log

class IosDeviceNames: NSObject {
    

  //MARK: Properties

  static let url = "http://carat.cs.helsinki.fi/ios-devices.csv"

  var cache:DeviceCache
  // Need a separate data model class because the last fetch time also needs to come from disk.
  // [String: String]() // Empty dictionary to be filled
  
  var uiDev: UIDeviceHardware = UIDeviceHardware()
    
    //MARK: Initialization
    
    override init() {
        super.init()
    }
  
  // Fetch device list asynchronously to not block main thread.
  func fetchDeviceListAsync() {
    // download data from url
    // split it to lines and parse it using semicolons
    // fill cache
    
    DispatchQueue.global().async {
      self.fetchDeviceList()
    }
  }
  
  // Fetch and store device list on disk.
  private func fetchDeviceList() {
    let list = try? String(contentsOf: URL(string: IosDeviceNames.url)!)
    let lines = list!.split(separator: "\n")
    var deviceMap = [String: String]()
    for line in lines {
      let parts = line.split(separator: ";")
      if parts.count > 1 {
        deviceMap[String(parts[0])] = String(parts[1])
      }
    }
    cache = DeviceCache(deviceMap:deviceMap, lastUpdated:UInt64(NSDate().timeIntervalSince1970))
    saveCache()
  }
  
  func getDeviceName() -> String? {
  // If the list in cache is nil or empty, try to loadCache().
  //TODO: Check how long it has been since last list update,
  // And update the list if it has been too long.

    return cache.get(platform: uiDev.platform())
  }
  
    //MARK: Private methods
    
    private func saveCache() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(cache, toFile: DeviceCache.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Cached Devices successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save cached devices.", log: OSLog.default, type: .error)
        }
    }
    
    private func loadCache() -> DeviceCache?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: DeviceCache.ArchiveURL.path) as? DeviceCache
    }
  
}

