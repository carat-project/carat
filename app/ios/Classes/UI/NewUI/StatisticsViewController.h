//
//  StatisticsViewController.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 06/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MeasurementBar.h"

@interface StatisticsViewController : BaseViewController
@property (retain, nonatomic) IBOutlet UILabel *genIntensiveDescLabel;
@property (retain, nonatomic) IBOutlet MeasurementBar *genIntensiveBar;
@property (retain, nonatomic) IBOutlet UILabel *androidIntensiveLabel;
@property (retain, nonatomic) IBOutlet MeasurementBar *androidIntensiveBar;
@property (retain, nonatomic) IBOutlet UILabel *iOSIntensiveDescLabel;
@property (retain, nonatomic) IBOutlet MeasurementBar *iOSIntensiveBar;
@property (retain, nonatomic) IBOutlet UILabel *allUsersIntensiveDescLabel;
@property (retain, nonatomic) IBOutlet MeasurementBar *allUsersIntensiveBar;

@property (retain, nonatomic) IBOutlet UILabel *popularDeviceModelsDescLabel;

@end
