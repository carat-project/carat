//
//  BaseViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 29/09/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "BaseViewController.h"

@implementation BaseViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self setFontFamily:@"SanFransisco" forView:self.view andSubViews:YES];
}

-(void)setFontFamily:(NSString*)fontFamily forView:(UIView*)view andSubViews:(BOOL)isSubViews
{
    if ([view isKindOfClass:[UILabel class]])
    {
        UILabel *lbl = (UILabel *)view;
        [lbl setFont:[UIFont fontWithName:fontFamily size:[[lbl font] pointSize]]];
    }
    
    if (isSubViews)
    {
        for (UIView *sview in view.subviews)
        {
            [self setFontFamily:fontFamily forView:sview andSubViews:YES];
        }
    }
}

@end
