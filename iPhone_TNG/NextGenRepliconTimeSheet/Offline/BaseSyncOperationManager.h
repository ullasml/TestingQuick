//
//  BaseSyncOperationManager.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 12/4/15.
//  Copyright © 2015 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TimesheetSyncOperationManager;
@class TimerProvider;

@protocol BaseSyncOperationManagerDelegate;
@interface BaseSyncOperationManager : NSObject

@property (nonatomic,readonly) TimesheetSyncOperationManager *timesheetSyncOperationManager;
@property (nonatomic, readonly) TimerProvider *timerProvider;
@property (nonatomic, readonly) NSTimer *startOfflineSyncingTimer;

- (instancetype)initWithTimesheetSyncOperationManager:(TimesheetSyncOperationManager *)timesheetSyncOperationManager timerProvider:(TimerProvider *)timerProvider;
-(void)startSync;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

@end

@protocol BaseSyncOperationManagerDelegate <NSObject>

- (void)startPendingQueueSync:(BaseSyncOperationManager *)baseSyncOperationManager;

@end