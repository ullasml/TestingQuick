//
//  ErrorDetailsRepository.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 6/2/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "ErrorDetailsRepository.h"

#import "RequestPromiseClient.h"
#import "ErrorDetailsRequestProvider.h"
#import "ErrorDetailsStorage.h"
#import <KSDeferred/KSPromise.h>
#import "ErrorDetailsDeserializer.h"
#import <KSDeferred/KSDeferred.h>
#import "UserSession.h"
#import "Constants.h"
#import "TimesheetService.h"

@interface ErrorDetailsRepository()

@property (nonatomic) id <RequestPromiseClient> client;
@property (nonatomic) id <UserSession>userSession;
@property (nonatomic) ErrorDetailsRequestProvider *errorDetailsRequestProvider;
@property (nonatomic) ErrorDetailsStorage *errorDetailsStorage;
@property (nonatomic) ErrorDetailsDeserializer *errorDetailsDeserializer;
@property (nonatomic) TimesheetService *timesheetService;

@end

@implementation ErrorDetailsRepository

- (instancetype)initWithErrorDetailsDeserializer:(ErrorDetailsDeserializer *)errorDetailsDeserializer
                                 requestProvider:(ErrorDetailsRequestProvider *)errorDetailsRequestProvider
                                     userSession:(id <UserSession>)userSession
                                          client:(id<RequestPromiseClient>)client
                                         storage:(ErrorDetailsStorage *)errorDetailsStorage
                                         timesheetService:(TimesheetService *)timesheetService
{
    self = [super init];
    if (self) {
        self.client = client;
        self.errorDetailsRequestProvider = errorDetailsRequestProvider;
        self.errorDetailsStorage = errorDetailsStorage;
        self.userSession = userSession;
        self.errorDetailsDeserializer = errorDetailsDeserializer;
        self.timesheetService = timesheetService;
    }
    return self;
}


#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


-(KSPromise *)fetchAllValidationErrors:(NSArray *)urisArray
{
    return [self fetchFreshValidationErrors:urisArray];
}

-(KSPromise *)fetchFreshValidationErrors:(NSArray *)urisArray
{
    NSURLRequest *request = [self.errorDetailsRequestProvider requestForValidationErrorsWithURI:urisArray];
    KSPromise *promise = [self.client promiseWithRequest:request];
    return [promise then:^id(NSDictionary *json) {
        [self.errorDetailsStorage deleteAllErrorDetails];
        NSArray *errorDetails = [self.errorDetailsDeserializer deserializeValidationServiceResponse:json];
        [self.errorDetailsStorage storeErrorDetails:errorDetails];
        return errorDetails;
    } error:^id(NSError *error) {
        return error;
    }];

}

-(KSPromise *)fetchTimeSheetUpdateData
{
    NSURLRequest *request = [self.errorDetailsRequestProvider requestForTimeSheetUpdateDataForUserUri:self.userSession.currentUserURI];
    KSPromise *promise = [self.client promiseWithRequest:request];
    return [promise then:^id(NSDictionary *json) {
        NSMutableArray *timeSheetUrisArr = [self.errorDetailsDeserializer deserializeTimeSheetUpdateData:json];
        for (NSString *uri in timeSheetUrisArr)
        {
            [self.errorDetailsStorage deleteErrorDetails:uri];
        }
        NSArray *errorDetailsArr = [self.errorDetailsStorage getAllErrorDetailsForModuleName:TIMESHEETS_TAB_MODULE_NAME];
        [self.timesheetService handleTimesheetsUpdateFetchData:@{@"response":json}];
        return errorDetailsArr;
    } error:^id(NSError *error) {
        return error;
    }];

}




@end
