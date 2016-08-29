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
    _topHogs = [TopHogsTableView new];
    [_topHogs attachSpinner:_spinner withBackground:_spinnerBackground];
    [_topHogsTable setDelegate:_topHogs];
    [_topHogsTable setDataSource:_topHogs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_spinner release];
    [_spinnerBackground release];
    [_navbarTitle release];
    [_topHogs release];
    [_topHogsTable release];
    [super dealloc];
}
@end
