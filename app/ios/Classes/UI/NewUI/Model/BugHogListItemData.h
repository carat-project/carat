//
//  BugHogListItemData.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 08/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BugHogListItemData : NSObject

@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *expImpTxt;
@property (nonatomic, strong) NSString *samples;
@property (nonatomic, strong) NSString *error;
@property (nonatomic, strong) NSString *samplesWithout;

@end
