//
//  ProgressStatusView.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 25/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressStatusView : UIView {
    UILabel *label;
    UIActivityIndicatorView *progress;
}
@property (retain, nonatomic) IBOutlet UILabel *label;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *progress;

@end
