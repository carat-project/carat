//
//  MeasurementBar.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 07/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface MeasurementBar : UIView
@property (nonatomic) IBInspectable CGFloat largerMeasureValue;
@property (nonatomic) IBInspectable CGFloat smallerMeasureValue;
@property (nonatomic) IBInspectable UIColor *largerBarColor;
@property (nonatomic) IBInspectable UIColor *smallerBarColor;

@end
