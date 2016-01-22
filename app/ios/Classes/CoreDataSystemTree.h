//
//  CoreDataSystemTree.h
//  Carat
//
//  Created by Jonatan C Hamberg on 22/01/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CoreDataSystemNode;

@interface CoreDataSystemTree : NSManagedObject

@property (nonatomic, retain) CoreDataSystemNode *root;

@end
