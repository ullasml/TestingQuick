#import "OfflineLocalPunch.h"


@implementation OfflineLocalPunch

- (instancetype)initWithLocalPunch:(LocalPunch * )localPunch
{
    return [super initWithPunchSyncStatus:localPunch.punchSyncStatus
                               actionType:localPunch.actionType
                             lastSyncTime:localPunch.lastSyncTime
                                breakType:localPunch.breakType
                                 location:localPunch.location
                                  project:localPunch.project
                                requestID:localPunch.requestID
                                 activity:localPunch.activity
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
    return YES;
}

- (BOOL)manual
{
    return NO;
}


@end
