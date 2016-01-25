//
//  DeviceInformation.m
//  Carat
//
//  Created by Jonatan C Hamberg on 25/01/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import "DeviceInformation.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@implementation DeviceInformation
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
@end
