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
@property (nonatomic) IBInspectable CGFloat firstMeasureValue;
@property (nonatomic) IBInspectable CGFloat secondMeasureValue;

@end
