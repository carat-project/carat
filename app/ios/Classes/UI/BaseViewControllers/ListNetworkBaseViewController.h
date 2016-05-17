//
//  ListNetworkBaseViewController.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 17/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "NetworkBaseViewController.h"
#import "CoreDataManager.h"
#import "MBProgressHUD.h"
#import "Utilities.h"
#import "SVPullToRefresh.h"
#import "CaratConstants.h"


@interface ListNetworkBaseViewController : NetworkBaseViewController <UITableViewDelegate, UITableViewDataSource>{
    NSString * expandedCell;
    NSString * collapsedCell;
}


@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *expandedCells;
@property (nonatomic, strong) NSString * expandedCell;
@property (nonatomic, strong) NSString * collapsedCell;

-(void)sampleCountUpdated:(NSNotification*)notification;
-(void)collapseCells;


@end
