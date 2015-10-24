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
@synthesize samplesValueLabel = _samplesValueLabel;
@synthesize samplesWithoutValueLabel = _samplesWithoutValueLabel;
@synthesize errorValueLabel = _errorValueLabel;
@synthesize helpLabel = _helpLabel;
@synthesize expandBtn = _expandBtn;
@synthesize delegate;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)showNumberHelp:(id)sender {
    
}

- (void)dealloc {
    [_nameLabel release];
    [_prepTimeLabel release];
    [_thumbnailImageView release];
    [_samplesValueLabel release];
    [_samplesWithoutValueLabel release];
    [_errorValueLabel release];
    [_helpLabel release];
    [_expandBtn release];
    delegate = nil;
    [super dealloc];
}


@end
