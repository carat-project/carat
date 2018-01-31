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

@interface NetworkBaseViewController ()

@end

@implementation NetworkBaseViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateView];
}

- (void)didReceiveMemoryWarning {
    DLog(@"Memory warning.");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // UPDATE REPORT DATA
    if ([[CommunicationManager instance] isInternetReachable] == YES && // online
        ![self isFresh] && // need to update
        [[CoreDataManager instance] getReportUpdateStatus] == nil) // not already updating
    {
        [[CoreDataManager instance] updateLocalReportsFromServer];

    } else if ([[CommunicationManager instance] isInternetReachable] == NO) {
        DLog(@"Starting without reachability; setting notification.");
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatus:) name:kUpdateNetworkStatusNotification object:nil];
    
    [self updateNetworkStatus:nil];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadDataWithHUD:)
                                                 name:NSLocalizedString(@"CCDMReportUpdateStatusNotification", nil)
                                               object:nil];
    // UPDATE REPORT DATA
    if ([[CommunicationManager instance] isInternetReachable] == YES && // online
        ![self isFresh] && // need to update
        [[CoreDataManager instance] getReportUpdateStatus] == nil) // not already updating
    {
        [[CoreDataManager instance] updateLocalReportsFromServer];
    } else if ([[CommunicationManager instance] isInternetReachable] == NO) {
        DLog(@"Starting without reachability; setting notification.");
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSLocalizedString(@"CCDMReportUpdateStatusNotification", nil) object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateNetworkStatusNotification object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) updateNetworkStatus:(NSNotification *) notice
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *dict = [notice userInfo];
    BOOL isInternetActive = [dict[kIsInternetActive] boolValue];
    
    if (isInternetActive || [[CommunicationManager instance] isInternetReachable]) {
        DLog(@"Checking if update needed with new reachability status...");
        if (![self isFresh] && // need to update
            [[CoreDataManager instance] getReportUpdateStatus] == nil) // not already updating
        {
            DLog(@"Update possible; initiating.");
            [[CoreDataManager instance] updateLocalReportsFromServer];
        }
    }
}

- (BOOL) isFresh
{
    return [[CoreDataManager instance] secondsSinceLastUpdate] < 600; // 600 == 10 minutes
}
#pragma mark - MBProgressHUDDelegate method
//show network communication states in GUI
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    // Remove HUD from screen when the HUD was hidded
    DLog(@"%s hudWasHidden", __PRETTY_FUNCTION__);
}

- (void)loadDataWithHUD:(id)obj
{

}

- (void)updateView
{
    
}

- (void)dealloc {
    [super dealloc];
}

@end
