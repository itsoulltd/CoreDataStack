//
//  CoreDataContextManager.m
//  CoreDataTest
//
//  Created by Towhid Islam on 1/25/14.
//  Copyright (c) 2017 Next Generation Object Ltd. All rights reserved.
//

#import "NGCoreDataContext.h"

@interface NGCoreDataContext ()
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSString *defaultModelFileName;
@end

@implementation NGCoreDataContext
@synthesize context = _context;

+ (instancetype)sharedInstance{
    
    static NGCoreDataContext *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NGCoreDataContext alloc] init];
    });
    return sharedInstance;
}

- (id)init{
    
    if (self = [super init]) {
        NSBundle *mainBundel = [NSBundle mainBundle];
        NSArray *array = [mainBundel pathsForResourcesOfType:@"momd" inDirectory:nil];
        NSString *fileName = [[array lastObject] lastPathComponent];
        fileName = [fileName stringByReplacingOccurrencesOfString:@".momd" withString:@""];
        _defaultModelFileName = fileName;
        _context = [self createFromDataModelFileName:fileName];
    }
    return self;
}

- (void)dealloc{
    NSLog(@"dealloc %@",NSStringFromClass([self class]));
}

- (NSManagedObjectContext*) defaultContext{
    
    return self.context;
}

- (NSManagedObjectContext *)cloneDefaultContext{
    
    if (!self.context) {
        return nil;
    }
    
    NSManagedObjectContext *clone = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [clone setPersistentStoreCoordinator:[self.context persistentStoreCoordinator]];
    return clone;
}

-(NSManagedObjectContext*) createFromDataModelFileName:(NSString*)name{
    
    if (!name) {
        return nil;
    }
    
    //Create ManagedObjectModel
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:name ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    //Create PersistanceStorage
    NSString *storeName = [name stringByAppendingPathExtension:@"sqlite"];
    NSString *fPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *storeURL = [NSURL fileURLWithPath: [fPath stringByAppendingPathComponent: storeName]];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             nil];
    NSError *error = nil;
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                                                initWithManagedObjectModel:managedObjectModel];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:storeURL
                                                        options:options
                                                          error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    //Create Context
    NSManagedObjectContext *managedObjectContext_ = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [managedObjectContext_ setPersistentStoreCoordinator:persistentStoreCoordinator];
    
    return managedObjectContext_;
}

- (void)saveDefaultContext{
    [self saveContext:self.context];
}

- (void)saveContext:(NSManagedObjectContext*)context{
    
    if (!context) {
        return;
    }
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = context;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

/**
 *There are two possible ways to adopt Thread confinement Pattern:
 
 ->Create a separate managed object context for each thread and share a single persistent store coordinator.
 This is the typically-recommended approach.
 
 ->Create a separate managed object context and persistent store coordinator for each thread.
 This approach provides for greater concurrency at the expense of greater complexity (particularly if you need to communicate changes between different contexts) and increased memory usage.
 *
 */
/** Sharing single persistent store coordinator with multiple MOC
 * Although the NSPersistentStoreCoordinator is not thread safe either,
 * the NSManagedObjectContext knows how to lock it properly when in use.
 * Therefore, we can attach as many NSManagedObjectContext objects to
 * a single NSPersistentStoreCoordinator as we want without fear of collision.
 */
/*Rule Of Thumb :: Don't pass the ManagedObjects across the thread boundaries. NSManagedObjects are not thread safe.
 *But NSManagedObjectId is thread safe, so these can be passes arround threads.
 */

- (void)mergeDefaultContextFromContext:(NSManagedObjectContext *)context{
    
    //Test If this is calling on main thread or not.
    NSLog(@"mergeDefaultContextFromContext execution queue :: %s",dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL));
    //
    
    if (!self.context || !context) {
        return;
    }
    
    if (context == self.context) {
        NSLog(@"Both are same no need to merge");
        return;
    }
    
    //Go for save and marge
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:context];
    
    NSError *error;
    if (![context save:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //remove observer from notification center;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];
        abort();
    }
}

NSString* const KGDefaultManagedContextDidMergeNotification = @"AppDefaultContextDidMergeNotification";

- (void)contextDidSave:(NSNotification*)notification {
    
    //Test If this is calling on main thread or not.
    NSLog(@"contextDidSave execution queue :: %s",dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL));
    //
    
    NSManagedObjectContext *context = self.context;
    NSManagedObjectContext *savedContext = (NSManagedObjectContext*)notification.object;
    
    if (context == savedContext) {
        return; //means saved context was the default context
    }
    
    if (context.persistentStoreCoordinator != savedContext.persistentStoreCoordinator) {
        return; //means other DB
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
        [[NSNotificationCenter defaultCenter] postNotificationName:KGDefaultManagedContextDidMergeNotification object:nil userInfo:userInfo];
    });
}

@end
