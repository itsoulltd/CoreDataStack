//
//  CSExceptionLog.m
//  RequestSynchronizer
//
//  Created by Towhid Islam on 8/25/14.
//  Copyright (c) 2017 Next Generation Object Ltd. All rights reserved.
//

#import "CSExceptionLog.h"
#import "CSLogTracker.h"

@implementation CSExceptionLog

static BOOL DEBUG_MODE_ON = YES;
static BOOL TRACKING_MODE_ON = NO;

+ (CSLogTracker*) getExceptionTracker{
    
    static CSLogTracker *_tracker2 = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tracker2 = [[CSLogTracker alloc] initWithPersistenceFileName:@"__log_manager__exception"];
    });
    return _tracker2;
}

+ (void)message:(NSString *)format, ...{
    
    @try {
        va_list args;
        va_start(args, format);
        NSString *fLog = [[NSString alloc] initWithFormat:format arguments:args];
        if (TRACKING_MODE_ON) [[CSExceptionLog getExceptionTracker] addToLogBook:fLog];
        if (DEBUG_MODE_ON) NSLog(@"%@",fLog);
    }
    @catch (NSException *exception) {
        NSLog(@"CSExceptionLog %@",[exception reason]);
    }
}

+ (void)message:(NSString *)format args:(va_list)args{
    
    @try {
        NSString *fLog = [[NSString alloc] initWithFormat:format arguments:args];
        if (TRACKING_MODE_ON) [[CSExceptionLog getExceptionTracker] addToLogBook:fLog];
        if (DEBUG_MODE_ON) NSLog(@"%@",fLog);
    }
    @catch (NSException *exception) {
        NSLog(@"Debug %@",[exception reason]);
    }
}

+ (void)save{
    
    [[CSExceptionLog getExceptionTracker] save];
}

+ (void)printSavedLog{
    
    if (DEBUG_MODE_ON) {
        [[CSExceptionLog getExceptionTracker] printSavedLog];
    }
}

//+ (void)sendFeedbackTo:(DNFileUploadRequest *)binary{
//    
//    [[CSExceptionLog getExceptionTracker] sendFeedbackTo:binary];
//}

@end
