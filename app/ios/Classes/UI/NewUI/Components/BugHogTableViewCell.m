//
//  BugHogTableViewCell.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 08/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "BugHogTableViewCell.h"

@implementation BugHogTableViewCell
@synthesize nameLabel = _nameLabel;
@synthesize expImpTimeLabel = _prepTimeLabel;
@synthesize thumbnailAppImg = _thumbnailImageView;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_nameLabel release];
    [_prepTimeLabel release];
    [_thumbnailImageView release];
    [super dealloc];
}

@end
