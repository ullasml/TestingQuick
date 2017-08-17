//
//  OEFTypesRepository.m
//  NextGenRepliconTimeSheet
//
//  Created by Prakashini Pattabiraman on 04/11/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "OEFTypesRepository.h"
#import "OEFTypesRequestProvider.h"
#import "RequestPromiseClient.h"
#import <KSDeferred/KSPromise.h>
#import "OEFDeserializer.h"
#import "OEFTypeStorage.h"
#import "UserPermissionsStorage.h"

@interface OEFTypesRepository()

@property (nonatomic) RequestDictionaryBuilder *requestDictionaryBuilder;
@property (nonatomic) OEFTypesRequestProvider *oefTypesRequestProvider;
@property (nonatomic) id<RequestPromiseClient> client;
@property (nonatomic) OEFDeserializer *oefDeserializer;
@property (nonatomic) UserUriDetector *userUriDetector;
@property (nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) OEFTypeStorage *oefTypesStorage;
@property (nonatomic) NSArray *oefTypesArray;
@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;

@end

@implementation OEFTypesRepository

- (instancetype)initWithOEFRequestProvider:(OEFTypesRequestProvider *)oefTypesRequestProvider
                            oefTypesDeserializer:(OEFDeserializer *)oefTypesDeserializer
                                 oefTypesStorage:(OEFTypeStorage *)oefTypesStorage
                                          client:(id <RequestPromiseClient>)client
                          userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
{
    
    if(self = [super init]) {
        self.oefDeserializer = oefTypesDeserializer;
        self.oefTypesRequestProvider = oefTypesRequestProvider;
        self.client = client;
        self.oefTypesStorage = oefTypesStorage;
        self.userPermissionsStorage = userPermissionsStorage;
    }
    
    return self;
}

- (KSPromise *)fetchOEFTypesWithUserURI:(NSString *)userUri {

    if (self.userPermissionsStorage.canViewTeamPunch)
    {
        NSURLRequest *request = [self.oefTypesRequestProvider requestForOEFTypesForUserUri:userUri];
        KSPromise *dictionaryPromise = [self.client promiseWithRequest:request];

        return [dictionaryPromise then:^id(NSDictionary *oefTypesResponseDictionary) {
            NSDictionary *responseDictionary = oefTypesResponseDictionary[@"d"];
            NSMutableArray *oefArray = [self.oefDeserializer deserializeGetObjectExtensionFieldBindingsForUsersServiceWithJson:responseDictionary];

            [self.oefTypesStorage setUpWithUserUri:userUri];
            [self.oefTypesStorage storeOEFTypes:oefArray];
            self.oefTypesArray = oefArray;
            return self.oefTypesArray;
        } error:^id(NSError *error) {
            return error;
        }];
    }

    return nil;
    
}

@end
