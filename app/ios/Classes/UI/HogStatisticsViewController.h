//
//  HogStatisticsViewController.h
//  Carat
//
//  Created by Jonatan C Hamberg on 29/02/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import "BaseViewController.h"

@interface HogStatisticsViewController : BaseViewController
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (retain, nonatomic) IBOutlet UIView *spinnerBackground;
@property (retain, nonatomic) IBOutlet UITableView *topHogsTable;
@end
