//
//  HogsViewController.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 06/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BugHogListViewController.h"

@interface HogsViewController : BugHogListViewController
@property (retain, nonatomic) IBOutlet UILabel *contentTitle;
@property (retain, nonatomic) IBOutlet UIButton *extraButton;
@property (retain, nonatomic) IBOutlet UITextView *content;

@end
