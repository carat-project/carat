//
//  PopularModel.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 27/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "PopularModel.h"

@implementation PopularModel
    
- (NSComparisonResult)compare:(PopularModel *)otherObject {
    return self.inUseCount < otherObject.inUseCount;
}


@end
