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
#import <CoreTelephony/CTCarrier.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import <CoreLocation/CoreLocation.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <ifaddrs.h>
#import <net/if_dl.h>

static processor_cpu_load_info_t priorLoadInfo;

const unsigned long KB = 1024;
const unsigned long MB = KB * 1024;
const unsigned long GB = MB * 1024;

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

// Country code representation in ISO 3661-1 standard
// @see https://developer.apple.com/library/ios/documentation/NetworkingInternet/Reference/CTCarrier/index.html
+ (NSString *) getCountryCode {
    CTTelephonyNetworkInfo *networkInfo= [CTTelephonyNetworkInfo new];
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    if(!carrier || !carrier.isoCountryCode) return @"Unknown";
    return carrier.isoCountryCode;
}

// Battery state: Unknown, unplugged, charging, full
// @see https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIDevice_Class/
+ (NSString *) getBatteryState {
    UIDeviceBatteryState bs = [UIDevice currentDevice].batteryState;
    if(!bs) return @"Unknown";
    
    // UIDeviceBatteryStateFull indicates the device is plugged and 100% charged
    if(bs == UIDeviceBatteryStateCharging) return @"Charging";
    else if(bs == UIDeviceBatteryStateUnplugged) return @"Unplugged";
    else if(bs == UIDeviceBatteryStateFull) return @"Full";
    else return @"Unknown";
}

+ (unsigned long) getNumCpu {
    return [[NSProcessInfo processInfo] processorCount];
}

// Processor usage percentage as a value between 0 and 1
// @see http://www.opensource.apple.com/source/xnu/xnu-344/osfmk/kern/host.c?txt
+ (double) getCpuUsage {
    double used, total;
    unsigned numCpu;
    processor_cpu_load_info_t loadInfo;
    mach_msg_type_number_t infoCount;
    processor_flavor_t flavor = PROCESSOR_CPU_LOAD_INFO;
    
    // Request cpu load information from host name port
    kern_return_t status = host_processor_info(mach_host_self(), flavor, &numCpu, (processor_info_array_t *) &loadInfo, &infoCount);
    
    if(status == KERN_SUCCESS) {
        for(int cpuId = 0; cpuId < numCpu; cpuId++) {
            unsigned int *ticks = loadInfo[cpuId].cpu_ticks;
            if (!priorLoadInfo) {
                used = ticks[CPU_STATE_SYSTEM] + ticks[CPU_STATE_USER] + ticks[CPU_STATE_NICE];
                total = used + ticks[CPU_STATE_IDLE];
            } else {
                unsigned int *priorTicks = priorLoadInfo[cpuId].cpu_ticks;
                used = ((ticks[CPU_STATE_SYSTEM] - priorTicks[CPU_STATE_SYSTEM])
                        + (ticks[CPU_STATE_USER] - priorTicks[CPU_STATE_USER])
                        + (ticks[CPU_STATE_NICE] - priorTicks[CPU_STATE_NICE]));
                total = used + (ticks[CPU_STATE_IDLE] - priorTicks[CPU_STATE_IDLE]);
            }
        }
        // Deallocate previous loadinfo arrays
        if(priorLoadInfo){
            vm_size_t size = infoCount * sizeof(*priorLoadInfo);
            vm_deallocate(mach_task_self(), (vm_address_t)priorLoadInfo, size);
        }
        priorLoadInfo = loadInfo;
        
        // Round to integer precision
        return (used/total);
    } else {
        // ...
        return 0;
    }
}

// Screen brightness in range of 0-255
// @see https://developer.apple.com/library/prerelease/ios/documentation/UIKit/Reference/UIScreen_Class/#//apple_ref/occ/instp/UIScreen/brightness
+ (NSNumber *) getScreenBrightness {
    float brightness = [UIScreen mainScreen].brightness*255;
    return [NSNumber numberWithFloat:brightness];
}

// Battery level with accuracy of 1pp or 5pp
// @see https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIDevice_Class/#//apple_ref/occ/instp/UIDevice/batteryLevel
+ (NSNumber *) getBatteryLevel {
    float level = [UIDevice currentDevice].batteryLevel;
    return [NSNumber numberWithFloat:level];
}

// Check network availability synchronously
// @see https://developer.apple.com/library/prerelease/ios/documentation/SystemConfiguration/Reference/SCNetworkReachabilityRef/
+ (NSString *) getNetworkStatus {
    
    // Check connectivity to an address, in this case google dns
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, "8.8.8.8");
    SCNetworkReachabilityFlags flags;
    bool status = SCNetworkReachabilityGetFlags(reachability, &flags);
    CFRelease(reachability);
    if(!status) return @"Unknown";
    bool networkReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0) &&
                            ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    if (!networkReachable) return @"NotReachable";
    else if(flags & kSCNetworkReachabilityFlagsIsWWAN) return @"ReachableWWAN";
    else return @"ReachableWIFI";
}


