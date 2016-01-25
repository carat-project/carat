//
//  DeviceInformation.h
//  Carat
//
//  Created by Jonatan C Hamberg on 25/01/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DeviceInformation : NSManagedObject
+ (NSString *) getMobileNetworkType;
@end
