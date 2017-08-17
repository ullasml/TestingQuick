#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

WidgetTimesheet *(^doSubjectAction)(NSString *, TimesheetPeriod *,Summary *,NSArray *,TimesheetApprovalTimePunchCapabilities *,BOOL,BOOL,BOOL,BOOL) = ^(NSString *uri, TimesheetPeriod *period,Summary *summary,NSArray *metadata,TimesheetApprovalTimePunchCapabilities *capabilities,BOOL canAutoSubmitOnDueDate,BOOL displayPayAmount,BOOL canOwnerViewPayrollSummary,BOOL displayPayTotals){
    return [[WidgetTimesheet alloc]initWithUri:uri
                                        period:period
                                       summary:summary
                               widgetsMetaData:metadata
                 approvalTimePunchCapabilities:capabilities
                        canAutoSubmitOnDueDate:canAutoSubmitOnDueDate
                              displayPayAmount:displayPayAmount 
                    canOwnerViewPayrollSummary:canOwnerViewPayrollSummary
                              displayPayTotals:displayPayTotals
                             attestationStatus:Attested];
};

SPEC_BEGIN(WidgetTimesheetSpec)

describe(@"WidgetTimesheet", ^{
    __block TimesheetPeriod *period;
    __block Summary *summary;
    __block NSArray *widgetsMetadata;
    __block TimesheetApprovalTimePunchCapabilities *approvalCapabalities;
    __block WidgetTimesheet *widgetTimesheetA;
    __block WidgetTimesheet *widgetTimesheetB;

    
    describe(@"<NSCopying>", ^{
        
        beforeEach(^{
            summary = nice_fake_for([Summary class]);
            period = nice_fake_for([TimesheetPeriod class]);
            approvalCapabalities = nice_fake_for([TimesheetApprovalTimePunchCapabilities class]);
            widgetsMetadata = @[@"some-widget-a",@"some-widget-b",@"some-widget-c"];
        });
        
        describe(NSStringFromSelector(@selector(copy)), ^{
            
            it(@"should return an exact copy of the object", ^{
                WidgetTimesheet *widgetTimesheetToBeCopied = [[WidgetTimesheet alloc]initWithUri:@"some-uri" 
                                                                                          period:period 
                                                                                         summary:summary 
                                                                                 widgetsMetaData:widgetsMetadata 
                                                                   approvalTimePunchCapabilities:approvalCapabalities 
                                                                          canAutoSubmitOnDueDate:false
                                                                                displayPayAmount:false 
                                                                      canOwnerViewPayrollSummary:false
                                                                                displayPayTotals:false
                                                                               attestationStatus:Attested];
                
                WidgetTimesheet *copiedWidgetTimesheet = [widgetTimesheetToBeCopied copy];
                
                copiedWidgetTimesheet should equal(widgetTimesheetToBeCopied);
                copiedWidgetTimesheet should_not be_same_instance_as(widgetTimesheetToBeCopied);
            });
        });
        
        describe(NSStringFromSelector(@selector(copyWithZone:)), ^{
            it(@"should return an exact copy of the object", ^{
                WidgetTimesheet *widgetTimesheetToBeCopied = [[WidgetTimesheet alloc]initWithUri:@"some-uri" 
                                                                                          period:period 
                                                                                         summary:summary 
                                                                                 widgetsMetaData:widgetsMetadata 
                                                                   approvalTimePunchCapabilities:approvalCapabalities 
                                                                          canAutoSubmitOnDueDate:false
                                                                                displayPayAmount:false 
                                                                      canOwnerViewPayrollSummary:false
                                                                                displayPayTotals:false
                                                                               attestationStatus:Attested];
                
                WidgetTimesheet *copiedWidgetTimesheet = [widgetTimesheetToBeCopied copyWithZone:nil];
                
                copiedWidgetTimesheet should equal(widgetTimesheetToBeCopied);
                copiedWidgetTimesheet should_not be_same_instance_as(widgetTimesheetToBeCopied);
            });
        });
    });
    
    describe(@"equality", ^{
        
        it(@"uri", ^{
            
            it(@"should be equal", ^{
                widgetTimesheetA = doSubjectAction(nil, nil,nil,nil,nil,false,false,false,false);
                widgetTimesheetB = doSubjectAction(@"timesheet-uri", nil,nil,nil,nil,false,false,false,false);
                widgetTimesheetA should_not equal(widgetTimesheetB);

            });
            
            it(@"should be equal", ^{
                widgetTimesheetA = doSubjectAction(@"timesheet-uri", nil,nil,nil,nil,false,false,false,false);
                widgetTimesheetA = doSubjectAction(@"timesheet-uri", nil,nil,nil,nil,false,false,false,false);
                widgetTimesheetA should equal(widgetTimesheetB);

            });
            
            it(@"should not be equal", ^{
                widgetTimesheetA = doSubjectAction(@"timesheet-uri-A", nil,nil,nil,nil,false,false,false,false);
                widgetTimesheetA = doSubjectAction(@"timesheet-uri-B", nil,nil,nil,nil,false,false,false,false);
                widgetTimesheetA should_not equal(widgetTimesheetB);
            });
            

        });
        
        it(@"period", ^{
            
            it(@"should be equal", ^{
                
                TimesheetPeriod *period = nice_fake_for([TimesheetPeriod class]);
                widgetTimesheetA = doSubjectAction(nil, nil,nil,nil,nil,false,false,false,false);
                widgetTimesheetB = doSubjectAction(nil, period,nil,nil,nil,false,false,false,false);
                widgetTimesheetA should_not equal(widgetTimesheetB);
                
            });
            
            it(@"should be equal", ^{
                TimesheetPeriod *periodA = [[TimesheetPeriod alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:0] 
                                                                             endDate:[NSDate dateWithTimeIntervalSince1970:1]];
                TimesheetPeriod *periodB = [[TimesheetPeriod alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:0] 
                                                                             endDate:[NSDate dateWithTimeIntervalSince1970:1]];

                widgetTimesheetA = doSubjectAction(@"timesheet-uri", periodA,nil,nil,nil,false,false,false,false);
                widgetTimesheetA = doSubjectAction(@"timesheet-uri", periodB,nil,nil,nil,false,false,false,false);
                widgetTimesheetA should equal(widgetTimesheetB);
                
            });
            
            it(@"should not be equal", ^{
                TimesheetPeriod *periodA = [[TimesheetPeriod alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1] 
                                                                             endDate:[NSDate dateWithTimeIntervalSince1970:1]];
                TimesheetPeriod *periodB = [[TimesheetPeriod alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:2] 
                                                                             endDate:[NSDate dateWithTimeIntervalSince1970:2]];
                
                widgetTimesheetA = doSubjectAction(@"timesheet-uri", periodA,nil,nil,nil,false,false,false,false);
                widgetTimesheetA = doSubjectAction(@"timesheet-uri", periodB,nil,nil,nil,false,false,false,false);
                widgetTimesheetA should_not equal(widgetTimesheetB);
            });
        });
        
        xit(@"summary", ^{
            
        });
        
        xit(@"widgetsMetaData", ^{
            
        });
        
        xit(@"approvalTimePunchCapabilities", ^{
            
        });
        
        it(@"canAutoSubmitOnDueDate", ^{
            
            it(@"should be equal", ^{
                widgetTimesheetA = doSubjectAction(nil, nil,nil,nil,nil,false,false,false,false);
                widgetTimesheetB = doSubjectAction(nil, nil,nil,nil,nil,true,false,false,false);
                widgetTimesheetA should_not equal(widgetTimesheetB);
                
            });
            
            it(@"should be equal", ^{
                widgetTimesheetA = doSubjectAction(nil, nil,nil,nil,nil,false,false,false,false);
                widgetTimesheetA = doSubjectAction(nil, nil,nil,nil,nil,false,false,false,false);
                widgetTimesheetA should equal(widgetTimesheetB);
                
            });
        });
        
        it(@"displayPayAmount", ^{
            
            it(@"should be equal", ^{
                widgetTimesheetA = doSubjectAction(nil, nil,nil,nil,nil,true,true,false,false);
                widgetTimesheetB = doSubjectAction(nil, nil,nil,nil,nil,true,false,false,false);
                widgetTimesheetA should_not equal(widgetTimesheetB);
                
            });
            
            it(@"should be equal", ^{
                widgetTimesheetA = doSubjectAction(nil, nil,nil,nil,nil,false,false,false,false);
                widgetTimesheetA = doSubjectAction(nil, nil,nil,nil,nil,false,false,false,false);
                widgetTimesheetA should equal(widgetTimesheetB);
                
            });
            
        });
        
        it(@"canOwnerViewPayrollSummary", ^{
            
            it(@"should be equal", ^{
                widgetTimesheetA = doSubjectAction(nil, nil,nil,nil,nil,true,false,true,false);
                widgetTimesheetB = doSubjectAction(nil, nil,nil,nil,nil,true,false,false,false);
                widgetTimesheetA should_not equal(widgetTimesheetB);
                
            });
            
            it(@"should be equal", ^{
                widgetTimesheetA = doSubjectAction(nil, nil,nil,nil,nil,false,false,false,false);
                widgetTimesheetA = doSubjectAction(nil, nil,nil,nil,nil,false,false,false,false);
                widgetTimesheetA should equal(widgetTimesheetB);
                
            });
            
        });
        
        it(@"displayPayTotals", ^{
            
            it(@"should be equal", ^{
                widgetTimesheetA = doSubjectAction(nil, nil,nil,nil,nil,false,false,false,true);
                widgetTimesheetB = doSubjectAction(nil, nil,nil,nil,nil,true,false,false,false);
                widgetTimesheetA should_not equal(widgetTimesheetB);
                
            });
            
            it(@"should be equal", ^{
                widgetTimesheetA = doSubjectAction(nil, nil,nil,nil,nil,false,false,false,false);
                widgetTimesheetA = doSubjectAction(nil, nil,nil,nil,nil,false,false,false,false);
                widgetTimesheetA should equal(widgetTimesheetB);
                
            });
            
        });
    });
});

SPEC_END
