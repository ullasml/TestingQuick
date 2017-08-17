#import "ManualPunch.h"

@implementation ManualPunch

- (instancetype)initWithLocalPunch:(LocalPunch * )localPunch
{
    return [super initWithPunchSyncStatus:localPunch.punchSyncStatus
                               actionType:localPunch.actionType
                             lastSyncTime:localPunch.lastSyncTime
                                breakType:localPunch.breakType
                                 location:localPunch.location
                                  project:localPunch.project
                                requestID:localPunch.requestID
                                 activity:nil
                                   client:localPunch.client
                                 oefTypes:localPunch.oefTypesArray
                                  address:localPunch.address
                                  userURI:localPunch.userURI
                                    image:localPunch.image
                                     task:localPunch.task
                                     date:localPunch.date];
}

- (BOOL)offline
{
    return YES;
}

- (BOOL)authentic
{
    return NO;
}

- (BOOL)manual
{
    return YES;
}

@end
