//
//  Address.h
//  CoreDataTest
//
//  Created by Towhid Islam on 4/13/14.
//  Copyright (c) 2014 Towhid Islam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreDataStack/CoreDataStack.h>

@class PhotoGrapher;

@interface Address : NGCoreObject

@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) PhotoGrapher *whoLive;

@end
