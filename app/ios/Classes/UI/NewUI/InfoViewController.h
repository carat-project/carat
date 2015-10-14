//
//  InfoViewController.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 13/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "LocalizedLabel.h"

@interface InfoViewController : BaseViewController
@property (retain, nonatomic) IBOutlet LocalizedLabel *labelRef;
@property (retain, nonatomic) IBOutlet UINavigationItem *navigationItemRef;
@property (retain, nonatomic) IBOutlet UINavigationBar *navigationBar;


@property (assign, nonatomic) NSString *titleForView;
@property (assign, nonatomic) NSString *messageForView;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;

@end
