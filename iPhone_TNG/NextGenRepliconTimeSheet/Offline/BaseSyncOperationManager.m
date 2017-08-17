//
//  BaseSyncOperationManager.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 12/4/15.
//  Copyright © 2015 Replicon. All rights reserved.
//

#import "BaseSyncOperationManager.h"
#import "FrameworkImport.h"
#import "TimesheetSyncOperationManager.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "TimerProvider.h"

@interface BaseSyncOperationManager ()

@property (nonatomic) NSTimer *startOfflineSyncingTimer;
@property (nonatomic) TimesheetSyncOperationManager *timesheetSyncOperationManager;
@property (nonatomic, weak) id<BSInjector> injector;
@property (nonatomic) TimerProvider *timerProvider;
@property (nonatomic) NSBlockOperation *blockOperation;
@end

@implementation BaseSyncOperationManager


- (instancetype)initWithTimesheetSyncOperationManager:(TimesheetSyncOperationManager *)timesheetSyncOperationManager timerProvider:(TimerProvider *)timerProvider
{
    self = [super init];
    if (self)
    {
        self.timesheetSyncOperationManager = timesheetSyncOperationManager;
        self.timerProvider = timerProvider;
    }

    return self;
}

-(void)startSync
{

    if ([NetworkMonitor isNetworkAvailableForListener:self] == YES)
    {
        if ([self.startOfflineSyncingTimer isValid])
        {
            [self.startOfflineSyncingTimer invalidate];
        }

        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        __weak typeof(self) weakSelf = self;

        __weak NSBlockOperation *blockOpr;
        NSBlockOperation *weakBlockOperation = [NSBlockOperation blockOperationWithBlock:^{
            if (blockOpr.isCancelled) return;
        }];
        self.blockOperation = weakBlockOperation;
        [self.blockOperation addExecutionBlock:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                dispatch_async(dispatch_get_main_queue(), ^{
                    [[weakSelf timesheetSyncOperationManager] startPendingQueueSync:weakSelf];
                });



                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.startOfflineSyncingTimer=[weakSelf.timerProvider scheduledTimerWithTimeInterval:900.0 target:weakSelf selector:@selector(startSync) userInfo:nil repeats:NO];
                });


            });
        }];
        
        mainQueue.name = @"Sync Queue";
        [mainQueue setMaxConcurrentOperationCount:1];
        [mainQueue addOperation:self.blockOperation];
    }

}


@end
