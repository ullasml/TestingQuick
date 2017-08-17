#import <Cedar/Cedar.h>
#import "MostRecentPunchInDetector.h"
#import "TimeLinePunchesStorage.h"
#import "Punch.h"
#import "LocalPunch.h"
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "OEFType.h"
#import "Enum.h"
#import "PunchActionTypes.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MostRecentPunchInDetectorSpec)

describe(@"MostRecentPunchInDetector", ^{
    __block MostRecentPunchInDetector *subject;
    __block TimeLinePunchesStorage *storage;
    beforeEach(^{
        storage = nice_fake_for([TimeLinePunchesStorage class]);
        subject = [[MostRecentPunchInDetector alloc]initWithTimeLinePunchesStorage:storage];
    });

    describe(@"-mostRecentPunchIn", ^{

        context(@"When there is no previous punch in", ^{
            __block id<Punch> punch;
            beforeEach(^{
                 punch = [subject mostRecentPunchIn];
            });
            
            it(@"should return nil", ^{
                punch should be_nil;
            });
        });

        context(@"When there is punch in", ^{
            __block id<Punch> punch;
            __block LocalPunch *firstPunch, *secondPunch, *thirdPunch;
            beforeEach(^{
                ClientType *client = nice_fake_for([ClientType class]);
                client stub_method(@selector(name)).and_return(@"client-name");
                
                ProjectType *project = nice_fake_for([ProjectType class]);
                project stub_method(@selector(name)).and_return(@"project-name");
                
                TaskType *task = nice_fake_for([TaskType class]);
                task stub_method(@selector(name)).and_return(@"task-name");
                
                firstPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:project requestID:NULL activity:nil client:client oefTypes:nil address:nil userURI:@"user:uri" image:nil task:task date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
                secondPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:nil project:project requestID:NULL activity:nil client:client oefTypes:nil address:nil userURI:@"user:uri" image:nil task:task date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]];

                thirdPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:project requestID:NULL activity:nil client:client oefTypes:nil address:nil userURI:@"user:uri" image:nil task:task date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];


                storage stub_method(@selector(recentPunches)).and_return(@[firstPunch, secondPunch, thirdPunch]);
                punch = [subject mostRecentPunchIn];
            });
            
            it(@"should return latest punchin", ^{
                punch should equal(thirdPunch);
            });
        });

        context(@"When there is punch in along with transfer", ^{
            __block id<Punch> punch;
            __block LocalPunch *firstPunch, *secondPunch, *thirdPunch, *fourthPunch;
            beforeEach(^{
                ClientType *client = nice_fake_for([ClientType class]);
                client stub_method(@selector(name)).and_return(@"client-name");

                ProjectType *project = nice_fake_for([ProjectType class]);
                project stub_method(@selector(name)).and_return(@"project-name");

                TaskType *task = nice_fake_for([TaskType class]);
                task stub_method(@selector(name)).and_return(@"task-name");

                firstPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:project requestID:NULL activity:nil client:client oefTypes:nil address:nil userURI:@"user:uri" image:nil task:task date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
                secondPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:nil project:project requestID:NULL activity:nil client:client oefTypes:nil address:nil userURI:@"user:uri" image:nil task:task date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]];

                thirdPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:project requestID:NULL activity:nil client:client oefTypes:nil address:nil userURI:@"user:uri" image:nil task:task date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];

                fourthPunch  = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:project requestID:NULL activity:nil client:client oefTypes:nil address:nil userURI:@"user:uri" image:nil task:task date:[NSDate dateWithTimeIntervalSinceReferenceDate:3]];


                storage stub_method(@selector(recentPunches)).and_return(@[firstPunch, secondPunch, thirdPunch,fourthPunch]);
                punch = [subject mostRecentPunchIn];
            });

            it(@"should return latest punchin", ^{
                punch should equal(fourthPunch);
            });
        });
    });

    describe(@"with OEF -mostRecentPunchIn", ^{

        context(@"When there is no previous punch in", ^{
            __block id<Punch> punch;
            beforeEach(^{
                punch = [subject mostRecentPunchIn];
            });

            it(@"should return nil", ^{
                punch should be_nil;
            });
        });

        context(@"When there is punch in", ^{
            __block id<Punch> punch;
            __block LocalPunch *firstPunch, *secondPunch, *thirdPunch;
            beforeEach(^{
                ClientType *client = nice_fake_for([ClientType class]);
                client stub_method(@selector(name)).and_return(@"client-name");

                ProjectType *project = nice_fake_for([ProjectType class]);
                project stub_method(@selector(name)).and_return(@"project-name");

                TaskType *task = nice_fake_for([TaskType class]);
                task stub_method(@selector(name)).and_return(@"task-name");

                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                NSArray *oefTypesArr = @[oefType1, oefType2];

                firstPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:project requestID:NULL activity:nil client:client oefTypes:oefTypesArr address:nil userURI:@"user:uri" image:nil task:task date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
                secondPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:nil project:project requestID:NULL activity:nil client:client oefTypes:oefTypesArr address:nil userURI:@"user:uri" image:nil task:task date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]];

                thirdPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:project requestID:NULL activity:nil client:client oefTypes:oefTypesArr address:nil userURI:@"user:uri" image:nil task:task date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];


                storage stub_method(@selector(recentPunches)).and_return(@[firstPunch, secondPunch, thirdPunch]);
                punch = [subject mostRecentPunchIn];
            });

            it(@"should return latest punchin", ^{
                punch should equal(thirdPunch);
            });
        });

        context(@"When there is punch in along with transfer", ^{
            __block id<Punch> punch;
            __block LocalPunch *firstPunch, *secondPunch, *thirdPunch, *fourthPunch;
            beforeEach(^{
                ClientType *client = nice_fake_for([ClientType class]);
                client stub_method(@selector(name)).and_return(@"client-name");

                ProjectType *project = nice_fake_for([ProjectType class]);
                project stub_method(@selector(name)).and_return(@"project-name");

                TaskType *task = nice_fake_for([TaskType class]);
                task stub_method(@selector(name)).and_return(@"task-name");

                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                NSArray *oefTypesArr = @[oefType1, oefType2];

                firstPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:project requestID:NULL activity:nil client:client oefTypes:oefTypesArr address:nil userURI:@"user:uri" image:nil task:task date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
                secondPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:nil project:project requestID:NULL activity:nil client:client oefTypes:oefTypesArr address:nil userURI:@"user:uri" image:nil task:task date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]];

                thirdPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:project requestID:NULL activity:nil client:client oefTypes:oefTypesArr address:nil userURI:@"user:uri" image:nil task:task date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];

                fourthPunch  = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:project requestID:NULL activity:nil client:client oefTypes:oefTypesArr address:nil userURI:@"user:uri" image:nil task:task date:[NSDate dateWithTimeIntervalSinceReferenceDate:3]];


                storage stub_method(@selector(recentPunches)).and_return(@[firstPunch, secondPunch, thirdPunch,fourthPunch]);
                punch = [subject mostRecentPunchIn];
            });
            
            it(@"should return latest punchin", ^{
                punch should equal(fourthPunch);
            });
        });
    });
});

SPEC_END
