#import <Cedar/Cedar.h>
#import "RepliconSpecHelper.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(WidgetTimesheetDeserializerSpec)

describe(@"WidgetTimesheetDeserializer", ^{
    __block WidgetTimesheetDeserializer *subject;
    __block id <BSInjector,BSBinder> injector;
    __block WidgetTimesheetSummaryDeserializer *widgetTimesheetSummaryDeserializer;
    __block NSCalendar *calendar;

    beforeEach(^{
        injector = [InjectorProvider injector];
        
        widgetTimesheetSummaryDeserializer = nice_fake_for([WidgetTimesheetSummaryDeserializer class]);
        [injector bind:[WidgetTimesheetSummaryDeserializer class] toInstance:widgetTimesheetSummaryDeserializer];

        calendar = nice_fake_for([NSCalendar class]);
        [injector bind:InjectorKeyCalendarWithUTCTimeZone toInstance:calendar];
        
        subject = [injector getInstance:[WidgetTimesheetDeserializer class]];
    });
    
    describe(@"deserialize:", ^{
        __block WidgetTimesheet *receivedWidgetTimesheet;
        __block NSString *timesheetUri;
        __block TimeSheetApprovalStatus *approvalStatus;
        __block TimesheetPeriod *timesheetPeriod;
        __block NSMutableDictionary *jsonDictionary;
        __block TimesheetDuration *timesheetDuration;
        __block Summary *expectedSummary;
        __block PayWidgetData *expectedPayWidgetData;
        
        context(@"when valid json response", ^{
            
            beforeEach(^{
                
                expectedPayWidgetData = [[PayWidgetData alloc]initWithGrossHours:nil 
                                                                        grossPay:nil
                                                                actualsByPaycode:nil
                                                               actualsByDuration:nil];
                
                expectedSummary = [[Summary alloc]initWithTimesheetStatus:nil
                                              workBreakAndTimeoffDuration:nil
                                                     violationsAndWaivers:nil
                                                              issuesCount:0 timeSheetPermittedActions:nil
                                                    lastUpdatedDateString:nil
                                                                   status:nil
                                      lastSuccessfulScriptCalculationDate:nil
                                                            payWidgetData:expectedPayWidgetData];
                
                jsonDictionary = [NSMutableDictionary dictionaryWithDictionary:[RepliconSpecHelper jsonWithFixture:@"widget_timesheet"]];                
                widgetTimesheetSummaryDeserializer stub_method(@selector(deserialize:isAutoSubmitEnabled:)).with(jsonDictionary[@"summary"],true).and_return(expectedSummary);
                
                timesheetUri = @"urn:replicon-tenant:4f0076fdc36342a6908df03bb5dbaee1:timesheet:39ca1236-b7d7-4f6b-8cfd-30e91562fd41";
                
                NSCalendar * calendar = [injector getInstance:InjectorKeyCalendarWithUTCTimeZone];
                NSDateComponents *startDateComponents = [[NSDateComponents alloc]init];
                startDateComponents.day = 10;
                startDateComponents.month = 7;
                startDateComponents.year = 2017;
                
                NSDateComponents *endDateComponents = [[NSDateComponents alloc]init];
                endDateComponents.day = 16;
                endDateComponents.month = 7;
                endDateComponents.year = 2017;
                
                NSDateComponents *workComponents = [[NSDateComponents alloc]init];
                workComponents.hour = 3;
                workComponents.minute = 4;
                workComponents.second = 5;
                
                NSDateComponents *breakComponents = [[NSDateComponents alloc]init];
                breakComponents.hour = 1;
                breakComponents.minute = 2;
                breakComponents.second = 3;
                
                NSDateComponents *timeoffComponents = [[NSDateComponents alloc]init];
                timeoffComponents.hour = 6;
                timeoffComponents.minute = 7;
                timeoffComponents.second = 8;
                
                
                timesheetDuration = [[TimesheetDuration alloc]initWithRegularHours:workComponents
                                                                        breakHours:breakComponents
                                                                      timeOffHours:timeoffComponents];
                
                NSDate *startDate = [calendar dateFromComponents:startDateComponents];
                NSDate *endDate = [calendar dateFromComponents:endDateComponents];
                approvalStatus = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:@"urn:replicon:approval-status:open"
                                                                            approvalStatus:@"Not Submitted"];
                
                timesheetPeriod = [[TimesheetPeriod alloc]initWithStartDate:startDate
                                                                    endDate:endDate];
            });
            
            it(@"should ask WidgetTimesheetSummaryDeserializer to return correct Summary", ^{
                receivedWidgetTimesheet = [subject deserialize:jsonDictionary];
                widgetTimesheetSummaryDeserializer should have_received(@selector(deserialize:isAutoSubmitEnabled:)).with(jsonDictionary[@"summary"],true);
                receivedWidgetTimesheet.summary should equal(expectedSummary);
            });
            
            it(@"should correctly set canOwnerViewPayrollSummary & displayPayAmount && displayPayTotals", ^{
                receivedWidgetTimesheet = [subject deserialize:jsonDictionary];
                receivedWidgetTimesheet.canOwnerViewPayrollSummary should be_truthy;
                receivedWidgetTimesheet.displayPayAmount should be_truthy;
                receivedWidgetTimesheet.displayPayTotals should be_truthy;
                receivedWidgetTimesheet.attestationStatus should equal(Unattested);
            });

            it(@"should ask TimesheetApprovalTimePunchCapabilities to return correct TimePunchCapabilities", ^{
                TimesheetApprovalTimePunchCapabilities *expectedTimesheetApprovalTimePunchCapabilities = [[TimesheetApprovalTimePunchCapabilities alloc]initWithHasBreakAccess:YES activitySelectionRequired:YES projectTaskSelectionRequired:YES hasProjectAccess:YES hasActivityAccess:YES hasClientAccess:YES];
                receivedWidgetTimesheet = [subject deserialize:jsonDictionary];
                receivedWidgetTimesheet.approvalTimePunchCapabilities should equal(expectedTimesheetApprovalTimePunchCapabilities);
            });
            
            context(@"when widgets are configured", ^{

                beforeEach(^{
                    jsonDictionary[@"widgets"] = @[@"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                   @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                   @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                   @"urn:replicon:policy:timesheet:widget-timesheet:attestation"
                                                   ];
                    receivedWidgetTimesheet = [subject deserialize:jsonDictionary];
                });
                
                it(@"should return correct WidgetTimesheet", ^{
                    receivedWidgetTimesheet.uri should equal(timesheetUri);
                    receivedWidgetTimesheet.period should equal(timesheetPeriod);
                    receivedWidgetTimesheet.summary should equal(expectedSummary);
                });
                
                it(@"should return correct WidgetTimesheet metadata objects", ^{
                    WidgetData *payrollMetaData = receivedWidgetTimesheet.widgetsMetaData[0];
                    payrollMetaData.timesheetWidgetTypeUri should equal(@"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary");
                    PayWidgetData *metadataForPayroll = (PayWidgetData *)payrollMetaData.timesheetWidgetMetaData;
                    metadataForPayroll should equal(expectedPayWidgetData);
                    
                    WidgetData *punchMetaData = receivedWidgetTimesheet.widgetsMetaData[1];
                    punchMetaData.timesheetWidgetTypeUri should equal(@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry");
                    PunchWidgetData *metadataForPunch = (PunchWidgetData *)punchMetaData.timesheetWidgetMetaData;
                    metadataForPunch should be_nil;
                    
                    WidgetData *noticeMetaData = receivedWidgetTimesheet.widgetsMetaData[2];
                    noticeMetaData.timesheetWidgetTypeUri should equal(@"urn:replicon:policy:timesheet:widget-timesheet:notice");
                    NoticeWidgetData *metadataForNotice = (NoticeWidgetData *)noticeMetaData.timesheetWidgetMetaData;
                    NoticeWidgetData *expectedNoticeMetaData = [[NoticeWidgetData alloc]initWithTitle:@"notice title"
                                                                                          description:@"notice text"];
                    metadataForNotice should equal(expectedNoticeMetaData);
                    
                    
                    WidgetData *attestationMetaData = receivedWidgetTimesheet.widgetsMetaData[3];
                    attestationMetaData.timesheetWidgetTypeUri should equal(@"urn:replicon:policy:timesheet:widget-timesheet:attestation");
                    AttestationWidgetData *metadataForAttestation = (AttestationWidgetData *)attestationMetaData.timesheetWidgetMetaData;
                    AttestationWidgetData *expectedAttestationMetaData = [[AttestationWidgetData alloc]initWithTitle:@"attestation-title"
                                                                                                         description:@"attestation-description"];
                    metadataForAttestation should equal(expectedAttestationMetaData);
                });
            });
            
            context(@"when widgets are not configured", ^{
                beforeEach(^{
                    [jsonDictionary removeObjectForKey:@"widgets"];
                    receivedWidgetTimesheet = [subject deserialize:jsonDictionary];
                });
                
                it(@"should return correct WidgetTimesheet", ^{
                    receivedWidgetTimesheet.uri should equal(timesheetUri);
                    receivedWidgetTimesheet.period should equal(timesheetPeriod);
                    receivedWidgetTimesheet.summary should equal(expectedSummary);
                    receivedWidgetTimesheet.widgetsMetaData.count should equal(0);
                });
            });
            
            context(@"when some unsupported widget is configured", ^{
                beforeEach(^{
                    jsonDictionary[@"widgets"] = @[@"some-value"];
                    receivedWidgetTimesheet = [subject deserialize:jsonDictionary];
                });
                
                it(@"should not set the widgetsMetaData", ^{
                    receivedWidgetTimesheet.widgetsMetaData.count should equal(0);
                });
            });
            
        });
        
        context(@"when invalid json response", ^{
            
            context(@"When nil json response", ^{
                
                beforeEach(^{
                    receivedWidgetTimesheet = [subject deserialize:nil];
                });
                
                it(@"should request the SwiftyJSONHelper to provide JSON", ^{
                    receivedWidgetTimesheet should be_nil;
                });
                
            });
            
            context(@"When non nil invalid json response", ^{
                
                beforeEach(^{
                    receivedWidgetTimesheet = [subject deserialize:@""];
                });
                
                it(@"should request the SwiftyJSONHelper to provide JSON", ^{
                    receivedWidgetTimesheet should be_nil;
                });
            });
            
        });
        
    });
});

SPEC_END
