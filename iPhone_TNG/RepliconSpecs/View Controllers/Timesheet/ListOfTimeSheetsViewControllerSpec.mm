#import <Cedar/Cedar.h>
#import "ListOfTimeSheetsViewController.h"
#import "TimesheetService.h"
#import "TimesheetModel.h"
#import "SpinnerDelegate.h"
#import "SVPullToRefresh.h"
#import "ErrorBannerViewParentPresenterHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface ListOfTimeSheetsViewController()
- (void)selectCurrentTimeSheet;
- (void)receivedTimesheetSummaryData:(NSNotification *)notification;
@end
SPEC_BEGIN(ListOfTimeSheetsViewControllerSpec)

describe(@"ListOfTimeSheetsViewController", ^{
    __block ListOfTimeSheetsViewController *subject;
    __block TimesheetService *fakeTimesheetService;
    __block TimesheetModel *fakeTimesheetModel;
    __block id<SpinnerDelegate> fakeSpinnerDelegate;
    __block NSNotificationCenter *notificationCenter;
    __block NSUserDefaults *userDefaults;
    __block ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;
    __block WidgetsManager *fakeWidgetsManager;
    
    beforeEach(^{
        fakeTimesheetModel = nice_fake_for([TimesheetModel class]);
        fakeTimesheetService = nice_fake_for([TimesheetService class]);
        fakeSpinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));
        notificationCenter = [[NSNotificationCenter alloc] init];
        userDefaults = nice_fake_for([NSUserDefaults class]);
        fakeWidgetsManager = nice_fake_for([WidgetsManager class]);
        
        errorBannerViewParentPresenterHelper = nice_fake_for([ErrorBannerViewParentPresenterHelper class]);
        
        spy_on(notificationCenter);

        subject = [[ListOfTimeSheetsViewController alloc] initWithErrorBannerViewParentPresenterHelper:errorBannerViewParentPresenterHelper
                                                                             errorBannerViewController:nil
                                                                              errorDetailsDeserializer:nil
                                                                                    notificationCenter:notificationCenter
                                                                                   errorDetailsStorage:nil
                                                                                       spinnerDelegate:fakeSpinnerDelegate
                                                                                      timesheetService:fakeTimesheetService
                                                                                        timeSheetModel:fakeTimesheetModel
                                                                                          userdefaults:userDefaults];
        subject.view should_not be_nil;
    });

    it(@"should return false for unsupported widget", ^{
       BOOL iskeyAvailable = [[WidgetsManager sharedInstance] isValueAvailableWithKey:@"some-key"];
        iskeyAvailable should be_falsy;
    });
    
    it(@"should return true for unsupported widget", ^{
        BOOL iskeyAvailable = [[WidgetsManager sharedInstance] isValueAvailableWithKey:@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"];
        iskeyAvailable should be_truthy;
    });
    
    describe(@"when the view will appear", ^{
        context(@"and there are timesheets cached", ^{
            beforeEach(^{
                NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:1427068800];
                NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:1427587200];
                NSDictionary *fakeTimesheetDictionary = @{
                                                          @"startDate": [NSNumber numberWithDouble:[startDate timeIntervalSince1970]],
                                                          @"endDate": [NSNumber numberWithDouble:[endDate timeIntervalSince1970]],
                                                          @"approvalStatus": NOT_SUBMITTED_STATUS,
                                                          @"mealBreakPenalties": @"10",
                                                          @"overtimeDurationDecimal": @2.00,
                                                          @"regularDurationDecimal": @3.00,
                                                          @"timeoffDurationDecimal": @4.00
                                                          };
                fakeTimesheetModel stub_method(@selector(getAllTimesheetsFromDB)).and_return(@[fakeTimesheetDictionary]);
            });

            beforeEach(^{
                [subject viewWillAppear:NO];
            });

            it(@"should display those timesheets", ^{
                [subject.timeSheetsTableView.visibleCells count] should equal(1);
            });

            it(@"should not request the timesheets from the timesheet service", ^{
                fakeTimesheetService should_not have_received(@selector(fetchTimeSheetData:));
            });
        });

        context(@"and there are no timesheets cached", ^{
            beforeEach(^{
                fakeTimesheetModel stub_method(@selector(getAllTimesheetsFromDB)).and_return(@[]);
                subject.timeSheetsTableView.showsInfiniteScrolling = YES;
                [subject viewWillAppear:NO];
            });

            it(@"should make a service call to fetch the timesheets", ^{
                fakeTimesheetService should have_received(@selector(fetchTimeSheetData:)).with(nil);
            });

            it(@"should start the spinner", ^{
                fakeSpinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
            });

            it(@"should disable infinite scrolling", ^{
                subject.timeSheetsTableView.showsInfiniteScrolling should be_falsy;
            });

            describe(@"when a allTimesheetRequestsServed notification is then posted", ^{
                context(@"when a timesheet is now available", ^{
                    beforeEach(^{
                        // The decision to disable infinite scrolling is made by referencing
                        // the number of timesheets downloaded from user defaults,
                        // NOT the count of the timesheets returned to the view controller.
                        userDefaults stub_method(@selector(objectForKey:)).with(@"timesheetsDownloadCount").and_return(@1);
                    });

                    beforeEach(^{
                        subject.timeSheetsTableView.showsInfiniteScrolling = YES;
                    });

                    beforeEach(^{
                        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:1427068800];
                        NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:1427587200];
                        NSDictionary *fakeTimesheetDictionary = @{
                                                                  @"startDate": [NSNumber numberWithDouble:[startDate timeIntervalSince1970]],
                                                                  @"endDate": [NSNumber numberWithDouble:[endDate timeIntervalSince1970]],
                                                                  @"approvalStatus": NOT_SUBMITTED_STATUS,
                                                                  @"mealBreakPenalties": @"10",
                                                                  @"overtimeDurationDecimal": @2.00,
                                                                  @"regularDurationDecimal": @3.00,
                                                                  @"timeoffDurationDecimal": @4.00
                                                                  };
                        fakeTimesheetModel stub_method(@selector(getAllTimesheetsFromDB)).again().and_return(@[fakeTimesheetDictionary]);
                    });

                    beforeEach(^{
                        [notificationCenter postNotificationName:@"allTimesheetRequestsServed" object:nil];
                    });


                    context(@"when the collaborating timesheet service has set timesheetsDownloadCount to zero", ^{
                        it(@"should hide the spinner", ^{
                            fakeSpinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                    });

                    it(@"should unsubscribe from allTimesheetRequestsServed notifications", ^{
                        notificationCenter should have_received(@selector(removeObserver:name:object:)).with(subject, @"allTimesheetRequestsServed", nil);
                    });

                    it(@"should disable infinite scrolling", ^{
                        subject.timeSheetsTableView.showsInfiniteScrolling should be_falsy;
                    });

                    it(@"should update the content of the table", ^{
                        subject.timeSheetsTableView.visibleCells.count should equal(1);
                        UITableViewCell *cell = [subject.timeSheetsTableView.visibleCells firstObject];
                        
                        UILabel *upperLeftLabel = [cell.contentView.subviews firstObject];
                        
                        
                        NSDateFormatter *df = [[NSDateFormatter alloc] init];
                        //Fix for Defect DE14916
                        
                        NSLocale *locale=[NSLocale currentLocale];
                        NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
                        [df setLocale:locale];
                        [df setTimeZone:timeZone];
                        
                        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:1427068800];
                        NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:1427587200];

                        [df setDateFormat:@"MMM dd"];

                        NSString *startDateStr =[NSString stringWithFormat:@"%@",
                                             [df stringFromDate:startDate]];

                        [df setDateFormat:@"MMM dd, yyyy"];

                        NSString *endDateStr =[NSString stringWithFormat:@"%@",
                                                 [df stringFromDate:endDate]];

                        upperLeftLabel.text should equal([NSString stringWithFormat:@"%@ - %@",startDateStr,endDateStr]);
                    });
                });

                context(@"when the timesheet service completes its request and no timesheets are available", ^{
                    beforeEach(^{
                        // The decision to disable infinite scrolling is made by referencing
                        // the number of timesheets downloaded from user defaults,
                        // NOT the count of the timesheets returned to the view controller.
                        userDefaults stub_method(@selector(objectForKey:)).with(@"timesheetsDownloadCount").and_return(@0);                    });

                    beforeEach(^{
                        fakeTimesheetService stub_method(@selector(didSuccessfullyFetchTimesheets)).and_return(YES);
                    });

                    beforeEach(^{
                        [notificationCenter postNotificationName:@"allTimesheetRequestsServed" object:nil];
                    });

                    it(@"should display a no timesheets available message", ^{
                        subject.msgLabel.text should equal(RPLocalizedString(_NO_TIMESHEETS_AVAILABLE, _NO_TIMESHEETS_AVAILABLE));

                        [subject.msgLabel isDescendantOfView:subject.view] should be_truthy;
                    });

                    describe(@"and the view is subsequently shown again", ^{
                        context(@"and the timesheet service has not yet finished fetching timesheets", ^{
                            beforeEach(^{
                                fakeTimesheetService stub_method(@selector(didSuccessfullyFetchTimesheets)).again().and_return(NO);
                            });

                            beforeEach(^{
                                [subject viewWillAppear:NO];
                            });

                            it(@"should remove the no timesheets available message", ^{
                                [subject.msgLabel isDescendantOfView:subject.view] should be_falsy;
                            });
                        });

                        context(@"and the timesheet service completes its request and a timesheet is available", ^{
                            beforeEach(^{
                                fakeTimesheetService stub_method(@selector(didSuccessfullyFetchTimesheets)).again().and_return(YES);
                            });

                            beforeEach(^{
                                fakeTimesheetModel stub_method(@selector(getAllTimesheetsFromDB)).again().and_return(@[@{}]);
                            });

                            beforeEach(^{
                                [subject viewWillAppear:NO];
                            });

                            it(@"should remove the no timesheets available message", ^{
                                [subject.msgLabel isDescendantOfView:subject.view] should be_falsy;
                            });
                        });
                    });
                });
            });
        });

        context(@"when there is a timesheet in the cache", ^{
            beforeEach(^{
                fakeTimesheetModel stub_method(@selector(getAllTimesheetsFromDB)).and_return(@[@{}]);
                [subject viewWillAppear:NO];
            });

            it(@"should not make a service call", ^{
                fakeTimesheetService should_not have_received(@selector(fetchTimeSheetData:));
            });

            it(@"should not start the spinner", ^{
                fakeSpinnerDelegate should_not have_received(@selector(showTransparentLoadingOverlay));
            });
        });
    });
    
    describe(@"the error banner view", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });
        
        it(@"should check for error banner view and set inset for tableview", ^{
            [subject viewWillAppear:NO];
            
            errorBannerViewParentPresenterHelper should have_received(@selector(setTableViewInsetWithErrorBannerPresentation:))
            .with(subject.timeSheetsTableView);
        });
    });

    describe(@"the error banner view", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });
        
        it(@"should check for error banner view and set inset for tableview", ^{
            [subject viewWillAppear:NO];
            
            errorBannerViewParentPresenterHelper should have_received(@selector(setTableViewInsetWithErrorBannerPresentation:))
            .with(subject.timeSheetsTableView);
        });
    });
    
    describe(@"when observer notified", ^{
        beforeEach(^{
            [subject errorBannerViewChanged];
        });
        
        it(@"should change tableview based on the permission", ^{
            errorBannerViewParentPresenterHelper should have_received(@selector(setTableViewInsetWithErrorBannerPresentation:))
            .with(subject.timeSheetsTableView);
        });
    });
    
    describe(@"when current timesheet is invoked", ^{
        
        context(@"and there are timesheets cached", ^{
            beforeEach(^{
                NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:1427068800];
                NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:1427587200];
                NSDictionary *fakeTimesheetDictionary = @{
                                                          @"startDate": [NSNumber numberWithDouble:[startDate timeIntervalSince1970]],
                                                          @"endDate": [NSNumber numberWithDouble:[endDate timeIntervalSince1970]],
                                                          @"approvalStatus": NOT_SUBMITTED_STATUS,
                                                          @"mealBreakPenalties": @"10",
                                                          @"overtimeDurationDecimal": @2.00,
                                                          @"regularDurationDecimal": @3.00,
                                                          @"timeoffDurationDecimal": @4.00
                                                          };
                fakeTimesheetModel stub_method(@selector(getAllTimesheetsFromDB)).and_return(@[fakeTimesheetDictionary]);
                [subject viewWillAppear:NO];
            });
            
            it(@"should return NO for isFromDeepLink", ^{
                subject.isFromDeepLink should equal(NO);
            });
            
            it(@"should display those timesheets", ^{
                [subject.timeSheetsTableView.visibleCells count] should equal(1);
            });
            
            context(@"launch current timesheet", ^{
                beforeEach(^{
                    spy_on(subject);
                    subject stub_method(@selector(receivedTimesheetSummaryData:));
                    [subject launchCurrentTimeSheet];
                });

                it(@"should set isFromDeepLink to YES", ^{
                    subject.isFromDeepLink should equal(YES);
                });
                
                it(@"should display current timesheet", ^{
                    subject should have_received(@selector(selectCurrentTimeSheet));
                });
                
            });
        });
    });
});

SPEC_END
