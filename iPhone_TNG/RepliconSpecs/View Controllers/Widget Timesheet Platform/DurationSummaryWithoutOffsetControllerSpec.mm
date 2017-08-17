#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(DurationSummaryWithoutOffsetControllerSpec)


WidgetTimesheet *(^doSubjectAction)(NSString *, TimesheetPeriod *,Summary *,NSArray *,TimesheetApprovalTimePunchCapabilities *) = ^(NSString *uri, TimesheetPeriod *period,Summary *summary,NSArray *metadata,TimesheetApprovalTimePunchCapabilities *capabilities){
    return [[WidgetTimesheet alloc]initWithUri:uri
                                        period:period
                                       summary:summary
                               widgetsMetaData:metadata
                 approvalTimePunchCapabilities:capabilities
                        canAutoSubmitOnDueDate:false
                              displayPayAmount:false 
                    canOwnerViewPayrollSummary:false
                              displayPayTotals:false 
                             attestationStatus:Attested];
};

Summary *(^doSummarySubjectAction)(TimeSheetApprovalStatus *, TimesheetDuration *,AllViolationSections *,NSInteger,TimeSheetPermittedActions *, NSString *,NSString *,NSDate *) = ^(TimeSheetApprovalStatus *timesheetStatus, TimesheetDuration *duration,AllViolationSections *violationsAndWaivers,NSInteger issuesCount,TimeSheetPermittedActions *timeSheetPermittedActions, NSString *status,NSString *lastUpdatedString,NSDate *lastSuccessfulScriptCalculationDate){
    return [[Summary alloc]initWithTimesheetStatus:timesheetStatus
                       workBreakAndTimeoffDuration:duration
                              violationsAndWaivers:violationsAndWaivers
                                       issuesCount:issuesCount 
                         timeSheetPermittedActions:timeSheetPermittedActions
                             lastUpdatedDateString:lastUpdatedString
                                            status:status 
               lastSuccessfulScriptCalculationDate:lastSuccessfulScriptCalculationDate 
                                     payWidgetData:nil];
};

