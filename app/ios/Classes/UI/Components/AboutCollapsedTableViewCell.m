//
//  AboutCollapsedTableViewCell.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 13/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "AboutCollapsedTableViewCell.h"

@implementation AboutCollapsedTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_title release];
    [_subTitle release];
    [super dealloc];
}
@end
