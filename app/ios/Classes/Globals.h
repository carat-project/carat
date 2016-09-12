//
//  Globals.m
//  Carat
//
//  Created by Anand Padmanabha Iyer on 11/10/11.
//  Copyright (c) 2011 UC Berkeley. All rights reserved.
//

#ifndef Globals_h
#define Globals_h
@interface Globals : NSObject
{
    NSString * myUUID;
    NSUserDefaults * defaults; 
}

@property (nonatomic, retain) NSString * myUUID;
@property (nonatomic, retain) NSUserDefaults * defaults;
@property (nonatomic, assign) BOOL *priorityChanged;

+ (id) instance;
- (void) getUUIDFromNSUserDefaults;
- (NSString*) getUUID;
- (NSDate *) utcDateTime;
- (double) utcSecondsSinceEpoch;
- (void) userHasConsented;
- (BOOL) hasUserConsented;
- (void) setDistanceTraveled : (double) distance;
- (double) getDistanceTraveled;
- (void) setHideConsumptionLimit:(float) limit;
- (float) getHideConsumptionLimit;
- (NSArray *) getHiddenApps;
- (BOOL) hiddenChanges;
- (BOOL) isAppHidden : (NSString *) appName;
- (void) hideApp : (NSString *) appName;
- (void) showApp : (NSString *) appName;
- (void) acknowledgeHiddenChanges;
- (NSString *) getStringForKey:(NSString *)key;
- (void) saveString:(NSString *)string forKey:(NSString *)key;
- (BOOL) getBoolForKey:(NSString *)key;
- (void) saveBool:(BOOL)boolean forKey:(NSString *)key;
- (float) getFloatForKey:(NSString *)key;
- (void) saveFloat:(float)flt forKey:(NSString *)key;

@end
#endif