//
//  BugHogTableViewCell.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 08/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BugHogTableViewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *thumbnailAppImg;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *expImpTimeLabel;


@end
