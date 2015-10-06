//
//  TutorialPageIndicatorView.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 05/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppColors.h"
IB_DESIGNABLE
@interface TutorialPageIndicatorView : UIView
@property (nonatomic) IBInspectable NSInteger pageCount;
@property (nonatomic) IBInspectable NSInteger pagePosition;

-(void)setPageCount:(int) pageCount;
-(void)setPagePositionAs:(int) pagePosition;

@end
