#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SummarySpec)

Summary *(^doSummarySubjectAction)(TimeSheetApprovalStatus *, TimesheetDuration *,AllViolationSections *,NSInteger,TimeSheetPermittedActions *, NSString *,NSString *,NSDate *,PayWidgetData *) = ^(TimeSheetApprovalStatus *timesheetStatus, TimesheetDuration *duration,AllViolationSections *violationsAndWaivers,NSInteger issuesCount,TimeSheetPermittedActions *timeSheetPermittedActions, NSString *status,NSString *lastUpdatedString,NSDate *lastSuccessfulScriptCalculationDate,PayWidgetData *payWidgetData){
    return [[Summary alloc]initWithTimesheetStatus:timesheetStatus
                       workBreakAndTimeoffDuration:duration
                              violationsAndWaivers:violationsAndWaivers
                                       issuesCount:issuesCount 
                         timeSheetPermittedActions:timeSheetPermittedActions
                             lastUpdatedDateString:lastUpdatedString
                                            status:status 
               lastSuccessfulScriptCalculationDate:lastSuccessfulScriptCalculationDate 
                                     payWidgetData:payWidgetData];
};

describe(@"Summary", ^{
    __block Summary *summaryA;
    __block Summary *summaryB;


    describe(@"equality", ^{
        
        context(@"when the two objects are not the same type", ^{
            
            it(@"should not be equal", ^{
                summaryA = doSummarySubjectAction(nil,nil,nil,0,nil,nil,nil,nil,nil);
                summaryB = (Summary *)@"asdf";
                summaryA should_not equal(summaryB);
            });
        });
        
        context(@"when all the properties are nil", ^{
            
            it(@"should be equal", ^{
                summaryA = doSummarySubjectAction(nil,nil,nil,0,nil,nil,nil,nil,nil);
                summaryB = doSummarySubjectAction(nil,nil,nil,0,nil,nil,nil,nil,nil);
                summaryA should equal(summaryB);
            });
        });
        
        context(@"workBreakAndTimeoffDuration", ^{
            
            it(@"should not be equal", ^{
                
                NSDateComponents *regularHours = [[NSDateComponents alloc]init];
                regularHours.hour = 1;
                regularHours.minute = 2;
                regularHours.second = 3;
                
                NSDateComponents *breakHours = [[NSDateComponents alloc]init];
                breakHours.hour = 1;
                breakHours.minute = 2;
                breakHours.second = 3;
                
                NSDateComponents *timeoffHours = [[NSDateComponents alloc]init];
                timeoffHours.hour = 1;
                timeoffHours.minute = 2;
                timeoffHours.second = 3;

                
                TimesheetDuration *duration = [[TimesheetDuration alloc]initWithRegularHours:regularHours 
                                                                                  breakHours:breakHours 
                                                                                timeOffHours:timeoffHours];
                summaryA = doSummarySubjectAction(nil,nil,nil,0,nil,nil,nil,nil,nil);
                summaryB = doSummarySubjectAction(nil,duration,nil,0,nil,nil,nil,nil,nil);
                summaryA should_not equal(summaryB);
            });
            
            it(@"should be equal", ^{
                
                NSDateComponents *regularHoursA = [[NSDateComponents alloc]init];
                regularHoursA.hour = 1;
                regularHoursA.minute = 2;
                regularHoursA.second = 3;
                
                NSDateComponents *breakHoursA = [[NSDateComponents alloc]init];
                breakHoursA.hour = 1;
                breakHoursA.minute = 2;
                breakHoursA.second = 3;
                
                NSDateComponents *timeoffHoursA = [[NSDateComponents alloc]init];
                timeoffHoursA.hour = 1;
                timeoffHoursA.minute = 2;
                timeoffHoursA.second = 3;
                
                
                NSDateComponents *regularHoursB = [[NSDateComponents alloc]init];
                regularHoursB.hour = 1;
                regularHoursB.minute = 2;
                regularHoursB.second = 3;
                
                NSDateComponents *breakHoursB = [[NSDateComponents alloc]init];
                breakHoursB.hour = 1;
                breakHoursB.minute = 2;
                breakHoursB.second = 3;
                
                NSDateComponents *timeoffHoursB = [[NSDateComponents alloc]init];
                timeoffHoursB.hour = 1;
                timeoffHoursB.minute = 2;
                timeoffHoursB.second = 3;
                
                
                TimesheetDuration *durationA = [[TimesheetDuration alloc]initWithRegularHours:regularHoursA 
                                                                                  breakHours:breakHoursA 
                                                                                timeOffHours:timeoffHoursA];
                
                
                TimesheetDuration *durationB = [[TimesheetDuration alloc]initWithRegularHours:regularHoursB 
                                                                                   breakHours:breakHoursB 
                                                                                 timeOffHours:timeoffHoursB];
                summaryA = doSummarySubjectAction(nil,durationA,nil,0,nil,nil,nil,nil,nil);
                summaryB = doSummarySubjectAction(nil,durationB,nil,0,nil,nil,nil,nil,nil);
                summaryA should equal(summaryB);
            });
            
            it(@"should be equal", ^{
                
                TimesheetDuration *durationA = [[TimesheetDuration alloc]initWithRegularHours:nil 
                                                                                   breakHours:nil 
                                                                                 timeOffHours:nil];
                
                
                TimesheetDuration *durationB = [[TimesheetDuration alloc]initWithRegularHours:nil 
                                                                                   breakHours:nil 
                                                                                 timeOffHours:nil];
                summaryA = doSummarySubjectAction(nil,durationA,nil,0,nil,nil,nil,nil,nil);
                summaryB = doSummarySubjectAction(nil,durationB,nil,0,nil,nil,nil,nil,nil);
                summaryA should equal(summaryB);
            });
        });
        
        context(@"TimesheetStatus", ^{
            
            it(@"should not be equal", ^{
                
                TimeSheetApprovalStatus *status = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:@"some-uri"   
                                                                                               approvalStatus:@"some-status"];
                summaryA = doSummarySubjectAction(nil,nil,nil,0,nil,nil,nil,nil,nil);
                summaryB = doSummarySubjectAction(status,nil,nil,0,nil,nil,nil,nil,nil);
                summaryA should_not equal(summaryB);
            });
            
            it(@"should be equal", ^{
                
                TimeSheetApprovalStatus *statusA = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:@"some-uri"   
                                                                                             approvalStatus:@"some-status"];
                
                
                TimeSheetApprovalStatus *statusB = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:@"some-uri"   
                                                                                              approvalStatus:@"some-status"];
                summaryA = doSummarySubjectAction(statusA,nil,nil,0,nil,nil,nil,nil,nil);
                summaryB = doSummarySubjectAction(statusB,nil,nil,0,nil,nil,nil,nil,nil);
                summaryA should equal(summaryB);
            });
            
            it(@"should be equal", ^{
                
                TimeSheetApprovalStatus *statusA = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:nil   
                                                                                              approvalStatus:nil];
                
                
                TimeSheetApprovalStatus *statusB = [[TimeSheetApprovalStatus alloc]initWithApprovalStatusUri:nil   
                                                                                              approvalStatus:nil];
                summaryA = doSummarySubjectAction(statusA,nil,nil,0,nil,nil,nil,nil,nil);
                summaryB = doSummarySubjectAction(statusB,nil,nil,0,nil,nil,nil,nil,nil);
                summaryA should equal(summaryB);
            });
        });
        
        context(@"issuesCount", ^{
            
            it(@"should not be equal", ^{
                
                summaryA = doSummarySubjectAction(nil,nil,nil,0,nil,nil,nil,nil,nil);
                summaryB = doSummarySubjectAction(nil,nil,nil,1,nil,nil,nil,nil,nil);
                summaryA should_not equal(summaryB);
            });
            
            it(@"should be equal", ^{

                summaryA = doSummarySubjectAction(nil,nil,nil,3,nil,nil,nil,nil,nil);
                summaryB = doSummarySubjectAction(nil,nil,nil,3,nil,nil,nil,nil,nil);
                summaryA should equal(summaryB);
            });
            
        });
        
        context(@"lastUpdatedDateString", ^{
            
            it(@"should not be equal", ^{
                
                summaryA = doSummarySubjectAction(nil,nil,nil,0,nil,nil,nil,nil,nil);
                summaryB = doSummarySubjectAction(nil,nil,nil,0,nil,@"some-string-b",nil,nil,nil);
                summaryA should_not equal(summaryB);
            });
            
            it(@"should be equal", ^{
                
                summaryA = doSummarySubjectAction(nil,nil,nil,3,nil,@"some-string-b",nil,nil,nil);
                summaryB = doSummarySubjectAction(nil,nil,nil,3,nil,@"some-string-b",nil,nil,nil);
                summaryA should equal(summaryB);
            });
            
        });
        
        context(@"SummaryStatus", ^{
            
            it(@"should not be equal", ^{
                
                summaryA = doSummarySubjectAction(nil,nil,nil,0,nil,nil,nil,nil,nil);
                summaryB = doSummarySubjectAction(nil,nil,nil,0,nil,@"some-status",nil,nil,nil);
                summaryA should_not equal(summaryB);
            });
            
            it(@"should be equal", ^{
                summaryA = doSummarySubjectAction(nil,nil,nil,0,nil,@"some-status",nil,nil,nil);
                summaryB = doSummarySubjectAction(nil,nil,nil,0,nil,@"some-status",nil,nil,nil);
                summaryA should equal(summaryB);
            });
        });
        
        context(@"timeSheetPermittedActions", ^{
            
            it(@"should not be equal", ^{
                
                TimeSheetPermittedActions *timeSheetPermittedActionsB = [[TimeSheetPermittedActions alloc]initWithCanSubmitOnDueDate:false canReopen:true canReSubmitTimeSheet:false];
                summaryA = doSummarySubjectAction(nil,nil,nil,0,nil,nil,nil,nil,nil);
                summaryB = doSummarySubjectAction(nil,nil,nil,0,timeSheetPermittedActionsB,nil,nil,nil,nil);
                summaryA should_not equal(summaryB);
            });
            
            it(@"should be equal", ^{
                
                TimeSheetPermittedActions *timeSheetPermittedActionsA = [[TimeSheetPermittedActions alloc]initWithCanSubmitOnDueDate:false canReopen:true canReSubmitTimeSheet:false];
                
                TimeSheetPermittedActions *timeSheetPermittedActionsB = [[TimeSheetPermittedActions alloc]initWithCanSubmitOnDueDate:false canReopen:true canReSubmitTimeSheet:false];
                
                summaryA = doSummarySubjectAction(nil,nil,nil,0,timeSheetPermittedActionsA,nil,nil,nil,nil);
                summaryB = doSummarySubjectAction(nil,nil,nil,0,timeSheetPermittedActionsB,nil,nil,nil,nil);
                summaryA should equal(summaryB);
            });
        });
        
        context(@"lastSuccessfulScriptCalculationDate", ^{
            
            it(@"should not be equal", ^{
                summaryA = doSummarySubjectAction(nil,nil,nil,0,nil,nil,nil,nil,nil);
                summaryB = doSummarySubjectAction(nil,nil,nil,0,nil,nil,nil,[NSDate dateWithTimeIntervalSince1970:0],nil);
                summaryA should_not equal(summaryB);
            });
            
            it(@"should be equal", ^{
                summaryA = doSummarySubjectAction(nil,nil,nil,0,nil,nil,nil,[NSDate dateWithTimeIntervalSince1970:0],nil);
                summaryB = doSummarySubjectAction(nil,nil,nil,0,nil,nil,nil,[NSDate dateWithTimeIntervalSince1970:0],nil);
                summaryA should equal(summaryB);
            });
            
            it(@"should not be equal", ^{
                summaryA = doSummarySubjectAction(nil,nil,nil,0,nil,nil,nil,[NSDate dateWithTimeIntervalSince1970:0],nil);
                summaryB = doSummarySubjectAction(nil,nil,nil,0,nil,nil,nil,[NSDate dateWithTimeIntervalSince1970:1],nil);
                summaryA should_not equal(summaryB);
            });
        });
        
        context(@"payWidgetData", ^{
            
            it(@"should not be equal", ^{
                
                Paycode *payCodeA = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                Paycode *payCodeB = [[Paycode alloc] initWithValue:@"$300" title:@"some-pay-code" timeSeconds:nil];
                CurrencyValue *grossPay = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"$" amount:@30];
                GrossHours *grossHours = [[GrossHours alloc]initWithHours:@"hours" minutes:@"minutes"];
                PayWidgetData *payWidgetDataA = [[PayWidgetData alloc]initWithGrossHours:grossHours grossPay:grossPay actualsByPaycode:@[payCodeA] actualsByDuration:@[payCodeB]];
                summaryA = doSummarySubjectAction(nil,nil,nil,0,nil,nil,nil,nil,nil);
                summaryB = doSummarySubjectAction(nil,nil,nil,0,nil,nil,nil,nil,payWidgetDataA);
                summaryA should_not equal(summaryB);
            });
            
            it(@"should be equal", ^{
                
                Paycode *payCodeA = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                Paycode *payCodeB = [[Paycode alloc] initWithValue:@"$300" title:@"some-pay-code" timeSeconds:nil];
                CurrencyValue *grossPayA = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"$" amount:@30];
                GrossHours *grossHoursA = [[GrossHours alloc]initWithHours:@"hours" minutes:@"minutes"];
                PayWidgetData *payWidgetDataA = [[PayWidgetData alloc]initWithGrossHours:grossHoursA grossPay:grossPayA actualsByPaycode:@[payCodeA] actualsByDuration:@[payCodeB]];
                
                Paycode *payCodeAA = [[Paycode alloc] initWithValue:@"$30" title:@"some-pay-code" timeSeconds:nil];
                Paycode *payCodeBB = [[Paycode alloc] initWithValue:@"$300" title:@"some-pay-code" timeSeconds:nil];
                CurrencyValue *grossPayB = [[CurrencyValue alloc]initWithCurrencyDisplayText:@"$" amount:@30];
                GrossHours *grossHoursB = [[GrossHours alloc]initWithHours:@"hours" minutes:@"minutes"];
                PayWidgetData *payWidgetDataB = [[PayWidgetData alloc]initWithGrossHours:grossHoursB grossPay:grossPayB actualsByPaycode:@[payCodeAA] actualsByDuration:@[payCodeBB]];
                
                TimeSheetPermittedActions *timeSheetPermittedActionsA = [[TimeSheetPermittedActions alloc]initWithCanSubmitOnDueDate:false canReopen:true canReSubmitTimeSheet:false];
                
                TimeSheetPermittedActions *timeSheetPermittedActionsB = [[TimeSheetPermittedActions alloc]initWithCanSubmitOnDueDate:false canReopen:true canReSubmitTimeSheet:false];
                
                summaryA = doSummarySubjectAction(nil,nil,nil,0,timeSheetPermittedActionsA,nil,nil,nil,payWidgetDataA);
                summaryB = doSummarySubjectAction(nil,nil,nil,0,timeSheetPermittedActionsB,nil,nil,nil,payWidgetDataB);
                summaryA should equal(summaryB);
            });
        });
        
    });
});

SPEC_END
