/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk

 Modified by Eric Horacek for Monospace Ltd. on 2/4/13
 
 Modified by Eemil Lagerspetz for Carat Project, University of Helsinki, 31.01.2018
 */

#include <sys/sysctl.h>
#import "UIDevice-Hardware.h"
#import "Carat-Swift.h"

@interface UIDevice (Hardward)

- (NSString *)modelNameForModelIdentifier:(NSString *)modelIdentifier;

@end

@implementation UIDevice (Hardware)

- (NSString *)getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);

    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);

    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];

    free(answer);
    return results;
}

- (NSString *)modelIdentifier
{
    return [self getSysInfoByName:"hw.machine"];
}

- (NSString *)modelName
{
    return [self modelNameForModelIdentifier:[self modelIdentifier]];
}

- (NSString *)modelNameForModelIdentifier:(NSString *)modelIdentifier
{
    
    // Simulator
    if ([modelIdentifier hasSuffix:@"86"] || [modelIdentifier isEqual:@"x86_64"])
    {
        BOOL smallerScreen = ([[UIScreen mainScreen] bounds].size.width < 768.0);
        return (smallerScreen ? @"Simulator" : @"Simulator");
    }
    
    return [IosDeviceNames.sharedInstance getDeviceNameWithPlatform:modelIdentifier];
}

- (UIDeviceFamily) deviceFamily
{
    NSString *modelIdentifier = [self modelIdentifier];
    if ([modelIdentifier hasPrefix:@"iPhone"]) return UIDeviceFamilyiPhone;
    if ([modelIdentifier hasPrefix:@"iPod"]) return UIDeviceFamilyiPod;
    if ([modelIdentifier hasPrefix:@"iPad"]) return UIDeviceFamilyiPad;
    if ([modelIdentifier hasPrefix:@"AppleTV"]) return UIDeviceFamilyAppleTV;
    return UIDeviceFamilyUnknown;
}

@end
