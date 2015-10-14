//
//  ProcessViewController.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 13/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "BugHogExpandedTableViewCell.h"
#import "BugHogListItemData.h"
#import "BugHogTableViewCell.h"

@interface ProcessViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *tableData;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *expandedCells;

@end
