#import <Cedar/Cedar.h>
#import "HttpErrorSerializer.h"
#import "Constants.h"
#import "AppProperties.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HttpErrorSerializerSpec)

describe(@"HttpErrorSerializer", ^{
    __block HttpErrorSerializer *subject;

    beforeEach(^{
        subject = [[HttpErrorSerializer alloc]init];
    });

    describe(@"-serializeHTTPError:", ^{

        context(@"When error from list of URL for which alert should not be shown", ^{

            context(@"When failed error is -InvalidUserSessionRequestDomain", ^{
                __block NSError *expectedError;
                beforeEach(^{
                    NSError *error = [[NSError alloc]initWithDomain:InvalidUserSessionRequestDomain code:-7777 userInfo:nil];
                    expectedError = [subject serializeHTTPError:error];
                });

                it(@"should serialize correctly configured error", ^{
                    expectedError.domain should equal(RepliconNoAlertErrorDomain);
                    expectedError.localizedDescription should equal(@"");
                });
            });

            context(@"When failed URL is -GetPunchClients", ^{
                __block NSError *expectedError;
                beforeEach(^{
                    NSString *url = [[AppProperties getInstance] getServiceURLFor: @"GetPunchClients"];
                    NSDictionary* userInfo = @{@"NSErrorFailingURLStringKey":url};
                    NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-7777 userInfo:userInfo];
                    expectedError = [subject serializeHTTPError:error];
                });

                it(@"should serialize correctly configured error", ^{
                    expectedError.domain should equal(RepliconNoAlertErrorDomain);
                    expectedError.localizedDescription should equal(@"");
                });
            });

            context(@"When failed URL is -GetPunchProjects", ^{
                __block NSError *expectedError;
                beforeEach(^{
                    NSString *url = [[AppProperties getInstance] getServiceURLFor: @"GetPunchProjects"];
                    NSDictionary* userInfo = @{@"NSErrorFailingURLStringKey":url};
                    NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-7777 userInfo:userInfo];
                    expectedError = [subject serializeHTTPError:error];
                });

                it(@"should serialize correctly configured error", ^{
                    expectedError.domain should equal(RepliconNoAlertErrorDomain);
                    expectedError.localizedDescription should equal(@"");
                });
            });

            context(@"When failed URL is -GetPunchTasks", ^{
                __block NSError *expectedError;
                beforeEach(^{
                    NSString *url = [[AppProperties getInstance] getServiceURLFor: @"GetPunchTasks"];
                    NSDictionary* userInfo = @{@"NSErrorFailingURLStringKey":url};
                    NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-7777 userInfo:userInfo];
                    expectedError = [subject serializeHTTPError:error];
                });

                it(@"should serialize correctly configured error", ^{
                    expectedError.domain should equal(RepliconNoAlertErrorDomain);
                    expectedError.localizedDescription should equal(@"");
                });
            });

            context(@"When failed URL is -GetPunchActivities", ^{
                __block NSError *expectedError;
                beforeEach(^{
                    NSString *url = [[AppProperties getInstance] getServiceURLFor: @"GetPunchActivities"];
                    NSDictionary* userInfo = @{@"NSErrorFailingURLStringKey":url};
                    NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-7777 userInfo:userInfo];
                    expectedError = [subject serializeHTTPError:error];
                });

                it(@"should serialize correctly configured error", ^{
                    expectedError.domain should equal(RepliconNoAlertErrorDomain);
                    expectedError.localizedDescription should equal(@"");
                });
            });

            context(@"When failed URL is -GetExpenseClients", ^{
                __block NSError *expectedError;
                beforeEach(^{
                    NSString *url = [[AppProperties getInstance] getServiceURLFor: @"GetExpenseClients"];
                    NSDictionary* userInfo = @{@"NSErrorFailingURLStringKey":url};
                    NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-7777 userInfo:userInfo];
                    expectedError = [subject serializeHTTPError:error];
                });

                it(@"should serialize correctly configured error", ^{
                    expectedError.domain should equal(RepliconNoAlertErrorDomain);
                    expectedError.localizedDescription should equal(@"");
                });
            });

            context(@"When failed URL is -GetExpenseProjects", ^{
                __block NSError *expectedError;
                beforeEach(^{
                    NSString *url = [[AppProperties getInstance] getServiceURLFor: @"GetExpenseProjects"];
                    NSDictionary* userInfo = @{@"NSErrorFailingURLStringKey":url};
                    NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-7777 userInfo:userInfo];
                    expectedError = [subject serializeHTTPError:error];
                });

                it(@"should serialize correctly configured error", ^{
                    expectedError.domain should equal(RepliconNoAlertErrorDomain);
                    expectedError.localizedDescription should equal(@"");
                });
            });

            context(@"When failed URL is -GetExpenseTasks", ^{
                __block NSError *expectedError;
                beforeEach(^{
                    NSString *url = [[AppProperties getInstance] getServiceURLFor: @"GetExpenseTasks"];
                    NSDictionary* userInfo = @{@"NSErrorFailingURLStringKey":url};
                    NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-7777 userInfo:userInfo];
                    expectedError = [subject serializeHTTPError:error];
                });

                it(@"should serialize correctly configured error", ^{
                    expectedError.domain should equal(RepliconNoAlertErrorDomain);
                    expectedError.localizedDescription should equal(@"");
                });
            });

            context(@"When failed URL is -GetVersionUpdateDetails", ^{
                __block NSError *expectedError;
                beforeEach(^{
                    NSString *url = [[AppProperties getInstance] getServiceURLFor: @"GetVersionUpdateDetails"];
                    NSDictionary* userInfo = @{@"NSErrorFailingURLStringKey":url};
                    NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-7777 userInfo:userInfo];
                    expectedError = [subject serializeHTTPError:error];
                });

                it(@"should serialize correctly configured error", ^{
                    expectedError.domain should equal(RepliconNoAlertErrorDomain);
                    expectedError.localizedDescription should equal(@"");
                });
            });

            context(@"When failed URL is -GetMyNotificationSummary", ^{
                __block NSError *expectedError;
                beforeEach(^{
                    NSString *url = [[AppProperties getInstance] getServiceURLFor: @"GetMyNotificationSummary"];
                    NSDictionary* userInfo = @{@"NSErrorFailingURLStringKey":url};
                    NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-7777 userInfo:userInfo];
                    expectedError = [subject serializeHTTPError:error];
                });

                it(@"should serialize correctly configured error", ^{
                    expectedError.domain should equal(RepliconNoAlertErrorDomain);
                    expectedError.localizedDescription should equal(@"");
                });
            });

            context(@"When failed URL is -getServerDownStatus", ^{
                __block NSError *expectedError;
                beforeEach(^{
                    NSString *url = [[AppProperties getInstance] getServiceURLFor: @"getServerDownStatus"];
                    NSDictionary* userInfo = @{@"NSErrorFailingURLStringKey":url};
                    NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-7777 userInfo:userInfo];
                    expectedError = [subject serializeHTTPError:error];
                });

                it(@"should serialize correctly configured error", ^{
                    expectedError.domain should equal(RepliconNoAlertErrorDomain);
                    expectedError.localizedDescription should equal(@"");
                });
            });

            context(@"When failed URL is -RegisterForPushNotifications", ^{
                __block NSError *expectedError;
                beforeEach(^{
                    NSString *url = [[AppProperties getInstance] getServiceURLFor: @"RegisterForPushNotifications"];
                    NSDictionary* userInfo = @{@"NSErrorFailingURLStringKey":url};
                    NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-7777 userInfo:userInfo];
                    expectedError = [subject serializeHTTPError:error];
                });

                it(@"should serialize correctly configured error", ^{
                    expectedError.domain should equal(RepliconNoAlertErrorDomain);
                    expectedError.localizedDescription should equal(@"");
                });
            });

            context(@"When failed URL is -Gen4TimesheetValidation", ^{
                __block NSError *expectedError;
                beforeEach(^{
                    NSString *url = [[AppProperties getInstance] getServiceURLFor: @"Gen4TimesheetValidation"];
                    NSDictionary* userInfo = @{@"NSErrorFailingURLStringKey":url};
                    NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-7777 userInfo:userInfo];
                    expectedError = [subject serializeHTTPError:error];
                });

                it(@"should serialize correctly configured error", ^{
                    expectedError.domain should equal(RepliconNoAlertErrorDomain);
                    expectedError.localizedDescription should equal(@"");
                });
            });

            context(@"When failed URL is -GetHomeSummary2", ^{
                __block NSError *expectedError;
                beforeEach(^{
                    NSString *url = [[AppProperties getInstance] getServiceURLFor: @"GetHomeSummary2"];
                    NSDictionary* userInfo = @{@"NSErrorFailingURLStringKey":url};
                    NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-7777 userInfo:userInfo];
                    expectedError = [subject serializeHTTPError:error];
                });

                it(@"should serialize correctly configured error", ^{
                    expectedError.domain should equal(RepliconNoAlertErrorDomain);
                    expectedError.localizedDescription should equal(@"");
                });
            });

            context(@"When failed URL is -GetHomeSummary", ^{
                __block NSError *expectedError;
                beforeEach(^{
                    NSString *url = [[AppProperties getInstance] getServiceURLFor: @"GetHomeSummary"];
                    NSDictionary* userInfo = @{@"NSErrorFailingURLStringKey":url};
                    NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-7777 userInfo:userInfo];
                    expectedError = [subject serializeHTTPError:error];
                });

                it(@"should serialize correctly configured error", ^{
                    expectedError.domain should equal(RepliconNoAlertErrorDomain);
                    expectedError.localizedDescription should equal(@"");
                });
            });

            context(@"When failed URL is -GetPageOfObjectExtensionTagsFilteredBySearch", ^{
                __block NSError *expectedError;
                beforeEach(^{
                    NSString *url = [[AppProperties getInstance] getServiceURLFor: @"GetPageOfObjectExtensionTagsFilteredBySearch"];
                    NSDictionary* userInfo = @{@"NSErrorFailingURLStringKey":url};
                    NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-7777 userInfo:userInfo];
                    expectedError = [subject serializeHTTPError:error];
                });

                it(@"should serialize correctly configured error", ^{
                    expectedError.domain should equal(RepliconNoAlertErrorDomain);
                    expectedError.localizedDescription should equal(@"");
                });
            });
        });

        context(@"when errorCode is -998", ^{
            __block NSError *expectedError;
            beforeEach(^{
                NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-998 userInfo:nil];
                expectedError = [subject serializeHTTPError:error];
            });

            it(@"should serialize correctly configured error", ^{
                expectedError.domain should equal(RepliconHTTPRequestErrorDomain);
                expectedError.code should equal(-998);
                expectedError.localizedDescription should equal(RPLocalizedString(RepliconHTTPRequestError_998, nil));
            });
        });

        context(@"when errorCode is -999", ^{
            __block NSError *expectedError;
            beforeEach(^{
                NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-999 userInfo:nil];
                expectedError = [subject serializeHTTPError:error];
            });

            it(@"should serialize correctly configured error", ^{
                expectedError.domain should equal(RepliconHTTPRequestErrorDomain);
                expectedError.code should equal(-999);
                expectedError.localizedDescription should equal(RPLocalizedString(RepliconHTTPRequestError_999, nil));
            });
        });

        context(@"when errorCode is -1001", ^{
            __block NSError *expectedError;
            beforeEach(^{
                NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-1001 userInfo:nil];
                expectedError = [subject serializeHTTPError:error];
            });

            it(@"should serialize correctly configured error", ^{
                expectedError.domain should equal(RepliconHTTPRequestErrorDomain);
                expectedError.code should equal(-1001);
                expectedError.localizedDescription should equal(RPLocalizedString(RepliconHTTPRequestError_1001, nil));
            });

        });

        context(@"when errorCode is -1200", ^{
            __block NSError *expectedError;
            beforeEach(^{
                NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-1200 userInfo:nil];
                expectedError = [subject serializeHTTPError:error];
            });

            it(@"should serialize correctly configured error", ^{
                expectedError.domain should equal(RepliconHTTPRequestErrorDomain);
                expectedError.code should equal(-1200);
                expectedError.localizedDescription should equal(RPLocalizedString(RepliconHTTPRequestError_1200, nil));
            });
        });

        context(@"when errorCode is -1003", ^{
            __block NSError *expectedError;
            beforeEach(^{
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"some fake 1003 error"};
                NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-1003 userInfo:userInfo];
                expectedError = [subject serializeHTTPError:error];
            });

            it(@"should serialize correctly configured error", ^{
                expectedError.domain should equal(RepliconHTTPRequestErrorDomain);
                expectedError.code should equal(-1003);
                expectedError.localizedDescription should equal(@"some fake 1003 error");
            });
        });

        context(@"when errorCode is -1004", ^{
            __block NSError *expectedError;
            beforeEach(^{
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"some fake 1004 error"};
                NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-1004 userInfo:userInfo];
                expectedError = [subject serializeHTTPError:error];
            });

            it(@"should serialize correctly configured error", ^{
                expectedError.domain should equal(RepliconHTTPRequestErrorDomain);
                expectedError.code should equal(-1004);
                expectedError.localizedDescription should equal(@"some fake 1004 error");
            });
        });

        context(@"when errorCode is -1005", ^{
            __block NSError *expectedError;
            beforeEach(^{
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"some fake 1005 error"};
                NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-1005 userInfo:userInfo];
                expectedError = [subject serializeHTTPError:error];
            });

            it(@"should serialize correctly configured error", ^{
                expectedError.domain should equal(RepliconHTTPRequestErrorDomain);
                expectedError.code should equal(-1005);
                expectedError.localizedDescription should equal(@"some fake 1005 error");
            });
        });

        context(@"when errorCode is -1006", ^{
            __block NSError *expectedError;
            beforeEach(^{
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"some fake 1006 error"};
                NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-1006 userInfo:userInfo];
                expectedError = [subject serializeHTTPError:error];
            });

            it(@"should serialize correctly configured error", ^{
                expectedError.domain should equal(RepliconHTTPRequestErrorDomain);
                expectedError.code should equal(-1006);
                expectedError.localizedDescription should equal(@"some fake 1006 error");
            });
        });

        context(@"when errorCode is -1008", ^{
            __block NSError *expectedError;
            beforeEach(^{
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"some fake 1008 error"};
                NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-1008 userInfo:userInfo];
                expectedError = [subject serializeHTTPError:error];
            });

            it(@"should serialize correctly configured error", ^{
                expectedError.domain should equal(RepliconHTTPRequestErrorDomain);
                expectedError.code should equal(-1008);
                expectedError.localizedDescription should equal(@"some fake 1008 error");
            });
        });

        context(@"when errorCode is -1009", ^{
            __block NSError *expectedError;
            beforeEach(^{
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"some fake 1009 error"};
                NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-1009 userInfo:userInfo];
                expectedError = [subject serializeHTTPError:error];
            });

            it(@"should serialize correctly configured error", ^{
                expectedError.domain should equal(RepliconNoAlertErrorDomain);
                expectedError.code should equal(-1009);
                expectedError.localizedDescription should equal(@"some fake 1009 error");
            });
        });

        context(@"when errorCode is -1011", ^{
            __block NSError *expectedError;
            beforeEach(^{
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"some fake 1011 error"};
                NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPRequestErrorDomain code:-1011 userInfo:userInfo];
                expectedError = [subject serializeHTTPError:error];
            });

            it(@"should serialize correctly configured error", ^{
                expectedError.domain should equal(RepliconHTTPRequestErrorDomain);
                expectedError.code should equal(-1011);
                expectedError.localizedDescription should equal(@"some fake 1011 error");
            });
        });

        context(@"when errorDomain is <RepliconHTTPNonJsonResponseErrorDomain>", ^{
            __block NSError *expectedError;
            beforeEach(^{
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"some fake error"};
                NSError *error = [[NSError alloc]initWithDomain:RepliconHTTPNonJsonResponseErrorDomain code:-9999 userInfo:userInfo];
                expectedError = [subject serializeHTTPError:error];
            });

            it(@"should serialize correctly configured error", ^{
                expectedError.domain should equal(RepliconHTTPNonJsonResponseErrorDomain);
                expectedError.code should equal(-9999);
                expectedError.localizedDescription should equal(RPLocalizedString(RepliconServerMaintenanceError,nil));
            });
        });
        
        context(@"when errorDomain is <RepliconServiceUnAvailabilityResponseErrorDomain> with error code 503", ^{
            __block NSError *expectedError;
            beforeEach(^{
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"some fake error"};
                NSError *error = [[NSError alloc]initWithDomain:RepliconServiceUnAvailabilityResponseErrorDomain code:503 userInfo:userInfo];
                expectedError = [subject serializeHTTPError:error];
            });
            
            it(@"should serialize correctly configured error", ^{
                expectedError.domain should equal(RepliconServiceUnAvailabilityResponseErrorDomain);
                expectedError.code should equal(503);
                expectedError.localizedDescription should equal(RPLocalizedString(RepliconServerMaintenanceError,nil));
            });
        });

        context(@"when errorDomain is <RepliconServiceUnAvailabilityResponseErrorDomain> with error code 504", ^{
            __block NSError *expectedError;
            beforeEach(^{
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"some fake error"};
                NSError *error = [[NSError alloc]initWithDomain:RepliconServiceUnAvailabilityResponseErrorDomain code:504 userInfo:userInfo];
                expectedError = [subject serializeHTTPError:error];
            });
            
            it(@"should serialize correctly configured error", ^{
                expectedError.domain should equal(RepliconServiceUnAvailabilityResponseErrorDomain);
                expectedError.code should equal(504);
                expectedError.localizedDescription should equal(RPLocalizedString(RepliconServerMaintenanceError,nil));
            });
        });

        context(@"when errorDomain is <RepliconFailureStatusCodeError>", ^{
            __block NSError *expectedError;
            beforeEach(^{
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"some fake error"};
                NSError *error = [[NSError alloc]initWithDomain:RepliconFailureStatusCodeDomain code:-9999 userInfo:userInfo];
                expectedError = [subject serializeHTTPError:error];
            });

            it(@"should serialize correctly configured error", ^{
                expectedError.domain should equal(RepliconFailureStatusCodeDomain);
                expectedError.code should equal(-9999);
                expectedError.localizedDescription should equal(RPLocalizedString(USER_FRIENDLY_ERROR_MSG,nil));
            });
        });

        context(@"when errorDomain is <NSPOSIXErrorDomain>", ^{
            __block NSError *expectedError;
            __block NSString *expectedErrorDescription;
            beforeEach(^{
                NSString *localizedDescription = @"some fake error";
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:localizedDescription};
                NSError *error = [[NSError alloc]initWithDomain:NSPOSIXErrorDomain code:-9999 userInfo:userInfo];
                expectedError = [subject serializeHTTPError:error];
                expectedErrorDescription = [NSString stringWithFormat:@"%@.%@",localizedDescription,RepliconGenericPosixOrUrlDomainError];
            });

            it(@"should serialize correctly configured error", ^{
                expectedError.domain should equal(NSPOSIXErrorDomain);
                expectedError.code should equal(-9999);
                expectedError.localizedDescription should equal(expectedErrorDescription);
            });
        });

        context(@"when errorDomain is <NSURLErrorDomain>", ^{
            __block NSError *expectedError;
            __block NSString *expectedErrorDescription;
            beforeEach(^{
                NSString *localizedDescription = @"some fake error";
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:localizedDescription};
                NSError *error = [[NSError alloc]initWithDomain:NSURLErrorDomain code:-9999 userInfo:userInfo];
                expectedError = [subject serializeHTTPError:error];
                expectedErrorDescription = [NSString stringWithFormat:@"%@.%@",localizedDescription,RepliconGenericPosixOrUrlDomainError];
            });

            it(@"should serialize correctly configured error", ^{
                expectedError.domain should equal(NSURLErrorDomain);
                expectedError.code should equal(-9999);
                expectedError.localizedDescription should equal(expectedErrorDescription);
            });
        });

        context(@"when errorDomain is Unknown/Anything", ^{
            __block NSError *expectedError;
            beforeEach(^{
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"some fake error",@"NSErrorFailingURLStringKey":@"some fake url"};
                NSError *error = [[NSError alloc]initWithDomain:@"Unknown" code:-9999 userInfo:userInfo];
                expectedError = [subject serializeHTTPError:error];
            });

            it(@"should serialize correctly configured error", ^{
                expectedError.domain should equal(RepliconHTTPRequestErrorDomain);
                expectedError.code should equal(-9999);
                expectedError.localizedDescription should equal(RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE));
                expectedError.userInfo[@"NSErrorFailingURLStringKey"] should equal(@"some fake url");
            });
        });

        context(@"when errorDomain is <RepliconNoAlertErrorDomain>", ^{
            __block NSError *expectedError;
            __block NSString *expectedErrorDescription;
            beforeEach(^{
                NSString *localizedDescription = @"some fake error";
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:localizedDescription};
                NSError *error = [[NSError alloc]initWithDomain:RepliconNoAlertErrorDomain code:-9999 userInfo:userInfo];
                expectedError = [subject serializeHTTPError:error];
                expectedErrorDescription = @"";
            });

            it(@"should serialize correctly configured error", ^{
                expectedError.domain should equal(RepliconNoAlertErrorDomain);
                expectedError.code should equal(-9999);
                expectedError.localizedDescription should equal(expectedErrorDescription);
            });
        });

    });
});

SPEC_END
