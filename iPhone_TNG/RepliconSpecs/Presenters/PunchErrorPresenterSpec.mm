#import <Cedar/Cedar.h>
#import "PunchErrorPresenter.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "FailedPunchErrorStorage.h"
#import "UIAlertView+Spec.h"
#import "Constants.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PunchErrorPresenterSpec)

describe(@"PunchErrorPresenter", ^{
    __block PunchErrorPresenter *subject;
    __block FailedPunchErrorStorage *failedPunchErrorStorage;
    __block id <BSBinder,BSInjector> injector;
    __block NSDateFormatter *longDateFormatter;
    __block NSDateFormatter *shortDateFormatter;
    __block NSDateFormatter *timeFormatter;
    beforeEach(^{
        injector = [InjectorProvider injector];
        
        
        longDateFormatter = nice_fake_for([NSDateFormatter class]);
        shortDateFormatter = nice_fake_for([NSDateFormatter class]);
        timeFormatter = nice_fake_for([NSDateFormatter class]);
        [injector bind:[NSDateFormatter class] toInstance:longDateFormatter];
        [injector bind:[NSDateFormatter class] toInstance:shortDateFormatter];
        [injector bind:[NSDateFormatter class] toInstance:timeFormatter];

        failedPunchErrorStorage = nice_fake_for([FailedPunchErrorStorage class]);
        [injector bind:[FailedPunchErrorStorage class] toInstance:failedPunchErrorStorage];
        
        subject = [[PunchErrorPresenter alloc] initWithLocalTimeZoneDateFormatter:longDateFormatter
                                                          failedPunchErrorStorage:failedPunchErrorStorage
                                                                    dateFormatter:shortDateFormatter
                                                                    timeFormatter:timeFormatter];;
    });
    
    describe(@"construct error description", ^{
        context(@"when there are errors to present", ^{
            __block NSArray *punchErrors;
            beforeEach(^{
                NSDate *currentDate =  [NSDate date];
                longDateFormatter stub_method(@selector(dateFromString:))
                .and_return(currentDate);
                
                shortDateFormatter stub_method(@selector(stringFromDate:))
                .and_return(@"Jan 1, 2017");

                timeFormatter stub_method(@selector(stringFromDate:))
                .and_return(@"01:00 AM");

                punchErrors = @[@{
                                    @"action_type" : @"Clocked In",
                                    @"activity_name" : @"activity-name",
                                    @"break_name" : @"<null>",
                                    @"client_name" : @"<null>",
                                    @"date" : [NSDate dateWithTimeIntervalSinceReferenceDate:0],
                                    @"error_msg" : @"error-msg sdlkfhkh ikwehgkjfjegwfkegwfjegw ikefyiuewyify ewfiuyiuweyf ewiufy \n skdjfhkofhkdhsfkjhsdkjfhvd dsvfsdvjklhdjklsh skjdhvkjsdh kjdhsvkjdhsv sdkjvhkjsdv jksdhv",
                                    @"project_name" : @"<null>",
                                    @"request_id" : @"ABCD123",
                                    @"task_name" : @"<null>",
                                    @"user_uri" : @"user:uri"
                                    },
                                @{
                                    @"action_type" : @"Clocked Out",
                                    @"activity_name" : @"<null>",
                                    @"break_name" : @"<null>",
                                    @"client_name" : @"<null>",
                                    @"date" : [NSDate dateWithTimeIntervalSinceReferenceDate:1],
                                    @"error_msg" : @"error-msg",
                                    @"project_name" : @"<null>",
                                    @"request_id" : @"ABCD123",
                                    @"task_name" : @"<null>",
                                    @"user_uri" : @"user:uri"
                                    },
                                @{
                                    @"action_type" : @"Break",
                                    @"activity_name" : @"<null>",
                                    @"break_name" : @"break-name",
                                    @"client_name" : @"<null>",
                                    @"date" : [NSDate dateWithTimeIntervalSinceReferenceDate:2],
                                    @"error_msg" : @"error-msg",
                                    @"project_name" : @"<null>",
                                    @"request_id" : @"ABCD123",
                                    @"task_name" : @"<null>",
                                    @"user_uri" : @"user:uri"
                                    }
                                ];
                
                failedPunchErrorStorage stub_method(@selector(getFailedPunchErrors)).and_return(punchErrors);
                [subject presentFailedPunchesErrors];
            });
            
            it(@"should return formatted string with date, time and error detail", ^{
                NSString *errorMsg = [NSString stringWithFormat:@"\n %@",RPLocalizedString(punchesWithErrorsMsg, punchesWithErrorsMsg)];
                NSString *firstPunchErrorMsg = @"Jan 1, 2017 at 01:00 AM, \n Clocked In with activity-name: error-msg sdlkfhkh ikwehgkjfjegwfkegwfjegw ikefyiuewyify ewfiuyiuweyf ewiufy \n skdjfhkofhkdhsfkjhsdkjfhvd dsvfsdvjklhdjklsh skjdhvkjsdh kjdhsvkjdhsv sdkjvhkjsdv jksdhv";
                NSString *secondPunchErrorMsg = @"Jan 1, 2017 at 01:00 AM, \n Clocked Out: error-msg";
                NSString *thirdPunchErrorMsg = @"Jan 1, 2017 at 01:00 AM, \n break-name Break: error-msg";
                
                errorMsg = [NSString stringWithFormat:@"\n %@ \n \n %@ \n \n %@ \n \n %@",RPLocalizedString(punchesWithErrorsMsg, punchesWithErrorsMsg), firstPunchErrorMsg, secondPunchErrorMsg, thirdPunchErrorMsg];
                
                UIAlertView *alertView = [UIAlertView currentAlertView];
                alertView.message should equal(errorMsg);
            });
            
            it(@"should delete all punch errors after showing to the user", ^{
                failedPunchErrorStorage should have_received(@selector(deletePunchErrors:)).with(punchErrors);
            });
        });
        
        context(@"when nothing to show", ^{
            beforeEach(^{
                failedPunchErrorStorage stub_method(@selector(getFailedPunchErrors)).and_return(@[]);
            });
            
            it(@"should not call deletePunchErrors", ^{
                failedPunchErrorStorage should_not have_received(@selector(deletePunchErrors:));
            });
        });

    });
});

SPEC_END
