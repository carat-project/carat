//
//  BugHogExpandedTableViewCell.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 09/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BugHogTableViewCell.h"

@interface BugHogExpandedTableViewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *thumbnailAppImg;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *expImpTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *samplesValueLabel;
@property (retain, nonatomic) IBOutlet UILabel *samplesWithoutValueLabel;
@property (retain, nonatomic) IBOutlet UILabel *errorValueLabel;
@property (retain, nonatomic) IBOutlet UILabel *helpLabel;
@property (retain, nonatomic) IBOutlet UIView *expandContent;
@property (retain, nonatomic) IBOutlet UIImageView *expandBtn;

@end
