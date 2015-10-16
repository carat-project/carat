//
//  NetworkBaseViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 16/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "NetworkBaseViewController.h"
#import "Utilities.h"
#import "Flurry.h"
#import "CoreDataManager.h"
#import "CaratConstants.h"
#import "UIDeviceHardware.h"

@interface NetworkBaseViewController ()

@end

@implementation NetworkBaseViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    DLog(@"Memory warning.");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadDataWithHUD:)
                                                 name:NSLocalizedString(@"CCDMReportUpdateStatusNotification", nil)
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSLocalizedString(@"CCDMReportUpdateStatusNotification", nil) object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - initHUD method
- (void)initHUD:(NSString *) hudLabel selector: (SEL)selector
{
    HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.view];
    [self.tabBarController.view addSubview:HUD];
    
    HUD.dimBackground = YES;
    
    // Register for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    HUD.labelText = hudLabel;
    
    [HUD showWhileExecuting:@selector(selector)
                   onTarget:self
                 withObject:nil
                   animated:YES];
}

#pragma mark - MBProgressHUDDelegate method

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
}


@end
