//
//  ActionObject.h
//  Carat
//
//  Created by Adam Oliner on 2/14/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ActionTypeKillApp,
    ActionTypeRestartApp,
    ActionTypeUpgradeOS,
    ActionTypeDimScreen,
    ActionTypeSpreadTheWord,
    ActionTypeCollectData,
    ActionTypeShowTopHogs,
    ActionTypeActiveBatteryLifeInfo,
    ActionTypeJScoreInfo,
    ActionTypeMemoryInfo,
    ActionTypeDetailInfo,
    ActionTypeGlobalStats,
} ActionType;

@interface ActionObject : NSObject {
    NSString *appName;
    NSString *actionText;
    NSInteger actionBenefit;
    NSInteger actionError;
    ActionType actionType;
}

@property (nonatomic, retain) NSString *appName;
@property (retain, nonatomic) NSString *actionText;
@property (nonatomic)         NSInteger actionBenefit;
@property (nonatomic)         NSInteger actionError;
@property (nonatomic)         ActionType actionType;

@end
