//
//  CoreDataSystemNode.h
//  Carat
//
//  Created by Jonatan C Hamberg on 22/01/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface CoreDataSystemNode : NSManagedObject

@property (nonatomic, retain) CoreDataSystemNode *parentNode;
@property (nonatomic, retain) NSOrderedSet *childNodes;
@property (nonatomic, retain) NSString *splitName;
@property (nonatomic, retain) NSString *valueString;
@property (nonatomic, assign) NSRange *valueRange; // Note assign

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * expectedValue;
// Depends on current setting
// @property (nonatomic, retain) NSNumber * expectedValueWithout;
@property (nonatomic, retain) NSNumber * error;
@property (nonatomic, retain) NSNumber * count; // Samples?

@end
