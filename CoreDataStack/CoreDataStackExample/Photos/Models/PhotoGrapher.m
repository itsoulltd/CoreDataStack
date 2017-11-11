//
//  PhotoGrapher.m
//  CoreDataTest
//
//  Created by Towhid Islam on 4/13/14.
//  Copyright (c) 2014 Towhid Islam. All rights reserved.
//

#import "PhotoGrapher.h"
#import "Address.h"
#import "Photo.h"

@implementation PhotoGrapher

@dynamic name;
@dynamic age;
@dynamic contactNo;
@dynamic dateOfBirth;
@dynamic photos;
@dynamic addresses;

+ (PhotoGrapher *)findByName:(NSString *)name context:(NSManagedObjectContext*)context{
    NSArray<PhotoGrapher*> *graphers = [PhotoGrapher read:@{@"name":name} context:context];
    return graphers.firstObject;
}

- (void)addAddressesObject:(Address *)value{
    value.whoLive = self;
    if (!self.addresses) {
        NSSet *addresss = [[NSSet alloc] initWithObjects:value, nil];
        self.addresses = addresss;
    }
    else{
        NSMutableSet *addresss = [[NSMutableSet alloc] initWithSet:self.addresses];
        [addresss addObject:value];
        self.addresses = addresss;
    }
}

- (void)addPhotosObject:(Photo *)value{
    value.whoTook = self;
    if (!self.photos) {
        NSOrderedSet *photos = [[NSOrderedSet alloc] initWithObject:value];
        self.photos = photos;
    }
    else{
        NSMutableOrderedSet *photos = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.photos];
        [photos addObject:value];
        self.photos = photos;
    }
}

@end
