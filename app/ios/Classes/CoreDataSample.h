//
//  CoreDataSample.h
//  Carat
//
//  Created by Anand Padmanabha Iyer on 3/22/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CaratProtocol.h"

@class CoreDataProcessInfo;

@interface CoreDataSample : NSManagedObject

@property (nonatomic, retain) NSNumber * batteryLevel;
@property (nonatomic, retain) NSString * batteryState;
@property (nonatomic, retain) NSNumber * memoryActive;
@property (nonatomic, retain) NSNumber * memoryFree;
@property (nonatomic, retain) NSNumber * memoryInactive;
@property (nonatomic, retain) NSNumber * memoryUser;
@property (nonatomic, retain) NSNumber * memoryWired;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSString * triggeredBy;
@property (nonatomic, retain) NSString * networkStatus;
@property (nonatomic, retain) NSNumber * distanceTraveled;
@property (nonatomic, retain) NSSet * processInfos;

@property (nonatomic, retain) NSNumber * screenBrightness;
@property (nonatomic, retain) NSData * cpuStatus;
@property (nonatomic, retain) NSData * networkDetails;
@property (nonatomic, retain) NSData * settings;
@property (nonatomic, retain) NSData * storageDetails;

@end

@interface CoreDataSample (CoreDataGeneratedAccessors)

- (void)addProcessInfosObject:(CoreDataProcessInfo *)value;
- (void)removeProcessInfosObject:(CoreDataProcessInfo *)value;
- (void)addProcessInfos:(NSSet *)values;
- (void)removeProcessInfos:(NSSet *)values;

@end
