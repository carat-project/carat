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
    
    // Assign reusable source for top hogs
    TopHogsTableView *topHogsTable = [TopHogsTableView new];
    [_topHogsTable setDelegate:topHogsTable];
    [_topHogsTable setDataSource:topHogsTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_topHogsTable release];
    [super dealloc];
}
@end
