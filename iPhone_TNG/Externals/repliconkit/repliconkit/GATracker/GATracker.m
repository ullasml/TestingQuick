//
//  GoogleAnalyticsTracker.m
//  NextGenRepliconTimeSheet
//
//  Created by Anil Reddy on 11/5/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "GATracker.h"

#define kEngineeringTrackerId @"UA-164929-21"
#define kEngineeringTrackerIdStaging @"UA-164929-22"

#define kProductContainerId @"GTM-MRGWH7"
#define kProductContainerIdStaging @"GTM-56GQ5G"

#define kDimensionNameCompany @"company"
#define kDimensionNameUserName @"username"
#define kDimensionNamePlatform @"platform"
#define kDimensionNameUniqueID @"uniqueid"
#define kDimensionNameCCUserName @"ccusername"
#define kDimensionErrorType @"errortype"
#define kDimensionNetworkType @"networktype"

#define kTrackerNameEngineering @"engineering"

#import "TAGContainer.h"
#import "TAGContainerOpener.h"
#import "TAGManager.h"
#import "TAGDataLayer.h"
#import "CommonUtil.h"
#import "ReportTechnicalErrors.h"

@interface GATracker ()<TAGContainerOpenerNotifier>

@property (nonatomic) TAGManager *productTagManager;
@property (nonatomic) TAGContainer *productContainer;
@property (nonatomic) TAGDataLayer *productDataLayer;

@end

@implementation GATracker


// Initialize tracker with a name.
// Google Analytics can have multiple tracker in app. Ex: Engineering tracker to track errors and Product tracker to track product analytics
- (instancetype)init {
    self = [super init];

    if(self){
        GAI *gai = [GAI sharedInstance];
        gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
        gai.dispatchInterval = CommonUtil.isRelease ? 30 : 2;
        gai.logger.logLevel = CommonUtil.isRelease ? kGAILogLevelNone : kGAILogLevelVerbose;

        [self setupGTM];
        [self setupTrackers];
    }
    return self;
}

- (void)setUserUri:(NSString *)userUri companyName:(NSString *)companyName username:(NSString *)username platform:(NSString *)platform {
    userUri = userUri != nil ? [userUri lowercaseString] : nil;
    companyName = companyName != nil ? [companyName lowercaseString] : nil;

    if (username != nil && companyName != nil) {
        username = [NSString stringWithFormat:@"%@>%@", companyName, username];
    }

    id<GAITracker> tracker = [self getTrackerByType:TrackerEngineering];
    [tracker set:kGAIUserId value:userUri];

    if (companyName)
    {
        NSInteger companyCustomDimentionIndex = [self dimensionIndexForName:kDimensionNameCompany forTracker:TrackerEngineering];
        [tracker set:[GAIFields customDimensionForIndex:companyCustomDimentionIndex] value:[companyName lowercaseString]];
    }

    if (username)
    {
        NSInteger usernameCustomDimentionIndex = [self dimensionIndexForName:kDimensionNameUserName forTracker:TrackerEngineering];
        [tracker set:[GAIFields customDimensionForIndex:usernameCustomDimentionIndex] value:[username lowercaseString]];
    }

    if (platform)
    {
        NSInteger platformCustomDimentionIndex = [self dimensionIndexForName:kDimensionNamePlatform forTracker:TrackerEngineering];
        [tracker set:[GAIFields customDimensionForIndex:platformCustomDimentionIndex] value:[platform lowercaseString]];
    }


    if (companyName==nil)
    {
        companyName=@"na";
    }
    if (username==nil)
    {
        username=@"na";
    }
    if (platform==nil)
    {
        platform=@"na";
    }

    if (userUri==nil)
    {
        [self.productDataLayer push:@{@"company": [companyName lowercaseString], @"userName": [username lowercaseString], @"repliconPlatformVersion": [platform lowercaseString]}];
    }
    else
    {
        [self.productDataLayer push:@{@"company": [companyName lowercaseString], @"userName": [username lowercaseString], @"repliconPlatformVersion": [platform lowercaseString], @"userID": userUri}];
    }
}

- (void)trackUIEvent:(NSString *)eventName forTracker:(TrackerType)trackerType {
    eventName = eventName != nil ? [eventName lowercaseString] : @"na";
    if (trackerType == TrackerProduct)
    {
        [self.productDataLayer push:@{@"event": @"GAEvent", @"eventCategory": @"ui", @"eventAction": eventName, @"eventLabel": [NSNull null], @"eventValue": @"0"}];
    }
    else
    {
        id<GAITracker> tracker = [self getTrackerByType:trackerType];
        NSMutableDictionary *event =
        [[GAIDictionaryBuilder createEventWithCategory:@"ui"
                                                action:eventName
                                                 label:nil
                                                 value:nil] build]; //FIXME: Verify we can pass 0 here.
        [tracker send:event];
    }
}

- (void)trackScreenView:(NSString *)screenName forTracker:(TrackerType)trackerType {
    screenName = screenName != nil ? [screenName lowercaseString] : @"na";
    if (trackerType == TrackerProduct)
    {
        [self.productDataLayer push:@{@"event": @"openScreen", @"screenName": screenName}];
    }
    else
    {
        screenName = [screenName lowercaseString];
        id<GAITracker> tracker = [self getTrackerByType:(TrackerType)trackerType];
        [tracker set:kGAIScreenName value:screenName];
        NSMutableDictionary *event = [[GAIDictionaryBuilder createScreenView] build];
        [tracker send:event];
        [tracker set:kGAIScreenName value:nil];
    }
}

