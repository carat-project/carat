//
//  ActionTableViewCell.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 22/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "ActionTableViewCell.h"

@implementation ActionTableViewCell
@synthesize actionString;
@synthesize actionValue;
@synthesize actionDescr;
@synthesize descValue;
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

- (void)dealloc {
    [actionString release];
    [actionValue release];
    [actionDescr release];
    [descValue release];
    [super dealloc];
}

@end
