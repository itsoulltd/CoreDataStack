//
//  Student+CoreDataProperties.m
//  CoreDataStackSample
//
//  Created by Towhidul Islam on 11/1/17.
//  Copyright © 2017 KITE GAMES STUDIO LTD. All rights reserved.
//
//

#import "Student+CoreDataProperties.h"

@implementation Student (CoreDataProperties)

+ (NSFetchRequest<Student *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Student"];
}

@dynamic address;
@dynamic age;
@dynamic name;
@dynamic mobileNumbers;

@end
