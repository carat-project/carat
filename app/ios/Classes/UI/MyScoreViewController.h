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
#import "NetworkBaseViewController.h"
#import "ProcessViewController.h"
#import "ProgressUpdateView.h"

@interface MyScoreViewController : NetworkBaseViewController {
    NSTimeInterval MAX_LIFE; // max battery life in seconds
}
@property (retain, nonatomic) IBOutlet ScoreView *jScore;
@property (retain, nonatomic) IBOutlet UILabel *caratIDValue;
@property (retain, nonatomic) IBOutlet UILabel *osVersionValue;
@property (retain, nonatomic) IBOutlet UILabel *deviceModelValue;
@property (retain, nonatomic) IBOutlet UILabel *batteryLifeTimeValue;
@property (retain, nonatomic) IBOutlet MeasurementBar *memoryUsedBar;
@property (retain, nonatomic) IBOutlet MeasurementBar *memoryActiveBar;
@property (retain, nonatomic) IBOutlet MeasurementBar *cpuUsageBar;
@property (retain, nonatomic) IBOutlet UILabel *lastUpdatedLabel;
@property (retain, nonatomic) IBOutlet ProgressUpdateView *progressUpdateView;

- (IBAction)showJScoreExplanation:(id)sender;
- (IBAction)showProcessList:(id)sender;
- (IBAction)showMemUsedInfo:(id)sender;
- (IBAction)showMemActiveInfo:(id)sender;
- (IBAction)showCPUUsageInfo:(id)sender;

@end
