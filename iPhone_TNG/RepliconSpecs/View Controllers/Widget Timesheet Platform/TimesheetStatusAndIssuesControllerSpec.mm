#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "UIControl+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimesheetStatusAndIssuesControllerSpec)

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

describe(@"TimesheetStatusAndIssuesController", ^{
    __block TimesheetStatusAndIssuesController *subject;
    __block id<Theme> theme;
    __block id <BSBinder,BSInjector> injector;
    __block id <TimesheetStatusAndIssuesControllerDelegate> delegate;
    __block WidgetTimesheet *widgetTimesheet;
    __block TimesheetPeriod *period;
    __block TimeSheetApprovalStatus *status;
    __block TimesheetDuration *timesheetDuration;
    
    beforeEach(^{
        injector = [InjectorProvider injector];
        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];
        
        theme stub_method(@selector(timesheetStatusLabelFont)).and_return([UIFont systemFontOfSize:3]);
        theme stub_method(@selector(issuesButtonDefaultTitleOrBorderColor)).and_return([UIColor redColor]);
        theme stub_method(@selector(timesheetStatusButtonDefaultTitleOrBorderColor)).and_return([UIColor greenColor]);
        theme stub_method(@selector(timesheetIssuesCountLabelFont)).and_return([UIFont systemFontOfSize:4]);
        theme stub_method(@selector(issuesCountColor)).and_return([UIColor orangeColor]);
        theme stub_method(@selector(timesheetViolationsLabelFont)).and_return([UIFont systemFontOfSize:5]);
        
        theme stub_method(@selector(notSubmittedColor)).and_return([UIColor magentaColor]);
        theme stub_method(@selector(approvedColor)).and_return([UIColor yellowColor]);
        theme stub_method(@selector(rejectedColor)).and_return([UIColor brownColor]);
        theme stub_method(@selector(waitingForApprovalButtonBorderColor)).and_return([UIColor cyanColor]);
        
        delegate = nice_fake_for(@protocol(TimesheetStatusAndIssuesControllerDelegate));
        period = nice_fake_for([TimesheetPeriod class]);
        status = nice_fake_for([TimeSheetApprovalStatus class]);
        status stub_method(@selector(approvalStatusUri)).and_return(@"urn:replicon:timesheet-status:approved");
        timesheetDuration = nice_fake_for([TimesheetDuration class]);
        delegate = nice_fake_for(@protocol(TimesheetStatusAndIssuesControllerDelegate));
        
       
        Summary *summary = doSummarySubjectAction(status,timesheetDuration,nil,3,nil,nil,nil,nil);
        widgetTimesheet = doSubjectAction(@"timesheet-uri", period,summary,nil,nil);
        subject = [injector getInstance:[TimesheetStatusAndIssuesController class]];
        
    });
    
    context(@"when issuesCount is zero", ^{
        
        beforeEach(^{
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate];
            subject.view should_not be_nil;
        });
        
        it(@"should not add issuesStatusLabel to its view", ^{
            subject.view.subviews should_not contain(subject.issuesStatusLabel);
            subject.view.subviews should_not contain(subject.issuesStatusView);
            
        });
        
    });
    
    context(@"when issuesCount is non zero", ^{
        
        it(@"Validation Count is plural", ^{

            Summary *summary = doSummarySubjectAction(status,timesheetDuration,nil,7,nil,nil,nil,nil);

            widgetTimesheet = doSubjectAction(@"timesheet-uri", period,summary,nil,nil);
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate];
            subject.view should_not be_nil;
            subject.issuesStatusLabel.text should equal(@"Validations");
            
        });
        
        it(@"Validation Count is singular", ^{
            
            Summary *summary = doSummarySubjectAction(status,timesheetDuration,nil,1,nil,nil,nil,nil);
            widgetTimesheet = doSubjectAction(@"timesheet-uri", period,summary,nil,nil);            
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate];
            subject.view should_not be_nil;
            subject.issuesStatusLabel.text should equal(@"Validation");
            
        });
        
        it(@"should correctly display issuesStatusLabel", ^{
            
            Summary *summary = doSummarySubjectAction(status,timesheetDuration,nil,7,nil,nil,nil,nil);

            widgetTimesheet = doSubjectAction(@"timesheet-uri", period,summary,nil,nil);            
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate];
            subject.view should_not be_nil;
            
            subject.issuesStatusLabel.font should equal([UIFont systemFontOfSize:3]);
            subject.issuesStatusLabel.textColor should equal( [UIColor redColor]);
            subject.issuesStatusLabel.backgroundColor should equal( [UIColor clearColor]);
            subject.issuesStatusLabel.text should equal(@"Validations");
            
            subject.issuesCountLabel.text should equal(@"7");
            subject.issuesCountLabel.textColor should equal( [UIColor orangeColor]);
            subject.issuesCountLabel.font should equal([UIFont systemFontOfSize:4]);
            
            subject.issuesStatusImageView.image should equal([UIImage imageNamed:@"violation-active"]);
            subject.issuesStatusImageView.backgroundColor = [UIColor clearColor];
            
            subject.issuesButton.backgroundColor should equal([UIColor clearColor]);
            subject.issuesButton.titleLabel.font should equal([UIFont systemFontOfSize:5]);
            subject.issuesButton.currentTitleColor should equal([UIColor clearColor]);
            subject.issuesButton.layer.cornerRadius should equal(14);
            subject.issuesButton.layer.borderColor should equal([[UIColor redColor] CGColor]) ;
            subject.issuesButton.layer.borderWidth should equal(2);
            subject.issuesButton.clipsToBounds should be_truthy;
            
            subject.approvalStatusLabel.font should equal( [UIFont systemFontOfSize:3]);
            subject.approvalStatusLabel.backgroundColor should equal( [UIColor clearColor]);
            subject.approvalStatusImageView.backgroundColor should equal( [UIColor clearColor]);
            
        });
        
        context(@"timesheet status", ^{
            
            context(@"when status is urn:replicon:timesheet-status:approved", ^{
                beforeEach(^{
                    status stub_method(@selector(approvalStatusUri)).again().and_return(@"urn:replicon:timesheet-status:approved");
                    [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate];
                    subject.view should_not be_nil;
                });
                
                it(@"should correctly configure the approval status", ^{
                    subject.approvalStatusImageView.image should equal([UIImage imageNamed:@"approved"]);
                    subject.approvalStatusLabel.text should equal( NSLocalizedString(APPROVED_STATUS, nil));
                    subject.approvalStatusLabel.textColor should equal( [UIColor yellowColor]);
                    subject.approvalStatusLabel.font should equal([UIFont systemFontOfSize:3]);
                    subject.approvalStatusLabel.backgroundColor should equal([UIColor clearColor]);
                    subject.approvalStatusImageView.backgroundColor should equal( [UIColor clearColor]);
                    
                    subject.approvalStatusButton.backgroundColor should equal([UIColor clearColor]);
                    subject.approvalStatusButton.titleLabel.font should equal([UIFont systemFontOfSize:5]);
                    subject.approvalStatusButton.currentTitleColor should equal([UIColor clearColor]);
                    subject.approvalStatusButton.layer.cornerRadius should equal(14);
                    subject.approvalStatusButton.layer.borderColor should equal([[UIColor yellowColor] CGColor]) ;
                    subject.approvalStatusButton.layer.borderWidth should equal(2);
                    subject.approvalStatusButton.clipsToBounds should be_truthy;
                });
            });
            
            context(@"urn:replicon:timesheet-status:open", ^{
                beforeEach(^{
                    status stub_method(@selector(approvalStatusUri)).again().and_return(@"urn:replicon:timesheet-status:open");
                    [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate];
                    subject.view should_not be_nil;
                });
                
                it(@"should correctly configure the approval status", ^{
                    subject.approvalStatusImageView.image should equal([UIImage imageNamed:@"not-submitted"]);
                    subject.approvalStatusLabel.text should equal(NSLocalizedString(NOT_SUBMITTED_STATUS, nil));
                    subject.approvalStatusLabel.textColor should equal( [UIColor magentaColor]);
                    subject.approvalStatusLabel.font should equal([UIFont systemFontOfSize:3]);
                    subject.approvalStatusLabel.backgroundColor should equal([UIColor clearColor]);
                    subject.approvalStatusImageView.backgroundColor should equal( [UIColor clearColor]);
                    
                    subject.approvalStatusButton.backgroundColor should equal([UIColor clearColor]);
                    subject.approvalStatusButton.titleLabel.font should equal([UIFont systemFontOfSize:5]);
                    subject.approvalStatusButton.currentTitleColor should equal([UIColor clearColor]);
                    subject.approvalStatusButton.layer.cornerRadius should equal(14);
                    subject.approvalStatusButton.layer.borderColor should equal([[UIColor magentaColor] CGColor]) ;
                    subject.approvalStatusButton.layer.borderWidth should equal(2);
                    subject.approvalStatusButton.clipsToBounds should be_truthy;
                });
            });
            
            context(@"urn:replicon:timesheet-status:waiting", ^{
                beforeEach(^{
                    status stub_method(@selector(approvalStatusUri)).again().and_return(@"urn:replicon:timesheet-status:waiting");
                    [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate];
                    subject.view should_not be_nil;
                });
                
                it(@"should correctly configure the approval status", ^{
                    subject.approvalStatusImageView.image should equal([UIImage imageNamed:@"waiting-for-approval"]);
                    subject.approvalStatusLabel.text should equal( NSLocalizedString(WAITING_FOR_APRROVAL_STATUS, nil));
                    subject.approvalStatusLabel.textColor should equal( [UIColor cyanColor]);
                    subject.approvalStatusLabel.font should equal([UIFont systemFontOfSize:3]);
                    subject.approvalStatusLabel.backgroundColor should equal([UIColor clearColor]);
                    subject.approvalStatusImageView.backgroundColor should equal( [UIColor clearColor]);
                    
                    subject.approvalStatusButton.backgroundColor should equal([UIColor clearColor]);
                    subject.approvalStatusButton.titleLabel.font should equal([UIFont systemFontOfSize:5]);
                    subject.approvalStatusButton.currentTitleColor should equal([UIColor clearColor]);
                    subject.approvalStatusButton.layer.cornerRadius should equal(14);
                    subject.approvalStatusButton.layer.borderColor should equal([[UIColor cyanColor] CGColor]) ;
                    subject.approvalStatusButton.layer.borderWidth should equal(2);
                    subject.approvalStatusButton.clipsToBounds should be_truthy;
                });
            });
            
            context(@"urn:replicon:timesheet-status:rejected", ^{
                beforeEach(^{
                    status stub_method(@selector(approvalStatusUri)).again().and_return(@"urn:replicon:timesheet-status:rejected");
                    [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate];
                    subject.view should_not be_nil;
                });
                
                it(@"should correctly configure the approval status", ^{
                    subject.approvalStatusImageView.image should equal([UIImage imageNamed:@"rejected"]);
                    subject.approvalStatusLabel.text should equal(NSLocalizedString(REJECTED_STATUS, nil));
                    subject.approvalStatusLabel.textColor should equal([UIColor brownColor]);
                    subject.approvalStatusLabel.font should equal([UIFont systemFontOfSize:3]);
                    subject.approvalStatusLabel.backgroundColor should equal([UIColor clearColor]);
                    subject.approvalStatusImageView.backgroundColor should equal( [UIColor clearColor]);
                    
                    
                    subject.approvalStatusButton.backgroundColor should equal([UIColor clearColor]);
                    subject.approvalStatusButton.titleLabel.font should equal([UIFont systemFontOfSize:5]);
                    subject.approvalStatusButton.currentTitleColor should equal([UIColor clearColor]);
                    subject.approvalStatusButton.layer.cornerRadius should equal(14);
                    subject.approvalStatusButton.layer.borderColor should equal([[UIColor brownColor] CGColor]) ;
                    subject.approvalStatusButton.layer.borderWidth should equal(2);
                    subject.approvalStatusButton.clipsToBounds should be_truthy;
                });
            });
            
            context(@"urn:replicon:timesheet-status:submitting", ^{
                beforeEach(^{
                    status stub_method(@selector(approvalStatusUri)).again().and_return(@"urn:replicon:timesheet-status:submitting");
                    [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate];
                    subject.view should_not be_nil;
                });
                
                it(@"should correctly configure the approval status", ^{
                    subject.approvalStatusImageView.image should equal([UIImage imageNamed:@"submitting"]);
                    subject.approvalStatusLabel.text should equal(NSLocalizedString(@"Submitting", nil));
                    subject.approvalStatusLabel.textColor should equal( [UIColor magentaColor]);
                    subject.approvalStatusLabel.font should equal([UIFont systemFontOfSize:3]);
                    subject.approvalStatusLabel.backgroundColor should equal([UIColor clearColor]);
                    subject.approvalStatusImageView.backgroundColor should equal( [UIColor clearColor]);
                    
                    subject.approvalStatusButton.backgroundColor should equal([UIColor clearColor]);
                    subject.approvalStatusButton.titleLabel.font should equal([UIFont systemFontOfSize:5]);
                    subject.approvalStatusButton.currentTitleColor should equal([UIColor clearColor]);
                    subject.approvalStatusButton.layer.cornerRadius should equal(14);
                    subject.approvalStatusButton.layer.borderColor should equal([[UIColor magentaColor] CGColor]) ;
                    subject.approvalStatusButton.layer.borderWidth should equal(2);
                    subject.approvalStatusButton.clipsToBounds should be_truthy;
                });
            });
            
            context(@"Unknown", ^{
                beforeEach(^{
                    status stub_method(@selector(approvalStatusUri)).again().and_return(@"urn:replicon:timesheet-status:Unknown");
                    [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate];
                    subject.view should_not be_nil;
                });
                
                it(@"should correctly configure the approval status", ^{
                    subject.approvalStatusImageView.image should equal([UIImage imageNamed:@"not-submitted"]);
                    subject.approvalStatusLabel.text should equal(NSLocalizedString(NOT_SUBMITTED_STATUS, nil));
                    subject.approvalStatusLabel.textColor should equal( [UIColor magentaColor]);
                    subject.approvalStatusLabel.font should equal([UIFont systemFontOfSize:3]);
                    subject.approvalStatusLabel.backgroundColor should equal([UIColor clearColor]);
                    subject.approvalStatusImageView.backgroundColor should equal( [UIColor clearColor]);
                    
                    subject.approvalStatusButton.backgroundColor should equal([UIColor clearColor]);
                    subject.approvalStatusButton.titleLabel.font should equal([UIFont systemFontOfSize:5]);
                    subject.approvalStatusButton.currentTitleColor should equal([UIColor clearColor]);
                    subject.approvalStatusButton.layer.cornerRadius should equal(14);
                    subject.approvalStatusButton.layer.borderColor should equal([[UIColor magentaColor] CGColor]) ;
                    subject.approvalStatusButton.layer.borderWidth should equal(2);
                    subject.approvalStatusButton.clipsToBounds should be_truthy;
                });
            });
        });
        
    });
    
    context(@"When the issues button is tapped ", ^{
        beforeEach(^{
            Summary *summary = doSummarySubjectAction(status,timesheetDuration,nil,7,nil,nil,nil,nil);
            widgetTimesheet = doSubjectAction(@"timesheet-uri", period,summary,nil,nil);
            [subject setupWithWidgetTimesheet:widgetTimesheet delegate:delegate];
            subject.view should_not be_nil;
            [subject.issuesButton tap];
        });
        
        it(@"should inform its delegate that user intends to view issues on timesheet", ^{
            delegate should have_received(@selector(timesheetStatusAndIssuesControllerIntendToViewViolationsWidget:)).with(subject);
        });
    });
    
});

SPEC_END
