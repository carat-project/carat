//
//  MyScoreViewController.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 06/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DashboardViewController.h"
#import "BaseViewController.h"
#import "ProcessViewController.h"

@interface MyScoreViewController : BaseViewController
- (IBAction)leftSwipe;
- (IBAction)showJScoreExplanation:(id)sender;
- (IBAction)showProcessList:(id)sender;
- (IBAction)showMemUsedInfo:(id)sender;
- (IBAction)showMemActiveInfo:(id)sender;
- (IBAction)showCPUUsageInfo:(id)sender;

@end
