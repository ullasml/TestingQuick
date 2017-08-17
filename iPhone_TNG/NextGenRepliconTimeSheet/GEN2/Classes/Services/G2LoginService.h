//
//  LoginService.h
//  Replicon
//
//  Created by Hemabindu on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G2BaseService.h"
#import "G2ServiceUtil.h"
#import "G2RequestBuilder.h"
#import "G2AppProperties.h"
#import "JsonWrapper.h"
#import "G2TransitionPageViewController.h"

@interface G2LoginService : G2BaseService <ProcessControllProtocol> {
	
}
-(BOOL)requestSystemPreferences:(id )note;
-(void)sendrequestToFetchAPIURLWithDelegate:(id )delegate ;
-(void)sendrequestToCheckExistenceOfUserByLoginNameWithDelegate:(id )delegate; 
-(void)sendRequestToCheckUserChangePasswordRequired:(id)delegate;
-(void)sendRequestToSubmitChangePassword:(id)delegate;
-(void)sendRequestToGetSessionBasedApi:(id)delegate;
-(void)sendRequestForSessionLogout:(id)delegate;
-(void)handleEndSessionResponse;
-(void)sendRequestForFreeTrialSignUp;
-(void)handleFreeTrialResponse:(id)response;
-(void) confirmAlert :(NSString *)_buttonTitle confirmMessage:(NSString*) message;
-(void)sendRequestToResetPassword;
-(void)handleResetPasswordResponse:(id)response;
-(void)sendrequestToFetchAuthRemoteAPIUrl:(id )delegate;
-(void)handleSAMLAPIURLResponse:(id)response;
-(void)sendrequestToCheckExistenceOfUserByLoginNameWithDelegate:(id )delegate forUsername:(NSString *)username;
-(void)userTimeOffNotification;
-(void)sendMultipleRequestForLoginWithDelegate:(id )delegate;
-(void)handleMergedLoginResponse:(id)response;
-(void)sendrequestToFetchUserIntegrationDetailsWithCompanyName:(NSString *)companyName andUsername:(NSString *)loginName;
-(void)handleNewSAMLAPIURLResponse:(id)response;
-(void)sendrequestToFetchNewAuthRemoteAPIUrl:(id )delegate;
-(void)sendrequestToCompleteSAMLFlow:(NSString *)guid;
-(void)handleCompleteSAMLFlowAPIURLResponse:(id)response;
@end
