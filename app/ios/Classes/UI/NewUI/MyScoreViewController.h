//
//  MyScoreViewController.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 06/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "DashboardViewController.h"
#import "BaseViewController.h"
#import "ProcessViewController.h"

@interface MyScoreViewController : BaseViewController <MBProgressHUDDelegate> {
    NSTimeInterval MAX_LIFE; // max battery life in seconds
    MBProgressHUD *HUD;
}
@property (retain, nonatomic) IBOutlet ScoreView *jScore;
@property (retain, nonatomic) IBOutlet UILabel *caratIDValue;
@property (retain, nonatomic) IBOutlet UILabel *osVersionValue;
@property (retain, nonatomic) IBOutlet UILabel *deviceModelValue;
@property (retain, nonatomic) IBOutlet UILabel *batteryLifeTimeValue;
@property (retain, nonatomic) IBOutlet MeasurementBar *memoryUsedBar;
@property (retain, nonatomic) IBOutlet MeasurementBar *memoryActiveBar;
@property (retain, nonatomic) IBOutlet MeasurementBar *cpuUsageBar;

- (IBAction)showJScoreExplanation:(id)sender;
- (IBAction)showProcessList:(id)sender;
- (IBAction)showMemUsedInfo:(id)sender;
- (IBAction)showMemActiveInfo:(id)sender;
- (IBAction)showCPUUsageInfo:(id)sender;

@end
