//
//  REPWebServices.m
//  Replicon
//
//  Created by Andre Muis on 9/14/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "REPWebServices.h"

#import "REPConstants.h"

@implementation REPWebServices

+ (REPWebServices *)webServices
{
    REPWebServices *webServices = [[REPWebServices alloc] init];
    return webServices;
}

- (void)clearResponseCache
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)getBeaconsJSONWithSuccess: (GetBeaconsJSONSuccessHandler)successHandler
                          failure: (GetBeaconsJSONFailureHandler)failureHandler
{
    NSURL *baseURL = [NSURL URLWithString: kREPServerBaseURLString];
    
    // subclass AFHTTPSessionManager?
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL: baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET: kREPBeaconsJSONFileName
      parameters: nil
         success: ^(NSURLSessionDataTask *task, id beaconsJSON)
    {
        successHandler(beaconsJSON);
    }
         failure: ^(NSURLSessionDataTask *task, NSError *error)
    {
        failureHandler(error);
    }];
}

@end
