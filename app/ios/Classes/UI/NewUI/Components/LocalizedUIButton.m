//
//  LocalizedUIButton.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 05/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "LocalizedUIButton.h"

@implementation LocalizedUIButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib{
    [super awakeFromNib];
    NSUInteger states[4] = {UIControlStateNormal, UIControlStateHighlighted, UIControlStateSelected, UIControlStateDisabled};
    for(int i=0; i<4; i++){
        NSString *title = [self titleForState:states[i]];
        [self setTitle:NSLocalizedString(title, nil) forState:states[i]];
    }
}

@end
