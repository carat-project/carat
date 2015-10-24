//
//  UiInsetLabel.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 05/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface UiInsetLabel : UILabel
{
    CGFloat topInset;
    CGFloat leftInset;
    CGFloat bottomInset;
    CGFloat rightInset;
}
@property (nonatomic) IBInspectable CGFloat topInset;
@property (nonatomic) IBInspectable CGFloat leftInset;
@property (nonatomic) IBInspectable CGFloat bottomInset;
@property (nonatomic) IBInspectable CGFloat rightInset;

@end
