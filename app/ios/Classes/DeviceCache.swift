//
//  DeviceCache.swift
//  Carat
//
//  Created by Lagerspetz, Eemil H on 29/01/2018.
//  Copyright © 2018 University of Helsinki. All rights reserved.
//

import Foundation
import os.log

class DeviceCache: NSObject, NSCoding {
    
    //MARK: Properties
    
    var deviceMap:[String: String]
    var lastUpdated: UInt64
    
    //MARK: Types
    
    // Keys for persisted data.
    struct PropertyKey{
        static let lastUpdated = "lastupdated"
        static let devices = "devices"
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("devicecache")
    
    
    
    //MARK: Initialization
    
    init(deviceMap: [String: String], lastUpdated: UInt64) {
        self.deviceMap = deviceMap
        self.lastUpdated = lastUpdated
    }
    
    //MARK: Core functionality
    
    func get(platform:String) -> String? {
        return deviceMap[platform]
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(deviceMap, forKey: PropertyKey.devices)
        aCoder.encode(lastUpdated, forKey: PropertyKey.lastUpdated)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let deviceMap = aDecoder.decodeObject(forKey: PropertyKey.devices) as? [String: String] else {
            print("Unable to decode stored device list.")
            return nil
        }
        
        guard let lastUpdated = aDecoder.decodeObject(forKey: PropertyKey.lastUpdated) as? UInt64 else {
            print("Unable to decode stored device list.")
            return nil
        }
        
        self.init(deviceMap:deviceMap, lastUpdated:lastUpdated)
    }

}
