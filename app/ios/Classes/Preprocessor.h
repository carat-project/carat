//
//  Preprocessor.h
//  Carat
//
//  Created by Jonatan C Hamberg on 29/02/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>

// App store identifier, can be checked from store uri
#define APP_STORE_ID 504771500
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

// Safest and most accurate way of checking iOS versions
// For future use: NSLog(@"%f", NSFoundationVersionNumber)

#ifndef NSFoundationVersionNumber_iOS_7_0
#define NSFoundationVersionNumber_iOS_7_0 1047.20
#endif

#ifndef NSFoundationVersionNumber_iOS_7_1
#define NSFoundationVersionNumber_iOS_7_1 1047.25
#endif

#ifndef NSFoundationVersionNumber_iOS_8_0
#define NSFoundationVersionNumber_iOS_8_0 1134.10
#endif

#ifndef NSFoundationVersionNumber_iOS_9_0
#define NSFoundationVersionNumber_iOS_9_0 1240.1
#endif