//
//  AboutViewController.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 12/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "AboutTableViewCell.h"
#import "AboutListItemData.h"
#import "BugsViewController.h"
#import "HogsViewController.h"


@interface AboutViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *tableData;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *expandedCells;

@end
