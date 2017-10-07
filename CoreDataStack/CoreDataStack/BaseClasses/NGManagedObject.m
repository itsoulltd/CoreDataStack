//
//  DyanaManagedObject.m
//  CoreDataTest
//
//  Created by Towhid Islam on 4/12/14.
//  Copyright (c) 2017 Next Generation Object Ltd. All rights reserved.
//

#import "NGManagedObject.h"
#import "CSExceptionLog.h"

@implementation NGManagedObject

- (instancetype)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context updateWithInfo:(NSDictionary *)info{
    
    if (self = [super initWithEntity:entity insertIntoManagedObjectContext:context]) {
        [self updateWithInfo:info];
    }
    
    return self;
}

+ (instancetype)insertIntoContext:(NSManagedObjectContext *)context withProperties:(NSDictionary *)properties{
    
    if (!context) {
        return nil;
    }
    
    NSString *entity = NSStringFromClass([self class]);
    
    Class encodeType = NSClassFromString(entity);
    if (![encodeType isSubclassOfClass:[NGManagedObject class]]) {
        return nil;
    }
    
    NGManagedObject *dObject = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:context];
    if (dObject) {
        [dObject updateWithInfo:properties];
    }
    return dObject;
}

- (void)updateWithInfo:(NSDictionary *)info{
    
    if (!info) {
        return;
    }
    //Using Obj-C Runtime
    for (id key in [info allKeys]) {
        
        if (![key isKindOfClass:[NSString class]]) {
            continue;
        }
        [self updateValue:[info objectForKey:key] forKey:key];
    }
}

- (void)updateValue:(id)value forKey:(NSString*)key{
    
    //check for NSNull or nil for key
    if ([key isKindOfClass:[NSNull class]] || nil == key) {
        return;
    }
    
    //check for NSNull or nil for value
    if ([value isKindOfClass:[NSNull class]] || nil == value) {
        return;
    }
    
    const char *propertyName = [(NSString*)key cStringUsingEncoding:NSUTF8StringEncoding];
    objc_property_t property = class_getProperty([self class], propertyName);
    Class encodeType = NSClassFromString([self property_getEncodeType:property]);
    
    if ([CSDebugLog isDebugModeOn])
        fprintf(stdout, "updateValue :: %s { %s }\n", propertyName, [NSStringFromClass(encodeType) cStringUsingEncoding:NSUTF8StringEncoding]);//logging
    
    if (property != NULL) {
        @try {
            if ([encodeType isSubclassOfClass:[NSDate class]]
                && [value isKindOfClass:[NSString class]]){
                
                //If property type is NSDate but value is string.
                //Then converted to NSDate
                if ([self respondsToSelector:@selector(updateDate:forKey:)]) {
                    NSDate *date = [self updateDate:value forKey:key];
                    [self setValue:date forKey:key];
                }else{
                    NSDate *date = [self updateDate:value];
                    [self setValue:date forKey:key];
                }
            }
            else{
                //@Now if property type and value type not matched then return.
                if (![value isKindOfClass:encodeType]) {
                    return;
                }
                [self setValue:value forKey:key];
            }
        }
        @catch (NSException *exception) {
            [CSExceptionLog message:[exception reason]];
        }
    }
}

- (NSDate *)updateDate:(NSString *)dateStr{
    return [NSDate date];
}

- (NSDate *)updateDate:(NSString *)dateStr forKey:(NSString*)key{
    return [self updateDate:dateStr];
}

- (NSString*) property_getEncodeType:(objc_property_t)property{
    
    NSString *encodeType = NSStringFromClass([NSObject class]);
    unsigned int count;
    objc_property_attribute_t *attributes = property_copyAttributeList(property, &count);
    if (count > 0) {
        objc_property_attribute_t attribute = attributes[0];
        encodeType = [NSString stringWithUTF8String:attribute.value];
        if ([encodeType hasPrefix:@"@\""] && [encodeType hasSuffix:@"\""] && encodeType.length > 2) {
            //at this moment we have got @"@"NSString"" type of thing.
            encodeType = [encodeType substringFromIndex:2];
            encodeType = [encodeType substringToIndex:encodeType.length-1];
        }
    }
    free(attributes);
    return encodeType;
}

- (instancetype)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context updateWithJSON:(NSData *)json{
    
    if (self = [super initWithEntity:entity insertIntoManagedObjectContext:context]) {
        [self updateWithJSON:json];
    }
    return self;
}

+ (instancetype)insertIntoContext:(NSManagedObjectContext *)context withJSON:(NSData *)json{
    
    if (!context) {
        return nil;
    }
    
    NSString *entity = NSStringFromClass([self class]);
    
    Class encodeType = NSClassFromString(entity);
    if (![encodeType isSubclassOfClass:[NGManagedObject class]]) {
        return nil;
    }
    
    NGManagedObject *dObject = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:context];
    
    if (dObject) {
        [dObject updateWithJSON:json];
    }
    
    return dObject;
}

