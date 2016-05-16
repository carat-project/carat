//
//  ActionTableViewCell.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 22/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionObject.h"

@interface ActionTableViewCell : UITableViewCell
{
    IBOutlet UILabel *actionString;
    IBOutlet UILabel *actionValue;
    IBOutlet UILabel *actionDescr;
    NSString *descValue;
    ActionType actionType;
}

@property (retain, nonatomic) IBOutlet UILabel *actionString;
@property (retain, nonatomic) IBOutlet UILabel *actionValue;
@property (retain, nonatomic) IBOutlet UILabel *actionDescr;
@property (retain, nonatomic) IBOutlet UIImageView *actionIcon;
@property (retain, nonatomic) NSString *descValue;
@property (nonatomic) ActionType actionType;

@end