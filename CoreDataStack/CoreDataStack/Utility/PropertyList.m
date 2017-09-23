//
//  CollectionPersistManager.m
//  ContrinerViewSample
//
//  Created by m.towhid.islam@gmail.com on 4/1/14.
//  Copyright (c) 2017 Next Generation Object Ltd. All rights reserved.
//

#import "PropertyList.h"
#import "CSDebugLog.h"

@interface PropertyList ()
@property (nonatomic, strong) id mutableCollection;
@property (nonatomic) BOOL isDictionary;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic) NSSearchPathDirectory directoryType;
@end

@implementation PropertyList
@synthesize mutableCollection = _mutableCollection;
@synthesize fileName = _fileName;
@synthesize directoryType = _directoryType;

- (instancetype)initWithFileName:(NSString *)fileName directoryType:(NSSearchPathDirectory)directory dictionary:(BOOL)isDictionary{
    
    if (self = [super init]) {
        self.fileName = [self validateFileName:fileName];
        self.directoryType = directory;
        NSURL *fileUrl = [self pathUrlForFileName:self.fileName directoryType:directory];
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:[fileUrl path]]) {
            
            [self loadFromUrl:fileUrl];
        }else{
            
            NSString *fileNameX = [self.fileName stringByDeletingPathExtension];
            NSString *fileExtention = @"plist";
            NSURL *bundelFilePath = [[NSBundle mainBundle] URLForResource:fileNameX withExtension:fileExtention];
            if (bundelFilePath) {
                [self loadFromUrl:bundelFilePath];
            }else {
                [self loadDefault:fileUrl isDictionary:isDictionary];
            }
        }
    }
    
    return self;
}

- (void)dealloc{
    NSLog(@"dealloc %@",NSStringFromClass([self class]));
}

- (NSString*) validateFileName:(NSString*)fileName{
    
    return [fileName hasSuffix:@".plist"] ? fileName : [NSString stringWithFormat:@"%@.plist",fileName];
}

- (void) loadFromUrl:(NSURL*)fileUrl{
    
    NSData *data = [NSData dataWithContentsOfURL:fileUrl];
    id plist = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainers format:NULL error:NULL];
    self.mutableCollection = plist;
    if ([plist isKindOfClass:[NSArray class]]) {
        self.isDictionary = NO;
    }
    else{
        self.isDictionary = YES;
    }
    if (self.mutableCollection) [CSDebugLog message:@"Successfully readed from fileSystem as %@",(self.isDictionary)?@"mutableDictionary":@"mutableArray"];
}

- (void) loadDefault:(NSURL*)fileUrl isDictionary:(BOOL)isDictionary{
    
    if (isDictionary) {
        self.isDictionary = isDictionary;
        self.mutableCollection = [[NSMutableDictionary alloc] init];
        if ([(NSMutableDictionary*)self.mutableCollection writeToURL:fileUrl atomically:YES]) {
            [CSDebugLog message:@"Successfully Written to fileSystem as mutableDictionary"];
        }
    }else{
        self.isDictionary = isDictionary;
        self.mutableCollection = [[NSMutableArray alloc] init];
        if ([(NSMutableArray*)self.mutableCollection writeToURL:fileUrl atomically:YES]) {
            [CSDebugLog message:@"Successfully Written to fileSystem as mutableArray"];
        }
    }
}

- (NSURL*) pathUrlForFileName:(NSString*)fileName directoryType:(NSSearchPathDirectory)directory{
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *paths = [manager URLsForDirectory:directory inDomains:NSUserDomainMask];
    return [[paths lastObject] URLByAppendingPathComponent:fileName];
}

- (NSString*) pathForFileName:(NSString*)fileName directoryType:(NSSearchPathDirectory)directory{
    
    NSURL *pathUrl = [self pathUrlForFileName:fileName directoryType:directory];
    return [pathUrl path];
}

- (NSURL *)storageLocation{
    
    return [self pathUrlForFileName:self.fileName directoryType:self.directoryType];
}

- (BOOL)save{
    
    BOOL result = NO;
    NSURL *fileUrl = [self pathUrlForFileName:self.fileName directoryType:self.directoryType];
    id collection = [self readOnlyCollection];
    if (fileUrl) {
        if (!self.isDictionary) {
            result = [(NSMutableArray*)collection writeToURL:fileUrl atomically:YES];
        }else{
            result = [(NSMutableDictionary*)collection writeToURL:fileUrl atomically:YES];
        }
    }
    return result;
}

- (void)saveBackground{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if ([self save]) {
            [CSDebugLog message:@"Successfully written to fileSystem in background"];
        }
    });
}

- (id)readOnlyCollection{
    id items = (!self.isDictionary) ? [NSArray arrayWithArray:self.mutableCollection] : [NSDictionary dictionaryWithDictionary:self.mutableCollection];
    return items;
}

- (void)addItemToCollection:(id)item{
    
    if (!self.isDictionary) {
        [(NSMutableArray*)self.mutableCollection addObject:item];
    }else{
        if ([item isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary*)item;
            for (id key in [dic allKeys]) {
                [self addItemToCollection:[dic objectForKey:key] forKey:key];
            }
        }
    }
}

- (void)addItemsToCollection:(NSArray *)items{
    
    if (!self.isDictionary) {
        [(NSMutableArray*)self.mutableCollection addObjectsFromArray:items];
    }
}

- (void)addItemToCollection:(id)item forKey:(id<NSCopying>)key{
    
    if (self.isDictionary) {
        
        if(!key) {[self addItemToCollection:item]; return;}
        [(NSMutableDictionary*)self.mutableCollection setObject:item forKey:key];
    }else{
        [self addItemToCollection:item];
    }
}

- (void)removeItemFromCollection:(id)item{
    
    if (!self.isDictionary) {
        NSInteger index = [(NSMutableArray*)self.mutableCollection indexOfObjectIdenticalTo:item];
        if (index != NSNotFound) {
            [(NSMutableArray*)self.mutableCollection removeObjectAtIndex:index];
        }
    }
}

- (void)removeItemsFromCollection:(NSArray *)items{
    
    if (!self.isDictionary) {
        for (id item in items) {
            [self removeItemFromCollection:item];
        }
    }
}

- (void)removeItemFromCollectionForKey:(id<NSCopying>)key{
    
    if (self.isDictionary) {
        [(NSMutableDictionary*)self.mutableCollection removeObjectForKey:key];
    }
}

- (void)removeItemsFromCollectionForKeys:(NSArray *)keys{
    
    if (self.isDictionary) {
        [(NSMutableDictionary*)self.mutableCollection removeObjectsForKeys:keys];
    }
}

- (id)itemAtIndex:(NSInteger)index{
    
    if (self.isDictionary) {
        return nil;
    }
    
    return (index < [(NSMutableArray*)self.mutableCollection count]) ?[self.mutableCollection objectAtIndex:index] : nil;
}

- (id)itemForKey:(id<NSCopying>)key{
    
    if (!self.isDictionary) {
        return nil;
    }
    
    return [(NSMutableDictionary*)self.mutableCollection objectForKey:key];
}

@end
