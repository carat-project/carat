//
//  BugHogListViewController.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 17/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "ListNetworkBaseViewController.h"
#import "WebInfoViewController.h";
#import "BugHogTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface BugHogListViewController : ListNetworkBaseViewController <ShowNumberHelpDelegate>{
    HogBugReport *report;
    NSMutableArray *filteredCells;    
}
@property (retain, nonatomic) HogBugReport *report;
@property (nonatomic, strong) NSMutableArray *filteredCells;

- (void)reloadReport;
- (void)setHogBugReport:(HogBugReport *)report;
- (void)showWhatTheseNumbersMeanInfo;

@end
