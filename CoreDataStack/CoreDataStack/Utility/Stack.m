//
//  StackArray.m
//  ArrayUtilSample
//
//  Created by m.towhid.islam@gmail.com on 3/27/14.
//  Copyright (c) 2014 Towhid Islam. All rights reserved.
//

#import "Stack.h"

@interface Stack (){
    NSInteger __index;
}
@property (nonatomic, strong) NSMutableArray *stack;
@end

@implementation Stack
@synthesize stack = _stack;

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init]) {
        NSArray *uncoded = [aDecoder decodeObjectForKey:@"stack"];
        self.stack = [[NSMutableArray alloc] initWithArray:uncoded];
        __index = [aDecoder decodeIntegerForKey:@"index"];
    }
    return self;
}

- (void)dealloc{
    NSLog(@"dealloc %@",NSStringFromClass([self class]));
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.stack forKey:@"stack"];
    [aCoder encodeInteger:__index forKey:@"index"];
}

- (id)copyWithZone:(NSZone *)zone{
    
    Stack *copy = [[Stack alloc] init];
    if (copy) {
        copy.stack = [self.stack copyWithZone:zone];
        copy->__index = __index;
    }
    return copy;
}

- (NSMutableArray *)stack{
    
    if (!_stack) {
        __index = 0;
        _stack = [[NSMutableArray alloc] init];
    }
    
    return _stack;
}

/*- (void) push:(id)item{
    
    if (!item || (NSNull*)item == [NSNull null]) {
        return;
    }
    
    [self.stack insertObject:item atIndex:__index];
}

- (id) pop{
    
    if (self.stack.count <= __index) {
        return nil;
    }
    
    id item = [self.stack objectAtIndex:__index];
    [self.stack removeObjectAtIndex:__index];
    
    return item;
}*/

- (void) push:(id)item{
    //
    if (!item || (NSNull*)item == [NSNull null]) {
        return;
    }
    
    [self.stack addObject:item];
}

- (id) pop{
    //
    id item = [self.stack lastObject];
    if (item) {
        [self.stack removeLastObject];
    }
    return item;
}

- (BOOL)isEmpty{
    return self.stack.count == 0 ? YES : NO;
}

- (void) printStack{
    
    NSLog(@"%@",self.stack);
}

@end
