//
//  DeviceInformation.h
//  Carat
//
//  Created by Jonatan C Hamberg on 25/01/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <mach/mach.h>

typedef struct NetworkUsage {
    double wifiReceived;
    double wifiSent;
    double mobileReceived;
    double mobileSent;
} NetworkUsage;

@interface DeviceInformation : NSManagedObject

+ (NSString *) getMobileNetworkType;
+ (NSString *) getBatteryState;
+ (double) getCpuUsage;
+ (unsigned long) getNumCpu;
+ (NSNumber *) getScreenBrightness;
+ (NSString *) getNetworkStatus;
+ (bool) getLocationEnabled;
+ (NetworkUsage) getDataUsage;
+ (time_t) getDeviceUptime;
+ (time_t) getDeviceSleepTime;
@end
