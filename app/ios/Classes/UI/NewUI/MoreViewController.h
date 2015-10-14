//
//  MoreViewController.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 12/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TouchViewDelegate.h"
#import "TutorialViewController.h"
#import "HideAppsViewController.h"
#import "AboutViewController.h"

@interface MoreViewController : BaseViewController
- (IBAction)wifiOnlySwitcherValueChanged:(id)sender;
- (IBAction)hideAppsClicked:(id)sender;
- (IBAction)feedBackClicked:(id)sender;
- (IBAction)tutorialClicked:(id)sender;
- (IBAction)aboutClicked:(id)sender;

@end
