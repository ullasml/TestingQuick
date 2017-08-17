//
//  LoginCredentialsHelper.m
//  NextGenRepliconTimeSheet
//
//  Created by Pairing01 on 11/6/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "LoginCredentialsHelper.h"
#import "ACSimpleKeychain.h"

@implementation LoginCredentialsHelper

- (NSDictionary *)getLoginCredentials{

    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    if ([keychain allCredentialsForService:@"repliconUserCredentials" limit:99] != nil &&
        ![[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] isKindOfClass:[NSNull class]]) {
        NSMutableDictionary *credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
        if (credentials != nil && ![credentials isKindOfClass:[NSNull class]]) {
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            NSString *companyName = [credentials valueForKey:ACKeychainCompanyName];
            if (companyName != nil && companyName.length > 0) {
                [result setObject:companyName forKey:@"companyName"];
            }

            NSString *userName = [credentials valueForKey:ACKeychainUsername];
            if (userName != nil && userName.length > 0) {
                [result setObject:userName forKey:@"userName"];
            }

            NSString *userUri = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserUri"];
            if (userUri != nil && userUri.length > 0) {
                CLS_LOG(@"-------getLoginCredentials useruri--------- %@",userUri);
                [result setObject:userUri forKey:@"userUri"];
            }

            return result;
        }
    }
    return nil;
}

@end
