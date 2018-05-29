//
//  NSObject+Properties.m
//  CoreDataStackExample
//
//  Created by Towhidul Islam on 5/29/18.
//  Copyright © 2018 Towhid Islam. All rights reserved.
//

#import "NSObject+Properties.h"
#import <objc/runtime.h>

@implementation NSString (AQPropertyKVC)

- (NSString *) propertyStyleString
{
    NSString * result = [[self substringToIndex: 1] lowercaseString];
    if ( [self length] == 1 )
        return ( result );
    
    return ( [result stringByAppendingString: [self substringFromIndex: 1]] );
}

@end

///////////////////////////////////////////////////////////////////////////

@implementation NSObject (Properties)

const char * property_getTypeString( objc_property_t property )
{
    const char * attrs = property_getAttributes( property );
    if ( attrs == NULL )
        return ( NULL );
    
    static char buffer[256];
    const char * e = strchr( attrs, ',' );
    if ( e == NULL )
        return ( NULL );
    
    int len = (int)(e - attrs);
    memcpy( buffer, attrs, len );
    buffer[len] = '\0';
    
    return ( buffer );
}

+ (BOOL) hasPropertyNamed: (NSString *) name
{
    return ( class_getProperty(self, [name UTF8String]) != NULL );
}

+ (BOOL) hasPropertyNamed: (NSString *) name ofType: (const char *) type
{
    objc_property_t property = class_getProperty( self, [name UTF8String] );
    if ( property == NULL )
        return ( NO );
    
    const char * value = property_getTypeString( property );
    if ( strcmp(type, value) == 0 )
        return ( YES );
    
    return ( NO );
}

+ (BOOL) hasPropertyForKVCKey: (NSString *) key
{
    if ( [self hasPropertyNamed: key] )
        return ( YES );
    
    return ( [self hasPropertyNamed: [key propertyStyleString]] );
}

+ (const char *) typeOfPropertyNamed: (NSString *) name
{
    objc_property_t property = class_getProperty( self, [name UTF8String] );
    if ( property == NULL )
        return ( NULL );
    
    return ( property_getTypeString(property) );
}

- (BOOL) hasPropertyForKVCKey: (NSString *) key
{
    return ( [[self class] hasPropertyForKVCKey: key] );
}

- (const char *) typeOfPropertyNamed: (NSString *) name
{
    return ( [[self class] typeOfPropertyNamed: name] );
}

@end

///////////////////////////////////////////////////////

@implementation NSString (CMTime)

+(NSString *)stringFromCMTime:(CMTime)theTime {
    // Need a string of format "hh:mm:ss:nanoseconds". (No milliseconds.)
    NSTimeInterval seconds = (NSTimeInterval)CMTimeGetSeconds(theTime);
    NSDate *date1 = [NSDate new];
    NSDate *date2 = [NSDate dateWithTimeInterval:seconds sinceDate:date1];
    NSCalendarUnit unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitNanosecond;
    NSDateComponents *converted = [[NSCalendar currentCalendar] components:unitFlags
                                                                  fromDate:date1
                                                                    toDate:date2
                                                                   options:0];
    
    NSString *str = [NSString stringWithFormat:@"%02d:%02d:%02d:%d",
                     (int)[converted hour],
                     (int)[converted minute],
                     (int)[converted second],
                     (int)[converted nanosecond]];
    return str;
}


+(CMTime)parseTimecodeStringIntoCMTime:(NSString *)timecodeString {
    NSArray *timeComponents = [timecodeString componentsSeparatedByString:@":"];
    
    int hours = [(NSString *)timeComponents[0] intValue];
    int minutes = [(NSString *)timeComponents[1] intValue];
    
    int seconds = [(NSString *)timeComponents[2] intValue ];
    
    int milliseconds = 0;
    if(timeComponents.count > 3) {
        milliseconds = [(NSString *)timeComponents[3] intValue] / 1000000;
    }
    
    
    NSUInteger totalNumSeconds = [TaskUtils totalSecondsForHours:hours minutes:minutes seconds:seconds];
    
    CMTime time = [TaskUtils convertSecondsMilliseconds:totalNumSeconds toCMTime:milliseconds];
    return time;
}

@end

@implementation TaskUtils

+(NSUInteger)totalSecondsForHours:(NSUInteger)hours
                          minutes:(NSUInteger)minutes
                          seconds:(NSUInteger)seconds {
    
    return (hours * 3600) + (minutes * 60) + seconds;
}

+(CMTime)convertSecondsMilliseconds:(NSUInteger)seconds toCMTime:(NSUInteger)milliseconds {
    CMTime secondsTime = CMTimeMake(seconds, 1);
    CMTime millisecondsTime;
    
    if (milliseconds == -1) {
        return secondsTime;
    } else {
        millisecondsTime = CMTimeMake(milliseconds, 1000);
        CMTime time = CMTimeAdd(secondsTime, millisecondsTime);
        return time;
    }
}

@end
