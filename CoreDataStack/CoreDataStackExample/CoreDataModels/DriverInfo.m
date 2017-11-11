//
//  DriverInfo.m
//  CoreDataStackSample
//
//  Created by KITE GAMES STUDIO LTD on 12/18/16.
//  Copyright © 2016 KITE GAMES STUDIO LTD. All rights reserved.
//

#import "DriverInfo.h"

@interface DriverInfo ()

//these properties used in encoding or decoding primitive/sturct type data as they are not conforming to NSCoding/NSSecure Coding protocol
//we will enocode/decode primitive data types or struct through converting them into NSString/NSNumber.

@property (nonatomic, strong) NSString *strIDriverAge;
@property (nonatomic, strong) NSString *strFlDiverHeight;
@property (nonatomic) NSString *strRcBodySize;

@end

@implementation DriverInfo

//override this methods to decode primitive and structure data types
-(void) updateValue:(id)value forKey:(NSString *)key{
    
     //assinging nsstring/nsnumber to their primitive data form
    
    if ([key isEqualToString: @"iDriverAge"]) {
        self.iDriverAge = [(NSNumber*)value integerValue];
    }
    else if ([key isEqualToString:@"flDiverHeight"]){
        self.flDiverHeight = [(NSNumber* )value doubleValue];
        
    }
    else if ([key isEqualToString:@"rcBodySize"]){
        self.rcBodySize = CGSizeFromString((NSString*)value);
        
    }
    else{//all properties those are conforms to NSSecrue Coding/NSCoding protocol
        [super updateValue: value forKey: key];
    }
    
}

//override this methods to encode primitive and structure data types
-(id) serializeValue:(id)value forKey:(NSString *)key{
    
    // convert primitive data types to nsstring/nsnumber
    if([key isEqualToString: @"iDriverAge"]){
        
        return  [NSNumber numberWithInteger: self.iDriverAge];
    }
    else if ([key isEqualToString:@"flDiverHeight"]){
        
        return [NSNumber numberWithDouble: self.flDiverHeight];
    }
    else if ([key isEqualToString:@"rcBodySize"]){
        
        return NSStringFromCGSize(self.rcBodySize);
    }
    else{//all properties those are conforms to NSSecrue Coding/NSCoding protocol
        return [super serializeValue: value forKey: key];
    }
}

@end
