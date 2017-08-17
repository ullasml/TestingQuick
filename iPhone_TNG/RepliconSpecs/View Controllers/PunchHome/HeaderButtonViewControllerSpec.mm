#import <Cedar/Cedar.h>
#import "HeaderButtonViewController.h"
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import <Blindside/Blindside.h>
#import "Theme.h"
#import "Timesheet.h"
#import "TimeSheetApprovalStatus.h"
#import "Constants.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HeaderButtonViewControllerSpec)

describe(@"HeaderButtonViewController", ^{
    __block HeaderButtonViewController *subject;
    __block id<Theme> theme;
    __block id <BSBinder,BSInjector> injector;
    __block id <HeaderButtonControllerDelegate> delegate;
    __block id<Timesheet> timesheet;


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

        delegate = nice_fake_for(@protocol(HeaderButtonControllerDelegate));
        timesheet = nice_fake_for(@protocol(Timesheet));
        subject = [injector getInstance:[HeaderButtonViewController class]];
        
    });
    
    context(@"when issuesCount is zero", ^{
        
        beforeEach(^{
            [subject setupWithDelegate:delegate timesheet:timesheet];
            subject.view should_not be_nil;
        });
        
        it(@"should not add issuesStatusLabel to its view", ^{
            subject.view.subviews should_not contain(subject.issuesStatusLabel);
            subject.view.subviews should_not contain(subject.issuesStatusView);

        });
        
    });
    
    context(@"when issuesCount is non zero", ^{

        
        it(@"Validation Count is plural", ^{
            
            NSInteger issues = 7;
            timesheet stub_method(@selector(issuesCount)).and_return(issues);
            [subject setupWithDelegate:delegate timesheet:timesheet];
            subject.view should_not be_nil;
            subject.issuesStatusLabel.text should equal(@"Validations");
            
        });
        
        it(@"Validation Count is singular", ^{
            
            NSInteger issues = 1;
            timesheet stub_method(@selector(issuesCount)).and_return(issues);
            [subject setupWithDelegate:delegate timesheet:timesheet];
            subject.view should_not be_nil;
            subject.issuesStatusLabel.text should equal(@"Validation");
            
        });
        
        it(@"should correctly display issuesStatusLabel", ^{
            
            NSInteger issues = 7;
            timesheet stub_method(@selector(issuesCount)).and_return(issues);
            [subject setupWithDelegate:delegate timesheet:timesheet];
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
            __block TimeSheetApprovalStatus *approvalStatus;

            beforeEach(^{
                approvalStatus = nice_fake_for([TimeSheetApprovalStatus class]);
            });
    
            context(@"when status is urn:replicon:approval-status:approved", ^{
                beforeEach(^{
                    approvalStatus stub_method(@selector(approvalStatusUri)).and_return(@"urn:replicon:approval-status:approved");
                    timesheet stub_method(@selector(approvalStatus)).and_return(approvalStatus);
                    [subject setupWithDelegate:delegate timesheet:timesheet];
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
            
            context(@"urn:replicon:approval-status:open", ^{
                beforeEach(^{
                    approvalStatus stub_method(@selector(approvalStatusUri)).and_return(@"urn:replicon:approval-status:open");
                    timesheet stub_method(@selector(approvalStatus)).and_return(approvalStatus);
                    [subject setupWithDelegate:delegate timesheet:timesheet];
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
            
            context(@"urn:replicon:approval-status:waiting", ^{
                beforeEach(^{
                    approvalStatus stub_method(@selector(approvalStatusUri)).and_return(@"urn:replicon:approval-status:waiting");
                    timesheet stub_method(@selector(approvalStatus)).and_return(approvalStatus);
                    [subject setupWithDelegate:delegate timesheet:timesheet];
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
            
            context(@"urn:replicon:approval-status:rejected", ^{
                beforeEach(^{
                    approvalStatus stub_method(@selector(approvalStatusUri)).and_return(@"urn:replicon:approval-status:rejected");
                    timesheet stub_method(@selector(approvalStatus)).and_return(approvalStatus);
                    [subject setupWithDelegate:delegate timesheet:timesheet];
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
        });
        
    });
  
});

SPEC_END
