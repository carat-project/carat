//
//  DashboardNavigationButton.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 04/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashboardNavigationButton : UIView
@property (retain, nonatomic) IBOutlet UIImageView *dashboardButtonImage;
@property (retain, nonatomic) IBOutlet UILabel *dashboardButtonExtra;
@property (retain, nonatomic) IBOutlet UILabel *dashboardButtonTitle;

-(void)setButtonImage:(UIImage *) image;
-(void)setButtonExtraInfo:(NSString *) info;
-(void)setButtonTitle:(NSString *) title;

@end
