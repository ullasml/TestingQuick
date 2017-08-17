#import <Cedar/Cedar.h>
#import "AuditTrailController.h"
#import <Blindside/BSInjector.h>
#import <Blindside/BSBinder.h>
#import "InjectorProvider.h"
#import "Punch.h"
#import <KSDeferred/KSDeferred.h>
#import "PunchLog.h"
#import "PunchLogRepository.h"
#import "PunchLogCell.h"
#import "RemotePunch.h"
#import "Theme.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(AuditTrailControllerSpec)

describe(@"AuditTrailController", ^{
    __block AuditTrailController *subject;
    __block id<AuditTrailControllerDelegate,CedarDouble> delegate;
    __block PunchLogRepository *punchLogRepository;
    __block RemotePunch *punch;
    __block id<Theme> theme;
    __block id<BSInjector, BSBinder> injector;

    beforeEach(^{
        injector = [InjectorProvider injector];

        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];

        punchLogRepository = nice_fake_for([PunchLogRepository class]);
        [injector bind:[PunchLogRepository class] toInstance:punchLogRepository];

        subject = [injector getInstance:[AuditTrailController class]];

        punch = fake_for([RemotePunch class]);
        delegate = nice_fake_for(@protocol(AuditTrailControllerDelegate));

        [subject setupWithPunch:punch delegate:delegate];
    });

    describe(@"presenting a table of punch history", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });
        it(@"should hide the top line", ^{
            subject.topLineView.hidden should be_truthy;
        });
        it(@"should tell its delegate that its height is 0 initially", ^{
            delegate should have_received(@selector(auditTrailController:didUpdateHeight:)).with(subject, CGFloat(0.0f));
        });

        context(@"when there are historical punch actions", ^{
            __block KSDeferred *deferred;
            beforeEach(^{
                deferred = [[KSDeferred alloc] init];
                punch stub_method(@selector(uri)).and_return(@"my special uri");
                punchLogRepository stub_method(@selector(fetchPunchLogsForPunchURI:))
                    .with(@"my special uri")
                    .and_return(deferred.promise);

                [subject viewWillAppear:NO];
            });

            context(@"when the repository finishes fetching punch actions", ^{
                __block NSDate *date1;
                __block NSDate *date2;
                beforeEach(^{
                    date1 = nice_fake_for([NSDate class]);
                    date2 = nice_fake_for([NSDate class]);
                    PunchLog *punchLog1 = [[PunchLog alloc] initWithText:@"punch log 1"];
                    PunchLog *punchLog2 = [[PunchLog alloc] initWithText:@"punch log 2"];

                    theme stub_method(@selector(auditTrailLogLabelFont)).and_return([UIFont systemFontOfSize:13.0f]);
                    theme stub_method(@selector(auditTrailLogLabelTextColor)).and_return([UIColor purpleColor]);

                    [deferred resolveWithValue:@[punchLog1, punchLog2]];
                });

                it(@"should tell its delegate that its height should be proportional to its row count", ^{
                    delegate should have_received(@selector(auditTrailController:didUpdateHeight:)).with(subject, (CGFloat)(200.0f));
                });

                it(@"should tell its delegate that its height is updated", ^{
                    [delegate reset_sent_messages];
                    [subject viewDidLayoutSubviews];
                    delegate should have_received(@selector(auditTrailController:didUpdateHeight:)).with(subject, (CGFloat)(148));
                });

                it(@"should display as many rows as there are punch actions", ^{
                    subject.tableView.visibleCells.count should equal(2);
                });
                it(@"should show the top line", ^{
                    subject.topLineView.hidden should be_falsy;
                });
                describe(@"the rows", ^{
                    __block UITableViewCell *cell0;
                    __block UITableViewCell *cell1;
                    beforeEach(^{
                        cell0 = subject.tableView.visibleCells[0];
                        cell1 = subject.tableView.visibleCells[1];
                    });

                    it(@"should show the correct text in each row", ^{
                        cell0.textLabel.text should equal(@"punch log 1");
                        cell1.textLabel.text should equal(@"punch log 2");
                    });

                    it(@"should style the cells correctly", ^{
                        cell0.textLabel.font should equal([UIFont systemFontOfSize:13.0f]);
                        cell0.textLabel.textColor should equal([UIColor purpleColor]);
                    });
                });
            });
        });
    });
});

SPEC_END
