//
//  Student+CoreDataClass.h
//  CoreDataStackSample
//
//  Created by Minhazur Rahman on 11/1/17.
//  Copyright © 2017 KITE GAMES STUDIO LTD. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreDataStack/CoreDataStack.h>

NS_ASSUME_NONNULL_BEGIN

@interface Student : NGCoreObject

+ (BOOL) exist:(NSString*)guid;
+ (NSArray<Student*>*)getAllStudents;
+ (void) addStudent:(NSDictionary*)info;
+ (void) updateStudent:(NSDictionary*)info;
+ (void) deleteStudent:(NSString*) name;

@end

NS_ASSUME_NONNULL_END

#import "Student+CoreDataProperties.h"
