//
//  BugsViewController.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 06/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BugHogExpandedTableViewCell.h"
#import "BugHogListItemData.h"
#import "BugHogTableViewCell.h"
#import "BaseViewController.h"

#import "UIImageView+WebCache.h"
#import "CoreDataManager.h"
#import "MBProgressHUD.h"

@interface BugsViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate> {
    HogBugReport *report;
    
}
@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *expandedCells;
@property (retain, nonatomic) HogBugReport *report;


@end
