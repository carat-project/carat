//
//  PopularModel.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 27/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PopularModel : NSObject

@property (nonatomic, strong) NSString *deviceName;
@property long inUseCount;

- (NSComparisonResult)compare:(PopularModel *)otherObject;
@end
