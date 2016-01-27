//
//  DeviceInformation.h
//  Carat
//
//  Created by Jonatan C Hamberg on 25/01/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import <CoreData/CoreData.h>
// #import <CoreBluetooth/CoreBluetooth.h>

@interface DeviceInformation : NSManagedObject
+ (NSString *) getMobileNetworkType;
+ (NSString *) getBatteryState;
+ (float) getCpuUsage;
+ (float) getScreenBrightness;
+ (NSString *) getNetworkStatus;
// + (bool) getBluetoothEnabled;
+ (bool) getLocationEnabled;
@end
