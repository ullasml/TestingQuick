//
//  HomeSummaryRepository.m
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 23/09/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "HomeSummaryRepository.h"
#import "HomeFlowRequestProvider.h"
#import "RequestBuilder.h"
#import "RequestDictionaryBuilder.h"
#import "JSONClient.h"
#import <KSDeferred/KSDeferred.h>

@interface HomeSummaryRepository ()

@property (nonatomic) HomeFlowRequestProvider *homeFlowRequestProvider;
@property (nonatomic) id<RequestPromiseClient> client;
@end

@implementation HomeSummaryRepository


- (instancetype)initWithHomeFlowRequestProvider:(HomeFlowRequestProvider *)homeFlowRequestProvider
                                         client:(id<RequestPromiseClient>)client {
    self = [super init];
    if (self) {
        
        self.homeFlowRequestProvider = homeFlowRequestProvider;
        self.client = client;
    }
    return self;
}



- (KSPromise *)getHomeSummary
{
    NSURLRequest *request = [self.homeFlowRequestProvider requestForHomeFlowService];
    KSPromise *dictionaryPromise = [self.client promiseWithRequest:request];
    
    return [dictionaryPromise then:^id(NSDictionary *homeSummaryResponse) {
        return homeSummaryResponse;
    } error:^id(NSError *error) {
        return error;
    }];
}



@end
