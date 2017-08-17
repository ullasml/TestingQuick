//
//  AppConfig.m
//  NextGenRepliconTimeSheet
//
//  Created by Ravikumar Duvvuri on 16/02/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

#import "AppConfig.h"
#import "PersistedSettingsStorage.h"
#import "NSDictionary+Validation.h"
#import "RepliconKitConstants.h"

@interface AppConfig ()
@property (nonatomic) PersistedSettingsStorage *persistedSettingsStorage;
@end

@implementation AppConfig

-(instancetype)initWithPersistedSettingsStorage:(PersistedSettingsStorage *)persistedSettingsStorage {
    self = [super init];
    if (self) {
        self.persistedSettingsStorage = persistedSettingsStorage;
    }
    return self;
}


#pragma mark -- public Methods

-(BOOL)getNodeBackend
{
    return [self.persistedSettingsStorage getAppConfigBoolValueforKey:kNodeBackend];
}

-(void)setNodeBackend:(BOOL)nodeBackend {
    [self.persistedSettingsStorage updateAppConfigValue:[NSNumber numberWithBool:nodeBackend] forKey:kNodeBackend];
}

-(NSString *)getConfigurationLevel
{
    return [self.persistedSettingsStorage getAppConfigStrinValueforKey:kSource] ? [self.persistedSettingsStorage getAppConfigStrinValueforKey:kSource] : @"global";
}

-(BOOL)getNewMarketingServices {
    return [self.persistedSettingsStorage getAppConfigBoolValueforKey:kNewMarketingServices];
}

- (BOOL)getNewContextualFlowPermission {
    return [self.persistedSettingsStorage getAppConfigBoolValueforKey:kNewContextualFlow];
}

- (BOOL)getTimesheetSaveAndStay{
    return [self.persistedSettingsStorage getAppConfigBoolValueforKey:kTimesheetSaveAndStay];
}

- (BOOL)getTimesheetWidgetPlatform{
    return [self.persistedSettingsStorage getAppConfigBoolValueforKey:kTimesheetWidgetPlatform];
}

@end
