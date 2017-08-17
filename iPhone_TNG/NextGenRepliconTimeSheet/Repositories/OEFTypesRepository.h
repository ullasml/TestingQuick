//
//  OEFTypesRepository.h
//  NextGenRepliconTimeSheet
//
//  Created by Prakashini Pattabiraman on 04/11/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RequestDictionaryBuilder;
@protocol RequestPromiseClient;
@class OEFTypesRequestProvider;
@class OEFDeserializer;
@class UserUriDetector;
@class KSPromise;
@class OEFTypeStorage;
@class UserPermissionsStorage;

@interface OEFTypesRepository : NSObject

@property (nonatomic, readonly) OEFTypesRequestProvider *oefTypesRequestProvider;
@property (nonatomic, readonly) id<RequestPromiseClient> client;
@property (nonatomic, readonly) OEFDeserializer *oefDeserializer;
@property (nonatomic, readonly) OEFTypeStorage *oefTypesStorage;
@property (nonatomic, readonly) UserPermissionsStorage *userPermissionsStorage;

- (instancetype)initWithOEFRequestProvider:(OEFTypesRequestProvider *)oefTypesRequestProvider
                   oefTypesDeserializer:(OEFDeserializer *)oefTypesDeserializer
                        oefTypesStorage:(OEFTypeStorage *)oefTypesStorage
                                 client:(id <RequestPromiseClient>)client
                    userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage;

- (KSPromise *)fetchOEFTypesWithUserURI:(NSString *)userUri;


@end
