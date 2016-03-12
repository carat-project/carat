//
//  HogStatisticsTableView.m
//  Carat
//
//  Created by Jonatan C Hamberg on 09/03/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import "TopHogsTableViewCell.h"

@implementation TopHogsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_appName release];
    [_expandButton release];
    [_rowNumber release];
    [_benefitText release];
    [_sampleCount release];
    [_usagePercentage release];
    [super dealloc];
}
@end
