//
//  LoginService.h
//  Replicon
//
//  Created by Hemabindu on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseService.h"
#import "ServiceUtil.h"
#import "RequestBuilder.h"
#import "AppProperties.h"
#import "JsonWrapper.h"
#import "LoginDelegate.h"
#import "SpinnerDelegate.h"


@class AppDelegate;
@class TabModuleNameProvider;
@class PunchRules;
@class BreakTypeRepository;
@protocol HomeSummaryDelegate;
@class MobileMonitorURLProvider;
@class AppConfig;


@interface LoginService : BaseService <ServerResponseProtocol, LoginDelegate> {

    id	activityIndicatorParentViewControllerdelegate;

}
@property (nonatomic, strong) id activityIndicatorParentViewControllerdelegate;
@property (nonatomic, readonly) TabModuleNameProvider* tabModuleNameProvider;
@property (nonatomic) BreakTypeRepository *breakTypeRepository;


-(void)sendrequestToFetchHomeSummaryWithDelegate:(id<LoginDelegate> )delegate;
-(void)sendrequestToFetchLightWeightHomeSummaryWithDelegate:(id )delegate andLaunchHomeView:(id)isLaunchHomeView;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithTabModuleNameProvider:(TabModuleNameProvider *)tabModuleNameProvider
                                 userDefaults:(NSUserDefaults *)userDefaults
                              spinnerDelegate:(id<SpinnerDelegate>)spinnerDelegate
                          homeSummaryDelegate:(id<HomeSummaryDelegate>)homeSummaryDelegate
                                  appDelegate:(AppDelegate *)appDelegate
                     mobileMonitorURLProvider:(MobileMonitorURLProvider *)mobileMonitorURLProvider
                                    appConfig:(AppConfig *)appConfig;

-(void)sendrequestToDropDownOptionForDropDownUri:(NSString*)dropDownUri WithDelegate:(id )delegate ;
-(void)sendrequestForNextDropDownOptionForDropDownUri:(NSString *)dropDownUri WithDelegate:(id)delegate;
-(void)sendrequestToRegisterForPushNotification:(NSString *)deviceID;


- (void)handleHomeSummaryResponse:(NSDictionary *)response;
-(void)sendrequestToLogOut;

-(void)handleUserDefinedFields:(NSArray *)udfsArray forModuleName:(NSString *)moduleName enabledUriArray:(NSMutableArray *)enabledUriArray;
-(void)sendrequestToUpdateMySessionTimeoutDuration;

-(void)sendrequestToFetchAuthRemoteAPIUrl:(id )delegate;
-(void)sendrequestToGetVersionUpdateDetails;
-(void)handleGetVersionUpdateDetails:(id)response;

-(void)sendrequestToFetchUserIntegrationDetailsForiOS7WithDelegate:(id )delegate buttonType:(NSString*)buttonType;

-(void)handleUserIntegrationDetailsforiOS7URLResponse:(id)responseData;
-(void)sendRequestToUpdatePasswordWithOldPassword:(NSString*)oldPswd newPassword:(NSString*)newPswd andDelegate:(id)delegate;
-(void)handleUserIntegrationDetailsURLForFreeTrialResponse:(id)response;
-(void)fetchGetMyNotificationSummary;
-(void)handleCountOfGetMyNotificationSummary:(id)response;

- (void)sendrequestToLogtoCustomerSupportWithMsg:(NSString *)erroMsg serviceURL:(NSString *)serviceURL;

- (void)sendRequestToCheckServerDownStatusWithServiceURL:(NSString *)serviceURL;
-(void)handleServerDownStatusResponse:(id)response;
-(NSString*)convertToUserDeviceTimeZone :(id)response;
-(NSString*)checkForTimeZoneString;
-(BOOL)checkForShowingAppUpdateAlert :(NSInteger)triggerCount isShownOnce:(BOOL)isShownOnce;


- (void)sendrequestForObjectExtensionTagsForDropDownUri:(NSString *)dropDownUri searchString:(NSString *)searchString WithDelegate:(id)delegate;

- (void)sendrequestForNextObjectExtensionTagsForDropDownUri:(NSString *)dropDownUri searchString:(NSString *)searchString WithDelegate:(id)delegate;


@end
