//
//  Photo+Photo_Helper.m
//  CoreDataTest
//
//  Created by Towhid Islam on 4/13/14.
//  Copyright (c) 2014 Towhid Islam. All rights reserved.
//

#import "Photo+Photo_Helper.h"

@implementation Photo (Photo_Helper)

- (NSDate *)updateDate:(NSString *)dateStr{
    
    NSDate *date = nil;
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    @try {
        date = [formatter dateFromString:dateStr];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception reason]);
    }
    return date;
}

- (NSString *)serializeDate:(NSDate *)date{
    
    NSString *result = @"";
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    @try {
        result = [formatter stringFromDate:date];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception reason]);
    }
    return result;
}

@end
