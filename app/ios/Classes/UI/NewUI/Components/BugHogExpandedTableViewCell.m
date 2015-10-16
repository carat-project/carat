//
//  BugHogExpandedTableViewCell.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 09/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "BugHogExpandedTableViewCell.h"

@implementation BugHogExpandedTableViewCell
@synthesize samplesValueLabel = _samplesValueLabel;
@synthesize samplesWithoutValueLabel = _samplesWithoutValueLabel;
@synthesize errorValueLabel = _errorValueLabel;
@synthesize helpLabel = _helpLabel;
@synthesize expandContent = _expandContent;
@synthesize expandBtn = _expandBtn;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
