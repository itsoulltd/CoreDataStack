//
//  NSArray+FilterAndSorting.m
//  CoreDataStack
//
//  Created by Towhidul Islam on 12/15/16.
//  Copyright © 2016 Towhidul Islam. All rights reserved.
//

#import "NSArray+FilterAndSorting.h"

@implementation NSArray (NGFilterAndSorting)

- (void)dealloc{
    //NSLog(@"dealloc %@",NSStringFromClass([self class]));
}

- (NSArray*) filterUsingClause:(NSString*)clause value:(id)value{
    
    NSArray *result = nil;
    NSString *keyPath = @"SELF";
    NSPredicate *predicate = nil;
    if ([value isKindOfClass:[NSNumber class]]) {
        NSString *formated = [NSString stringWithFormat:@"%@ %@ %@",keyPath,clause,[(NSNumber*)value stringValue]];
        predicate = [NSPredicate predicateWithFormat:formated];
    }else{
        predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@",value];
    }
    result = [self filteredArrayUsingPredicate:predicate];
    
    return result;
}

- (NSArray*) filterWithType:(NSPredicateOperatorType)type keyPath:(NSString *)keyPath value:(id)value{
    
    NSArray *result = nil;
    NSExpression *leftExp = [NSExpression expressionForKeyPath:keyPath];
    NSExpression *rightExp = [NSExpression expressionForVariable:@"Value"];
    NSPredicate *predicateX = [NSComparisonPredicate predicateWithLeftExpression:leftExp
                                                                 rightExpression:rightExp
                                                                        modifier:NSDirectPredicateModifier
                                                                            type:type options:NSCaseInsensitivePredicateOption];
    
    NSPredicate *pred = [predicateX predicateWithSubstitutionVariables:@{@"Value":value}];
    result = [self filteredArrayUsingPredicate:pred];
    return result;
}

- (NSArray*) createSortDescriptor:(NSArray*)keyPaths ascending:(BOOL)isYes{
    
    NSMutableArray *sortDescriptors = [[NSMutableArray alloc] initWithCapacity:keyPaths.count];
    for (NSString *keyPath in keyPaths) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:keyPath ascending:isYes];
        [sortDescriptors addObject:sortDescriptor];
    }
    return sortDescriptors;
}

- (NSArray *)sortForKeyPaths:(NSArray *)keyPaths assecding:(BOOL)isYes{
    
    if (self.count <= 1) {
        return self;
    }
    
    NSArray *reslut = nil;
    NSArray *sortDescriptors = [self createSortDescriptor:keyPaths ascending:isYes];
    reslut = [self sortedArrayUsingDescriptors:sortDescriptors];
    
    return reslut;
}

- (NSArray *)sortForKeyPath:(NSString*)keyPath assecding:(BOOL)isYes{
    return [self sortForKeyPaths:@[keyPath] assecding:isYes];
}

- (NSArray *)sortWhenAssecding:(BOOL)isYes{
    return [self sortForKeyPath:@"self" assecding:isYes];
}

- (id)getMaxValue{
    return [self getMaxValueForKeyPath:@"self"];
}

- (id)getMaxValueForKeyPath:(NSString*)keyPath{
    if (self.count <= 0) {
        return nil;
    }
    keyPath = [NSString stringWithFormat:@"@max.%@",keyPath];
    id value = [self valueForKeyPath:keyPath];
    return value;
}

- (id)getMinValue{
    return [self getMinValueForKeyPath:@"self"];
}

- (id)getMinValueForKeyPath:(NSString*)keyPath{
    if (self.count <= 0) {
        return nil;
    }
    keyPath = [NSString stringWithFormat:@"@min.%@",keyPath];
    id value = [self valueForKeyPath:keyPath];
    return value;
}
@end
