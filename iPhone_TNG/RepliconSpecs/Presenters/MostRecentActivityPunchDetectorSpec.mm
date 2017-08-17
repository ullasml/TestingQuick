#import <Cedar/Cedar.h>
#import "MostRecentActivityPunchDetector.h"
#import "TimeLinePunchesStorage.h"
#import "Punch.h"
#import "LocalPunch.h"
#import "Activity.h"
#import "OEFType.h"
#import "Enum.h"
#import "PunchActionTypes.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MostRecentActivityPunchDetectorSpec)

describe(@"MostRecentActivityPunchDetector", ^{
    __block MostRecentActivityPunchDetector *subject;
    __block TimeLinePunchesStorage *storage;
    beforeEach(^{
        storage = nice_fake_for([TimeLinePunchesStorage class]);
        subject = [[MostRecentActivityPunchDetector alloc]initWithTimeLinePunchesStorage:storage];
    });
    
    describe(@"-mostRecentPunchIn", ^{
        
        context(@"When there is no previous punch in", ^{
            __block id<Punch> punch;
            beforeEach(^{
                punch = [subject mostRecentActivityPunch];
            });
            
            it(@"should return nil", ^{
                punch should be_nil;
            });
        });
        
        context(@"When there is punch in", ^{
            __block id<Punch> punch;
            __block LocalPunch *firstPunch, *secondPunch, *thirdPunch;
            beforeEach(^{
                Activity *activity = nice_fake_for([Activity class]);
                activity stub_method(@selector(name)).and_return(@"activity-name");
                
                firstPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:activity client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
                secondPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:activity client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]];
                
                thirdPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:activity client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];
                
                
                storage stub_method(@selector(recentPunches)).and_return(@[firstPunch, secondPunch, thirdPunch]);
                punch = [subject mostRecentActivityPunch];
            });
            
            it(@"should return latest punchin", ^{
                punch should equal(thirdPunch);
            });
        });
        
        context(@"When there is punch in along with transfer", ^{
            __block id<Punch> punch;
            __block LocalPunch *firstPunch, *secondPunch, *thirdPunch, *fourthPunch;
            beforeEach(^{
                Activity *activity = nice_fake_for([Activity class]);
                activity stub_method(@selector(name)).and_return(@"activity-name");
                
                firstPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:activity client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
                secondPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:activity client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]];
                
                thirdPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:activity client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];
                
                fourthPunch  = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:activity client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:3]];
                
                
                storage stub_method(@selector(recentPunches)).and_return(@[firstPunch, secondPunch, thirdPunch,fourthPunch]);
                punch = [subject mostRecentActivityPunch];
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
                punch = [subject mostRecentActivityPunch];
            });

            it(@"should return nil", ^{
                punch should be_nil;
            });
        });

        context(@"When there is punch in", ^{
            __block id<Punch> punch;
            __block LocalPunch *firstPunch, *secondPunch, *thirdPunch;
            beforeEach(^{
                Activity *activity = nice_fake_for([Activity class]);
                activity stub_method(@selector(name)).and_return(@"activity-name");

                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                NSArray *oefTypesArr = @[oefType1, oefType2];

                firstPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:activity client:nil oefTypes:oefTypesArr address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
                secondPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:activity client:nil oefTypes:oefTypesArr address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]];
                thirdPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:activity client:nil oefTypes:oefTypesArr address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];


                storage stub_method(@selector(recentPunches)).and_return(@[firstPunch, secondPunch, thirdPunch]);
                punch = [subject mostRecentActivityPunch];
            });

            it(@"should return latest punchin", ^{
                punch should equal(thirdPunch);
            });
        });

        context(@"When there is punch in along with transfer", ^{
            __block id<Punch> punch;
            __block LocalPunch *firstPunch, *secondPunch, *thirdPunch, *fourthPunch;
            beforeEach(^{
                Activity *activity = nice_fake_for([Activity class]);
                activity stub_method(@selector(name)).and_return(@"activity-name");

                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                NSArray *oefTypesArr = @[oefType1, oefType2];

                firstPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:activity client:nil oefTypes:oefTypesArr address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
                secondPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:activity client:nil oefTypes:oefTypesArr address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]];

                thirdPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:activity client:nil oefTypes:oefTypesArr address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];

                fourthPunch  = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:activity client:nil oefTypes:oefTypesArr address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:3]];


                storage stub_method(@selector(recentPunches)).and_return(@[firstPunch, secondPunch, thirdPunch,fourthPunch]);
                punch = [subject mostRecentActivityPunch];
            });

            it(@"should return latest punchin", ^{
                punch should equal(fourthPunch);
            });
        });
    });

});

SPEC_END
