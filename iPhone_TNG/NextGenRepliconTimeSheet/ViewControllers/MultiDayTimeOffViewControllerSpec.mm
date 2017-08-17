#import <Cedar/Cedar.h>
#import "RepliconSpecHelper.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "Theme.h"
#import "NextGenRepliconTimeSheet-Swift.h"
#import "UITableViewCell+Spec.h"
#import "UdfDropDownViewController.h"
#import "UIBarButtonItem+Spec.h"
#import "UIControl+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MultiDayTimeOffViewControllerSpec)

describe(@"MultiDayTimeOffViewController", ^{
    __block MultiDayTimeOffViewController *subject;
    __block UdfDropDownViewController *udfDropDownViewController;
    __block id<Theme> theme;
    __block id<BSInjector, BSBinder> injector;
    
    __block TimeOffDeserializer *timeOffDeserializer;
    __block TimeOffRepository *timeOffRepository;
    __block ReachabilityMonitor *reachabilityMonitor;
    __block TimesheetModel *timesheetModel;
    __block AppDelegate *appDelegate;
    
    __block TimeoffModel *timeOffModel;
    __block ApprovalsModel *approvalsModel;
    __block LoginModel *loginModel;
    __block TimeOffRequestProvider *requestProvider;
    __block id<UserSession> userSession;
    __block id<RequestPromiseClient> requestPromiseClient;
    __block URLStringProvider *urlStringProvider;
    __block NSUserDefaults *userDefaults;
    __block GUIDProvider *guidProvider;
    
    beforeEach(^{
        injector = [InjectorProvider injector];
        
        timeOffModel = nice_fake_for([TimeoffModel class]);
        loginModel = nice_fake_for([LoginModel class]);
        approvalsModel = nice_fake_for([ApprovalsModel class]);
        udfDropDownViewController = nice_fake_for([UdfDropDownViewController class]);
        
        [injector bind:[TimeoffModel class] toInstance:timeOffModel];
        [injector bind:[LoginModel class] toInstance:loginModel];
        [injector bind:[ApprovalsModel class] toInstance:approvalsModel];
        [injector bind:[UdfDropDownViewController class] toInstance:udfDropDownViewController];
        
        urlStringProvider = nice_fake_for([URLStringProvider class]);
        guidProvider = nice_fake_for([GUIDProvider class]);
        userDefaults = nice_fake_for([NSUserDefaults class]);
        
        [injector bind:[URLStringProvider class] toInstance:urlStringProvider];
        [injector bind:[GUIDProvider class] toInstance:guidProvider];
        [injector bind:InjectorKeyStandardUserDefaults toInstance:userDefaults];
        
        requestProvider = nice_fake_for([TimeOffRequestProvider class]);
        requestPromiseClient = nice_fake_for(@protocol(RequestPromiseClient));
        userSession = nice_fake_for(@protocol(UserSession));
        timeOffDeserializer = nice_fake_for([TimeOffDeserializer class]);
        
        [injector bind:InjectorKeyRepliconClientForeground toInstance:requestPromiseClient];
        [injector bind:@protocol(UserSession) toInstance:userSession];
        [injector bind:InjectorKeyTimeOffDeserializer toInstance:timeOffDeserializer];
        [injector bind:InjectorKeyTimeOffRequestProvider toInstance:requestProvider];
        
        timeOffRepository = nice_fake_for([TimeOffRepository class]);
        reachabilityMonitor = [[ReachabilityMonitor alloc] init];
        spy_on(reachabilityMonitor);
        timesheetModel = nice_fake_for([TimesheetModel class]);
        theme = nice_fake_for(@protocol(Theme));
        appDelegate = nice_fake_for([AppDelegate class]);
        
        [injector bind:InjectorKeyTimeOffRepository toInstance:timeOffRepository];
        [injector bind:[ReachabilityMonitor class] toInstance:reachabilityMonitor];
        [injector bind:[TimesheetModel class] toInstance:timesheetModel];
        [injector bind:@protocol(Theme) toInstance:theme];
        [injector bind:InjectorKeyAppDelegate toInstance:appDelegate];
        
        subject = [injector getInstance:InjectorKeyMultiDayTimeOffViewController];
        
    });
    
    describe(@"TimeoffBooking with out TimeOffURI, Default timeoff model type", ^{
        __block TimeOffTypeDetails *timeOffTypeDetails = [[TimeOffTypeDetails alloc] initWithUri:@"Some-URI"
                                                                                           title:@"Some-Title"
                                                                                  measurementUri:@"Some-Mesurement-URI"];
        beforeEach(^{
            timeOffDeserializer stub_method(@selector(getAllTimeOffType)).and_return(@[timeOffTypeDetails]);
        });
        
        describe(@"Without setting start date and", ^{

            describe(@"With out default timeoff type details", ^{
                __block NSDate *currentDate;
                beforeEach(^{
                    currentDate = [NSDate date];
                    [subject setupWithModelType:TimeOffModelTypeTimeOff
                                     screenMode:0
                                 navigationFlow:TIMEOFF_BOOKING_NAVIGATION
                                       delegate:subject
                                     timeOffUri:@""
                                   timeSheetURI:@""
                                           date:currentDate];
                    
                    subject.view should_not be_nil;
                });
                
                it(@"should have called necessory methods from repository", ^{
                    appDelegate should have_received(@selector(showTransparentLoadingOverlay));
                    timeOffRepository should have_received(@selector(getUserEntriesAndDurationOptionsWithTimeOffTypeUri:startDate:endDate:)).with(timeOffTypeDetails.uri,currentDate,currentDate);
                });
            });
            
            describe(@"With default timeoff type details", ^{
                __block NSDate *currentDate;
                beforeEach(^{
                    TimeOffTypeDetails *defaultTypeDetails = [[TimeOffTypeDetails alloc] initWithUri:@"Test-URI"
                                                                                               title:@"Some-Title"
                                                                                      measurementUri:@"Some-Mesurement-URI"];
                    timeOffDeserializer stub_method(@selector(getDefaultTimeOffType)).and_return(defaultTypeDetails);
                    currentDate = [NSDate date];
                    [subject setupWithModelType:TimeOffModelTypeTimeOff
                                     screenMode:0
                                 navigationFlow:TIMEOFF_BOOKING_NAVIGATION
                                       delegate:subject
                                     timeOffUri:@""
                                   timeSheetURI:@""
                                           date:currentDate];
                    subject.view should_not be_nil;
                });
                
                it(@"should have called necessory methods from repository", ^{
                    appDelegate should have_received(@selector(showTransparentLoadingOverlay));
                    timeOffRepository should have_received(@selector(getUserEntriesAndDurationOptionsWithTimeOffTypeUri:startDate:endDate:)).with(@"Test-URI",currentDate,currentDate);
                });
            });
        });
        
        describe(@"With setting start date", ^{
            __block NSDate *date;
            beforeEach(^{
                date = [NSDate date];
                [subject setupWithModelType:TimeOffModelTypeTimeOff screenMode:ADD_BOOKTIMEOFF navigationFlow:UNKNOWN_NAVIGATION delegate:nil timeOffUri:nil timeSheetURI:nil date:date];
            });
            
            describe(@"With out default timeoff type details", ^{
                __block NSDate *currentDate;
                beforeEach(^{
                    currentDate = [NSDate date];
                    [subject setupWithModelType:TimeOffModelTypeTimeOff
                                     screenMode:0
                                 navigationFlow:TIMEOFF_BOOKING_NAVIGATION
                                       delegate:subject
                                     timeOffUri:@""
                                   timeSheetURI:@""
                                           date:currentDate];
                    subject.view should_not be_nil;
                });
                
                it(@"should have called necessory methods from repository", ^{
                    subject.navigationItem.rightBarButtonItem.title should equal(RPLocalizedString(@"Submit", @"Submit"));
                    subject.navigationItem.rightBarButtonItem.target should equal(subject);
                    
                    appDelegate should have_received(@selector(showTransparentLoadingOverlay));
                    timeOffRepository should have_received(@selector(getUserEntriesAndDurationOptionsWithTimeOffTypeUri:startDate:endDate:)).with(timeOffTypeDetails.uri,currentDate,currentDate);
                });
            });
            
            describe(@"With default timeoff type details", ^{
                __block NSDate *currentDate;
                beforeEach(^{
                    TimeOffTypeDetails *defaultTypeDetails = [[TimeOffTypeDetails alloc] initWithUri:@"Test-URI"
                                                                                               title:@"Some-Title"
                                                                                      measurementUri:@"Some-Mesurement-URI"];
                    timeOffDeserializer stub_method(@selector(getDefaultTimeOffType)).and_return(defaultTypeDetails);
                    currentDate = [NSDate date];
                    [subject setupWithModelType:TimeOffModelTypeTimeOff
                                     screenMode:0
                                 navigationFlow:TIMEOFF_BOOKING_NAVIGATION
                                       delegate:subject
                                     timeOffUri:@""
                                   timeSheetURI:@""
                                           date:currentDate];
                    subject.view should_not be_nil;
                });
                
                it(@"should have called necessory methods from repository", ^{
                    appDelegate should have_received(@selector(showTransparentLoadingOverlay));
                    timeOffRepository should have_received(@selector(getUserEntriesAndDurationOptionsWithTimeOffTypeUri:startDate:endDate:)).with(@"Test-URI",currentDate,currentDate);
                });
            });
        });
        
    });
    
    describe(@"TimeoffBooking with TimeOffURI, Default timeoff model type", ^{
        
        beforeEach(^{
            [subject setupWithModelType:TimeOffModelTypeTimeOff screenMode:ADD_BOOKTIMEOFF navigationFlow:UNKNOWN_NAVIGATION delegate:nil timeOffUri:@"Some-URI" timeSheetURI:nil date:nil];
        });
        
        describe(@"Without setting start date", ^{
            
            beforeEach(^{
                TimeOffDuration *timeOffDuration1 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:full-day"
                                                                                   title:@"Full Day"
                                                                                duration:@"8.0"];
                
                TimeOffDuration *timeOffDuration2 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:full-day"
                                                                                   title:@"Full Day"
                                                                                duration:@"8.0"];
                
                TimeOffDuration *timeOffDuration3 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:none"
                                                                                   title:@"None"
                                                                                duration:@"0.0"];
                
                TimeOffDuration *timeOffDuration4 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:none"
                                                                                   title:@"None"
                                                                                duration:@"0.0"];
                TimeOffDuration *timeOffDuration5 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:full-day"
                                                                                   title:@"Full Day"
                                                                                duration:@"8.0"];
                
                NSDate *entryDate1 = [NSDate dateWithTimeIntervalSince1970:1492041600];
                NSDate *entryDate2 = [NSDate dateWithTimeIntervalSince1970:1492128000];
                NSDate *entryDate3 = [NSDate dateWithTimeIntervalSince1970:1492214400];
                NSDate *entryDate4 = [NSDate dateWithTimeIntervalSince1970:1492300800];
                NSDate *entryDate5 = [NSDate dateWithTimeIntervalSince1970:1492387200];
                
                TimeOffEntry *timeOffEntry1 = [[TimeOffEntry alloc] initWithDate:entryDate1
                                                                scheduleDuration:@"8.0"
                                                              bookingDurationObj:timeOffDuration1
                                                                     timeStarted:@""
                                                                       timeEnded:@""];
                
                TimeOffEntry *timeOffEntry2 = [[TimeOffEntry alloc] initWithDate:entryDate2
                                                                scheduleDuration:@"8.0"
                                                              bookingDurationObj:timeOffDuration2
                                                                     timeStarted:@""
                                                                       timeEnded:@""];
                
                TimeOffEntry *timeOffEntry3 = [[TimeOffEntry alloc] initWithDate:entryDate3
                                                                scheduleDuration:@"0.0"
                                                              bookingDurationObj:timeOffDuration3
                                                                     timeStarted:@""
                                                                       timeEnded:@""];
                
                TimeOffEntry *timeOffEntry4 = [[TimeOffEntry alloc] initWithDate:entryDate4
                                                                scheduleDuration:@"0.0"
                                                              bookingDurationObj:timeOffDuration4
                                                                     timeStarted:@""
                                                                       timeEnded:@""];
                
                TimeOffEntry *timeOffEntry5 = [[TimeOffEntry alloc] initWithDate:entryDate5
                                                                scheduleDuration:@"0.0"
                                                              bookingDurationObj:timeOffDuration5
                                                                     timeStarted:@""
                                                                       timeEnded:@""];
                
                NSArray *timeOffDurations = [NSArray arrayWithObjects:timeOffDuration1,timeOffDuration2,timeOffDuration3,timeOffDuration4,timeOffDuration5, nil];
                
                TimeOffDurationOptions *timeOffDurationOptions = [[TimeOffDurationOptions alloc] initWithScheduleDuration:@"0.0"
                                                                                                          durationOptions:timeOffDurations];
                
                TimeOffUDF *timeOffUdf = [[TimeOffUDF alloc] initWithName:@"Number Udf" value:@"Hello" uri:@"UDF-uri" typeUri:@"Text" timeOffUri:@"timeOff-uri" decimalPlaces:2 optionsUri:@""];
                
                TimeOffTypeDetails *timeOffTypeDetails = [[TimeOffTypeDetails alloc] initWithUri:@"timeoff-type-uri" title:@"Vacation" measurementUri:@"days-measure"];
                
                TimeOffDetails *timeOffDetails = [[TimeOffDetails alloc] initWithUri:@"timeoff-type-uri" comments:@"hello" resubmitComments:@"hello" edit:YES delete:YES];
                
                TimeOffStatusDetails *statusDetails = [[TimeOffStatusDetails alloc] initWithUri:@"Some-URI" title:@"Some-Title"];
                TimeOff* timeOff = [[TimeOff alloc] initWithStartDayEntry:timeOffEntry1
                                                              endDayEntry:timeOffEntry5
                                                         middleDayEntries:@[timeOffEntry2, timeOffEntry3, timeOffEntry4]
                                                       allDurationOptions:@[timeOffDurationOptions]
                                                                  allUDFs:@[timeOffUdf]
                                                           approvalStatus:statusDetails
                                                              balanceInfo:nil
                                                                     type:timeOffTypeDetails
                                                                  details:timeOffDetails];
                timeOffDeserializer stub_method(@selector(deserializeTimeOffDetailsWithTimeOffUri:)).and_return(timeOff);
                subject.view should_not be_nil;
            });
            
            it(@"should have called deserializer with the URI", ^{
                subject.navigationItem.rightBarButtonItem.title should equal(RPLocalizedString(@"Edit", @"Edit"));
                timeOffDeserializer should have_received(@selector(deserializeTimeOffDetailsWithTimeOffUri:)).with(@"Some-URI");
            });
        });
        
    });
    
    describe(@"should have correct tableview cell values", ^{
        __block TimeOff *timeOff;
        context(@"display TableView Data", ^{
            beforeEach(^{
                NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:1497263121];
                NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:1497435921];
                NSDate *middleDate = [NSDate dateWithTimeIntervalSince1970:1497349521];
                
                TimeOffDuration *timeOffDuration = [[TimeOffDuration alloc] initWithUri:@"full-day"
                                                                                  title:@"Full day"
                                                                               duration:@"8.00"];
                
                TimeOffDuration *partialTimeOffDuration = [[TimeOffDuration alloc] initWithUri:@"partial-day"
                                                                                         title:@"Partial day"
                                                                                      duration:@"8.00"];
                
                TimeOffEntry *startDayEntry = [[TimeOffEntry alloc] initWithDate:startDate
                                                                scheduleDuration:@"8"
                                                              bookingDurationObj:timeOffDuration
                                                                     timeStarted:@"10:30"
                                                                       timeEnded:@""];
                
                TimeOffEntry *endDayEntry = [[TimeOffEntry alloc] initWithDate:endDate
                                                              scheduleDuration:@"8"
                                                            bookingDurationObj:timeOffDuration
                                                                   timeStarted:@""
                                                                     timeEnded:@""];
                
                TimeOffEntry *middleDayEntry = [[TimeOffEntry alloc] initWithDate:middleDate
                                                                 scheduleDuration:@"3.5"
                                                               bookingDurationObj:partialTimeOffDuration
                                                                      timeStarted:@"10:00"
                                                                        timeEnded:@""];
                
                TimeOffUDF *timeOffUdf1 = [[TimeOffUDF alloc] initWithName:@"text-udf"
                                                                     value:@"Hello"
                                                                       uri:@"text-udf-uri"
                                                                   typeUri:@""
                                                                timeOffUri:@"timeoff-uri"
                                                             decimalPlaces:0
                                                                optionsUri:@""];
                
                TimeOffUDF *timeOffUdf2 = [[TimeOffUDF alloc] initWithName:@"numeric-udf"
                                                                     value:@"123123"
                                                                       uri:@"num-udf-uri"
                                                                   typeUri:@""
                                                                timeOffUri:@"timeoff-uri"
                                                             decimalPlaces:2
                                                                optionsUri:@""];
                
                TimeOffUDF *timeOffUdf3 = [[TimeOffUDF alloc] initWithName:@"date-udf"
                                                                     value:@"12/02/2017"
                                                                       uri:@"date-udf-uri"
                                                                   typeUri:@""
                                                                timeOffUri:@"timeoff-uri"
                                                             decimalPlaces:0
                                                                optionsUri:@""];
                
                TimeOffUDF *timeOffUdf4 = [[TimeOffUDF alloc] initWithName:@"dropdown-udf"
                                                                     value:@"Hello"
                                                                       uri:@"dropdown-udf-uri"
                                                                   typeUri:@""
                                                                timeOffUri:@"timeoff-uri"
                                                             decimalPlaces:0
                                                                optionsUri:@""];
                
                TimeOffStatusDetails *timeOffStatusDetails = [[TimeOffStatusDetails alloc] initWithUri:@"waiting-uri"
                                                                                                 title:@"Waiting For Approval"];
                
                TimeOffBalance *timeOffBalance = [[TimeOffBalance alloc] initWithTimeRemaining:@"5"
                                                                                     timeTaken:@"1"];
                
                TimeOffTypeDetails *timeOffTypeDetails = [[TimeOffTypeDetails alloc] initWithUri:@"type-uri"
                                                                                           title:@"Vacation"
                                                                                  measurementUri:@"timeoff-days"];
                
                TimeOffDetails *timeOffDetails = [[TimeOffDetails alloc] initWithUri:@"timeoff-uri"
                                                                            comments:@"submit-comments"
                                                                    resubmitComments:@""
                                                                                edit:TRUE
                                                                              delete:TRUE];
                
                timeOff = [[TimeOff alloc] initWithStartDayEntry:startDayEntry
                                                     endDayEntry:endDayEntry
                                                middleDayEntries:@[middleDayEntry]
                                              allDurationOptions:@[timeOffDuration, partialTimeOffDuration]
                                                         allUDFs:@[timeOffUdf1,timeOffUdf2,timeOffUdf3,timeOffUdf4]
                                                  approvalStatus:timeOffStatusDetails
                                                     balanceInfo:timeOffBalance
                                                            type:timeOffTypeDetails
                                                         details:timeOffDetails];
                
                [subject setupWithModelType:TimeOffModelTypeTimeOff screenMode:ADD_BOOKTIMEOFF navigationFlow:UNKNOWN_NAVIGATION delegate:nil timeOffUri:@"timeoff-uri" timeSheetURI:nil date:nil];
                timeOffDeserializer stub_method(@selector(deserializeTimeOffDetailsWithTimeOffUri:)).and_return(timeOff);
                subject.view should_not be_nil;
                spy_on(subject.tableView);
            });
            
            context(@"Timeoff type section", ^{
                __block TimeOffTypeCell *cell;
                beforeEach(^{
                    cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
                });
                it(@"should have correct values for first section", ^{
                    
                    cell.timeOffType.text should equal(@"Vacation");
                    cell.typetitle.text should equal(@"Type :");
                });
            });
            
            context(@"TimeOff Start Date", ^{
                __block TimeOffDateEntryCell *cell;
                beforeEach(^{
                    cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
                });
                it(@"should have correct values for start date section", ^{
                    cell.dayTitle.text should equal(@"Start Date");
                    cell.weekDayDesc.text should equal(@"Mon, Jun 12");
                    cell.scheduleDuration.text should equal(@"8.00");
                    cell.scheduleDurationTitle.text should equal(@"Scheduled Days");
                    cell.bookDurationTitle.text should equal(@"Book Days");
                    cell.leaveType.titleLabel.text should equal(@"Full day");
                });
            });
            
            context(@"TimeOff End Date", ^{
                __block TimeOffDateEntryCell *cell;
                beforeEach(^{
                    cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:3]];
                });
                it(@"should have correct values for end date section", ^{
                    
                    cell.dayTitle.text should equal(@"End Date");
                    cell.weekDayDesc.text should equal(@"Wed, Jun 14");
                    cell.scheduleDuration.text should equal(@"8.00");
                    cell.scheduleDurationTitle.text should equal(@"Scheduled Days");
                    cell.bookDurationTitle.text should equal(@"Book Days");
                    cell.leaveType.titleLabel.text should equal(@"Full day");
                });
            });
            
            context(@"TimeOff Balance", ^{
                __block TimeOffBalanceCell *cell;
                beforeEach(^{
                    cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:4]];
                });
                it(@"should have correct values for balance section", ^{
                    cell.requestedTitle.text should equal(@"Requested :");
                    cell.balanceTitle.text should equal(@"Balance :");
                    cell.timeTaken.text should equal(@"1.00 day");
                    cell.timeRemaining.text should equal(@"5.00 days");
                });
            });
            
            context(@"TimeOff Comments", ^{
                __block TimeOffCommentsCell *cell;
                beforeEach(^{
                    cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:5]];
                });
                it(@"should design correct comments section", ^{
                    
                    cell.commentsTitle.text should equal(@"Comments");
                    cell.userComments.text should equal(@"submit-comments");
                });
            });
            
            context(@"TimeOff Udf's", ^{
                __block TimeOffUDFCell *cell1;
                __block TimeOffUDFCell *cell2;
                __block TimeOffUDFCell *cell3;
                __block TimeOffUDFCell *cell4;
                
                beforeEach(^{
                    cell1 = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:6]];
                    cell2 = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:6]];
                    cell3 = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:6]];
                    cell4 = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:6]];
                });
                it(@"should design UDF's correctly", ^{
                    cell1.title.text should equal(@"text-udf");
                    cell1.valueLabel.text should equal(@"Hello");
                    
                    cell2.title.text should equal(@"numeric-udf");
                    cell2.valueLabel.text should equal(@"123123");
                    
                    cell3.title.text should equal(@"date-udf");
                    cell3.valueLabel.text should equal(@"12/02/2017");
                    
                    cell4.title.text should equal(@"dropdown-udf");
                    cell4.valueLabel.text should equal(@"Hello");
                });
            });
            
            context(@"TimeOff Delete", ^{
                __block TimeOffActionCell *cell;
                beforeEach(^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:7];
                    [subject.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                    cell = [subject.tableView cellForRowAtIndexPath:indexPath];
                });
                
                it(@"should style the button", ^{
                    cell.deleteBtn.titleLabel.text should equal(@"Delete");
                });
            });
        });
    });
    
    describe(@"Timeoff Loading for Approvals", ^{
        
        beforeEach(^{
            TimeOffDuration *timeOffDuration1 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:full-day"
                                                                               title:@"Full Day"
                                                                            duration:@"8.0"];
            
            TimeOffDuration *timeOffDuration2 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:full-day"
                                                                               title:@"Full Day"
                                                                            duration:@"8.0"];
            
            TimeOffDuration *timeOffDuration3 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:none"
                                                                               title:@"None"
                                                                            duration:@"0.0"];
            
            TimeOffDuration *timeOffDuration4 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:none"
                                                                               title:@"None"
                                                                            duration:@"0.0"];
            
            TimeOffDuration *timeOffDuration5 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:full-day"
                                                                               title:@"Full Day"
                                                                            duration:@"8.0"];
            
            NSDate *entryDate1 = [NSDate dateWithTimeIntervalSince1970:1492041600];
            NSDate *entryDate2 = [NSDate dateWithTimeIntervalSince1970:1492128000];
            NSDate *entryDate3 = [NSDate dateWithTimeIntervalSince1970:1492214400];
            NSDate *entryDate4 = [NSDate dateWithTimeIntervalSince1970:1492300800];
            NSDate *entryDate5 = [NSDate dateWithTimeIntervalSince1970:1492387200];
            
            TimeOffEntry *timeOffEntry1 = [[TimeOffEntry alloc] initWithDate:entryDate1
                                                            scheduleDuration:@"8.0"
                                                          bookingDurationObj:timeOffDuration1
                                                                 timeStarted:@""
                                                                   timeEnded:@""];
            
            TimeOffEntry *timeOffEntry2 = [[TimeOffEntry alloc] initWithDate:entryDate2
                                                            scheduleDuration:@"8.0"
                                                          bookingDurationObj:timeOffDuration2
                                                                 timeStarted:@""
                                                                   timeEnded:@""];
            
            TimeOffEntry *timeOffEntry3 = [[TimeOffEntry alloc] initWithDate:entryDate3
                                                            scheduleDuration:@"0.0"
                                                          bookingDurationObj:timeOffDuration3
                                                                 timeStarted:@""
                                                                   timeEnded:@""];
            
            TimeOffEntry *timeOffEntry4 = [[TimeOffEntry alloc] initWithDate:entryDate4
                                                            scheduleDuration:@"0.0"
                                                          bookingDurationObj:timeOffDuration4
                                                                 timeStarted:@""
                                                                   timeEnded:@""];
            
            TimeOffEntry *timeOffEntry5 = [[TimeOffEntry alloc] initWithDate:entryDate5
                                                            scheduleDuration:@"0.0"
                                                          bookingDurationObj:timeOffDuration5
                                                                 timeStarted:@""
                                                                   timeEnded:@""];
            
            NSArray *timeOffDurations = [NSArray arrayWithObjects:timeOffDuration1,timeOffDuration2,timeOffDuration3,timeOffDuration4,timeOffDuration5, nil];
            
            TimeOffDurationOptions *timeOffDurationOptions = [[TimeOffDurationOptions alloc] initWithScheduleDuration:@"0.0"
                                                              
                                                                                                      durationOptions:timeOffDurations];
            
            TimeOffUDF *timeOffUdf = [[TimeOffUDF alloc] initWithName:@"Number Udf" value:@"Hello" uri:@"UDF-uri" typeUri:@"Text" timeOffUri:@"timeOff-uri" decimalPlaces:2 optionsUri:@""];
            
            TimeOffTypeDetails *timeOffTypeDetails = [[TimeOffTypeDetails alloc] initWithUri:@"timeoff-type-uri" title:@"Vacation" measurementUri:@"days-measure"];
            
            TimeOffDetails *timeOffDetails = [[TimeOffDetails alloc] initWithUri:@"timeoff-type-uri" comments:@"hello" resubmitComments:@"hello" edit:YES delete:YES];
            
            TimeOffStatusDetails *statusDetails = [[TimeOffStatusDetails alloc] initWithUri:@"Some-URI" title:@"Some-Title"];
            
            TimeOff* timeOff = [[TimeOff alloc] initWithStartDayEntry:timeOffEntry1
                                                          endDayEntry:timeOffEntry5
                                                     middleDayEntries:@[timeOffEntry2, timeOffEntry3, timeOffEntry4]
                                                   allDurationOptions:@[timeOffDurationOptions]
                                                              allUDFs:@[timeOffUdf]
                                                       approvalStatus:statusDetails
                                                          balanceInfo:nil
                                                                 type:timeOffTypeDetails
                                                              details:timeOffDetails];
            timeOffDeserializer stub_method(@selector(deserializeTimeOffDetailsWithTimeOffUri:)).and_return(timeOff);
            
        });
        
        
        
        describe(@"Pending", ^{
            
            beforeEach(^{
                [subject setupWithModelType:TimeOffModelTypePendingApproval screenMode:VIEW_BOOKTIMEOFF navigationFlow:PENDING_APPROVER_NAVIGATION delegate:nil timeOffUri:@"Some-URI" timeSheetURI:nil date:nil];
                [subject setupForApprovalWithUserName:@"Some-UserName" timeoffType:@"Some-TimeoffType" currentViewTag:@(2) totalViewCount:@(10)];
                subject.view should_not be_nil;
            });
            
            it(@"timeoffDeserializer should have recieved setTimeoffModel type with Pending Approvals",^{
                
                timeOffDeserializer should have_received(@selector(setTimeOffModelTypeWithType:)).with(TimeOffModelTypePendingApproval);
            });
        });
        
        describe(@"Previous", ^{
            beforeEach(^{
                [subject setupWithModelType:TimeOffModelTypePreviousApproval screenMode:VIEW_BOOKTIMEOFF navigationFlow:PREVIOUS_APPROVER_NAVIGATION delegate:self timeOffUri:@"Some-URI" timeSheetURI:nil date:nil];
                
                [subject setupForApprovalWithUserName:@"Some-UserName" timeoffType:@"Some-TimeoffType" currentViewTag:nil totalViewCount:nil];
                
                subject.view should_not be_nil;
                
            });
            
            it(@"timeoffDeserializer should have recieved setTimeoffModel type with Pending Approvals",^{
                timeOffDeserializer should have_received(@selector(setTimeOffModelTypeWithType:)).with(TimeOffModelTypePreviousApproval);
            });
            
        });
        
    });
    
    
});

SPEC_END
