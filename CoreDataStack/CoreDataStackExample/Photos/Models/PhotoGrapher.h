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

- (void)insertObject:(Photo *)value inPhotosAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPhotosAtIndex:(NSUInteger)idx;
- (void)insertPhotos:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePhotosAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPhotosAtIndex:(NSUInteger)idx withObject:(Photo *)value;
- (void)replacePhotosAtIndexes:(NSIndexSet *)indexes withPhotos:(NSArray *)values;
- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSOrderedSet *)values;
- (void)removePhotos:(NSOrderedSet *)values;
- (void)addAddressesObject:(Address *)value;
- (void)removeAddressesObject:(Address *)value;
- (void)addAddresses:(NSSet *)values;
- (void)removeAddresses:(NSSet *)values;

@end
