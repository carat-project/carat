//
//  DeviceInformation.h
//  Carat
//
//  Created by Jonatan C Hamberg on 25/01/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <mach/mach.h>
#import "CaratProtocol.h"

#ifndef NSFoundationVersionNumber_iOS_9_0
#define _iOS_9_0 NSFoundationVersionNumber_iOS_9_0
#endif


typedef struct MemoryInfo {
    double wired;
    double active;
    double inactive;
    double free;
    double user;
} MemoryInfo;

@interface DeviceInformation : NSManagedObject

+ (NSString *) getMobileNetworkType;
+ (NSString *) getCountryCode;
+ (NSString *) getBatteryState;
+ (NSNumber *) getBatteryLevel;
+ (double) getCpuUsage;
+ (unsigned long) getNumCpu;
+ (NSNumber *) getScreenBrightness;
+ (NSString *) getNetworkStatus;
+ (bool) getLocationEnabled;
+ (NetworkStatistics *) getNetworkStatistics;
+ (NSString *) getNetworkOperator;
+ (NSString *) getNetworkMcc;
+ (NSString *) getNetworkMnc;
+ (time_t) getDeviceUptime;
+ (time_t) getDeviceSleepTime;
+ (StorageDetails *) getStorageDetails;
+ (bool) getPowersaverEnabled;
+ (MemoryInfo) getMemoryInformation;
@end
