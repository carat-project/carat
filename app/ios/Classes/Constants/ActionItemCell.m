//
//  ActionItemCell.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 21/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "ActionItemCell.h"

@implementation ActionItemCell
@synthesize actionString;
@synthesize actionValue;
@synthesize actionHeader;
@synthesize actionType;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end