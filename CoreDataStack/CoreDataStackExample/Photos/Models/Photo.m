//
//  Photo.m
//  CoreDataTest
//
//  Created by Towhid Islam on 4/13/14.
//  Copyright (c) 2014 Towhid Islam. All rights reserved.
//

#import "Photo.h"
#import "PhotoGrapher.h"


@implementation Photo

@dynamic location;
@dynamic photoId;
@dynamic title;
@dynamic datetimeAtTook;
@dynamic whoTook;

- (NSDate *)updateDate:(NSString *)dateStr{
    //should be formated by NSDateFormatter
    return [NSDate date];
}

- (NSString *)serializeDate:(NSDate *)date{
    //should be formated by NSDateFormatter
    return [date description];
}

- (id)serializeValue:(id)value forKey:(NSString *)key{
    //whoTook is not Json writable, so we skiped.
    if ([key isEqualToString:@"whoTook"]) {
        return [NSNull null];
    }else{
        return [super serializeValue:value forKey:key];
    }
}

@end
