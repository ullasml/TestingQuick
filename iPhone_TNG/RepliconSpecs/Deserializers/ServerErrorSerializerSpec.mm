#import <Cedar/Cedar.h>
#import "ServerErrorSerializer.h"
#import "RepliconSpecHelper.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "TimesheetNavigationController.h"
#import "ExpensesNavigationController.h"
#import "BookedTimeOffNavigationController.h"
#import "ApprovalsNavigationController.h"
#import "ApprovalsPendingTimesheetViewController.h"
#import "ApprovalsTimesheetHistoryViewController.h"
#import "ApprovalsPendingExpenseViewController.h"
#import "ApprovalsExpenseHistoryViewController.h"
#import "ApprovalsPendingTimeOffViewController.h"
#import "ApprovalsTimeOffHistoryViewController.h"
#import "SupervisorDashboardNavigationController.h"
#import "PunchHomeNavigationController.h"
#import "URLStringProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ServerErrorSerializerSpec)

describe(@"ServerErrorSerializer", ^{
    __block ServerErrorSerializer *subject;
    __block AppDelegate *appDelegate;
    __block URLStringProvider *urlStringProvider;
    __block NSURLRequest *request;
    beforeEach(^{
        appDelegate = nice_fake_for([AppDelegate class]);
        urlStringProvider = nice_fake_for([URLStringProvider class]);
        request = nice_fake_for([NSURLRequest class]);
        NSURL *url = [NSURL URLWithString:@"my-url"];
        request stub_method(@selector(URL)).and_return(url);
        urlStringProvider stub_method(@selector(urlStringWithEndpointName:)).and_return(@"");
        
        subject = [[ServerErrorSerializer alloc]
                                          initWithAppdelegateUrlStringProvider:urlStringProvider
                                                                   appDelegate:appDelegate];
    });

    describe(@"-deserialize:isFromRequestMadeWhilePendingQueueSync:", ^{

        context(@"When edit punch Error", ^{
            __block NSError *editPuncherror;

            context(@"With no errors returned from server", ^{
                beforeEach(^{
                    NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"edit_punch_error"];
                    editPuncherror = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                });

                it(@"should reject the returned promise with an error", ^{
                    editPuncherror.domain should equal(RandomErrorDomain);
                    editPuncherror.code should equal(200);
                    editPuncherror.localizedDescription should equal(@"URI not found : Incorrect URI Type : urn:replicon-tenant:repliconiphone-2:time-punch:96a38130-0d64-47fa-b38d-700aff1d262d");
                });

            });

            context(@"With errors returned from server", ^{
                beforeEach(^{
                    NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"edit_punch_error_with_notifications"];
                    editPuncherror = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                });

                it(@"should reject the returned promise with an error", ^{
                    editPuncherror.domain should equal(RandomErrorDomain);
                    editPuncherror.code should equal(200);
                    NSString *errorMsg=[NSString stringWithFormat:@"%@\n\n%@",@"random error1",@"random error2"];
                    editPuncherror.localizedDescription should equal(errorMsg);
                });

            });
            
            context(@"With invaild project error returned from server", ^{
                beforeEach(^{
                    NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"invalid_project_or_task_error"];
                    editPuncherror = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                });
                
                it(@"should reject the returned promise with an error", ^{
                    editPuncherror.domain should equal(RandomErrorDomain);
                    editPuncherror.code should equal(200);
                    editPuncherror.localizedDescription should equal(RPLocalizedString(@"The Project or Task selected is closed or you are no longer assigned to it.", nil));
                });
                
                it(@"should return expected failureUri", ^{
                    NSString *failureUri = editPuncherror.userInfo[@"ErroredPunches"][0][@"failureUri"];
                    failureUri should equal(invalidProjectFailureUri);
                });
                
            });


            context(@"Without any server error", ^{
                beforeEach(^{
                    NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"edit_punch_no_error"];
                    editPuncherror = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                });

                it(@"should reject the returned promise with an error", ^{
                    editPuncherror should be_nil;
                });
            });

            context(@"With multiple errors returned from server along with successfull punch for bulk creating punch", ^{
                beforeEach(^{
                    NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"bulk_punch_multiple_error_with_notifications"];
                    editPuncherror = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                });

                it(@"should reject the returned promise with an error", ^{
                    editPuncherror.domain should equal(RandomErrorDomain);
                    editPuncherror.code should equal(200);
                    NSString *errorMsg=[NSString stringWithFormat:@"%@\n%@",@"Activity is required on time punch",@"Activity is required on time punch"];
                    editPuncherror.localizedDescription should equal(errorMsg);
                });
                
            });
            
            context(@"With multiple errors returned from server along with successfull punch for bulk updating punch", ^{
                beforeEach(^{
                    NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"bulk_update_punch_multiple_error_with_notifications"];
                    editPuncherror = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                });

                it(@"should reject the returned promise with an error", ^{
                    editPuncherror.domain should equal(RandomErrorDomain);
                    editPuncherror.code should equal(200);
                    NSString *errorMsg=[NSString stringWithFormat:@"%@\n%@",@"Oct 9 at 6:31PM: Punch could not be saved to server. Activity is required on time punch",@"Oct 9 at 6:33PM: Punch could not be saved to server. Invalid TimePunchParameter. Start break attributes must be provided if time punch action is start-break."];
                    editPuncherror.localizedDescription should equal(errorMsg);
                });

                it(@"error user info ErroredPunches should bee correct", ^{
                    editPuncherror.userInfo[@"ErroredPunches"] should equal(@[
                   @{@"displayText" : @"Oct 9 at 6:31PM: Punch could not be saved to server. Activity is required on time punch",@"parameterCorrelationId" : @"a0c2f495-e5a9-456d-a7c0-b7f24748ece6"},
                   @{@"displayText" : @"Oct 9 at 6:33PM: Punch could not be saved to server. Invalid TimePunchParameter. Start break attributes must be provided if time punch action is start-break.", @"parameterCorrelationId" : @"b4d7ffd2-ace1-49fc-abec-16ec44dbff91"}                   ]);
                });

            });
        });

        describe(@"When other generic errors", ^{

            context(@"When <NoErrorFailureUriDomain> Error", ^{
                __block NSError *error;
                beforeEach(^{
                    NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"No_Failure_Uri_error"];
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                });

                it(@"should reject the returned promise with an error", ^{
                    error.domain should equal(RepliconNoAlertErrorDomain);
                });

            });
            context(@"When <AuthenticationError> Error", ^{
                __block NSError *error;

                context(@"When security error", ^{
                    beforeEach(^{
                        NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"invalid_password_security_error"];
                        error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    });

                    it(@"should reject the returned promise with an error", ^{
                        error.domain should equal(PasswordAuthenticationErrorDomain);
                        error.localizedDescription should equal(RPLocalizedString(USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_MESSAGE, nil));
                    });
                });
                context(@"When application error", ^{
                    beforeEach(^{
                        NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"invalid_password_application_error"];
                        error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    });

                    it(@"should reject the returned promise with an error", ^{
                        error.domain should equal(PasswordAuthenticationErrorDomain);
                        error.localizedDescription should equal(RPLocalizedString(USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_MESSAGE, nil));

                    });
                });

            });

            context(@"When <CompanyKeyError> Error", ^{
                __block NSError *error;
                beforeEach(^{
                    NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"invalid_company_error"];
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                });
                it(@"should reject the returned promise with an error", ^{
                    error.domain should equal(CompanyAuthenticationErrorDomain);
                    error.localizedDescription should equal(RPLocalizedString(COMPANY_NOT_EXISTS_ERROR_MESSAGE, nil));
                });
            });

            context(@"When <CompanyDisabled> Error", ^{
                __block NSError *error;

                context(@"When security error", ^{
                    beforeEach(^{
                        NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"company_disabled_security_error"];
                        error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    });

                    it(@"should reject the returned promise with an error", ^{
                        error.domain should equal(CompanyDisabledErrorDomain);
                        error.localizedDescription should equal(RPLocalizedString(COMPANY_DISABLED_ERROR_MESSAGE, nil));

                    });
                });
                context(@"When application error", ^{
                    beforeEach(^{
                        NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"company_disabled_authentication_error"];
                        error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    });

                    it(@"should reject the returned promise with an error", ^{
                        error.domain should equal(CompanyDisabledErrorDomain);
                        error.localizedDescription should equal(RPLocalizedString(COMPANY_DISABLED_ERROR_MESSAGE, nil));

                    });
                });

            });

            context(@"When <NoAuthentication> Error", ^{
                __block NSError *error;

                context(@"When security error", ^{
                    beforeEach(^{
                        NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"no_auth_security_error"];
                        error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    });

                    it(@"should reject the returned promise with an error", ^{
                        error.domain should equal(NoAuthErrorDomain);
                        error.localizedDescription should equal(RPLocalizedString(NO_AUTH_CREDENTIALS_PROVIDED_ERROR_MESSAGE, nil));
                    });
                });
                context(@"When application error", ^{
                    beforeEach(^{
                        NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"no_auth_authentication_error"];
                        error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    });

                    it(@"should reject the returned promise with an error", ^{
                        error.domain should equal(NoAuthErrorDomain);
                        error.localizedDescription should equal(RPLocalizedString(NO_AUTH_CREDENTIALS_PROVIDED_ERROR_MESSAGE, nil));
                    });
                });

            });

            context(@"When <Password Expired> Error", ^{
                __block NSError *error;

                context(@"When security error", ^{
                    beforeEach(^{
                        NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"password_expired_security_error"];
                        error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    });

                    it(@"should reject the returned promise with an error", ^{
                        error.domain should equal(PasswordExpiredErrorDomain);
                        error.localizedDescription should equal(RPLocalizedString(USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_MESSAGE, nil));

                    });
                });
                context(@"When application error", ^{
                    beforeEach(^{
                        NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"password_expired_authentication_error"];
                        error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    });

                    it(@"should reject the returned promise with an error", ^{
                        error.domain should equal(PasswordExpiredErrorDomain);
                        error.localizedDescription should equal(RPLocalizedString(USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_MESSAGE, nil));

                    });
                });

            });

            context(@"When <Unknown> Error", ^{
                __block NSError *error;

                context(@"When security error", ^{
                    beforeEach(^{
                        NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"unknown_security_error"];
                        error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    });

                    it(@"should reject the returned promise with an error", ^{
                        error.domain should equal(UnknownErrorDomain);
                        error.localizedDescription should equal(RPLocalizedString(UNKNOWN_ERROR_MESSAGE, nil));

                    });
                });
                context(@"When application error", ^{
                    beforeEach(^{
                        NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"unknown_authentication_error"];
                        error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    });

                    it(@"should reject the returned promise with an error", ^{
                        error.domain should equal(UnknownErrorDomain);
                        error.localizedDescription should equal(RPLocalizedString(UNKNOWN_ERROR_MESSAGE, nil));

                    });
                });

            });

            context(@"When <UserAuthChange> Error", ^{
                __block NSError *error;

                context(@"When security error", ^{
                    beforeEach(^{
                        NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"user_auth_change_security_error"];
                        error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    });

                    it(@"should reject the returned promise with an error", ^{
                        error.domain should equal(UserAuthChangeErrorDomain);
                        error.localizedDescription should equal(RPLocalizedString(USER_AUTHENTICATION_CHANGE_ERROR_MESSAGE, nil));

                    });
                });
                context(@"When application error", ^{
                    beforeEach(^{
                        NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"user_auth_change_authentication_error"];
                        error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    });

                    it(@"should reject the returned promise with an error", ^{
                        error.domain should equal(UserAuthChangeErrorDomain);
                        error.localizedDescription should equal(RPLocalizedString(USER_AUTHENTICATION_CHANGE_ERROR_MESSAGE, nil));

                    });
                });

            });

            context(@"When <UserDisabled> Error", ^{
                __block NSError *error;

                context(@"When security error", ^{
                    beforeEach(^{
                        NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"user_disabled_security_error"];
                        error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    });

                    it(@"should reject the returned promise with an error", ^{
                        error.domain should equal(UserDisabledErrorDomain);
                        error.localizedDescription should equal(RPLocalizedString(USER_DISABLED_ERROR_MESSAGE, nil));

                    });
                });
                context(@"When application error", ^{
                    beforeEach(^{
                        NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"user_disabled_authentication_error"];
                        error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    });

                    it(@"should reject the returned promise with an error", ^{
                        error.domain should equal(UserDisabledErrorDomain);
                        error.localizedDescription should equal(RPLocalizedString(USER_DISABLED_ERROR_MESSAGE, nil));

                    });
                });

            });
        });

        describe(@"When InvalidTimesheetFormatError", ^{
            __block NSError *error;
            beforeEach(^{
                NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"Invalid_timesheet_format_error"];
                error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request] ;
            });

            it(@"should reject the returned promise with an error", ^{
                error.domain should equal(InvalidTimesheetFormatErrorDomain);
                error.localizedDescription should equal(RPLocalizedString(TIMESHEET_FORMAT_NOT_SUPPORTED_IN_MOBILE, nil));
            });
        });

        describe(@"When OperationExecutionTimeoutError1", ^{
            __block NSError *error;
            beforeEach(^{
                NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"Operation_Execution_Timeout_error"];
                error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
            });

            it(@"should reject the returned promise with an error", ^{
                error.domain should equal(OperationTimeoutErrorDomain);
                error.localizedDescription should equal(RPLocalizedString(ERROR_URLErrorTimedOut_FromServer, nil));
            });
        });

        describe(@"When UriError1", ^{
            __block NSError *error;
            __block NSDictionary *errorDictionary;
            beforeEach(^{
                errorDictionary = [RepliconSpecHelper jsonWithFixture:@"uri_error"];
            });

            context(@"When navigation is through TimesheetNavigationController", ^{
                beforeEach(^{
                    UINavigationController *navigationController = nice_fake_for([TimesheetNavigationController class]);
                    UITabBarController *tabBarController = nice_fake_for([UITabBarController class]);
                    tabBarController stub_method(@selector(selectedViewController)).and_return(navigationController);
                    appDelegate stub_method(@selector(rootTabBarController)).and_return(tabBarController);
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                });
                it(@"should reject the returned promise with an error", ^{
                    error.domain should equal(UriErrorDomain);
                    error.localizedDescription should equal(RPLocalizedString(Timesheet_URLError_Msg, nil));
                });
            });

            context(@"When navigation is through ExpensesNavigationController", ^{
                beforeEach(^{
                    UINavigationController *navigationController = nice_fake_for([ExpensesNavigationController class]);
                    UITabBarController *tabBarController = nice_fake_for([UITabBarController class]);
                    tabBarController stub_method(@selector(selectedViewController)).and_return(navigationController);
                    appDelegate stub_method(@selector(rootTabBarController)).and_return(tabBarController);
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                });
                it(@"should reject the returned promise with an error", ^{
                    error.domain should equal(UriErrorDomain);
                    error.localizedDescription should equal(RPLocalizedString(Expense_URLError_Msg, nil));
                });
            });

            context(@"When navigation is through BookedTimeOffNavigationController", ^{
                beforeEach(^{
                    UINavigationController *navigationController = nice_fake_for([BookedTimeOffNavigationController class]);
                    UITabBarController *tabBarController = nice_fake_for([UITabBarController class]);
                    tabBarController stub_method(@selector(selectedViewController)).and_return(navigationController);
                    appDelegate stub_method(@selector(rootTabBarController)).and_return(tabBarController);
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                });
                it(@"should reject the returned promise with an error", ^{
                    error.domain should equal(UriErrorDomain);
                    error.localizedDescription should equal(RPLocalizedString(TimeOff_URLErroe_Msg, nil));
                });
            });

            context(@"When navigation is through ApprovalsNavigationController", ^{
                __block UINavigationController <CedarDouble> *navigationController;
                beforeEach(^{
                    navigationController = nice_fake_for([ApprovalsNavigationController class]);
                    UITabBarController *tabBarController = nice_fake_for([UITabBarController class]);
                    tabBarController stub_method(@selector(selectedViewController)).and_return(navigationController);
                    appDelegate stub_method(@selector(rootTabBarController)).and_return(tabBarController);

                });

                it(@"when rootView of navigation is ApprovalsPendingTimesheetViewController should reject the returned promise with an error", ^{
                    ApprovalsPendingTimesheetViewController *controller = nice_fake_for([ApprovalsPendingTimesheetViewController class]);
                    navigationController stub_method(@selector(viewControllers)).and_return(@[controller]);
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    error.domain should equal(UriErrorDomain);
                    error.localizedDescription should equal(RPLocalizedString(Pending_Timesheet_URLError_Msg, nil));
                });

                it(@"when rootView of navigation is ApprovalsTimesheetHistoryViewController should reject the returned promise with an error", ^{
                    ApprovalsTimesheetHistoryViewController *controller = nice_fake_for([ApprovalsTimesheetHistoryViewController class]);
                    navigationController stub_method(@selector(viewControllers)).and_return(@[controller]);
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    error.domain should equal(UriErrorDomain);
                    error.localizedDescription should equal(RPLocalizedString(Previous_Timesheet_URLError_Msg, nil));
                });

                it(@"when rootView of navigation is ApprovalsPendingExpenseViewController should reject the returned promise with an error", ^{
                    ApprovalsPendingExpenseViewController *controller = nice_fake_for([ApprovalsPendingExpenseViewController class]);
                    navigationController stub_method(@selector(viewControllers)).and_return(@[controller]);
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    error.domain should equal(UriErrorDomain);
                    error.localizedDescription should equal(RPLocalizedString(Pending_Expense_URLError_Msg, nil));
                });

                it(@"when rootView of navigation is ApprovalsExpenseHistoryViewController should reject the returned promise with an error", ^{
                    ApprovalsExpenseHistoryViewController *controller = nice_fake_for([ApprovalsExpenseHistoryViewController class]);
                    navigationController stub_method(@selector(viewControllers)).and_return(@[controller]);
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    error.domain should equal(UriErrorDomain);
                    error.localizedDescription should equal(RPLocalizedString(Previous_Expense_URLError_Msg, nil));
                });

                it(@"when rootView of navigation is ApprovalsPendingTimeOffViewController should reject the returned promise with an error", ^{
                    ApprovalsPendingTimeOffViewController *controller = nice_fake_for([ApprovalsPendingTimeOffViewController class]);
                    navigationController stub_method(@selector(viewControllers)).and_return(@[controller]);
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    error.domain should equal(UriErrorDomain);
                    error.localizedDescription should equal(RPLocalizedString(Pending_TimeOff_URLErroe_Msg, nil));
                });

                it(@"when rootView of navigation is ApprovalsTimeOffHistoryViewController should reject the returned promise with an error", ^{
                    ApprovalsTimeOffHistoryViewController *controller = nice_fake_for([ApprovalsTimeOffHistoryViewController class]);
                    navigationController stub_method(@selector(viewControllers)).and_return(@[controller]);
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    error.domain should equal(UriErrorDomain);
                    error.localizedDescription should equal(RPLocalizedString(Previous_TimeOff_URLErroe_Msg, nil));
                });
            });

            context(@"When navigation is through SupervisorDashboardNavigationController", ^{
                __block UINavigationController<CedarDouble> *navigationController;
                beforeEach(^{
                    navigationController = nice_fake_for([SupervisorDashboardNavigationController class]);
                    UITabBarController *tabBarController = nice_fake_for([UITabBarController class]);
                    tabBarController stub_method(@selector(selectedViewController)).and_return(navigationController);
                    appDelegate stub_method(@selector(rootTabBarController)).and_return(tabBarController);

                });

                it(@"when rootView of navigation is ApprovalsPendingTimesheetViewController should reject the returned promise with an error", ^{
                    ApprovalsPendingTimesheetViewController *controller = nice_fake_for([ApprovalsPendingTimesheetViewController class]);
                    navigationController stub_method(@selector(viewControllers)).and_return(@[controller]);
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    error.domain should equal(UriErrorDomain);
                    error.localizedDescription should equal(RPLocalizedString(Pending_Timesheet_URLError_Msg, nil));
                });

                it(@"when rootView of navigation is ApprovalsTimesheetHistoryViewController should reject the returned promise with an error", ^{
                    ApprovalsTimesheetHistoryViewController *controller = nice_fake_for([ApprovalsTimesheetHistoryViewController class]);
                    navigationController stub_method(@selector(viewControllers)).and_return(@[controller]);
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    error.domain should equal(UriErrorDomain);
                    error.localizedDescription should equal(RPLocalizedString(Previous_Timesheet_URLError_Msg, nil));
                });

                it(@"when rootView of navigation is ApprovalsPendingExpenseViewController should reject the returned promise with an error", ^{
                    ApprovalsPendingExpenseViewController *controller = nice_fake_for([ApprovalsPendingExpenseViewController class]);
                    navigationController stub_method(@selector(viewControllers)).and_return(@[controller]);
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    error.domain should equal(UriErrorDomain);
                    error.localizedDescription should equal(RPLocalizedString(Pending_Expense_URLError_Msg, nil));
                });

                it(@"when rootView of navigation is ApprovalsExpenseHistoryViewController should reject the returned promise with an error", ^{
                    ApprovalsExpenseHistoryViewController *controller = nice_fake_for([ApprovalsExpenseHistoryViewController class]);
                    navigationController stub_method(@selector(viewControllers)).and_return(@[controller]);
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    error.domain should equal(UriErrorDomain);
                    error.localizedDescription should equal(RPLocalizedString(Previous_Expense_URLError_Msg, nil));
                });

                it(@"when rootView of navigation is ApprovalsPendingTimeOffViewController should reject the returned promise with an error", ^{
                    [navigationController reset_sent_messages];
                    ApprovalsPendingTimeOffViewController *controller = nice_fake_for([ApprovalsPendingTimeOffViewController class]);
                    navigationController stub_method(@selector(viewControllers)).and_return(@[controller]);
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request] ;
                    error.domain should equal(UriErrorDomain);
                    error.localizedDescription should equal(RPLocalizedString(Pending_TimeOff_URLErroe_Msg, nil));
                });

                it(@"when rootView of navigation is ApprovalsTimeOffHistoryViewController should reject the returned promise with an error", ^{
                    [navigationController reset_sent_messages];
                    ApprovalsTimeOffHistoryViewController *controller = nice_fake_for([ApprovalsTimeOffHistoryViewController class]);
                    navigationController stub_method(@selector(viewControllers)).and_return(@[controller]);
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                    error.domain should equal(UriErrorDomain);
                    error.localizedDescription should equal(RPLocalizedString(Previous_TimeOff_URLErroe_Msg, nil));
                });
            });

            context(@"When navigation is through PunchHomeNavigationController", ^{
                beforeEach(^{
                    UINavigationController *navigationController = nice_fake_for([PunchHomeNavigationController class]);
                    UITabBarController *tabBarController = nice_fake_for([UITabBarController class]);
                    tabBarController stub_method(@selector(selectedViewController)).and_return(navigationController);
                    appDelegate stub_method(@selector(rootTabBarController)).and_return(tabBarController);
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                });
                it(@"should reject the returned promise with an error", ^{
                    error.domain should equal(UriErrorDomain);
                    error.localizedDescription should equal(RPLocalizedString(Punch_URLError_Msg, nil));
                });
            });


        });

        describe(@"When any random error", ^{

            context(@"with no error text", ^{
                __block NSError *error;
                beforeEach(^{
                    NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"some_random_error_without_text"];
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                });

                it(@"should reject the returned promise with an error", ^{
                    error.domain should equal(RepliconNoAlertErrorDomain);
                    error.localizedDescription should equal(RPLocalizedString(UNKNOWN_ERROR_MESSAGE, nil));
                });
            });

            context(@"with single error text", ^{
                __block NSError *error;
                beforeEach(^{
                    NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"some_random_error"];
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                });

                it(@"should reject the returned promise with an error", ^{
                    error.domain should equal(RandomErrorDomain);
                    error.localizedDescription should equal(@"random error1");
                });
            });

            context(@"with multiple error text", ^{
                __block NSError *error;
                beforeEach(^{
                    NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"some_random_multiple_error"];
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                });

                it(@"should reject the returned promise with an error", ^{
                    error.domain should equal(RandomErrorDomain);
                    NSString *errorMsg=[NSString stringWithFormat:@"%@\n\n%@",@"random error1",@"random error2"];
                    error.localizedDescription should equal(errorMsg);
                });
            });
        });

        describe(@"When delete punch error", ^{
            __block NSError *deletePuncherror;
            beforeEach(^{
                NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"delete_punch_error"];
                deletePuncherror = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
            });

            it(@"should reject the returned promise with an error", ^{
                deletePuncherror.domain should equal(RandomErrorDomain);
                deletePuncherror.code should equal(200);
                deletePuncherror.localizedDescription should equal(@"You are not authorized to take this action");
            });
        });

        describe(@"When no error", ^{
            __block NSError *error;
            beforeEach(^{
                NSDictionary *errorDictionary = @{@"d":[NSNull null]};
                error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
            });

            it(@"should not be an error", ^{
                error should be_nil;
            });
        });

        describe(@"When any random error and isFromRequestMadeWhilePendingQueueSync is TRUE", ^{

            context(@"with no error text", ^{
                __block NSError *error;
                beforeEach(^{
                    NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"some_random_error_without_text"];
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:YES request:request];
                });

                it(@"should reject the returned promise with an error", ^{
                    error.domain should equal(RepliconNoAlertErrorDomain);
                    error.localizedDescription should equal(RPLocalizedString(UNKNOWN_ERROR_MESSAGE, nil));
                });
            });

            context(@"with single error text", ^{
                __block NSError *error;
                beforeEach(^{
                    NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"some_random_error"];
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:YES request:request];
                });

                it(@"should reject the returned promise with an error", ^{
                    error.domain should equal(RepliconNoAlertErrorDomain);
                    error.localizedDescription should equal(@"random error1");
                });
            });

            context(@"with multiple error text", ^{
                __block NSError *error;
                beforeEach(^{
                    NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"some_random_multiple_error"];
                    error = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:YES request:request];
                });

                it(@"should reject the returned promise with an error", ^{
                    error.domain should equal(RepliconNoAlertErrorDomain);
                    NSString *errorMsg=[NSString stringWithFormat:@"%@\n\n%@",@"random error1",@"random error2"];
                    error.localizedDescription should equal(errorMsg);
                });
            });
        });
        
        describe(@"When validation error ", ^{
            __block NSError *editPuncherror;
            context(@"With multiple errors returned from server along with successfull punch for bulk creating punch", ^{
                beforeEach(^{
                    urlStringProvider stub_method(@selector(urlStringWithEndpointName:)).again().and_return(@"my-url");
                    NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"bulk_punch_multiple_error_with_notifications"];
                    editPuncherror = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                });
                
                it(@"should reject the returned promise with an error", ^{
                    editPuncherror.domain should equal(RepliconNoAlertErrorDomain);
                    editPuncherror.code should equal(200);
                    NSString *errorMsg=[NSString stringWithFormat:@"%@\n%@",@"Activity is required on time punch",@"Activity is required on time punch"];
                    editPuncherror.localizedDescription should equal(errorMsg);
                });
                
            });

            
            context(@"With multiple errors returned from server along with some Random Error", ^{
                beforeEach(^{
                    NSDictionary *errorDictionary = [RepliconSpecHelper jsonWithFixture:@"bulk_punch_multiple_error_with_notifications"];
                    editPuncherror = [subject deserialize:errorDictionary isFromRequestMadeWhilePendingQueueSync:NO request:request];
                });
                
                it(@"should reject the returned promise with an error", ^{
                    editPuncherror.domain should equal(RandomErrorDomain);
                    editPuncherror.code should equal(200);
                    NSString *errorMsg=[NSString stringWithFormat:@"%@\n%@",@"Activity is required on time punch",@"Activity is required on time punch"];
                    editPuncherror.localizedDescription should equal(errorMsg);
                });
                
            });

        });

    });


});

SPEC_END