- (void)trackNonFatalError:(NSString *)description withErrorID:(id)errorID withErrorType:(NSString *)errorType
{
    NSString *strErrorID = [NSString stringWithFormat:@"%@",errorID];

    NSInteger uniqueIdCustomDimentionIndex = [self dimensionIndexForName:kDimensionNameUniqueID forTracker:TrackerEngineering];
    NSInteger errorTypeCustomDimentionIndex = [self dimensionIndexForName:kDimensionErrorType forTracker:TrackerEngineering];
    NSInteger networkTypeCustomDimentionIndex = [self dimensionIndexForName:kDimensionNetworkType forTracker:TrackerEngineering];

    if (strErrorID)
    {
        // set errorid into custom dimension uniqueid. scope of this value is per hit.
        [self.engineeringTracker set:[GAIFields customDimensionForIndex:uniqueIdCustomDimentionIndex] value:strErrorID];
    }

    if (errorType)
    {
        // set errorid into custom dimension errortype. scope of this value is per hit.
        [self.engineeringTracker set:[GAIFields customDimensionForIndex:errorTypeCustomDimentionIndex] value:errorType];
    }

    NSString *networkType = [ReportTechnicalErrors fetchNetworkType];
    if (networkType)
    {
        // set errorid into custom dimension networktype. scope of this value is per hit.
        [self.engineeringTracker set:[GAIFields customDimensionForIndex:networkTypeCustomDimentionIndex] value:networkType];
    }


    NSMutableDictionary *event = [[GAIDictionaryBuilder createExceptionWithDescription:description
                                                withFatal:[NSNumber numberWithBool:NO]] build];
    [self.engineeringTracker send:event];

    [self.engineeringTracker set:[GAIFields customDimensionForIndex:uniqueIdCustomDimentionIndex] value:nil];
    [self.engineeringTracker set:[GAIFields customDimensionForIndex:errorTypeCustomDimentionIndex] value:nil];
    [self.engineeringTracker set:[GAIFields customDimensionForIndex:networkTypeCustomDimentionIndex] value:nil];
}

- (void)trackCrash:(NSException *)exception {
    NSMutableDictionary *event = [[GAIDictionaryBuilder createExceptionWithDescription:exception.description
                                                                             withFatal:[NSNumber numberWithBool:YES]] build];
    [self.engineeringTracker send:event];
}

#pragma mark - private methods

// Initialize all the trackers with their tracking id. This starts automatic capturing of default data by GA.
- (void)setupTrackers {
    [self getTrackerByType:TrackerEngineering];
}

- (void)setupGTM {
    self.productTagManager = [TAGManager instance];
    self.productDataLayer = self.productTagManager.dataLayer;

    // Modify the log level of the logger to print out not only
    // warning and error messages, but also verbose, debug, info messages.
    [self.productTagManager.logger setLogLevel:CommonUtil.isRelease ? kTAGLoggerLogLevelNone : kTAGLoggerLogLevelVerbose];

    // Open a container.
    [TAGContainerOpener openContainerWithId:CommonUtil.isRelease ? kProductContainerId : kProductContainerIdStaging
                                 tagManager:self.productTagManager
                                   openType:kTAGOpenTypePreferFresh
                                    timeout:nil
                                   notifier:self];
}


/*!
 Returns the custom dimension index for given name

 @param name the name of the custom dimension.

 @return an NSInteger representing the index of custom dimension parameter
 */
- (NSInteger)dimensionIndexForName:(NSString *)name forTracker:(TrackerType)trackerType {
    switch (trackerType) {
        case TrackerEngineering:
            if(CommonUtil.isRelease){
                if([name compare:kDimensionNameCompany] == NSOrderedSame){
                    return 1;
                }
                else if([name compare:kDimensionNameUserName] == NSOrderedSame){
                    return 2;
                }
                else if([name compare:kDimensionNamePlatform] == NSOrderedSame){
                    return 3;
                }
                else if([name compare:kDimensionNameUniqueID] == NSOrderedSame){
                    return 4;
                }
                else if([name compare:kDimensionErrorType] == NSOrderedSame){
                    return 5;
                }
                else if([name compare:kDimensionNetworkType] == NSOrderedSame){
                    return 6;
                }
            }
            else {
                if([name compare:kDimensionNameCompany] == NSOrderedSame){
                    return 1;
                }
                else if([name compare:kDimensionNameUserName] == NSOrderedSame){
                    return 2;
                }
                else if([name compare:kDimensionNamePlatform] == NSOrderedSame){
                    return 3;
                }
                else if([name compare:kDimensionNameUniqueID] == NSOrderedSame){
                    return 4;
                }
                else if([name compare:kDimensionNameCCUserName] == NSOrderedSame){
                    return 5;
                }
                else if([name compare:kDimensionErrorType] == NSOrderedSame){
                    return 6;
                }
                else if([name compare:kDimensionNetworkType] == NSOrderedSame){
                    return 7;
                }
            }
            break;
        default:
            return 0;
    }
    return 0;
}

// GA creates a tracker if one does not exists, otherwise returns previously created tracker
- (id<GAITracker>)getTrackerByType:(NSUInteger)trackerType {
    GAI *gai = [GAI sharedInstance];
    switch (trackerType) {
        case TrackerEngineering:
            if (self.engineeringTracker == nil) {
                self.engineeringTracker = [gai trackerWithName:kTrackerNameEngineering trackingId:(CommonUtil.isRelease ? kEngineeringTrackerId : kEngineeringTrackerIdStaging)];
            }

            return self.engineeringTracker;
            break;
        default:
            return nil;
    }
}



#pragma mark - <TAGContainerOpenerNotifier callback>

// TAGContainerOpenerNotifier callback.
- (void)containerAvailable:(TAGContainer *)container {
    // Note that containerAvailable may be called on any thread, so you may need to dispatch back to
    // your main thread.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.productContainer = container;
    });
}


@end
