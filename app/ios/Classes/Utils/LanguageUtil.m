//
//  LanguageUtil.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 03/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "LanguageUtil.h"


// define singlton using block
#ifndef DEFINE_SHARED_INSTANCE_USING_BLOCK

#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block)   \
static dispatch_once_t pred = 0;                \
__strong static id _sharedObject = nil;         \
dispatch_once(&pred, ^{                         \
_sharedObject = block();                    \
});                                             \
return _sharedObject;                           \

#endif


static LanguageUtil*  _languageUtil = nil;

NSString* LANG(NSString *key){
    NSString *path = nil;
    NSString *preferredLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSLog(@"preferredLanguage %@", preferredLanguage);
    if ([preferredLanguage containsString:@"en"]){
        path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
    }else if ([preferredLanguage containsString:@"fi"]){
        path = [[NSBundle mainBundle] pathForResource:@"fi" ofType:@"lproj"];
    }else{
        path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
    }
    NSLog(@"path %@", path);
    NSBundle* languageBundle = [NSBundle bundleWithPath:path];
    NSString* ret = [languageBundle localizedStringForKey:key value:@"" table:@"InfoPlist"];
    return ret;
}


@implementation LanguageUtil
+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self){
        if (_languageUtil == nil)
        {
            _languageUtil = [super allocWithZone:zone];
            return _languageUtil;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

+ (id)shared
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}
@end
