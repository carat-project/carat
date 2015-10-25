//
//  ProgressStatusView.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 25/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "ProgressStatusView.h"

@implementation ProgressStatusView
@synthesize progress;
@synthesize label;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) layoutSubviews
{
    NSLog(@"%s before height: %f",__PRETTY_FUNCTION__, self.frame.size.height);
    [super layoutSubviews];
    NSLog(@"%s after height: %f", __PRETTY_FUNCTION__, self.frame.size.height);
}

- (void)dealloc {
    [progress release];
    [label release];
    [super dealloc];
}
@end
