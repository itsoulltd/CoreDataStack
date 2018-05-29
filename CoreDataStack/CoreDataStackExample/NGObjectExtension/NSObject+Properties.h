//
//  NSObject+Properties.h
//  CoreDataStackExample
//
//  Created by Towhidul Islam on 5/29/18.
//  Copyright © 2018 Towhid Islam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface NSObject (Properties)

+ (BOOL) hasPropertyForKVCKey: (NSString *) key;
+ (const char *) typeOfPropertyNamed: (NSString *) name;

- (BOOL) hasPropertyForKVCKey: (NSString *) key;
- (const char *) typeOfPropertyNamed: (NSString *) name;

@end

@interface TaskUtils : NSObject

+(NSUInteger)totalSecondsForHours:(NSUInteger)hours
                          minutes:(NSUInteger)minutes
                          seconds:(NSUInteger)seconds;

+(CMTime)convertSecondsMilliseconds:(NSUInteger)seconds toCMTime:(NSUInteger)milliseconds;

@end

@interface NSString (CMTime)

+(NSString *)stringFromCMTime:(CMTime)theTime;

+(CMTime)parseTimecodeStringIntoCMTime:(NSString *)timecodeString;

@end

@interface NSString (PropertyKVC)

- (NSString *) propertyStyleString;

@end
