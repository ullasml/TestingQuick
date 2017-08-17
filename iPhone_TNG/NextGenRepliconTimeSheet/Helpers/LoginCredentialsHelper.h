//
//  LoginCredentialsHelper.h
//  NextGenRepliconTimeSheet
//
//  Created by Pairing01 on 11/6/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginCredentialsHelper : NSObject

// returns stored company, user information.
- (NSDictionary *)getLoginCredentials;

@end
