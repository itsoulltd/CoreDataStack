//
//  NGPrimitiveObject.m
//  CoreDataStackExample
//
//  Created by Towhidul Islam on 5/29/18.
//  Copyright © 2018 Towhid Islam. All rights reserved.
//

#import "NGPrimitiveObject.h"
#import "NSObject+Properties.h"

@implementation NGPrimitiveObject

- (void)updateValue:(id)value forKey:(NSString *)key{
    //if property type is CGFloat (Td) or int(Ti)
    if (strcmp([self typeOfPropertyNamed:key], "Td") == 0 || strcmp([self typeOfPropertyNamed:key], "Ti") == 0) {
        [self setValue:value forKey:key];
        return;
    }
    
    //if property type is NSInteger (Tq)
    if (strcmp([self typeOfPropertyNamed:key], "Tq") == 0) {
        [self setValue:value forKey:key];
        return;
    }
    
    //if property type is BOOL (TB)
    if (strcmp([self typeOfPropertyNamed:key], "TB") == 0 || strcmp([self typeOfPropertyNamed:key], "TB") == 0) {
        [self setValue:value forKey:key];
        //        NSLog(@"===>key %@ type %s value %@",key, [self typeOfPropertyNamed:key], value);
        return;
    }
    
    //if property type is CGAffineTransform T{CGAffineTransform=dddddd}
    if (strcmp([self typeOfPropertyNamed:key], "T{CGAffineTransform=dddddd}") == 0) {
        NSString *transformString = value;
        CGAffineTransform affineTransform = CGAffineTransformFromString(transformString);
        NSValue *transformValue = [NSValue valueWithCGAffineTransform:affineTransform];
        [self setValue:transformValue forKey:key];
        return;
    }
    
    //if property type is TransitionType TQ
    if (strcmp([self typeOfPropertyNamed:key], "TQ") == 0) {
        NSNumber *type = value;
        [self setValue:type forKey:key];
        return;
    }
    
    //if property type is CMTime T{?=qiIq}
    if (strcmp([self typeOfPropertyNamed:key], "T{?=qiIq}") == 0) {
        NSString *time = value;
        CMTime cmTime = [NSString parseTimecodeStringIntoCMTime:time];
        NSValue *cmTimeValue = [NSValue valueWithCMTime:cmTime];
        [self setValue:cmTimeValue forKey:key];
        return;
    }
    
    [super updateValue:value forKey:key];
}

- (id)serializeValue:(id)value forKey:(NSString *)key{
    //if property type is CGFloat (Td) or int(Ti)
    if (strcmp([self typeOfPropertyNamed:key], "Td") == 0 || strcmp([self typeOfPropertyNamed:key], "Ti") == 0) {
        NSNumber *numb = [self valueForKey:key];
        return numb;
    }
    
    //if property type is NSInteger (Tq)
    if (strcmp([self typeOfPropertyNamed:key], "Tq") == 0) {
        NSNumber *numb = [self valueForKey:key];
        return numb;
    }
    
    //if property type is BOOL (TB)
    if (strcmp([self typeOfPropertyNamed:key], "TB") == 0 || strcmp([self typeOfPropertyNamed:key], "Tc") == 0) {
        NSNumber *numb = [self valueForKey:key];
        //        NSLog(@"===>key %@ type %s value %@",key, [self typeOfPropertyNamed:key], value);
        return numb;
    }
    
    //if property type is CGAffineTransform T{CGAffineTransform=dddddd}
    if (strcmp([self typeOfPropertyNamed:key], "T{CGAffineTransform=dddddd}") == 0) {
        CGAffineTransform *transform = (__bridge CGAffineTransform *)([self valueForKey:key]);
        return NSStringFromCGAffineTransform(*transform);
    }
    
    //if property type is NSUInteger TQ
    if (strcmp([self typeOfPropertyNamed:key], "TQ") == 0) {
        NSNumber *type = [self valueForKey:key];
        return type;
    }
    
    //if property type is CMTime T{?=qiIq}
    if (strcmp([self typeOfPropertyNamed:key], "T{?=qiIq}") == 0) {
        CMTime cmTime;
        NSValue *value = [self valueForKey:key];
        [value getValue:&cmTime];
        return [NSString stringFromCMTime:cmTime];
    }
    
    //all properties those are conforms to NSSecrue Coding/NSCoding protocol
    return [super serializeValue: value forKey: key];
}

@end
