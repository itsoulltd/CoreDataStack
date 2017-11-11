//
//  Photo.h
//  CoreDataTest
//
//  Created by Towhid Islam on 4/13/14.
//  Copyright (c) 2014 Towhid Islam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreDataStack/CoreDataStack.h>

@class PhotoGrapher;

@interface Photo : NGCoreObject

@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * photoId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * datetimeAtTook;
@property (nonatomic, retain) PhotoGrapher *whoTook;

@end