describe(@"DurationSummaryWithoutOffsetController", ^{
    __block DurationSummaryWithoutOffsetController *subject;
    __block id <Theme> theme;
    __block WidgetTimesheet *widgetTimesheet;
    __block id <DurationSummaryWithoutOffsetControllerDelegate> delegate;
    __block TimesheetDuration *timesheetDuration;
    __block NSDateComponents *workComponents;
    __block NSDateComponents *breakComponents;
    __block NSDateComponents *timeoffComponents;


    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
        theme stub_method(@selector(breakTimeDurationColor)).and_return([UIColor orangeColor]);
        theme stub_method(@selector(timeOffTimeDurationColor)).and_return([UIColor grayColor]);
        theme stub_method(@selector(workTimeDurationColor)).and_return([UIColor greenColor]);
        theme stub_method(@selector(timeDurationNameLabelFont)).and_return([UIFont systemFontOfSize:1]);
        theme stub_method(@selector(timeDurationValueLabelFont)).and_return([UIFont systemFontOfSize:2]);
        
        workComponents = [[NSDateComponents alloc]init];
        workComponents.hour = 1;
        workComponents.minute = 2;
        workComponents.second = 3;
        
        breakComponents = [[NSDateComponents alloc]init];
        breakComponents.hour = 4;
        breakComponents.minute = 5;
        breakComponents.second = 6;
        
        timeoffComponents = [[NSDateComponents alloc]init];
        timeoffComponents.hour = 7;
        timeoffComponents.minute = 8;
        timeoffComponents.second = 9;
        
        timesheetDuration = [[TimesheetDuration alloc]initWithRegularHours:workComponents
                                                                breakHours:breakComponents
                                                              timeOffHours:timeoffComponents];
        
        Summary *summary = doSummarySubjectAction(nil,timesheetDuration,nil,0,nil,nil,nil,nil);
        
        delegate = nice_fake_for(@protocol(DurationSummaryWithoutOffsetControllerDelegate));
        
        widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil);
        
    });
    
    context(@"styling the cells", ^{
        
        beforeEach(^{
            subject = [[DurationSummaryWithoutOffsetController alloc]initWithTheme:theme];
            [subject setupWithTimesheetDuration:timesheetDuration delegate:delegate hasBreakAccess:true];
            subject.view should_not be_nil;
            [subject.collectionView layoutIfNeeded];
        });
        
        it(@"should display the cells correctly", ^{
            subject.collectionView.visibleCells.count should equal(3);
            DurationCollectionCell *cellA = (DurationCollectionCell *)[subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];;
            DurationCollectionCell *cellB = (DurationCollectionCell *)[subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            DurationCollectionCell *cellC = (DurationCollectionCell *)[subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];;
            
            cellA.nameLabel.textColor should equal([UIColor greenColor]);
            cellA.durationHoursLabel.textColor should equal([UIColor greenColor]);
            cellA.durationHoursLabel.backgroundColor should equal([UIColor clearColor]);
            cellA.nameLabel.backgroundColor should equal([UIColor clearColor]);
            cellA.typeImageView.backgroundColor should equal([UIColor clearColor]);
            cellA.nameLabel.font should equal([UIFont systemFontOfSize:1]);
            cellA.durationHoursLabel.font should equal([UIFont systemFontOfSize:2]);


            
            cellB.nameLabel.textColor should equal([UIColor orangeColor]);
            cellB.durationHoursLabel.textColor should equal([UIColor orangeColor]);
            cellB.durationHoursLabel.backgroundColor should equal([UIColor clearColor]);
            cellB.nameLabel.backgroundColor should equal([UIColor clearColor]);
            cellB.typeImageView.backgroundColor should equal([UIColor clearColor]);
            cellB.nameLabel.font should equal([UIFont systemFontOfSize:1]);
            cellB.durationHoursLabel.font should equal([UIFont systemFontOfSize:2]);
            
           
            cellC.nameLabel.textColor should equal([UIColor grayColor]);
            cellC.durationHoursLabel.textColor should equal([UIColor grayColor]);
            cellC.durationHoursLabel.backgroundColor should equal([UIColor clearColor]);
            cellC.nameLabel.backgroundColor should equal([UIColor clearColor]);
            cellC.typeImageView.backgroundColor should equal([UIColor clearColor]);
            cellC.nameLabel.font should equal([UIFont systemFontOfSize:1]);
            cellC.durationHoursLabel.font should equal([UIFont systemFontOfSize:2]);
            
        });

    });
    
    context(@"presenting the break hours", ^{
        
        context(@"when break components is present", ^{
            beforeEach(^{
                timesheetDuration = [[TimesheetDuration alloc]initWithRegularHours:workComponents
                                                                        breakHours:breakComponents
                                                                      timeOffHours:timeoffComponents];
                Summary *summary = doSummarySubjectAction(nil,timesheetDuration,nil,0,nil,nil,nil,nil);
                widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil);
                subject = [[DurationSummaryWithoutOffsetController alloc]initWithTheme:theme];
                [subject setupWithTimesheetDuration:timesheetDuration delegate:delegate hasBreakAccess:true];
                subject.view should_not be_nil;
                [subject.collectionView layoutIfNeeded];
            });
            
            it(@"should display the cells correctly", ^{
                subject.collectionView.visibleCells.count should equal(3);
                DurationCollectionCell *cellA = (DurationCollectionCell *)[subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];;
                DurationCollectionCell *cellB = (DurationCollectionCell *)[subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                DurationCollectionCell *cellC = (DurationCollectionCell *)[subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];;
                cellA.durationHoursLabel.text should equal(@"1h:02m");
                cellA.nameLabel.text should equal(NSLocalizedString(@"Work", nil));
                cellA.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                
                cellB.durationHoursLabel.text should equal(@"4h:05m");
                cellB.nameLabel.text should equal(NSLocalizedString(@"Break", nil));
                cellB.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                
                cellC.durationHoursLabel.text should equal(@"7h:08m");
                cellC.nameLabel.text should equal(NSLocalizedString(@"Time Off", nil));
                cellC.typeImageView.image should equal([UIImage imageNamed:@"icon_time_off"]);
                
            });
        });
        
        context(@"when break components is not present", ^{
            
            beforeEach(^{
                breakComponents = [[NSDateComponents alloc]init];
                breakComponents.hour = 0;
                breakComponents.minute = 0;
                breakComponents.second = 0;
                timesheetDuration = [[TimesheetDuration alloc]initWithRegularHours:workComponents
                                                                        breakHours:breakComponents
                                                                      timeOffHours:timeoffComponents];
            });
            context(@"When break access is disabled", ^{
                beforeEach(^{
                    Summary *summary = doSummarySubjectAction(nil,timesheetDuration,nil,0,nil,nil,nil,nil);
                    widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil);
                    subject = [[DurationSummaryWithoutOffsetController alloc]initWithTheme:theme];
                    [subject setupWithTimesheetDuration:timesheetDuration delegate:delegate hasBreakAccess:false];
                    subject.view should_not be_nil;
                    [subject.collectionView layoutIfNeeded];
                });
                
                it(@"should display the cells correctly", ^{
                    subject.collectionView.visibleCells.count should equal(2);
                    DurationCollectionCell *cellA = (DurationCollectionCell *)[subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];;
                    DurationCollectionCell *cellC = (DurationCollectionCell *)[subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];;
                    cellA.durationHoursLabel.text should equal(@"1h:02m");
                    cellA.nameLabel.text should equal(NSLocalizedString(@"Work", nil));
                    cellA.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                    cellC.durationHoursLabel.text should equal(@"7h:08m");
                    cellC.nameLabel.text should equal(NSLocalizedString(@"Time Off", nil));
                    cellC.typeImageView.image should equal([UIImage imageNamed:@"icon_time_off"]);
                    
                });
            });
            
            context(@"When break access is enabled", ^{
                beforeEach(^{
                    Summary *summary = doSummarySubjectAction(nil,timesheetDuration,nil,0,nil,nil,nil,nil);
                    widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil);
                    subject = [[DurationSummaryWithoutOffsetController alloc]initWithTheme:theme];
                    [subject setupWithTimesheetDuration:timesheetDuration delegate:delegate hasBreakAccess:true];
                    subject.view should_not be_nil;
                    [subject.collectionView layoutIfNeeded];
                });
                
                it(@"should display the cells correctly", ^{
                    subject.collectionView.visibleCells.count should equal(3);
                    DurationCollectionCell *cellA = (DurationCollectionCell *)[subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];;
                    DurationCollectionCell *cellB = (DurationCollectionCell *)[subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    DurationCollectionCell *cellC = (DurationCollectionCell *)[subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];;
                    cellA.durationHoursLabel.text should equal(@"1h:02m");
                    cellA.nameLabel.text should equal(NSLocalizedString(@"Work", nil));
                    cellA.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                    
                    cellB.durationHoursLabel.text should equal(@"0h:00m");
                    cellB.nameLabel.text should equal(NSLocalizedString(@"Break", nil));
                    cellB.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                    
                    cellC.durationHoursLabel.text should equal(@"7h:08m");
                    cellC.nameLabel.text should equal(NSLocalizedString(@"Time Off", nil));
                    cellC.typeImageView.image should equal([UIImage imageNamed:@"icon_time_off"]);
                    
                });
            });
        });
    });
    
    context(@"presenting the time off hours", ^{
        
        context(@"when time off components is present", ^{
            beforeEach(^{
                timesheetDuration = [[TimesheetDuration alloc]initWithRegularHours:workComponents
                                                                        breakHours:breakComponents
                                                                      timeOffHours:timeoffComponents];

                Summary *summary = doSummarySubjectAction(nil,timesheetDuration,nil,0,nil,nil,nil,nil);
                widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil);
                subject = [[DurationSummaryWithoutOffsetController alloc]initWithTheme:theme];
                [subject setupWithTimesheetDuration:timesheetDuration delegate:delegate hasBreakAccess:true];
                subject.view should_not be_nil;
                [subject.collectionView layoutIfNeeded];
            });
            
            it(@"should display the cells correctly", ^{
                subject.collectionView.visibleCells.count should equal(3);
                DurationCollectionCell *cellA = (DurationCollectionCell *)[subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];;
                DurationCollectionCell *cellB = (DurationCollectionCell *)[subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                DurationCollectionCell *cellC = (DurationCollectionCell *)[subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];;
                cellA.durationHoursLabel.text should equal(@"1h:02m");
                cellA.nameLabel.text should equal(NSLocalizedString(@"Work", nil));
                cellA.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                
                cellB.durationHoursLabel.text should equal(@"4h:05m");
                cellB.nameLabel.text should equal(NSLocalizedString(@"Break", nil));
                cellB.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                
                cellC.durationHoursLabel.text should equal(@"7h:08m");
                cellC.nameLabel.text should equal(NSLocalizedString(@"Time Off", nil));
                cellC.typeImageView.image should equal([UIImage imageNamed:@"icon_time_off"]);
                
            });
        });
        
        context(@"when time off components is not present", ^{
            
            beforeEach(^{
                timeoffComponents = [[NSDateComponents alloc]init];
                timeoffComponents.hour = 0;
                timeoffComponents.minute = 0;
                timeoffComponents.second = 0;
                timesheetDuration = [[TimesheetDuration alloc]initWithRegularHours:workComponents
                                                                        breakHours:breakComponents
                                                                      timeOffHours:timeoffComponents];
                Summary *summary = doSummarySubjectAction(nil,timesheetDuration,nil,0,nil,nil,nil,nil);
                widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,summary,nil,nil);
                subject = [[DurationSummaryWithoutOffsetController alloc]initWithTheme:theme];
                [subject setupWithTimesheetDuration:timesheetDuration delegate:delegate hasBreakAccess:true];
                subject.view should_not be_nil;
                [subject.collectionView layoutIfNeeded];
            });
            
            it(@"should display the cells correctly", ^{
                subject.collectionView.visibleCells.count should equal(2);
                DurationCollectionCell *cellA = (DurationCollectionCell *)[subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];;
                DurationCollectionCell *cellB = (DurationCollectionCell *)[subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];;
                cellA.durationHoursLabel.text should equal(@"1h:02m");
                cellA.nameLabel.text should equal(NSLocalizedString(@"Work", nil));
                cellA.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                
                cellB.durationHoursLabel.text should equal(@"4h:05m");
                cellB.nameLabel.text should equal(NSLocalizedString(@"Break", nil));
                cellB.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                
            });
        });
    });
    
    context(@"presenting work hours , break hours and timeoff hours", ^{
        beforeEach(^{
            subject = [[DurationSummaryWithoutOffsetController alloc]initWithTheme:theme];
            [subject setupWithTimesheetDuration:timesheetDuration delegate:delegate hasBreakAccess:true];
            subject.view should_not be_nil;
            [subject.collectionView layoutIfNeeded];
        });
        
        it(@"should display the cells correctly", ^{
            subject.collectionView.visibleCells.count should equal(3);
            DurationCollectionCell *cellA = (DurationCollectionCell *)[subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];;
            DurationCollectionCell *cellB = (DurationCollectionCell *)[subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            DurationCollectionCell *cellC = (DurationCollectionCell *)[subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];;
            cellA.durationHoursLabel.text should equal(@"1h:02m");
            cellA.nameLabel.text should equal(NSLocalizedString(@"Work", nil));
            cellA.nameLabel.textColor should equal([UIColor greenColor]);
            cellA.durationHoursLabel.textColor should equal([UIColor greenColor]);
            cellA.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
            
            cellB.durationHoursLabel.text should equal(@"4h:05m");
            cellB.nameLabel.text should equal(NSLocalizedString(@"Break", nil));
            cellB.nameLabel.textColor should equal([UIColor orangeColor]);
            cellB.durationHoursLabel.textColor should equal([UIColor orangeColor]);
            cellB.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
            
            cellC.durationHoursLabel.text should equal(@"7h:08m");
            cellC.nameLabel.text should equal(NSLocalizedString(@"Time Off", nil));
            cellC.nameLabel.textColor should equal([UIColor grayColor]);
            cellC.durationHoursLabel.textColor should equal([UIColor grayColor]);
            cellC.typeImageView.image should equal([UIImage imageNamed:@"icon_time_off"]);
            
        });
    });
    
    describe(@"updates its height when view layouts", ^{
        
        beforeEach(^{
            subject = [[DurationSummaryWithoutOffsetController alloc]initWithTheme:theme];
            [subject setupWithTimesheetDuration:timesheetDuration delegate:delegate hasBreakAccess:true];
            subject.view should_not be_nil;
            [subject.collectionView layoutIfNeeded];
            [subject viewDidLayoutSubviews];
        });
        
        afterEach(^{
            stop_spying_on(subject.collectionView);
        });
        
        it(@"should request its delagte to update its container height constraint", ^{
            delegate should have_received(@selector(durationSummaryWithoutOffsetControllerIntendsToUpdateItsContainerWithHeight:)).with(Arguments::anything);
        });
    });
    

});

SPEC_END
