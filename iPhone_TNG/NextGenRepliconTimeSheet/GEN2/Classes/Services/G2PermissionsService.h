//
//  PermissionsService.h
//  Replicon
//
//  Created by Devi Malladi on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "G2BaseService.h"
#import "G2ServiceUtil.h"
#import "G2RequestBuilder.h"
#import "G2AppProperties.h"
#import "JsonWrapper.h"
#import "G2PermissionsModel.h"
#import "FrameworkImport.h"
@interface G2PermissionsService : NSObject {
	G2BaseService *baseService;
	G2PermissionsModel *permissionsModel;

}
//-(void)sendRequestToGetAllUserPermissionsWithDelegate:(id)delegate;
-(void)sendRequestToGetAllUserPermissionsWithDelegate;
-(void)handleUserPermissonsResponse:(id)response;
-(void)serverDidRespondWithResponse:(id) response;
-(void)serverDidFailWithError:(NSError *) error;
-(void)showErrorAlert:(NSError *) error;
@end
