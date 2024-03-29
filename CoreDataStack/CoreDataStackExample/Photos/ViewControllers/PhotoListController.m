//
//  PhotoListController.m
//  CoreDataTest
//
//  Created by Towhid Islam on 1/25/14.
//  Copyright (c) 2014 Towhid Islam. All rights reserved.
//

#import "PhotoListController.h"
#import "PhotoCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Photo.h"
#import "PhotoGrapher.h"
#import "Address.h"

@interface PhotoListController ()
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSArray *names;
@property (nonatomic, strong) NSArray *places;
@property (nonatomic, strong) NSArray *titles;
- (IBAction)backgroundAction:(id)sender;
- (IBAction)deleteAction:(id)sender;
@end

@implementation PhotoListController

static NSString *CellIdentifier = @"cellId";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSArray *)titles{
    if (_titles == nil) {
        _titles = @[@"Mount Everest",@"Danger K2",@"Beautiful Anapurna"];
    }
    return _titles;
}

- (NSArray *)names{
    if (_names == nil) {
        _names = @[@"Josh",@"Bengamin",@"Sarah"];
    }
    return _names;
}

- (NSArray *)places{
    if (_places == nil) {
        _places = @[@"Everest",@"K2",@"Anapurna"];
    }
    return _places;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = NO;
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    //[self.tableView registerClass:[PhotoCell class] forCellReuseIdentifier:CellIdentifier];
    //[self.tableView registerNib:[UINib nibWithNibName:@"PhotoCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    [self loadDataFromStore];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(letsUpdateTableView:) name:NGDefaultManagedContextDidMergeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NGDefaultManagedContextDidMergeNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark private
//This function returns the indexPath for newly inserted rows in the table.
//If insertedPhotos is nil then lead from default context.

- (NSArray*) calculateInertionIndexPaths:(NSSet*)allInsertedIds{
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    NSMutableArray *insertedPhotos = [NSMutableArray new];
    NSManagedObjectContext *cContext = [[NGKeyedContext sharedInstance] contextForKey:@"CoreDataTest"];
    for (id item in allInsertedIds) {
        if ([item isKindOfClass:[NSManagedObjectID class]]) {
            NSManagedObjectID *objId = (NSManagedObjectID*)item;
            NSManagedObject *obj = [cContext existingObjectWithID:objId error:NULL];
            if ([obj isKindOfClass:[Photo class]]) {
                [insertedPhotos addObject:obj];
            }
        }
    }
    
    NSInteger lastIndex = self.photos.count;
    [self.photos addObjectsFromArray:insertedPhotos];
    for (NSInteger index = lastIndex; index < self.photos.count; index++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }
    return indexPaths;
}

- (NSArray*) calculateDeletionIndexPaths:(NSSet*)deletedPhotos{
    
    NSMutableArray *deletedIndexes = [NSMutableArray new];
    [self.photos removeAllObjects];
    for (NSInteger index = 0; index < deletedPhotos.count; index++) {
        [deletedIndexes addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }
    return deletedIndexes;
}


- (void) loadDataFromStore{
    
    if (!self.photos) {
        _photos = [[NSMutableArray alloc] init];
    }
    
    NSManagedObjectContext *context = [[NGKeyedContext sharedInstance] contextForKey:@"CoreDataTest"];
    
    /*NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context];
    NSError *error;
    NSArray *temps = [context executeFetchRequest:request error:&error];*/
    //Above lines replace by:
    NSArray *temps = [Photo read:nil context:context];
    
    [self.photos removeAllObjects];
    [self.photos addObjectsFromArray:temps];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (NSInteger index = 0; index < self.photos.count; index++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.photos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if ([cell isKindOfClass:[PhotoCell class]]) {
        Photo *photo = self.photos[indexPath.row];
        PhotoCell *pCell = (PhotoCell*)cell;
        [pCell updateCell:photo];
    }
    
    return cell;
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (IBAction)backgroundAction:(id)sender {
    NSLog(@"Dispatch To Background");
    /**
     * Calling -mergeContextForKey:fromContext: from main-queue will causes certain crash.
     * Background-context must be created in backgroud queue, using -cloneContextForKey: method.
     * After that merge that context with other context tracked by NGKeyedContext.
     */
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    dispatch_async(queue, ^{
        
        [NSThread sleepForTimeInterval:2.40];//2.40 sec pause, b/w insert and save&merge
       
        NSManagedObjectContext *backbgoundContext = [[NGKeyedContext sharedInstance] cloneContextForKey:@"CoreDataTest"];
        
        /*NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:chupaContext];
        NSInteger count = [chupaContext countForFetchRequest:request error:NULL];*/
        //Above liens replace by:
        NSUInteger count = [Photo rows:backbgoundContext];
        NSLog(@"Dispatch To Background : Eexecuted : %ld",(long)count);
        
        [self addObjectToStore:backbgoundContext];
        [[NGKeyedContext sharedInstance] mergeContextForKey:@"CoreDataTest" fromContext:backbgoundContext];
    });
    
}

- (IBAction)deleteAction:(id)sender {
    NSLog(@"Dispatch To Background Delete");
    /**
     * Calling -mergeContextForKey:fromContext: from main-queue will causes certain crash.
     * Background-context must be created in backgroud queue, using -cloneContextForKey: method.
     * After that merge that context with other context tracked by NGKeyedContext.
     */
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    dispatch_async(queue, ^{
        
        NSManagedObjectContext *backgroundContext = [[NGKeyedContext sharedInstance] cloneContextForKey:@"CoreDataTest"];
        
        NSUInteger count = [Photo rows:backgroundContext];
        NSLog(@"Dispatch To Background : Delete : %ld",(long)count);
        
        NSArray *items = [Photo read:nil context:backgroundContext];
        if (items && items.count > 0) {
            for (Photo *photo in items) {
                [backgroundContext deleteObject:photo];
            }
        }
        
        [[NGKeyedContext sharedInstance] mergeContextForKey:@"CoreDataTest" fromContext:backgroundContext];
    });
}

- (void) addObjectToStore:(NSManagedObjectContext*)_managedObjectContext{
    //Photo and PhotoGrapher 1
    NSLog(@"------------------------------------------------------------------------------------------");
    NSString *location = self.places[arc4random() % self.places.count];
    NSString *title = self.titles[arc4random() % self.titles.count];
    
    Photo *photo = [Photo insertIntoContext:_managedObjectContext withProperties:@{@"location":location
                                                                                   ,@"title":title
                                                                                   ,@"photoId":[NSUUID UUID].UUIDString
                                                                                   ,@"datetimeAtTook":[NSDate date]}];
    
    NSString *pgname = self.names[arc4random() % self.names.count];
    PhotoGrapher *pGrapher = [PhotoGrapher findByName:pgname context:_managedObjectContext];
    if (pGrapher == nil) {
        pGrapher = [PhotoGrapher insertIntoContext:_managedObjectContext withProperties:@{@"name":pgname,@"age":@32}];
    }
    [pGrapher addPhotosObject:photo];
    Address *photographerAdd = [Address insertIntoContext:_managedObjectContext withProperties:@{@"street":@"---",@"city":@"---"}];
    [pGrapher addAddressesObject:photographerAdd];
    NSLog(@"--------------------------------------------------------------------------------------------");
    
    //Photo and PhotoGrapher 2
    NSLog(@"--------------------------------------------------------------------------------------------");
    NSData *jsonData = [photo serializeIntoJSON];
    NSLog(@"JSON encoded string %@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    NSLog(@"Recreate NSDictionary from JSON Data : %@",[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:NULL]);
    
    NSLog(@"--------------------------------------------------------------------------------------------");
    Photo *newPhoto = [Photo insertIntoContext:_managedObjectContext withJSON:jsonData];
    title = self.titles[arc4random() % self.titles.count];
    [newPhoto write:@{@"title":title
                      ,@"photoId":[NSUUID UUID].UUIDString
                      ,@"datetimeAtTook":[NSDate date]
                      }];
    NSLog(@"%@",[newPhoto serializeIntoInfo]);
    NSString *pgname2 = self.names[arc4random() % self.names.count];
    PhotoGrapher *pGrapher2 = [PhotoGrapher findByName:pgname2 context:_managedObjectContext];
    if (pGrapher2 == nil) {
        pGrapher2 = [PhotoGrapher insertIntoContext:_managedObjectContext withProperties:@{@"name":pgname2,@"age":@32}];
    }
    [pGrapher2 addPhotosObject:newPhoto];
    
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

- (void) letsUpdateTableView:(NSNotification*)notification{
    
    //Test If this is calling on main thread or not.
    NSLog(@"current execution queue :: %s",dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL));
    //Don't pass the ManagedObjects across thread boundaries.
    //NSLog(@"%@",notification.userInfo);
    //
    
    //When Inserted
    NSSet *allInserted = [notification.userInfo objectForKey:kInsertedIDs];
    if (allInserted && allInserted.count > 0) {
        
        NSArray *insertIndex = [self calculateInertionIndexPaths:allInserted];//this will call on main thread, and its safe :)
        if (insertIndex.count > 0) {
            [self.tableView insertRowsAtIndexPaths:insertIndex withRowAnimation:UITableViewRowAnimationTop];
        }
    }
    
    //when deleted
    NSSet *deleted = [notification.userInfo objectForKey:kDeletedIDs];
    if (deleted && deleted.count > 0) {
        NSArray *deletedIndexes = [self calculateDeletionIndexPaths:deleted];
        if (deletedIndexes.count > 0) {
            [self.tableView deleteRowsAtIndexPaths:deletedIndexes withRowAnimation:UITableViewRowAnimationTop];
        }
    }
}

@end
