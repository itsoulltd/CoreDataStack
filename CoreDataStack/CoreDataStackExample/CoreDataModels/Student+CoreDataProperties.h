//
//  Student+CoreDataProperties.h
//  CoreDataStackSample
//
//  Created by Towhidul Islam on 11/1/17.
//  Copyright © 2017 KITE GAMES STUDIO LTD. All rights reserved.
//
//

#import "Student+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Student (CoreDataProperties)

+ (NSFetchRequest<Student *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *address;
@property (nullable, nonatomic, copy) NSNumber *age;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSArray *mobileNumbers;

@end

NS_ASSUME_NONNULL_END
