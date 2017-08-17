//
//  REPWebServices.h
//  Replicon
//
//  Created by Andre Muis on 9/14/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"

@interface REPWebServices : NSObject

typedef void (^GetBeaconsJSONSuccessHandler)(id beaconsJSON);
typedef void (^GetBeaconsJSONFailureHandler)(NSError *error);

+ (REPWebServices *)webServices;

- (void)clearResponseCache;

- (void)getBeaconsJSONWithSuccess: (GetBeaconsJSONSuccessHandler)successHandler
                          failure: (GetBeaconsJSONFailureHandler)failureHandler;

@end
