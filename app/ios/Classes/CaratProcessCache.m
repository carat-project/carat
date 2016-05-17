//
//  CaratProcessCache.m
//  Carat
//
//  Keeps running processes and actions in memory for fast queries.
//  Expires and updates on application priority change.
//
//  Created by Jonatan C Hamberg on 17/05/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import "Globals.h"
#import "ActionObject.h"
#import "CoreDataManager.h"
#import "CaratProcessCache.h"

#ifdef USE_INTERNALS
#import "CaratInternals.h"
#endif

@implementation CaratProcessCache
static id instance = nil;

+ (void)initialize {
    if (self == [CaratProcessCache class]) {
        instance = [[self alloc] init];
    }
}

+ (id) instance {
    return instance;
}

- (void) checkUpdates {
    if([self shouldUpdate]){
        #ifdef USE_INTERNALS
        // Update process list first, it is needed by actions
        [self setProcessList:[CaratInternals getActive:NO]];
        [self setActionList:[[CoreDataManager instance] getActions:[self processList]]];
        [[Globals instance] setPriorityChanged:false];
        #endif
    }
}

- (BOOL) shouldUpdate {
    return ([[Globals instance] priorityChanged]
            || [self actionList] == nil
            || [self processList] == nil
            || [[self actionList] count] <= 0
            || [[self processList] count] <= 0);
}

- (void) getProcessNames:(void (^)(NSArray* result))callback {
    [self getProcessList:^(NSArray *result) {
        if(result != nil && [result count] > 0){
            callback([result valueForKey:@"lowercaseString"]);
        } else {
            callback(nil);
        }
    }];
}

- (void) getProcessList:(void (^)(NSArray* result))callback {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         [self checkUpdates];
         callback([self processList]);
    });
}

- (void) getActionList:(void (^)(NSArray *result))callback {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self checkUpdates];
        callback([self actionList]);
    });
}

@end
