#import "PunchCreator.h"
#import "PunchRequestProvider.h"
#import "RequestPromiseClient.h"
#import <KSDeferred/KSPromise.h>
#import "Punch.h"
#import <KSDeferred/KSDeferred.h>
#import "PunchOutboxStorage.h"
#import "Constants.h"
#import "LocalPunch.h"
#import "PunchNotificationScheduler.h"
#import "TimeLinePunchesStorage.h"
#import "FailedPunchStorage.h"
#import "Punch.h"
#import "FailedPunchErrorStorage.h"
#import "PunchErrorPresenter.h"
#import "DateProvider.h"
#import "InvalidProjectAndTakDetector.h"

@interface PunchCreator ()

@property (nonatomic) FailedPunchStorage *failedPunchStorage;
@property (nonatomic) TimeLinePunchesStorage *timeLinePunchesStorage;
@property (nonatomic) PunchRequestProvider *punchRequestProvider;
@property (nonatomic) PunchOutboxStorage *punchOutboxStorage;
@property (nonatomic) id<RequestPromiseClient> client;
@property (nonatomic) PunchNotificationScheduler *punchNotificationScheduler;
@property (nonatomic) FailedPunchErrorStorage *failedPunchErrorStorage;
@property (nonatomic) UIApplication *application;
@property (nonatomic) PunchErrorPresenter *punchErrorPresenter;
@property (nonatomic) NSUserDefaults *defaults;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) InvalidProjectAndTakDetector *invalidProjectAndTakDetector;

@end


@implementation PunchCreator

- (instancetype)initWithInvalidProjectAndTakDetector:(InvalidProjectAndTakDetector *)invalidProjectAndTakDetector
                          punchNotificationScheduler:(PunchNotificationScheduler *)punchNotificationScheduler
                             failedPunchErrorStorage:(FailedPunchErrorStorage *)failedPunchErrorStorage
                              timeLinePunchesStorage:(TimeLinePunchesStorage *)timeLinePunchesStorage
                                punchRequestProvider:(PunchRequestProvider *)punchRequestProvider
                                 punchErrorPresenter:(PunchErrorPresenter *)punchErrorPresenter
                                  punchOutboxStorage:(PunchOutboxStorage *)punchOutboxStorage
                                  failedPunchStorage:(FailedPunchStorage *)failedPunchStorage
                                         application:(UIApplication *)application
                                              client:(id <RequestPromiseClient>)client
                                            defaults:(NSUserDefaults *)defaults
                                        dateProvider:(DateProvider *)dateProvider
                                       dateFormatter:(NSDateFormatter *)dateFormatter {
    self = [super init];
    if (self) {
        self.client = client;
        self.application = application;
        self.punchOutboxStorage = punchOutboxStorage;
        self.failedPunchStorage = failedPunchStorage;
        self.punchErrorPresenter = punchErrorPresenter;
        self.punchRequestProvider = punchRequestProvider;
        self.timeLinePunchesStorage = timeLinePunchesStorage;
        self.failedPunchErrorStorage = failedPunchErrorStorage;
        self.punchNotificationScheduler = punchNotificationScheduler;
        self.invalidProjectAndTakDetector = invalidProjectAndTakDetector;
        self.defaults = defaults;
        self.dateProvider = dateProvider;
        self.dateFormatter = dateFormatter;
    }
    return self;
}

- (KSPromise *)creationPromiseForPunch:(NSArray *)punchesArray
{
    KSDeferred *deferred = [[KSDeferred alloc] init];

    for (id<Punch>punch in punchesArray)
    {
        [self.punchOutboxStorage updateSyncStatusToPendingAndSave:punch];
    }

    NSURLRequest *request = [self.punchRequestProvider punchRequestWithPunch:punchesArray];

    KSPromise *punchPromise = [self.client promiseWithRequest:request];

    [punchPromise then:^id(NSDictionary *jsonResponseDictionary) {
        NSArray *errors;

        if([jsonResponseDictionary[@"d"] respondsToSelector:@selector(objectForKey:)])
        {
            errors =  jsonResponseDictionary[@"d"][@"erroredPunches"];
        }

        if (errors)
        {
            NSMutableArray *mutablePunches = [punchesArray mutableCopy];
            for (NSDictionary *errorDictionary in errors)
            {
                NSString *errorDisplayText = errorDictionary[@"displayText"];
                [self.punchNotificationScheduler scheduleCurrentFireDateNotificationWithAlertBody:errorDisplayText];
                for (id<Punch>punch in punchesArray)
                {
                    if ([errorDictionary[@"parameterCorrelationId"] isEqualToString:punch.requestID])
                    {
                        [self.invalidProjectAndTakDetector validatePunchAndUpdate:punch withError:errorDictionary];
                        [self.failedPunchErrorStorage storeFailedPunchError:errorDictionary punch:punch];
                        [self.punchOutboxStorage deletePunch:punch];
                        [mutablePunches removeObject:punch];
                        break;
                    }
                }
            }
            
            if (self.application.applicationState == UIApplicationStateActive) {
                [self.punchErrorPresenter presentFailedPunchesErrors];
            }
            
            for (id<Punch>punch in mutablePunches)
            {
                [self.timeLinePunchesStorage updateSyncStatusToRemoteAndSaveWithPunch:punch withRemoteUri:nil];
            }

            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: jsonResponseDictionary[@"d"][@"errors"]};
            NSError *error = [NSError errorWithDomain:@"PunchCreatorErrorDomain" code:0 userInfo:userInfo];
            [deferred rejectWithError:error];
            
        }
        else
        {

            NSArray *punchReferences =  jsonResponseDictionary[@"d"][@"punchReferences"];
            NSMutableDictionary *punchesMapper = [@{}mutableCopy];
            for(NSDictionary *punchReferenceDict in punchReferences)
            {
                [punchesMapper setObject:punchReferenceDict[@"uri"] forKey:punchReferenceDict[@"parameterCorrelationId"]];
            }

            for (id<Punch>punch in punchesArray)
            {
                NSString *uri = punchesMapper[punch.requestID];
                [self.timeLinePunchesStorage updateSyncStatusToRemoteAndSaveWithPunch:punch withRemoteUri:uri];
            }

            [deferred resolveWithValue:punchesArray];

        }

        [self updatePunchRecordedLastModifiedTime];

        return nil;
    } error:^id(NSError *error) {
         NSString *alertBody = RPLocalizedString(PunchesWereNotSavedErrorNotificationMsg, @"");
        [self.punchNotificationScheduler scheduleNotificationWithAlertBody:alertBody];
        [deferred rejectWithError:error];
        for (id<Punch>punch in punchesArray)
        {
            [self.failedPunchStorage updateSyncStatusToUnsubmittedAndSaveWithPunch:punch];
        }
        return nil;
    }];

    return deferred.promise;
}

#pragma mark - <Private>

-(void)updatePunchRecordedLastModifiedTime
{
    NSString *serverTimestamp = [self.dateFormatter stringFromDate:self.dateProvider.date];
    if (serverTimestamp!=nil && ![serverTimestamp isKindOfClass:[NSNull class]])
    {
        NSString *key=@"PunchRecordedLastModifiedTime";
        [self.defaults removeObjectForKey:key];
        [self.defaults  setObject:serverTimestamp forKey:key];
        [self.defaults  synchronize];
    }
}

@end
