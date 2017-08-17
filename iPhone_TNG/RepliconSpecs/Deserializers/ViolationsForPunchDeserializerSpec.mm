#import <Cedar/Cedar.h>
#import "ViolationsForPunchDeserializer.h"
#import "RepliconSpecHelper.h"
#import "AllViolationSections.h"
#import "ViolationSection.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "SingleViolationDeserializer.h"
#import "Violation.h"
#import "Waiver.h"
#import "WaiverOption.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ViolationsForPunchDeserializerSpec)

describe(@"ViolationsForPunchDeserializer", ^{
    __block ViolationsForPunchDeserializer *subject;
    __block id <BSBinder, BSInjector> injector;
    __block SingleViolationDeserializer *singleViolationDeserializer;

    beforeEach(^{
        singleViolationDeserializer = nice_fake_for([SingleViolationDeserializer class]);
        [injector bind:[SingleViolationDeserializer class] toInstance:singleViolationDeserializer];

        injector = [InjectorProvider injector];
        subject = [injector getInstance:[ViolationsForPunchDeserializer class]];
    });

    describe(@"-deserialize", ^{
        
        context(@"when data is nil", ^{
            __block AllViolationSections *allViolationSections;
            beforeEach(^{
                allViolationSections = [[AllViolationSections alloc] initWithTotalViolationsCount:0 sections:@[]];
                [subject deserialize:@{@"d":[NSNull null]}];
            });
            
            it(@"should not raise an exception", ^{
                ^ {[subject deserialize:@{@"d":[NSNull null]}]; } should_not raise_exception;
            });

            it(@"should send correct AllViolationSections object", ^{
                allViolationSections.totalViolationsCount should equal(0);
                [allViolationSections.sections count] should equal(0);
            });
        });
        
        context(@"when data is available", ^{
            __block AllViolationSections *allViolationSections;
            __block ViolationSection *expectedViolationSection;
            __block ViolationSection *violationSection;
            __block NSArray *expectedViolationsArray;
            __block NSDate *expectedDate;
            __block WaiverOption *waiverOptionAccept;
            __block WaiverOption *waiverOptionReject;
            __block WaiverOption *expectedWaiverOptionA;
            __block WaiverOption *expectedWaiverOptionB;
            __block Waiver *waiver;
            __block Waiver *expectedWaiver;
            __block Violation *expectedViolation;
            __block Violation *violation;
            
            beforeEach(^{
                
                NSDictionary *jsonDictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_validations_for_punch"];
                
                waiverOptionAccept = [[WaiverOption alloc]initWithDisplayText:@"Waive Meal Penalty" value:@"accept"];
                waiverOptionReject = [[WaiverOption alloc]initWithDisplayText:@"Do not Waive" value:@"reject"];
                
                waiver = [[Waiver alloc]initWithURI:@"urn:replicon-tenant:astro:validation-waiver:a8cf3ab6-2bae-4c95-9529-f4dbc7f7a517"
                                        displayText:@"To waive this violation, click the button below. Employees waives violation pay for this day." options:@[waiverOptionAccept, waiverOptionReject] selectedOption:nil];
                
                expectedViolation = [[Violation alloc]initWithSeverity:ViolationSeverityError
                                                                waiver:waiver
                                                                 title:@"Error validation"];
                
                NSArray *validationMessages = @[expectedViolation];
                NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
                dateComponents.day = 29;
                dateComponents.month = 5;
                dateComponents.year = 2015;
                dateComponents.hour = 17;
                dateComponents.minute = 7;
                dateComponents.second = 0;
                
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                expectedDate = [calendar dateFromComponents:dateComponents];
                
                expectedViolationSection = [[ViolationSection alloc] initWithTitleObject:expectedDate
                                                                              violations:validationMessages
                                                                                    type:ViolationSectionTypeDate];
                expectedViolationsArray = @[expectedViolationSection];
                allViolationSections = [subject deserialize:jsonDictionary];
                
                violationSection = [allViolationSections.sections firstObject];
                violation = [violationSection.violations firstObject];
                expectedWaiver = violation.waiver;
                expectedWaiverOptionA = [expectedWaiver.options firstObject];
                expectedWaiverOptionB = [expectedWaiver.options lastObject];
                
            });
            
            it(@"should send correct AllViolationSections object", ^{
                allViolationSections.totalViolationsCount should equal(1);
                [allViolationSections.sections count] should equal(1);
            });
            
            it(@"should send correct ViolationSection object", ^{
                violationSection.titleObject should equal(expectedViolationSection.titleObject);
                [violationSection.violations count] should equal(1);
                violationSection.type should equal(expectedViolationSection.type);
            });
            
            it(@"should send correct Violation object", ^{
                violation.title should equal(expectedViolation.title);
                violation.severity should equal(expectedViolation.severity);
            });
            
            it(@"should should send correct Waiver object", ^{
                expectedWaiver.URI should equal(waiver.URI);
                expectedWaiver.displayText should equal(waiver.displayText);
                [expectedWaiver.options count] should equal([waiver.options count]);
            });
            it(@"should should send correct WaiverOption object", ^{
                expectedWaiverOptionA.displayText should equal(waiverOptionAccept.displayText);
                expectedWaiverOptionA.value should equal(waiverOptionAccept.value);
                
                expectedWaiverOptionB.displayText should equal(waiverOptionReject.displayText);
                expectedWaiverOptionB.value should equal(waiverOptionReject.value);
            });
        });
    });
});

SPEC_END
