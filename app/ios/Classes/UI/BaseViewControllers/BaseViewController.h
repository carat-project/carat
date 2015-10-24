//
//  BaseViewController.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 29/09/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppColors.h"
#import "AppLayout.h"
#include <stdint.h>

@interface BaseViewController : UIViewController

@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;
- (IBAction)barItemBackPressed;
- (IBAction)barItemMorePressed;
- (void)showInfoView:(NSString *)title message:(NSString *)message;
@end
