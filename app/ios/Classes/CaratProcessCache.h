//
//  CaratProcessCache.h
//  Carat
//
//  Created by Jonatan C Hamberg on 17/05/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CaratProcessCache : NSObject

@property (nonatomic, retain) NSArray *actionList;
@property (nonatomic, retain) NSArray *processList;

// Singleton
+ (id) instance;
- (id) init NS_UNAVAILABLE;

- (void) getActionList:(void (^)(NSArray *result))callback;
- (void) getProcessList:(void (^)(NSArray *result))callback;

@end
