#import "PunchRevitalizer.h"
#import "PunchCreator.h"
#import "PunchNotificationScheduler.h"
#import "PunchOutboxStorage.h"
#import "PunchRepository.h"
#import "Punch.h"
#import "RemotePunch.h"
#import <KSDeferred/KSDeferred.h>

@interface PunchRevitalizer ()

@property (nonatomic) PunchNotificationScheduler *punchNotificationScheduler;
@property (nonatomic) PunchOutboxStorage *punchOutboxStorage;
@property (nonatomic) PunchRepository *punchRepository;
@property (nonatomic) id <UserSession>userSession;
@property (nonatomic) PunchCreator *punchCreator;
@end

@implementation PunchRevitalizer

- (instancetype)initWithPunchNotificationScheduler:(PunchNotificationScheduler *)punchNotificationScheduler
                                punchOutboxStorage:(PunchOutboxStorage *)punchOutboxStorage
                                   punchRepository:(PunchRepository *)punchRepository
                                       userSession:(id <UserSession>)userSession
                                      punchCreator:(PunchCreator *)punchCreator {
    self = [super init];
    if (self)
    {
        self.punchNotificationScheduler = punchNotificationScheduler;
        self.punchOutboxStorage = punchOutboxStorage;
        self.punchRepository =  punchRepository;
        self.punchCreator = punchCreator;
        self.userSession = userSession;
    }
    return self;
}

- (void)revitalizePunches
{
    [self.punchNotificationScheduler cancelNotification];
    
    NSArray *outboxPunches = [self.punchOutboxStorage unSubmittedAndPendingSyncPunches];

    NSMutableArray *newOutboxPunches = [@[]mutableCopy];
    NSMutableArray *updatedOutboxPunches = [@[]mutableCopy];

    for (id<Punch>punch in outboxPunches)
    {
        if ([punch isKindOfClass:[RemotePunch class]])
        {
            [updatedOutboxPunches addObject:punch];

        }
        else
        {
            [newOutboxPunches addObject:punch];
        }
    }

    if (newOutboxPunches.count>0)
    {
        KSPromise *punchPromise = [self.punchCreator creationPromiseForPunch:newOutboxPunches];
        
        [punchPromise then:^id(id value) {
            [self.punchRepository punchOutboxQueueCoordinatorDidSyncPunches:nil];
            return nil;
        } error:^id(NSError *error) {
            if ([[error domain] isEqualToString:@"PunchCreatorErrorDomain"]) {
                 [self.punchRepository punchOutboxQueueCoordinatorDidSyncPunches:nil];
            }
            return nil;
        }];
    }

    if (updatedOutboxPunches.count>0)
    {
        [self.punchRepository updatePunch:updatedOutboxPunches];
    }
}



#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
