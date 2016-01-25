//
//  DeviceInformation.m
//  Carat
//
//  Provides device and system information.
//
//  Created by Jonatan C Hamberg on 25/01/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import "DeviceInformation.h"
#import <sys/sysctl.h>
#import <sys/types.h>
#import <sys/param.h>
#import <sys/mount.h>
#import <mach/mach.h>
#import <mach/processor_info.h>
#import <mach/mach_host.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@implementation DeviceInformation

// Mobile network type, available in iOS 7.0+
// @see https://developer.apple.com/library/ios/releasenotes/General/iOS70APIDiffs/
+ (NSString *) getMobileNetworkType {
    CTTelephonyNetworkInfo *ti = [CTTelephonyNetworkInfo new];
    NSString *radioAccessTechnology = ti.currentRadioAccessTechnology;
    
    // String representations of different access technologies
    if(!radioAccessTechnology) return @"none";
    else if([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]) return @"1xrtt";
    else if([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]) return @"edge";
    else if([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]) return @"ehrpd";
    else if([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) return @"evdo_0";
    else if([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) return @"evdo_a";
    else if([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) return @"evdo_b";
    else if([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) return @"gprs";
    else if([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA]) return @"hsdpa";
    else if([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) return @"lte";
    else if([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA]) return @"umts"; //wcdma
    else return radioAccessTechnology;
}

// Battery state, available in iOS 2.0+
// Possible states: Unknown, unplugged, charging, full
// @see https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIDevice_Class/
+ (NSString *) getBatteryState {
    UIDeviceBatteryState bs = [UIDevice currentDevice].batteryState;
    if(!bs) return @"unknown";
    
    // UIDeviceBatteryStateFull indicates the device is plugged and 100% charged
    if(bs == UIDeviceBatteryStateCharging || bs == UIDeviceBatteryStateFull) return @"charging";
    else if(bs == UIDeviceBatteryStateUnplugged) return @"discharging";
    else return @"unknown";
}

// Experimental
+ (float) getCpuUsage {
    processor_cpu_load_info_t load;
    mach_msg_type_number_t msgCount;
    unsigned cpuCount;
    float system=0, user=0, idle=0;
    kern_return_t code = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &cpuCount, (processor_info_array_t *)&load, &msgCount);
    if(code == KERN_SUCCESS) {
        for(unsigned i=0; i<cpuCount; i++){
            system += load[i].cpu_ticks[CPU_STATE_SYSTEM];
            user += load[i].cpu_ticks[CPU_STATE_USER] + load[i].cpu_ticks[CPU_STATE_NICE];
            idle += load[i].cpu_ticks[CPU_STATE_IDLE];
        }
        float total = system + user + idle;
        float used = system + user;
        return used/total;
    } else return 0.0;
}
@end
