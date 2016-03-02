//
//  TopHogsTableView.h
//  Carat
//
//  Created by Jonatan C Hamberg on 01/03/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface TopHogsTableView : NSObject <UITableViewDataSource, UITableViewDelegate>
@property (retain, nonatomic) NSArray *data;
@property (retain, nonatomic) UIActivityIndicatorView *spinner;
@property (retain, nonatomic) UIView *spinnerBackground;
- (void)attachSpinner:(UIActivityIndicatorView *)spinner withBackground:(UIView *)spinnerBackGround;
@end
