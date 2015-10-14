//
//  DashBoardViewController.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 29/09/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "BaseViewController.h"
#import "ScoreView.h"
#import "ShareView.h"
#import "DashboardNavigationButton.h"

#import "TutorialViewController.h"
#import "BugsViewController.h"
#import "HogsViewController.h"
#import "StatisticsViewController.h"
#import "ActionsViewController.h"
#import "MyScoreViewController.h"
#import "MoreViewController.h"

@interface DashBoardViewController : BaseViewController
@property (retain, nonatomic) IBOutlet ScoreView *scoreView;
@property (retain, nonatomic) IBOutlet UILabel *updateLabel;
@property (retain, nonatomic) IBOutlet ShareView *shareView;
@property (retain, nonatomic) IBOutlet LocalizedLabel *batteryLastLabel;
@property (retain, nonatomic) IBOutlet DashboardNavigationButton *bugsBtn;
@property (retain, nonatomic) IBOutlet DashboardNavigationButton *hogsBtn;
@property (retain, nonatomic) IBOutlet DashboardNavigationButton *statisticsBtn;
@property (retain, nonatomic) IBOutlet DashboardNavigationButton *actionsBtn;

- (IBAction)shareButtonTapped:(id)sender;
- (IBAction)showScoreInfo:(id)sender;
- (IBAction)showMyDevice:(id)sender;
- (IBAction)showBugs:(id)sender;
- (IBAction)showHogs:(id)sender;
- (IBAction)showStatistics:(id)sender;
- (IBAction)showActions:(id)sender;


@end
