//
//  GoogleAnalyticsTracker.h
//  NextGenRepliconTimeSheet
//
//  Created by Anil Reddy on 11/5/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"



typedef NS_ENUM(NSInteger, TrackerType) {
    TrackerProduct,
    TrackerEngineering,
    trackerCount
};

@class TAGManager;
@class TAGContainer;
@class TAGDataLayer;

@interface GATracker : NSObject

@property id<GAITracker> engineeringTracker;

@property (nonatomic, readonly) TAGManager *productTagManager;
@property (nonatomic, readonly) TAGContainer *productContainer;
@property (nonatomic, readonly) TAGDataLayer *productDataLayer;

- (void)setUserUri:(NSString *)userUri companyName:(NSString *)companyName username:(NSString *)username platform:(NSString *)platform;

- (void)trackUIEvent:(NSString *)eventName forTracker:(TrackerType)trackerType;
- (void)trackScreenView:(NSString *)screenName forTracker:(TrackerType)trackerType;
- (void)trackNonFatalError:(NSString *)description withErrorID:(id)errorID withErrorType:(NSString *)errorType;
- (void)trackCrash:(NSException *)exception;
- (id<GAITracker>)getTrackerByType:(NSUInteger)trackerType;
- (NSInteger)dimensionIndexForName:(NSString *)name forTracker:(TrackerType)trackerType;
@end
