// IosDeviceNames.swift
// Gets the device name of the current device based on modelIdentifier
// from a periodically fetched list stored at carat-web / ios-devices.csv.
//
//  Created by Lagerspetz, Eemil H on 29/01/2018.
//  Copyright © 2018 University of Helsinki. All rights reserved.
//

import Foundation

class IosDeviceNames: NSObject {
    static let sharedInstance = IosDeviceNames()
    

  //MARK: Properties

  static let url = "http://carat.cs.helsinki.fi/ios-devices.csv"

  var cache:DeviceCache? = nil
  // Need a separate data model class because the last fetch time also needs to come from disk.
  // [String: String]() // Empty dictionary to be filled
  
  var uiDev: UIDeviceHardware = UIDeviceHardware()
    
    //MARK: Initialization
    
    override init() {
        super.init()
        self.cache = loadCache()
    }
  
  // Fetch device list asynchronously to not block main thread.
  func fetchDeviceListAsync() {
    // download data from url
    // split it to lines and parse it using semicolons
    // fill cache
    DispatchQueue.main.async {
      self.fetchDeviceList()
    }
  }
  
  // Fetch and store device list on disk.
  private func fetchDeviceList() {
    let list = try? String(contentsOf: URL(string: IosDeviceNames.url)!)
    print("Got list", list ?? "nil")
    if let gotList = list { // Compare with scala: val list = Some(Seq("a;c", "b;d")); list.map{gotList => ... }
        let lines = gotList.split(separator: "\n")
        print("Got lines ",lines)
        var deviceMap = [String: String]()
        for line in lines {
          let parts = line.split(separator: ";")
          if parts.count > 1 {
            print("Line ", parts[0], " -> ", parts[1])
            deviceMap[String(parts[0])] = String(parts[1])
          }
        }
        cache = DeviceCache(deviceMap:deviceMap, lastUpdated:UInt64(NSDate().timeIntervalSince1970))
        saveCache()
    }
  }
  
  func getDeviceName() -> String {
  // If the list in cache is nil or empty, try to loadCache().
  //TODO: Check how long it has been since last list update,
  // And update the list if it has been too long.
    if cache == nil {
        print("Cache nil, fetching device list over the network.")
        fetchDeviceList()
    }
    print("Platform is ", uiDev.platform())
    let deviceName = cache?.get(platform: uiDev.platform())
    if deviceName != nil{
        return deviceName!
    } else {
        return uiDev.platform()
    }
  }
  
    //MARK: Private methods
    
    private func saveCache() {
        if cache != nil {
        // What is the right way here? Cache may be null, in which case save should not be called at all...
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(cache!, toFile: DeviceCache.ArchiveURL.path)
        if isSuccessfulSave {
            print("Cached Devices successfully saved.")
        } else {
            print("Failed to save cached devices.")
        }
        }
    }
    
    private func loadCache() -> DeviceCache?  {
        let c = NSKeyedUnarchiver.unarchiveObject(withFile: DeviceCache.ArchiveURL.path) as? DeviceCache
        print("Loaded cache from disk: ", c ?? "nil")
        return c
    }
  
}

