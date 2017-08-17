//
//  AppConfig.h
//  NextGenRepliconTimeSheet
//
//  Created by Ravikumar Duvvuri on 16/02/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PersistedSettingsStorage;

@interface AppConfig : NSObject

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithPersistedSettingsStorage:(PersistedSettingsStorage *)persistedSettingsStorage NS_DESIGNATED_INITIALIZER;

- (BOOL)getNodeBackend;
- (void)setNodeBackend:(BOOL)nodeBackend;
- (NSString *)getConfigurationLevel;
- (BOOL)getNewMarketingServices;
- (BOOL)getNewContextualFlowPermission;
- (BOOL)getTimesheetSaveAndStay;
- (BOOL)getTimesheetWidgetPlatform;
@end
