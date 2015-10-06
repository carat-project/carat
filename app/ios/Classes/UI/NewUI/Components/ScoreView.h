//
//  JScoreView.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 30/09/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppColors.h"

IB_DESIGNABLE
@interface ScoreView : UIView

@property (nonatomic) IBInspectable NSInteger score;
@property (nonatomic, retain) IBInspectable NSString *scoreTitle;

- (void)setTitle:(NSString*)title;
- (void)setScore:(int) score;


@end
