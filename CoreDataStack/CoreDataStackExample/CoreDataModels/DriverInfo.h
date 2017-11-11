//
//  DriverInfo.h
//  CoreDataStackSample
//
//  Created by KITE GAMES STUDIO LTD on 12/18/16.
//  Copyright © 2016 KITE GAMES STUDIO LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreDataStack/CoreDataStack.h>
@interface DriverInfo : NGObject

//these properties will store into coredata storage

@property (nonatomic,strong) NSString *strDriverName;
@property (nonatomic) NSInteger iDriverAge;
@property (nonatomic) CGFloat flDiverHeight;
@property (nonatomic) CGSize rcBodySize;
@property (nonatomic, strong) UIColor *hairColor;

@end
