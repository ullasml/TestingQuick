//
//  ModulesGATracker.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 2/22/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GATracker;
@class UserPermissionsStorage;
@interface ModulesGATracker : NSObject

@property (nonatomic, readonly) GATracker *tracker;
@property(nonatomic,readonly) UserPermissionsStorage *userPermissionStorage;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary  UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTracker:(GATracker *)tracker userPermissionStorage:(UserPermissionsStorage *)userPermissionStorage;


-(BOOL)sendGAEventForModule:(int)moduleTag;

@end
