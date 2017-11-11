//
//  PhotoGrapher.h
//  CoreDataTest
//
//  Created by Towhid Islam on 4/13/14.
//  Copyright (c) 2014 Towhid Islam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreDataStack/CoreDataStack.h>

@class Address, Photo;

@interface PhotoGrapher : NGCoreObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * contactNo;
@property (nonatomic, retain) NSDate * dateOfBirth;
@property (nonatomic, retain) NSOrderedSet *photos;
@property (nonatomic, retain) NSSet *addresses;
@end

@interface PhotoGrapher (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)addAddressesObject:(Address *)value;
+ (PhotoGrapher*) findByName:(NSString*)name context:(NSManagedObjectContext*)context;
@end
