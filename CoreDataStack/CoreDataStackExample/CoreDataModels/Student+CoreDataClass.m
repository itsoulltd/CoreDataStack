//
//  Student+CoreDataClass.m
//  CoreDataStackSample
//
//  Created by Minhazur Rahman on 11/1/17.
//  Copyright © 2017 KITE GAMES STUDIO LTD. All rights reserved.
//
//

#import "Student+CoreDataClass.h"
#import <CoreDataStack/CoreDataStack.h>

@implementation Student

+ (NSManagedObjectContext*) getDefaultContext{
    //User [[NGCoreDataContext sharedInstance] defaultContext] to get a default context, if you have only one Xcdatamodel file.
    return [[NGKeyedContext sharedInstance] contextForKey:@"Model"];
}

+ (BOOL)exist:(NSString *)guid{
    NSManagedObjectContext *context = [self getDefaultContext];
    NGCoreObject *obj = [Student readByGuid:guid context:context];
    return obj != nil;
}

+ (NSArray<Student *> *)getAllStudents{
    
    NSManagedObjectContext *context = [self getDefaultContext];
    //Basic way
    /*
    NSFetchRequest *request = [self fetchRequest];
    NSArray<Student*> *stds = [context executeFetchRequest:request error:nil];
    return stds;
    */
    //KGCoreObject way
    return [Student read:nil context:context];
}

+ (void)addStudent:(NSDictionary *)info{
    
    NSManagedObjectContext *context = [self getDefaultContext];
    //Basic way
    /*
    Student *std = (Student*)[NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:context];
    std.name = info[@"name"];
    std.age = info[@"age"];
    std.address = info[@"address"];
    //Save if required
     */
    //KGCoreObject way
    [Student insertIntoContext:context withProperties:info];
    //Save if required
}

+ (void)updateStudent:(NSDictionary *)info{
    
    NSManagedObjectContext *context = [self getDefaultContext];
    //Basic way
    /*
    NSFetchRequest *request = [self fetchRequest];
    NSPredicate *nameFilter = [NSPredicate predicateWithFormat:@"name = %@", info[@"name"]];
    request.predicate = nameFilter;
    NSArray<Student*> *stds = [context executeFetchRequest:request error:nil];
    if (stds.count > 0) {
        Student *std = [stds firstObject];
        std.name = info[@"name"];
        std.age = info[@"age"];
        std.address = info[@"address"];
        //Save if required
    }
    */
    //KGCoreObject way
    NSArray<Student*> *stds = [Student read:@{@"name":info[@"name"]} context:context];
    Student *std = [stds lastObject];
    [std updateWithInfo:info];
    //Save if required
}

+ (void)deleteStudent:(NSString *)name{
    NSManagedObjectContext *context = [[NGCoreDataContext sharedInstance] defaultContext];
    //Basic way
    /*
    NSFetchRequest *request = [self fetchRequest];
    NSPredicate *nameFilter = [NSPredicate predicateWithFormat:@"name = %@", name];
    request.predicate = nameFilter;
    NSArray<Student*> *stds = [context executeFetchRequest:request error:nil];
    if (stds.count > 0) {
        Student *std = [stds firstObject];
        [context deleteObject:std];
    }
     */
    //KGCoreObject way
    NSArray<Student*> *stds = [Student read:@{@"name":name} context:context];
    Student *std = [stds lastObject];
    [context deleteObject:std];
}

@end
