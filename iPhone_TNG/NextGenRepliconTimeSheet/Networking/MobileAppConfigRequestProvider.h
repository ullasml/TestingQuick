//
//  MobileAppConfigRequestProvider.h
//  repliconkit
//
//  Created by Ravikumar Duvvuri on 10/03/17.
//  Copyright © 2017 replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MobileMonitorURLProvider;
@class LoginCredentialsHelper;

@interface MobileAppConfigRequestProvider : NSObject

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithMobileMonitorURLProvider:(MobileMonitorURLProvider *)mobileMonitorURLProvider
                          loginCredentialsHelper:(LoginCredentialsHelper *)LoginCredentialsHelper
                                          bundle:(NSBundle *)bundle NS_DESIGNATED_INITIALIZER;

- (NSMutableURLRequest *)getRequest;
@end
