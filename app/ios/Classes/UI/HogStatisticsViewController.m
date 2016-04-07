//
//  HogStatisticsViewController.m
//  Carat
//
//  Created by Jonatan C Hamberg on 29/02/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import "HogStatisticsViewController.h"
#import "TopHogsTableView.h"

@interface HogStatisticsViewController ()

@end

@implementation HogStatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _navbarTitle.title = [NSLocalizedString(@"WorstHogsTitle", nil) uppercaseString];
    
    // Assign reusable source for top hogs
    TopHogsTableView *topHogs = [TopHogsTableView new];
    [topHogs attachSpinner:_spinner withBackground:_spinnerBackground];
    [_topHogsTable setDelegate:topHogs];
    [_topHogsTable setDataSource:topHogs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_topHogsTable release];
    [_spinner release];
    [_spinnerBackground release];
    [_navbarTitle release];
    [super dealloc];
}
@end
