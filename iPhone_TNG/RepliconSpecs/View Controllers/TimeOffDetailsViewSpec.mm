#import <Cedar/Cedar.h>
#import "TimeOffDetailsView.h"
#import "TimeOffObject.h"
#import "TimeOffRequestedCellView.h"
#import "TimeoffModel.h"
#import "Constants.h"
#import "UIAlertView+Spec.h"
using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimeOffDetailsViewSpec)

xdescribe(@"TimeOffDetailsView", ^{
    __block TimeOffDetailsView *subject;
    __block TimeOffObject *timeOffObject;
    __block TimeoffModel *fakeTimeOffModel;
    __block CGRect frame;
    __block id<TimeOffDetailsDateSelectionDelegate> fakeTimeOffDetailsDelegate;
    beforeEach(^{
        subject = [[TimeOffDetailsView alloc] initWithFrame:frame errorBannerViewParentPresenterHelper:nil];
        fakeTimeOffModel = nice_fake_for([TimeoffModel class]);
    });
    
    context(@"When the timeOff is not a multiDay booking", ^{
        beforeEach(^{
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:1427068800];
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:1427587200];
            fakeTimeOffDetailsDelegate = nice_fake_for(@protocol(TimeOffDetailsDateSelectionDelegate));
            NSDictionary *fakeTimeOffDictionary = @{
                                                      @"startDate": [NSNumber numberWithDouble:[startDate timeIntervalSince1970]],
                                                      @"endDate": [NSNumber numberWithDouble:[endDate timeIntervalSince1970]],
                                                      @"approvalStatus": WAITING_FOR_APRROVAL_STATUS,
                                                      @"totalDurationDecimal": @12.00,
                                                      @"timeoffDurationDecimal": @4.00,
                                                      @"WAITING_FOR_APRROVAL_STATUS":@"",
                                                      @"timeoffTypeName":@"",
                                                      @"timeoffTypeUri":@"",
                                                      @"comments":@"",
                                                      @"timeoffUri":@"",
                                                      @"isDeviceSupportedEntryConfiguration":@TRUE,
                                                      @"startEntryDurationUri":FULLDAY_DURATION_TYPE_KEY,
                                                      @"endEntryDurationUri":HALFDAY_DURATION_TYPE_KEY,
                                                      @"startDateDurationDecimal":@8.00,
                                                      @"endDateDurationDecimal":@3.00,
                                                      @"startDateTime":@"",
                                                      @"endDateTime":@"",
                                                      @"totalTimeoffDays":@"",
                                                      @"timeOffDisplayFormatUri":@"",
                                                      @"totalDurationHour":@"8"
                                                      };
        
            timeOffObject = [[TimeOffObject alloc] initWithDataDictionary:fakeTimeOffDictionary];
            [subject setUpTimeOffDetailsView:timeOffObject :EDIT_TIME_ENTRY_NAVIGATION];
            subject.timeOffDateSelectionDelegate = fakeTimeOffDetailsDelegate;
            __block volatile bool loadComplete = false;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                CFRunLoopStop(CFRunLoopGetCurrent());
                
                loadComplete = true;
                
            });
            
            
            NSDate* startTime = [NSDate date];
            while ( !loadComplete )
            {
                
                
                NSDate* nextTry = [NSDate dateWithTimeIntervalSinceNow:0.1];
                [[NSRunLoop currentRunLoop] runUntilDate:nextTry];
                
                if ( [nextTry timeIntervalSinceDate:startTime]/* some appropriate time interval here */ )
                    NSLog(@"");
            }

        });
        it(@"should call the balance method", ^{
            fakeTimeOffDetailsDelegate should_not be_nil;
        });
        it(@"should call the balance service call method", ^{
            fakeTimeOffDetailsDelegate should have_received(@selector(balanceCalculationMethod:::));
        });
    });

    
    context(@"When the timeOff is a multiDay booking", ^{
        beforeEach(^{
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:1427068800];
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:1427587200];
            fakeTimeOffDetailsDelegate = nice_fake_for(@protocol(TimeOffDetailsDateSelectionDelegate));
            NSDictionary *fakeTimeOffDictionary = @{
                                                    @"startDate": [NSNumber numberWithDouble:[startDate timeIntervalSince1970]],
                                                    @"endDate": [NSNumber numberWithDouble:[endDate timeIntervalSince1970]],
                                                    @"approvalStatus": WAITING_FOR_APRROVAL_STATUS,
                                                    @"totalDurationDecimal": @12.00,
                                                    @"timeoffDurationDecimal": @4.00,
                                                    @"WAITING_FOR_APRROVAL_STATUS":@"",
                                                    @"timeoffTypeName":@"",
                                                    @"timeoffTypeUri":@"",
                                                    @"comments":@"",
                                                    @"timeoffUri":@"",
                                                    @"isDeviceSupportedEntryConfiguration":@FALSE,
                                                    @"startEntryDurationUri":FULLDAY_DURATION_TYPE_KEY,
                                                    @"endEntryDurationUri":HALFDAY_DURATION_TYPE_KEY,
                                                    @"startDateDurationDecimal":@8.00,
                                                    @"endDateDurationDecimal":@3.00,
                                                    @"startDateTime":@"",
                                                    @"endDateTime":@"",
                                                    @"totalTimeoffDays":@"",
                                                    @"timeOffDisplayFormatUri":@"",
                                                    @"totalDurationHour":@"8"
                                                    };
            
            timeOffObject = [[TimeOffObject alloc] initWithDataDictionary:fakeTimeOffDictionary];
            [subject setUpTimeOffDetailsView:timeOffObject :EDIT_TIME_ENTRY_NAVIGATION];
            subject.timeOffDateSelectionDelegate = fakeTimeOffDetailsDelegate;
            __block volatile bool loadComplete = false;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                CFRunLoopStop(CFRunLoopGetCurrent());
                
                loadComplete = true;
                
            });
            
            
            NSDate* startTime = [NSDate date];
            while ( !loadComplete )
            {
                
                
                NSDate* nextTry = [NSDate dateWithTimeIntervalSinceNow:0.1];
                [[NSRunLoop currentRunLoop] runUntilDate:nextTry];
                
                if ( [nextTry timeIntervalSinceDate:startTime]/* some appropriate time interval here */ )
                    NSLog(@"");
            }
            
        });
        it(@"should call the balance method", ^{
            fakeTimeOffDetailsDelegate should_not be_nil;
        });
        it(@"should call the balance service call method", ^{
            fakeTimeOffDetailsDelegate should_not have_received(@selector(balanceCalculationMethod:::));
        });
    });
    
    context(@"Checking for the balance and requested label values in hours", ^{
        beforeEach(^{
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:1427068800];
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:1427587200];
            
            NSDictionary *fakeTimeOffDictionary = @{
                                                    @"startDate": [NSNumber numberWithDouble:[startDate timeIntervalSince1970]],
                                                    @"endDate": [NSNumber numberWithDouble:[endDate timeIntervalSince1970]],
                                                    @"approvalStatus": WAITING_FOR_APRROVAL_STATUS,
                                                    @"totalDurationDecimal": @12.00,
                                                    @"timeoffDurationDecimal": @4.00,
                                                    @"WAITING_FOR_APRROVAL_STATUS":@"",
                                                    @"timeoffTypeName":@"",
                                                    @"timeoffTypeUri":@"",
                                                    @"comments":@"",
                                                    @"timeoffUri":@"",
                                                    @"isDeviceSupportedEntryConfiguration":@FALSE,
                                                    @"startEntryDurationUri":FULLDAY_DURATION_TYPE_KEY,
                                                    @"endEntryDurationUri":HALFDAY_DURATION_TYPE_KEY,
                                                    @"startDateDurationDecimal":@8.00,
                                                    @"endDateDurationDecimal":@3.00,
                                                    @"startDateTime":@"",
                                                    @"endDateTime":@"",
                                                    @"totalTimeoffDays":@"",
                                                    @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:hours",
                                                    @"totalDurationHour":@"8"
                                                    };
            timeOffObject = [[TimeOffObject alloc] initWithDataDictionary:fakeTimeOffDictionary];
            subject.timeOffDetailsObj = timeOffObject;
            subject.navigationFlow = TIMEOFF_BOOKING_NAVIGATION;
            subject.balanceTrackingOption = TIME_OFF_AVAILABLE_KEY;
            [subject setUpTimeOffDetailsView:timeOffObject :TIMEOFF_BOOKING_NAVIGATION];
            
            NSDictionary *balanceDataFakeDictionary = @{
                                                        @"balanceRemainingDays":@"38.54795138",
                                                        @"balanceRemainingHours":@"308.38",
                                                        @"requestedDays":@"0.125",
                                                        @"requestedHours":@"1.00",
                                                        @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:hours"
                                                        };
            fakeTimeOffModel stub_method(@selector(getTimeoffBalanceForMultidayBooking:)).and_return(@[balanceDataFakeDictionary]);
            [subject updateBalanceValue:balanceDataFakeDictionary :1];
        });
        it(@"should update the Requested and Balance value of the table", ^{
            TimeOffRequestedCellView *requestedCell = (id)[subject tableView:subject.timeOffDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
            requestedCell.balanceValueLbl.text should equal(RPLocalizedString(@"308.38 hours", nil));
            requestedCell.requestedValueLbl.text should equal(RPLocalizedString(@"1.00 hour", nil));
        });

    });

    context(@"Checking for the balance and requested label values in days", ^{
        beforeEach(^{
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:1427068800];
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:1427587200];
            
            NSDictionary *fakeTimeOffDictionary = @{
                                                    @"startDate": [NSNumber numberWithDouble:[startDate timeIntervalSince1970]],
                                                    @"endDate": [NSNumber numberWithDouble:[endDate timeIntervalSince1970]],
                                                    @"approvalStatus": WAITING_FOR_APRROVAL_STATUS,
                                                    @"totalDurationDecimal": @12.00,
                                                    @"timeoffDurationDecimal": @4.00,
                                                    @"WAITING_FOR_APRROVAL_STATUS":@"",
                                                    @"timeoffTypeName":@"",
                                                    @"timeoffTypeUri":@"",
                                                    @"comments":@"",
                                                    @"timeoffUri":@"",
                                                    @"isDeviceSupportedEntryConfiguration":@FALSE,
                                                    @"startEntryDurationUri":FULLDAY_DURATION_TYPE_KEY,
                                                    @"endEntryDurationUri":HALFDAY_DURATION_TYPE_KEY,
                                                    @"startDateDurationDecimal":@8.00,
                                                    @"endDateDurationDecimal":@3.00,
                                                    @"startDateTime":@"",
                                                    @"endDateTime":@"",
                                                    @"totalTimeoffDays":@"",
                                                    @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:hours",
                                                    @"totalDurationHour":@"8"
                                                    };
            timeOffObject = [[TimeOffObject alloc] initWithDataDictionary:fakeTimeOffDictionary];
            subject.timeOffDetailsObj = timeOffObject;
            subject.navigationFlow = TIMEOFF_BOOKING_NAVIGATION;
            subject.balanceTrackingOption = TIME_OFF_AVAILABLE_KEY;
            [subject setUpTimeOffDetailsView:timeOffObject :TIMEOFF_BOOKING_NAVIGATION];
            
            NSDictionary *balanceDataFakeDictionary = @{
                                                        @"balanceRemainingDays":@"38.54795138",
                                                        @"balanceRemainingHours":@"308.38",
                                                        @"requestedDays":@"0.125",
                                                        @"requestedHours":@"1.00",
                                                        @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:work-days"
                                                        };
            fakeTimeOffModel stub_method(@selector(getTimeoffBalanceForMultidayBooking:)).and_return(@[balanceDataFakeDictionary]);
            [subject updateBalanceValue:balanceDataFakeDictionary :1];
        });
        it(@"should update the Requested and Balance value of the table", ^{
            TimeOffRequestedCellView *requestedCell = (id)[subject tableView:subject.timeOffDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
            requestedCell.balanceValueLbl.text should equal(RPLocalizedString(@"38.55 days", nil));
            requestedCell.requestedValueLbl.text should equal(RPLocalizedString(@"1.00 hour", nil));
        });
        
    });

    context(@"Checking for the balance and requested label values in days", ^{
        __block UIAlertView *alertView;
        
        beforeEach(^{
            
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:1427068800];
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:1427587200];
            NSDictionary *fakeTimeOffDictionary = @{
                                                    @"startDate": [NSNumber numberWithDouble:[startDate timeIntervalSince1970]],
                                                    @"endDate": [NSNumber numberWithDouble:[endDate timeIntervalSince1970]],
                                                    @"approvalStatus": WAITING_FOR_APRROVAL_STATUS,
                                                    @"totalDurationDecimal": @12.00,
                                                    @"timeoffDurationDecimal": @4.00,
                                                    @"WAITING_FOR_APRROVAL_STATUS":@"",
                                                    @"timeoffTypeName":@"",
                                                    @"timeoffTypeUri":@"",
                                                    @"comments":@"",
                                                    @"timeoffUri":@"",
                                                    @"isDeviceSupportedEntryConfiguration":@FALSE,
                                                    @"startEntryDurationUri":FULLDAY_DURATION_TYPE_KEY,
                                                    @"endEntryDurationUri":HALFDAY_DURATION_TYPE_KEY,
                                                    @"startDateDurationDecimal":@8.00,
                                                    @"endDateDurationDecimal":@3.00,
                                                    @"startDateTime":@"",
                                                    @"endDateTime":@"",
                                                    @"totalTimeoffDays":@"",
                                                    @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:hours",
                                                    @"totalDurationHour":@"8"
                                                    };
            timeOffObject = [[TimeOffObject alloc] initWithDataDictionary:fakeTimeOffDictionary];
            subject.timeOffDetailsObj = timeOffObject;
            subject.navigationFlow = TIMEOFF_BOOKING_NAVIGATION;
            subject.balanceTrackingOption = TIME_OFF_AVAILABLE_KEY;
            subject.timeOffStatus = YES;
            [subject setUpTimeOffDetailsView:timeOffObject :TIMEOFF_BOOKING_NAVIGATION];
            [subject ActionForSave_Edit];
            
        });
        it(@"should display a correctly configured alert", ^{
            alertView = [UIAlertView currentAlertView];
            alertView.message should equal(RPLocalizedString(MULTIDAY_NOT_SUPPORTED_FROM_MOBILE, @""));
            alertView.numberOfButtons should equal(1);
            [alertView buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @""));
        
        });
        
    });

    
});

SPEC_END