- (void)updateWithJSON:(NSData *)json{
    
    //now update with Dictionary info.
    id info = [self serializeJson:json];
    [self updateWithInfo:info];
}

- (id) serializeJson:(NSData*)json{
    
    if (!json) {
        return nil;
    }
    
    NSError *error;
    id info = nil;
    
    @try {
        info = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableContainers error:&error];
    }
    @catch (NSException *exception) {
        [CSExceptionLog message:@"%@",[exception reason]];
    }
    
    if ( !info || ![info isKindOfClass:[NSDictionary class]] || error) {
        return nil;
    }
    
    return info;
}

- (NSData *)serializeIntoJSON{
    
    NSError *error;
    NSDictionary *info = [self serializeIntoInfo];
    NSData *data = nil;
    @try {
        data = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&error];
    }
    @catch (NSException *exception) {
        [CSExceptionLog message:@"%@",[exception reason]];
    }
    return [[NSData alloc] initWithData:data];
}

- (NSArray*) propertyList{
    
    NSMutableArray *properties = [NSMutableArray new];
    
    Class currentClass = [self class];
    
    do{
        //Using Objective-C runtime
        unsigned int count;
        objc_property_t *propertyList = class_copyPropertyList(currentClass, &count);
        
        for (int index = 0; index < count; index++) {
            
            objc_property_t property = propertyList[index];
            const char *propertyName = property_getName(property);
            NSString *key = [NSString stringWithUTF8String:propertyName];
            if ([CSDebugLog isDebugModeOn])
                fprintf(stdout, "Property Found :: %s { %s }\n", propertyName, property_getAttributes(property));//logging
            [properties addObject:key];
        }
        
        free(propertyList);
        currentClass = [currentClass superclass];
        
    }while ([currentClass superclass]);
    
    return properties;
}

- (BOOL) isIgnorantPropertie:(NSString*)key{
    
    /*
     debugDescription
     description
     hash
     superclass
     deleted
     entity
     fault
     faultingState
     hasChanges
     inserted
     managedObjectContext
     objectID
     updated
     */
    
    return [key isEqualToString:@"debugDescription"]
    || [key isEqualToString:@"description"]
    || [key isEqualToString:@"hash"]
    || [key isEqualToString:@"superclass"]
    || [key isEqualToString:@"deleted"]
    || [key isEqualToString:@"entity"]
    || [key isEqualToString:@"fault"]
    || [key isEqualToString:@"faultingState"]
    || [key isEqualToString:@"hasChanges"]
    || [key isEqualToString:@"inserted"]
    || [key isEqualToString:@"managedObjectContext"]
    || [key isEqualToString:@"objectID"]
    || [key isEqualToString:@"updated"];
}

- (NSDictionary *)serializeIntoInfo{
    
    NSMutableDictionary *newInfo = nil;
    NSArray *propertyList = [self propertyList];
    
    if (propertyList.count > 0) {
        newInfo = [[NSMutableDictionary alloc] initWithCapacity:propertyList.count];
    }
    
    for (int index = 0; index < propertyList.count; index++) {
        
        NSString *key = propertyList[index];
        if ([self isIgnorantPropertie:key]) {
            continue;
        }
        
        id value = [self serializeValue:[self valueForKey:key] forKey:key];
        if (value) [newInfo setValue:value forKey:key];
    }
    
    return newInfo;
}

- (id) serializeValue:(id)value forKey:(NSString*)key{
    
    id result = nil;
    
    if ([value isKindOfClass:[NGManagedObject class]]) {
        result = [(NGManagedObject*)value serializeIntoInfo];
    }
    else if ([value isKindOfClass:[NSDate class]]){
        //NSDate is not a valid JSON writable object.
        //SO converted to NSString
        if ([self respondsToSelector:@selector(serializeDate:forKey:)]) {
            result = [self serializeDate:value forKey:key];
        }else{
            result = [self serializeDate:value];
        }
    }
    else if ([value isKindOfClass:[NSData class]]){
        NSString *encoded = [(NSData*)value base64EncodedStringWithOptions:0];
        result = encoded;
    }
    else if ([value isKindOfClass:[NSString class]]
             || [value isKindOfClass:[NSNumber class]]
             || [value respondsToSelector:@selector(encodeWithCoder:)]){
        result = value;
    }
    else{
        [CSDebugLog message:@"Root Key : %@ of encode type :: %@ has failed to parse." ,key, NSStringFromClass([value class])];
        result = [NSNull null];
    }
    return result;
}

- (NSString *)serializeDate:(NSDate *)date{
    return [NSString stringWithFormat:@"%@",date];
}

- (NSString *)serializeDate:(NSDate *)date forKey :(NSString*)key{
    return [self serializeDate:date];
}

- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

@end
