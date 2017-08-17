//
//  AppDelegateService.h
//  Replicon
//
//  Created by Dipta Rakshit on 3/19/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G2BaseService.h"

@interface G2AppDelegateService : G2BaseService
{
    int totalRequestsSent;
	int totalRequestsServed;
}
-(void)sendRequestToLoadUser;
-(void)handleUserDownloadContent:(id)response;
-(void)showErrorAlert:(NSError *) error;
@end
