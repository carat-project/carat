//
//  DeviceInformation.h
//  Carat
//
//  Created by Jonatan C Hamberg on 25/01/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <mach/mach.h>

@interface DeviceInformation : NSManagedObject
+ (NSString *) getMobileNetworkType;
+ (NSString *) getBatteryState;
+ (float) getCpuUsage;
+ (unsigned long) getNumCpu;
+ (float) getScreenBrightness;
+ (NSString *) getNetworkStatus;
+ (bool) getLocationEnabled;
@end
