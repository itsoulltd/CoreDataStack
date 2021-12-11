# CoreDataStack
### How to initialize a core-data-context using CoreDataStack
	
	//Lets say you have a core-data model named: CoreDataTest.xcdatamodeld file
	//where usually all models are laied down.
	//Using CoreDataStack that's like this:
	NSManagedObjectContext *context = [[NGKeyedContext sharedInstance] contextForKey:@"CoreDataTest"];
	
	//Now we have an context, so how do we read rows from the context of an perticular Entity named: Photo.h
	//Write just this:
	NSArray *temps = [Photo read:nil context:context];
	
	//Insted of doing this: (Too much boilerplate code need to write for a simple work)
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context];
    NSError *error;
    NSArray *temps = [context executeFetchRequest:request error:&error];
    //
    
    //Insert New Photo object into context: using methods form NGManagedObjectProtocol
    //we have 2 verient: using NSDictionary or NSData
    //e.g. -insertIntoContext:(NSManagedObjectContext) withProperties:(NSDictionary)
    // or  -insertIntoContext:(NSManagedObjectContext) withJSON:(NSData*)
    
    //On success of insertion new object will return
    Photo *photo = [Photo insertIntoContext:context 
                          withProperties:@{@"location":location
                                          ,@"title":@"Mount Everest"
                                          ,@"photoId":[NSUUID UUID].UUIDString
                                          ,@"datetimeAtTook":[NSDate date]}];
    
    //We know update/delete relatively easy using context.
    
    //For updating..
    //first find the Object, using -read:(NSDictionary) context:(NSManagedContext) api:
    //where we can provide search criteria for an object: e.g. finding photo by title = @"photo-title"
    //
    NSArray* photos = [Photo read:@{@"title":@"Mount Everest"} context:context];
    Photo *photoToUpdate = photos[0];
    //..update
    [context save:nil];
    
    //For Deleting..
    [context deleteObject: photoToUpdate];
    
###How deal with multiple context .e.g one context for main-thread others are for background thread
    
    /**
     * Calling -mergeContextForKey:fromContext: from main-queue will causes certain crash.
     * Background-context must be created in backgroud queue, using -cloneContextForKey: method.
     * After that merge that context with other context tracked by NGKeyedContext.
     */
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        NSManagedObjectContext *bgContext = [[NGKeyedContext sharedInstance] cloneContextForKey:@"CoreDataTest"];
        //Writing new entity into the background context:
        NSUInteger count = [Photo rows:backbgoundContext];
        NSLog(@"RowCount : %ld",(long)count);
        // -insertIntoContext:withProperties will insert a new Photo instance into the context and
        //return the newly created onject.
        Photo *photo = [Photo insertIntoContext:bgContext
                                withProperties:@{@"location":location
                                               ,@"title":@"K2 peak"
                                               ,@"photoId":[NSUUID UUID].UUIDString
                                               ,@"datetimeAtTook":[NSDate date]}];
        assert(photo);
        //Finally merge the current change with other context:
        [[NGKeyedContext sharedInstance] mergeContextForKey:@"CoreDataTest" fromContext:backbgoundContext];
    });
