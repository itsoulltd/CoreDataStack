//
//  Queue.m
//  RequestSynchronizer
//
//  Created by m.towhid.islam@gmail.com on 4/15/14.
//  Copyright (c) 2014 Towhid Islam. All rights reserved.
//

#import "Queue.h"

@interface Queue (){
    NSInteger __index;
}
@property (nonatomic, strong) NSMutableArray *queue;
@end

@implementation Queue
@synthesize queue = _queue;

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init]) {
        NSArray *uncoded = [aDecoder decodeObjectForKey:@"queue"];
        self.queue = [[NSMutableArray alloc] initWithArray:uncoded];
        __index = [aDecoder decodeIntegerForKey:@"index"];
    }
    return self;
}

- (void)dealloc{
    NSLog(@"dealloc %@",NSStringFromClass([self class]));
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.queue forKey:@"queue"];
    [aCoder encodeInteger:__index forKey:@"index"];
}

- (id)copyWithZone:(NSZone *)zone{
    
    Queue *copy = [[Queue alloc] init];
    if (copy) {
        copy.queue = [self.queue copyWithZone:zone];
        copy->__index = __index;
    }
    return copy;
}

- (NSMutableArray *)queue{
    
    if (!_queue) {
        __index = 0;
        _queue = [[NSMutableArray alloc] init];
    }
    
    return _queue;
}

- (void)enqueue:(id)item{
    
    if (!item || (NSNull*)item == [NSNull null]) {
        return;
    }
    [self.queue addObject:item];
}

- (id)dequeue{
    
    if (self.queue.count <= __index) {
        return nil;
    }
    
    id item = [self.queue objectAtIndex:__index];
    [self.queue removeObjectAtIndex:__index];
    
    return item;
}

- (BOOL)isEmpty{
    return self.queue.count == 0 ? YES : NO;
}

- (void)printQueue{
    NSLog(@"%@",self.queue);
}

@end
