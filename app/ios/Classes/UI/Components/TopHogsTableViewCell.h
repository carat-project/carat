//
//  HogStatisticsTableView.h
//  Carat
//
//  Created by Jonatan C Hamberg on 09/03/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopHogsTableViewCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *rowNumber;
@property (retain, nonatomic) IBOutlet UILabel *appName;
@property (retain, nonatomic) IBOutlet UILabel *benefitText;
@property (retain, nonatomic) IBOutlet UILabel *sampleCount;
@property (retain, nonatomic) IBOutlet UILabel *usagePercentage;
@property (retain, nonatomic) IBOutlet UIImageView *expandButton;
@end
