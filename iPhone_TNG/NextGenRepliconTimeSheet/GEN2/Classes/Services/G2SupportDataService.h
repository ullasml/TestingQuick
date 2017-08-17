//
//  SupportDataService.h
//  Replicon
//
//  Created by Devi Malladi on 3/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G2BaseService.h"
#import "G2ServiceUtil.h"
#import "G2RequestBuilder.h"
#import "G2AppProperties.h"
#import "JsonWrapper.h"
#import "G2SupportDataModel.h"
#import "FrameworkImport.h"
@interface G2SupportDataService : G2BaseService {

	G2SupportDataModel *supportDataModel;
}

@property(nonatomic, strong) G2SupportDataModel *supportDataModel;

-(void)sendRequestToGetSystemPerferencesWithDelegate:(id)delegate;
-(void)sendRequestToGetAllTaxeCodesWithDelegate:(id)delegate;
-(void)sendRequestToGetPaymentMethodAllWithDelegate:(id)delegate;
-(void)sendRequestToGetSystemCurrenciesWithDelegate:(id)delegate;
-(void)sendRequestToGetBaseCurrencyWithDelegate:(id)delegate;
-(void)sendRequestForUDFSetting:(id)delegate;
-(void)sendRequestToGetUserPreferences;
-(void)handleUserPreferencesResponse: (id)response;
-(void)sendRequestToGetProjectsAndClients;
-(void)handleProjectsAndClientsResponse: (id)response;
-(void)showErrorAlert:(NSError *) error;
-(void)sendRequestToGetUserActivities :(id)_delegate;
-(void)sendRequestToGetProjectBillingOptions;
-(void)sendRequestToGetTimesheetsUDFSettings :(id)_delegate;
-(void)handleTimesheetUDFSettingsResponse : (id)response; 
-(void)sendRequestToGetDisclaimerPreferences;
-(void)handleDisclaimerPreferencesResponse: (id)response;
-(void)sendRequestToGetUserTimeOffs:(id)delegate;
-(void)handleTimeOffResponse:(id)response;
-(void)handleSystemPreferencesResponse:(id) response;
@end
