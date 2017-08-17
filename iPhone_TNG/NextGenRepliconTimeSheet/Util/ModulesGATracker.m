//
//  ModulesGATracker.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 2/22/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "ModulesGATracker.h"
#import <Blindside/Blindside.h>
#import "InjectorKeys.h"
#import "Constants.h"
#import "FrameworkImport.h"
#import "UserPermissionsStorage.h"

@interface ModulesGATracker ()

@property (nonatomic, weak) id<BSInjector> injector;
@property (nonatomic) NSDictionary *moduleTags;
@property (nonatomic) GATracker *tracker;
@property (nonatomic) NSString *currentGAEventName;
@property (nonatomic) UserPermissionsStorage *userPermissionStorage;
@end

@implementation ModulesGATracker



- (instancetype)initWithTracker:(GATracker *)tracker userPermissionStorage:(UserPermissionsStorage *)userPermissionStorage
{
    self = [super init];
    if (self)
    {
        
        self.tracker = tracker;
        self.moduleTags = @{
                            NEW_PUNCH_WIDGET_MODULE_NAME        : @1,
                            PUNCH_IN_PROJECT_MODULE_NAME        : @2,
                            PUNCH_INTO_ACTIVITIES_MODULE_NAME   : @3,
                            TIMESHEETS_TAB_MODULE_NAME          : @4,
                            SCHEDULE_TAB_MODULE_NAME            : @5,
                            APPROVAL_TAB_MODULE_NAME            : @6,
                            EXPENSES_TAB_MODULE_NAME            : @7,
                            TIME_OFF_TAB_MODULE_NAME            : @8,
                            SETTINGS_TAB_MODULE_NAME            : @9,
                            CLOCK_IN_OUT_TAB_MODULE_NAME        : @10,
                            PUNCH_HISTORY_TAB_MODULE_NAME       : @11,
                            };
        self.userPermissionStorage = userPermissionStorage;
    }
    return self;
}

-(BOOL)sendGAEventForModule:(int)moduleTag
{
    NSString *gaEventName = nil;
    switch (moduleTag) {
        case 1:
        case 2:
        case 3:
            gaEventName = @"my_replicon_timesheets_punch";
            break;
        case 4:
            if ([self.userPermissionStorage hasTimePunchAccess])
            {
              gaEventName = @"my_replicon_timesheets_punch";
            }
            else
            {
              gaEventName = @"my_replicon_timesheets";
            }

            break;
        case 5:
            gaEventName = @"my_replicon_schedule";
            break;
        case 6:
            gaEventName = @"team_dashboard";
            break;
        case 7:
            gaEventName = @"my_replicon_expenses";
            break;
        case 8:
            gaEventName = @"my_replicon_time_off";
            break;
        case 9:
            gaEventName = @"settings";
            break;
        case 10:
            gaEventName = @"my_replicon_clock_in_or_out";
            break;
        case 11:
            gaEventName = @"my_replicon_punch_history";
            break;
        case 12:
            gaEventName = @"team_time_punches";
            break;

        default:
            break;
    }

    if (gaEventName)
    {
        if (self.currentGAEventName!=nil)
        {
            if (![gaEventName isEqualToString:self.currentGAEventName])
            {
                [self.tracker trackScreenView:gaEventName forTracker:TrackerProduct];
            }
            else
            {
                return NO;
            }
        }
        else
        {
            [self.tracker trackScreenView:gaEventName forTracker:TrackerProduct];
        }

        self.currentGAEventName = gaEventName;

        return YES;
        
    }
    
    return NO;
}

@end