// Location status, enabled/disabled
// @see https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/
+ (bool) getLocationEnabled {
    return [CLLocationManager locationServicesEnabled];
}

// Low power mode, available in iOS 9.0+
// @see https://developer.apple.com/library/ios/documentation/Performance/Conceptual/EnergyGuide-iOS/LowPowerMode.html
+ (bool) getPowersaverEnabled {
    
    [self isAppleWatchPaired];
    // Make sure the method is available
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(isLowPowerModeEnabled)]) {
        return [[NSProcessInfo processInfo] isLowPowerModeEnabled];
    }
    return false;
}

// Check if device is paired with an Apple watch
// Experimental: not sampled!
+ (bool) isAppleWatchPaired {
    if([WCSession isSupported]){
        WCSession *session = [WCSession defaultSession];
        // Might be needed
        // session.delegate = self;
        [session activateSession];
        return session.paired;
    }
    return false;
}

// Sysctl call to fetch real uptime which includes sleep
// @see http://opensource.apple.com/source/shell_cmds/shell_cmds-187/w/w.c
+ (time_t) getDeviceUptime {
    struct timeval bootTime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(bootTime);
    if(sysctl(mib, 2, &bootTime, &size, NULL, 0) != -1){
        return (time(0) - bootTime.tv_sec);
    }
    
    return 0;
}

// Calculate the difference between real and awake uptime
// @see https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSProcessInfo_Class/#//apple_ref/occ/instp/NSProcessInfo/systemUptime
+ (time_t) getDeviceSleepTime {
    time_t sleepTime = [self getDeviceUptime] - [[NSProcessInfo processInfo] systemUptime];
    return sleepTime > 0 ? sleepTime : 0;
}

// Data sent and received by wifi and mobile interfaces in megabytes
// @see https://developer.apple.com/library/ios/documentation/System/Conceptual/ManPages_iPhoneOS/man3/getifaddrs.3.html
+ (NetworkStatistics *) getNetworkStatistics {
    NetworkStatistics *stats = [NetworkStatistics new];
    struct ifaddrs *ifaddr;
    const struct ifaddrs *cursor;
    
    // Get list of network interfaces
    if(getifaddrs(&ifaddr) == 0){
        for(cursor = ifaddr; cursor != NULL; cursor = cursor->ifa_next){
            // Look for link layer interface
            if(cursor->ifa_addr->sa_family == AF_LINK){
                NSString *ifname = [NSString stringWithUTF8String:cursor->ifa_name];
                const struct if_data *data = (struct if_data *) cursor -> ifa_data;
                if(data == NULL) continue;
                
                // en is wifi
                if([ifname hasPrefix:@"en"]){
                    stats.wifiSent += (data->ifi_obytes)/MB;
                    stats.wifiReceived += (data->ifi_ibytes)/MB;
                }
                // pdp_ip is mobile
                else if([ifname hasPrefix:@"pdp_ip"]){
                    stats.mobileSent += (data->ifi_obytes)/MB;
                    stats.mobileReceived += (data->ifi_ibytes)/MB;
                }
            }
        }
        freeifaddrs(ifaddr);
    }
    return stats;
}

// Total and free filesystem space in megabytes
// @see https://developer.apple.com/library/prerelease/mac/documentation/Cocoa/Reference/Foundation/Classes/NSFileManager_Class/index.html
+ (StorageDetails *) getStorageDetails {
    StorageDetails *storage = [StorageDetails new];
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
        
    if (dictionary) {
        storage.total = (int)[[dictionary objectForKey: NSFileSystemSize] unsignedLongLongValue]/MB;
        storage.free = (int)[[dictionary objectForKey: NSFileSystemFreeSize] unsignedLongLongValue]/MB;
    }
    return storage;
}


// Virtual memory statistics
// @see http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/host_statistics.html
+ (MemoryInfo) getMemoryInformation {
    MemoryInfo memory = {0,0,0,0,0};
    kern_return_t success;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    vm_statistics_data_t vmStats;
    
    memory.user = [DeviceInformation getHardwareValue:HW_USERMEM];
    
    NSInteger pageSize = [DeviceInformation getHardwareValue:HW_PAGESIZE];
    success = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if(success == KERN_SUCCESS) {
        memory.wired = vmStats.wire_count * pageSize;
        memory.active = vmStats.active_count * pageSize;
        memory.inactive = vmStats.inactive_count * pageSize;
        memory.free = vmStats.free_count * pageSize;
    }
    
    return memory;
}

// Generic hardware information
// @see https://developer.apple.com/library/ios/documentation/System/Conceptual/ManPages_iPhoneOS/man3/sysctl.3.html
+ (NSInteger) getHardwareValue: (int) value;
{
    int result;
    size_t size = sizeof(result);
    int mib[2] = {CTL_HW, value};
    if(sysctl(mib, 2, &result, &size, NULL, 0) != 1) {
        return result;
    }
    return 0;
}

@end