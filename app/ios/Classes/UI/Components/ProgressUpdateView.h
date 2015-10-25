//
//  ProgressUpdateView.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 25/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressUpdateView : UIView
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UILabel *label;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *actIndicator;

@end
