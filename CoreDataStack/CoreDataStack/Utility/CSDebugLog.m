//
//  Debug.m
//  RequestSynchronizer
//
//  Created by Towhid Islam on 7/27/14.
//  Copyright (c) 2017 Next Generation Object Ltd. All rights reserved.
//

#import "CSDebugLog.h"
#import "CSLogTracker.h"

@implementation CSDebugLog

static BOOL DEBUG_MODE_ON = YES;
static BOOL TRACKING_MODE_ON = NO;

+ (CSLogTracker*) getTracker{
    
    static CSLogTracker *_tracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tracker = [[CSLogTracker alloc] initWithPersistenceFileName:@"__log_manager__data"];
    });
    return _tracker;
}

+ (BOOL)isDebugModeOn{
    return DEBUG_MODE_ON;
}

+ (void)setDebugModeOn:(BOOL)on{
    DEBUG_MODE_ON = on;
}

+ (void)setTrackingModeOn:(BOOL)on{
    TRACKING_MODE_ON = on;
}

+ (void)message:(NSString *)format, ...{
    
    @try {
        va_list args;
        va_start(args, format);
        NSString *fLog = [[NSString alloc] initWithFormat:format arguments:args];
        if (TRACKING_MODE_ON) [[CSDebugLog getTracker] addToLogBook:fLog];
        if (DEBUG_MODE_ON) NSLog(@"%@",fLog);
    }
    @catch (NSException *exception) {
        NSLog(@"Debug %@",[exception reason]);
    }
}

+ (void)message:(NSString *)format args:(va_list)args{
    
    @try {
        NSString *fLog = [[NSString alloc] initWithFormat:format arguments:args];
        if (TRACKING_MODE_ON) [[CSDebugLog getTracker] addToLogBook:fLog];
        if (DEBUG_MODE_ON) NSLog(@"%@",fLog);
    }
    @catch (NSException *exception) {
        NSLog(@"Debug %@",[exception reason]);
    }
}

+ (void)save{
    
    [[CSDebugLog getTracker] save];
}

+ (void)printSavedLog{
    
    if (DEBUG_MODE_ON) {
        [[CSDebugLog getTracker] printSavedLog];
    }
}

//+ (void)sendFeedbackTo:(DNFileUploadRequest *)binary{
//    
//    [[CSDebugLog getTracker] sendFeedbackTo:binary];
//}

@end
