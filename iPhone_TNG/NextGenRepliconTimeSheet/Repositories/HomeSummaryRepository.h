//
//  HomeSummaryRepository.h
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 23/09/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HomeFlowRequestProvider;
@class KSPromise;
@protocol RequestPromiseClient;

@interface HomeSummaryRepository : NSObject


@property (nonatomic, readonly) HomeFlowRequestProvider *homeFlowRequestProvider;
@property (nonatomic, readonly) id<RequestPromiseClient> client;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;


-  (instancetype)initWithHomeFlowRequestProvider:(HomeFlowRequestProvider *)homeFlowRequestProvider
                                          client:(id<RequestPromiseClient>)client NS_DESIGNATED_INITIALIZER;

- (KSPromise *)getHomeSummary;


@end
