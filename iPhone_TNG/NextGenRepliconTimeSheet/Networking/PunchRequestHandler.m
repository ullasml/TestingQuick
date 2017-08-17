#import "PunchRequestHandler.h"
#import "PunchCreator.h"
#import "PunchOutboxStorage.h"
#import "Constants.h"
#import "FailedPunchStorage.h"
#import "PunchNotificationScheduler.h"


@interface PunchRequestHandler ()

@property (nonatomic) PunchNotificationScheduler *punchNotificationScheduler;
@property (nonatomic) FailedPunchStorage *failedPunchStorage;
@property (nonatomic) PunchOutboxStorage *punchOutboxStorage;

@end


@implementation PunchRequestHandler


- (instancetype)initWithPunchNotificationScheduler:(PunchNotificationScheduler *)punchNotificationScheduler
                                failedPunchStorage:(FailedPunchStorage *)failedPunchStorage
                                punchOutboxStorage:(PunchOutboxStorage *)punchOutboxStorage
                                urlSessionListener:(URLSessionListener *)urlSessionListener
{
    self = [super init];
    if (self)
    {
        self.punchNotificationScheduler = punchNotificationScheduler;
        self.failedPunchStorage = failedPunchStorage;
        self.punchOutboxStorage = punchOutboxStorage;

        [urlSessionListener addObserver:self];
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - <URLSessionListenerObserver>

- (void)urlSessionListener:(URLSessionListener *)urlSessionListener downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingData:(NSData *)data
{
    if (data != nil && ![data isKindOfClass:[NSNull class]]) {
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        

        NSString *formatString = RPLocalizedString(@"Punches were not saved to Replicon server due to following reason: %@ Tap to retry. If that does not resolve the issue, please contact your Admin.", @"");
        
        NSDictionary *errorDictionary = responseDictionary[@"error"];
        if (errorDictionary)
        {
            NSString *alertBody = [NSString stringWithFormat:formatString, errorDictionary[@"reason"], nil];
            [self.punchNotificationScheduler scheduleNotificationWithAlertBody:alertBody];
        }
        
        NSArray *errorDictionaries = responseDictionary[@"d"][@"errors"];
        if (errorDictionaries.count > 0)
        {
            NSDictionary *punchErrorDictionary = errorDictionaries.firstObject;
            NSArray *notificationDictionaries = punchErrorDictionary[@"notifications"];
            if (notificationDictionaries != nil && notificationDictionaries != (id) [NSNull null] &&notificationDictionaries.count > 0)
            {
                NSDictionary *notificationDictionary = notificationDictionaries.firstObject;
                NSString *alertBody = [NSString stringWithFormat:formatString, notificationDictionary[@"displayText"], nil];
                [self.punchNotificationScheduler scheduleNotificationWithAlertBody:alertBody];
            }
            else
            {
                NSString *alertBody = RPLocalizedString(@"Punches were not saved to Replicon server due to unknown reason. Tap to retry. If that does not resolve the issue, please contact your Admin.", @"");
                [self.punchNotificationScheduler scheduleNotificationWithAlertBody:alertBody];

            }
        }
        
        if (errorDictionary || errorDictionaries.count)
        {
            NSString *requestID = [downloadTask.originalRequest valueForHTTPHeaderField:PunchRequestIdentifierHeader];
            LocalPunch *punch = [self.punchOutboxStorage getAndDeletePunchForRequestId:requestID];
            [self.failedPunchStorage storePunch:punch];
        }
    }
}

- (void)urlSessionListener:(URLSessionListener *)urlSessionListener task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSString *requestID = [task.originalRequest valueForHTTPHeaderField:PunchRequestIdentifierHeader];
    LocalPunch *punch = [self.punchOutboxStorage getAndDeletePunchForRequestId:requestID];

    if (error && punch)
    {
        [self.failedPunchStorage storePunch:punch];
        NSString *alertBody = RPLocalizedString(PunchesWereNotSavedErrorNotificationMsg, @"");
        [self.punchNotificationScheduler scheduleNotificationWithAlertBody:alertBody];
    }
}

@end
