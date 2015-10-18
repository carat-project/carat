//
//  ActionsViewController.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 06/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListNetworkBaseViewController.h"

#import "ActionItemCell.h"

#import "ActionObject.h"

@interface ActionsViewController : ListNetworkBaseViewController{
    NSMutableArray *actionList;
    NSMutableArray *tableViewCellsList;
}

@property (retain, nonatomic) NSMutableArray *actionList;
@property (retain, nonatomic) NSMutableArray *tableViewCellsList;

@end
