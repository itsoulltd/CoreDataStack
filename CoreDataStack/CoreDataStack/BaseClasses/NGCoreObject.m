//
//  NGCoreObject.m
//  StartupProjectSampleA
//
//  Created by Towhid Islam on 4/12/15.
//  Copyright (c) 2017 Next Generation Object Ltd. All rights reserved.
//

#import "NGCoreObject.h"

@implementation NGCoreObject
@dynamic guid;
@dynamic eventTimeStamp;
@dynamic eventOrder;
@dynamic eventRemarks;

#pragma Private Class Methods

+ (NSString*) entityName{
    NSString *entity = NSStringFromClass([self class]);
    return entity;
}

+ (NSPredicate*) predicateForKey:(NSString*)key value:(id)value{
    
    NSExpression *leftExpression = [NSExpression expressionForKeyPath:key];
    NSExpression *rightExpression = [NSExpression expressionForVariable:@"Value"];
    NSPredicate *predicateX = [NSComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                 rightExpression:rightExpression
                                                                        modifier:NSDirectPredicateModifier
                                                                            type:NSEqualToPredicateOperatorType options:NSCaseInsensitivePredicateOption];
    
    NSPredicate *predicate = [predicateX predicateWithSubstitutionVariables:@{@"Value":value}];
    return predicate;
}

#pragma NGCoreObjectProtocol Implementation

+ (NSUInteger)rows:(NSManagedObjectContext *)context{
    //
    NSFetchRequest *request = [[self class] createRequestWithEntityName];
    NSError *error;
    NSUInteger counts = [context countForFetchRequest:request error:&error];
    if (error != nil) {
        NSLog(@"%@",[error debugDescription]);
    }
    return counts;
}

+ (NSArray*) read:(NSDictionary*)searchPaths context:(NSManagedObjectContext*)context{
    //
    Match match = All;
    return [[self class] readUsing:context withSearchHandler:^(NSFetchRequest *request) {
        //Now create predicate with dynamic behaviour
        NSString *guid = searchPaths[@"guid"];
        if (guid) {
            request.predicate = [NSPredicate predicateWithFormat:@"guid = %@",guid];
        }
        else{
            NSMutableArray *predicates = [NSMutableArray new];
            for (NSString *key in [searchPaths allKeys]) {
                NSPredicate *predicate = [[self class] predicateForKey:key value:[searchPaths objectForKey:key]];
                [predicates addObject:predicate];
            }
            if (predicates.count > 0) {
                NSCompoundPredicateType compoundType = (match == All) ? NSAndPredicateType : NSOrPredicateType;
                request.predicate = [[NSCompoundPredicate alloc] initWithType:compoundType subpredicates:predicates];
            }
        }
    }];
}

- (void) write:(NSDictionary*)updateProperties{
    //
    if (updateProperties != nil) {
        [self updateWithInfo:updateProperties];
    }
}

+ (NGCoreObject*) readBy:(NSManagedObjectID*)managedId context:(NSManagedObjectContext*)context{
    //
    if (managedId.isTemporaryID == NO) {
        NSError *error;
        NGCoreObject *obj = (NGCoreObject*)[context existingObjectWithID:managedId error:&error];
        if (error != nil) {
            NSLog(@"%@",[error debugDescription]);
        }
        return obj;
    }
    else{
        NSLog(@"%@ -> given ManagedId is a temporaryID, Please save to context, before further use.",NSStringFromClass([self class]));
    }
    return nil;
}

#pragma Other Methods Implementation

+ (NSArray*) readUsing:(NSManagedObjectContext*)context sortDescriptors:(NSArray*)descriptors searchHandler:(SearchHandler)handler{
    //
    NSFetchRequest *request = [[self class] createRequestWithEntityName];
    if (handler) {
        handler(request);
    }
    if (descriptors && descriptors.count > 0) {
        request.sortDescriptors = descriptors;
    }
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    return results;
}

+ (NSArray*) readUsing:(NSManagedObjectContext*)context withSearchHandler:(SearchHandler)handler{
    //
    NSFetchRequest *request = [[self class] createRequestWithEntityName];
    if (handler) {
        handler(request);
    }
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    return results;
}

+ (NSFetchRequest*) createRequestWithEntityName{
    //
    NSString *entity = NSStringFromClass([self class]);
    Class encodeType = NSClassFromString(entity);
    if (![encodeType isSubclassOfClass:[NGManagedObject class]]) {
        return nil;
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entity];
    return request;
}

+ (NGCoreObject*) readByGuid:(NSString*)guid context:(NSManagedObjectContext*)context{
    //
    NSArray *items = [[self class] read:@{@"guid": guid} context:context];
    if (items.count == 1) {
        return items.firstObject;
    }
    else{
        return [[self class] maxOrderedItem:items];
    }
}

+ (NGCoreObject*) maxOrderedItem:(NSArray*)items{
    //
    NSString *keyPath = [NSString stringWithFormat:@"@max.%@",@"eventOrder"];
    NSNumber *max = [items valueForKeyPath:keyPath];
    NSArray *maxItem = [items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"eventOrder >= %@",max]];
    return maxItem.firstObject;
}

+ (void) write:(NSDictionary *)updateProperties whereGuid:(NSString *)guid context:(NSManagedObjectContext *)context{
    //
    NGCoreObject *item = [[self class] readByGuid:guid context:context];
    if (item) {
        [item write:updateProperties];
    }
}

+ (void) write:(NSDictionary *)updateProperties whereManagedID:(NSManagedObjectID *)ID context:(NSManagedObjectContext *)context{
    //
    NGCoreObject *item = [[self class] readBy:ID context:context];
    if (item) {
        [item write:updateProperties];
    }
}

+ (void) insert:(NSArray*)items context:(NSManagedObjectContext *)context{
    //
    NSArray *guidIds = [items valueForKey:@"guid"];
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"guid IN %@", guidIds];
    NSArray *itemsWithGuid = [items filteredArrayUsingPredicate:searchPredicate];
    if (itemsWithGuid.count > 0) {
        items = itemsWithGuid;
    }
    for (NSDictionary *item in items) {
        [[self class] insertIntoContext:context withProperties:item];
        NSLog(@"Inserted :: %@", item);
    }
}

@end
