//
//  MultiDataContextManager.m
//  RequestSynchronizer
//
//  Created by Towhid Islam on 7/18/14.
//  Copyright (c) 2017 Next Generation Object Ltd. All rights reserved.
//

#import "NGKeyedContext.h"

@interface NGKeyedContext ()
@property (nonatomic, strong) NSMutableDictionary *contextContainer;
@end

@implementation NGKeyedContext

- (NSMutableDictionary *)contextContainer{
    
    if (!_contextContainer) {
        _contextContainer = [NSMutableDictionary new];
    }
    return _contextContainer;
}

- (id)init{
    
    if (self = [super init]) {
        NSBundle *mainBundel = [NSBundle mainBundle];
        NSArray *array = [mainBundel pathsForResourcesOfType:@"momd" inDirectory:nil];
        for (NSInteger index = 0; index < array.count; index++) {
            NSString *fileName = [array[index] lastPathComponent];
            fileName = [fileName stringByReplacingOccurrencesOfString:@".momd" withString:@""];
            if (![fileName isEqualToString:self.defaultModelFileName]) {
                NSManagedObjectContext *context = [self createFromDataModelFileName:fileName];
                if (context) [self.contextContainer setObject:context forKey:fileName];
            }else{
                if (self.context) [self.contextContainer setObject:self.context forKey:self.defaultModelFileName];
            }
        }
    }
    return self;
}

- (void)dealloc{
    NSLog(@"dealloc %@",NSStringFromClass([self class]));
}

+ (instancetype) sharedInstance{
    
    static NGKeyedContext *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NGKeyedContext alloc] init];
    });
    return sharedInstance;
}

- (NSManagedObjectContext*) contextForKey:(NSString*)key{
    
    return [self.contextContainer objectForKey:key];
}

- (NSManagedObjectContext*) cloneContextForKey:(NSString*)key{
    
    NSManagedObjectContext *context = [self contextForKey:key];
    if (!context) {
        return nil;
    }
    
    NSManagedObjectContext *clone = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [clone setPersistentStoreCoordinator:[context persistentStoreCoordinator]];
    return clone;
}

- (void)saveContextForKey:(NSString*)key{
    
    NSManagedObjectContext *context = [self contextForKey:key];
    if (!context) {
        return;
    }
    
    [self saveContext:context];
}

- (void)mergeContextForKey:(NSString*)key fromContext:(NSManagedObjectContext*)context{
    
    
    //Test If this is calling on main thread or not.
    NSLog(@"mergeDefaultContextFromContext execution queue :: %s",dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL));
    //
    
    NSManagedObjectContext *xcontext = [self contextForKey:key];
    if (!xcontext) {
        return;
    }
    
    if (!xcontext || !context) {
        return;
    }
    
    if (context == xcontext) {
        NSLog(@"Both are same no need to merge");
        return;
    }
    
    //Go for save and marge
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(multiContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:context];
    
    NSError *error;
    if (![context save:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //remove observer from notification center;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];
        abort();
    }
}

- (NSManagedObjectContext*)contextPairWith:(NSManagedObjectContext*)pairContext{
    
    NSArray *allKeys = [self.contextContainer allKeys];
    NSManagedObjectContext *matchedContext = nil;
    
    for (NSString *key in allKeys) {
        matchedContext = [self.contextContainer objectForKey:key];
        if (matchedContext.persistentStoreCoordinator == pairContext.persistentStoreCoordinator) {
            break;
        }
    }
    
    return matchedContext;
}

- (void)multiContextDidSave:(NSNotification*)notification {
    
    //Test If this is calling on main thread or not.
    NSLog(@"contextDidSave execution queue :: %s",dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL));
    //
    
    NSManagedObjectContext *savedContext = (NSManagedObjectContext*)notification.object;
    NSManagedObjectContext *context = [self contextPairWith:savedContext];
    
    if (context == savedContext) {
        return; //means saved context was the default context
    }
    
    // Merging changes causes the fetched results controller to update its results
    dispatch_sync(dispatch_get_main_queue(), ^{
        [context mergeChangesFromContextDidSaveNotification:notification];
    });
    
    //remove observer from notification center;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:savedContext];
    
    //NOW NOTIFY ALL LISTENERS WHO WAITING FOR MERGING
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    //When Inserted
    NSSet *inserted = [notification.userInfo objectForKey:@"inserted"];
    if (inserted && inserted.count > 0) {
        NSMutableSet *allIds = [NSMutableSet new];
        for (NSManagedObject *obj in inserted) {
            [allIds addObject:[obj objectID]];
        }
        [userInfo setObject:allIds forKey:kInsertedIDs];
    }
    //when Updated
    NSSet *updated = [notification.userInfo objectForKey:@"updated"];
    if (updated && updated.count > 0) {
        NSMutableSet *allIds = [NSMutableSet new];
        for (NSManagedObject *obj in updated) {
            [allIds addObject:[obj objectID]];
        }
        [userInfo setObject:allIds forKey:kUpdatedIDs];
    }
    //when Deleted
    NSSet *deleted = [notification.userInfo objectForKey:@"deleted"];
    if (deleted && deleted.count > 0) {
        NSMutableSet *allIds = [NSMutableSet new];
        for (NSManagedObject *obj in deleted) {
            [allIds addObject:[obj objectID]];
        }
        [userInfo setObject:allIds forKey:kDeletedIDs];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NGDefaultManagedContextDidMergeNotification object:nil userInfo:userInfo];
    });
}

@end
