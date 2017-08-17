//
//  ErrorDetailsRepository.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 6/2/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KSPromise;
@class ErrorDetailsStorage;
@class ErrorDetailsDeserializer;
@class ErrorDetailsRequestProvider;
@class TimesheetService;

@protocol RequestPromiseClient;
@protocol UserSession;


@interface ErrorDetailsRepository : NSObject

@property (nonatomic,readonly) id <RequestPromiseClient> client;
@property (nonatomic,readonly) ErrorDetailsRequestProvider *errorDetailsRequestProvider;
@property (nonatomic,readonly) ErrorDetailsStorage *errorDetailsStorage;
@property (nonatomic,readonly) id <UserSession> userSession;
@property (nonatomic,readonly) ErrorDetailsDeserializer *errorDetailsDeserializer;
@property (nonatomic,readonly) TimesheetService *timesheetService;



+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithErrorDetailsDeserializer:(ErrorDetailsDeserializer *)errorDetailsDeserializer
                                 requestProvider:(ErrorDetailsRequestProvider *)errorDetailsRequestProvider
                                     userSession:(id <UserSession>)userSession
                                          client:(id<RequestPromiseClient>)client
                                         storage:(ErrorDetailsStorage *)errorDetailsStorage timesheetService:(TimesheetService *)timesheetService NS_DESIGNATED_INITIALIZER;

-(KSPromise *)fetchFreshValidationErrors:(NSArray *)urisArray;
-(KSPromise *)fetchTimeSheetUpdateData;
@end
