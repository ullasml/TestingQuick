#import <MacTypes.h>
#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "DelayedTodaysPunchesRepository.h"
#import "PunchOverviewController.h"
#import "UserPermissionsStorage.h"
#import "PunchesForDateFetcher.h"
#import "UITableViewCell+Spec.h"
#import "TimeLineCellStylist.h"
#import "AddPunchController.h"
#import "TimesheetDayTimeLineController.h"
#import "InjectorProvider.h"
#import "PunchRepository.h"
#import "PunchPresenter.h"
#import "UIControl+Spec.h"
#import "DayTimeLineCell.h"
#import <KSDeferred/KSDeferred.h>
#import "LocalPunch.h"
#import "RemotePunch.h"
#import "OfflineLocalPunch.h"
#import "Util.h"
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "Enum.h"
#import "TimeLinePunchesSummary.h"
#import "TimeLinePunchesStorage.h"
#import "OEFType.h"
#import "Theme.h"
#import "Activity.h"
#import "AuditHistoryRepository.h"
#import "AuditHistory.h"
#import "ButtonStylist.h"
#import "AddPunchTimeLineCell.h"
#import "PunchEmptyStateCell.h"
#import "Violation.h"
#import "DurationStringPresenter.h"
#import "BreakType.h"
#import "MissingPunchCell.h"
#import "ImageFetcher.h"
#import "DayTimeLineHeaderViewController.h"
#import "ChildControllerHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TimesheetDayTimeLineControllerSpec)

describe(@"TimesheetDayTimeLineController", ^{
    __block TimesheetDayTimeLineController *subject;
    __block PunchPresenter <CedarDouble> *punchPresenter;
    __block TimeLineCellStylist *timeLineCellStylist;
    __block UserPermissionsStorage *punchRulesStorage;
    __block PunchRepository *punchRepository;
    __block DelayedTodaysPunchesRepository *delayedTodaysPunchesFetcher;
    __block TimeLinePunchesStorage *timeLinePunchesStorage;
    __block id<BSBinder, BSInjector> injector;
    __block AuditHistoryRepository *auditHistoryRepository;
    __block ButtonStylist *buttonStylist;
    __block id<Theme> theme;
    __block DurationStringPresenter *durationStringPresenter;
    __block ReachabilityMonitor *reachabilityMonitor;
    __block ImageFetcher *imageFetcher;
    __block DayTimeLineHeaderViewController *dayTimeLineHeaderViewController;
    __block ChildControllerHelper *childControllerHelper;

    beforeEach(^{
        injector = [InjectorProvider injector];
        
        dayTimeLineHeaderViewController = nice_fake_for([DayTimeLineHeaderViewController class]);
        [injector bind:[DayTimeLineHeaderViewController class] toInstance:dayTimeLineHeaderViewController];
        
        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];

        imageFetcher = nice_fake_for([ImageFetcher class]);
        [injector bind:[ImageFetcher class] toInstance:imageFetcher];

        reachabilityMonitor = nice_fake_for([ReachabilityMonitor class]);
        [injector bind:[ReachabilityMonitor class] toInstance:reachabilityMonitor];

        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];

        punchRepository = nice_fake_for([PunchRepository class]);
        [injector bind:[PunchRepository class] toInstance:punchRepository];

        delayedTodaysPunchesFetcher = nice_fake_for([DelayedTodaysPunchesRepository class]);
        [injector bind:[DelayedTodaysPunchesRepository class] toInstance:delayedTodaysPunchesFetcher];

        punchPresenter = nice_fake_for([PunchPresenter class]);
        [injector bind:[PunchPresenter class] toInstance:punchPresenter];

        timeLineCellStylist = nice_fake_for([TimeLineCellStylist class]);
        [injector bind:[TimeLineCellStylist class] toInstance:timeLineCellStylist];

        punchRulesStorage = nice_fake_for([UserPermissionsStorage class]);
        [injector bind:[UserPermissionsStorage class] toInstance:punchRulesStorage];

        timeLinePunchesStorage = nice_fake_for([TimeLinePunchesStorage class]);
        [injector bind:[TimeLinePunchesStorage class] toInstance:timeLinePunchesStorage];
        
        auditHistoryRepository = nice_fake_for([AuditHistoryRepository class]);
        [injector bind:[AuditHistoryRepository class] toInstance:auditHistoryRepository];

        buttonStylist = nice_fake_for([ButtonStylist class]);
        [injector bind:[ButtonStylist class] toInstance:buttonStylist];
        
        durationStringPresenter = nice_fake_for([DurationStringPresenter class]);
        [injector bind:[DurationStringPresenter class] toInstance:durationStringPresenter];
        
        theme stub_method(@selector(addPunchButtonTitleColor)).and_return([UIColor orangeColor]);
        theme stub_method(@selector(addPunchButtonBackgroundColor)).and_return([UIColor yellowColor]);
        theme stub_method(@selector(addPunchButtonBorderColor)).and_return([UIColor redColor]);
        theme stub_method(@selector(timelineSelectedCellColor)).and_return([UIColor grayColor]);

        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);

        punchPresenter stub_method(@selector(descendingLineViewColorForPunchActionType:)).with(PunchActionTypePunchIn).and_return([UIColor redColor]);
        punchPresenter stub_method(@selector(descendingLineViewColorForPunchActionType:)).with(PunchActionTypePunchOut).and_return([UIColor greenColor]);
        punchPresenter stub_method(@selector(descendingLineViewColorForPunchActionType:)).with(PunchActionTypeStartBreak).and_return([UIColor blueColor]);

        subject = [injector getInstance:[TimesheetDayTimeLineController class]];
        spy_on(subject);
    });

    
    context(@"when the view appears again and isNetworkReachable not there", ^{
        __block KSDeferred *serverDidFinishPunchDeferred;
        __block id<TimesheetDayTimeLineControllerDelegate, CedarDouble> delegate;
        __block NSDate *date;
        __block NSString *userURI;
        __block UINavigationController *navigationController;
        beforeEach(^{
            reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(NO);
            date = nice_fake_for([NSDate class]);
            delegate = nice_fake_for(@protocol(TimesheetDayTimeLineControllerDelegate));
            delegate stub_method(@selector(timesheetDayTimeLineControllerDidRequestDate:))
            .with(subject)
            .and_return(date);
            serverDidFinishPunchDeferred = [[KSDeferred alloc] init];
            userURI  = @"some-fancy-user-uri";
            
            [subject setupWithPunchChangeObserverDelegate:nil
                              serverDidFinishPunchPromise:serverDidFinishPunchDeferred.promise
                                                 delegate:delegate
                                                  userURI:userURI
                                                 flowType:UserFlowContext
                                                  punches:@[]
                                        timeLinePunchFlow:CardTimeLinePunchFlowContext];
            
            navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
            spy_on(navigationController);
            navigationController stub_method(@selector(presentedViewController)).and_return(nil);
            navigationController stub_method(@selector(viewControllers)).and_return(@[[[UIViewController alloc]init]]);
        });
        
        it(@"should not fetch punches when the view will appear", ^{
            subject.view should_not be_nil;
            [subject viewDidLayoutSubviews];
            
            delegate should_not have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:));
        });
    });

    context(@"when set up with a server did finish punch promise and UIImagePickerController is being presented", ^{
        __block KSDeferred *serverDidFinishPunchDeferred;
        __block id<TimesheetDayTimeLineControllerDelegate, CedarDouble> delegate;
        __block NSDate *date;
        __block NSString *userURI;
        __block UINavigationController *navigationController;

        context(@"for user context", ^{
            beforeEach(^{
                date = nice_fake_for([NSDate class]);
                delegate = nice_fake_for(@protocol(TimesheetDayTimeLineControllerDelegate));
                delegate stub_method(@selector(timesheetDayTimeLineControllerDidRequestDate:))
                .with(subject)
                .and_return(date);
                serverDidFinishPunchDeferred = [[KSDeferred alloc] init];
                userURI  = @"some-fancy-user-uri";
                
                [subject setupWithPunchChangeObserverDelegate:nil
                                  serverDidFinishPunchPromise:serverDidFinishPunchDeferred.promise
                                                     delegate:delegate
                                                      userURI:userURI
                                                     flowType:UserFlowContext
                                                      punches:@[]
                                            timeLinePunchFlow:CardTimeLinePunchFlowContext];
                
                navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                spy_on(navigationController);
                navigationController stub_method(@selector(presentedViewController)).and_return(nil);
                navigationController stub_method(@selector(viewControllers)).and_return(nil);
            });

            it(@"should not fetch punches when the view will appear", ^{
                subject.view should_not be_nil;
                [subject viewWillAppear:YES];
                
                delegate should_not have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:));
            });
        });

        context(@"for supervisor context", ^{
            beforeEach(^{
                date = nice_fake_for([NSDate class]);
                delegate = nice_fake_for(@protocol(TimesheetDayTimeLineControllerDelegate));
                delegate stub_method(@selector(timesheetDayTimeLineControllerDidRequestDate:))
                .with(subject)
                .and_return(date);
                serverDidFinishPunchDeferred = [[KSDeferred alloc] init];
                userURI  = @"some-fancy-user-uri";
                [subject setupWithPunchChangeObserverDelegate:nil
                                  serverDidFinishPunchPromise:serverDidFinishPunchDeferred.promise
                                                     delegate:delegate
                                                      userURI:userURI
                                                     flowType:SupervisorFlowContext
                                                      punches:@[]
                                            timeLinePunchFlow:DayControllerTimeLinePunchFlowContext];
                navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                spy_on(navigationController);
                navigationController stub_method(@selector(presentedViewController)).and_return(nil);
                navigationController stub_method(@selector(viewControllers)).and_return(nil);


            });

            it(@"should not fetch punches after a delay when the view will appear", ^{
                subject.view should_not be_nil;
                [subject viewWillAppear:YES];

               delegate should_not have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:));
            });
        });

    });

    context(@"when set up with no punches", ^{
        __block KSDeferred *serverDidFinishPunchDeferred;
        __block KSDeferred *punchesWithServerDidFinishPunchDeferred;
        __block id<TimesheetDayTimeLineControllerDelegate, CedarDouble> delegate;
        __block NSDate *date;
        __block NSString *userURI;
        __block UINavigationController *navigationController;
        __block AddPunchTimeLineCell *addPunchTimeLineCell;
        __block UITableView *tableView;

        context(@"for user context", ^{
            context(@"when canedit permission is enabled", ^{
                __block id <AddPunchTimeLineCellDelegate> receivedDelegate;
                __block CGFloat receivedPadding;

                beforeEach(^{
                    punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
                    
                    addPunchTimeLineCell = nice_fake_for([AddPunchTimeLineCell class]);
                    
                    date = nice_fake_for([NSDate class]);
                    delegate = nice_fake_for(@protocol(TimesheetDayTimeLineControllerDelegate));
                    delegate stub_method(@selector(timesheetDayTimeLineControllerDidRequestDate:))
                    .with(subject)
                    .and_return(date);
                    serverDidFinishPunchDeferred = [[KSDeferred alloc] init];
                    punchesWithServerDidFinishPunchDeferred = [[KSDeferred alloc] init];
                    userURI  = @"some-fancy-user-uri";
                    [subject setupWithPunchChangeObserverDelegate:nil
                                      serverDidFinishPunchPromise:serverDidFinishPunchDeferred.promise
                                                         delegate:delegate
                                                          userURI:userURI
                                                         flowType:UserFlowContext
                                                          punches:@[]
                                                timeLinePunchFlow:CardTimeLinePunchFlowContext];
                    navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                    spy_on(navigationController);
                    navigationController stub_method(@selector(presentedViewController)).and_return(nil);
                    navigationController stub_method(@selector(viewControllers)).and_return(@[[[UIViewController alloc]init]]);
                    
                    addPunchTimeLineCell = nice_fake_for([AddPunchTimeLineCell class]);
                    tableView = nice_fake_for([UITableView class]);
                    tableView stub_method(@selector(dequeueReusableCellWithIdentifier:forIndexPath:)).with(@"AddPunchTimeLineCellIdentifier",[NSIndexPath indexPathForRow:0 inSection:0]).and_return(addPunchTimeLineCell);
                    
                    addPunchTimeLineCell stub_method(@selector(setUpWithDelegate:topConstraint:)).and_do_block(^void(id <AddPunchTimeLineCellDelegate> delegate, CGFloat padding) {
                        receivedDelegate = delegate;
                        receivedPadding = padding;
                    });
                    
                    subject.view should_not be_nil;
                    [subject viewWillAppear:YES];
                });
                
                it(@"should have the correct number of rows", ^{
                    [subject.timelineTableView numberOfRowsInSection:0] should equal(1);
                });
                
                it(@"should have the correct number of rows", ^{
                    [subject tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    addPunchTimeLineCell should have_received(@selector(setUpWithDelegate:topConstraint:));
                    receivedDelegate should be_same_instance_as(subject);
                    receivedPadding should equal(0);
                });
                
                it(@"should fetch punches after a delay when the view will appear", ^{
                    delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject,(float)0.0);
                });
            });
            
            context(@"when canedit permission is not enabled", ^{
                beforeEach(^{
                    punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(NO);
                    
                    date = nice_fake_for([NSDate class]);
                    delegate = nice_fake_for(@protocol(TimesheetDayTimeLineControllerDelegate));
                    delegate stub_method(@selector(timesheetDayTimeLineControllerDidRequestDate:))
                    .with(subject)
                    .and_return(date);
                    serverDidFinishPunchDeferred = [[KSDeferred alloc] init];
                    punchesWithServerDidFinishPunchDeferred = [[KSDeferred alloc] init];
                    userURI  = @"some-fancy-user-uri";
                    [subject setupWithPunchChangeObserverDelegate:nil
                                      serverDidFinishPunchPromise:serverDidFinishPunchDeferred.promise
                                                         delegate:delegate
                                                          userURI:userURI
                                                         flowType:UserFlowContext
                                                          punches:@[]
                                                timeLinePunchFlow:CardTimeLinePunchFlowContext];
                    navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                    spy_on(navigationController);
                    navigationController stub_method(@selector(presentedViewController)).and_return(nil);
                    navigationController stub_method(@selector(viewControllers)).and_return(@[[[UIViewController alloc]init]]);
                    
                    subject.view should_not be_nil;
                    [subject viewWillAppear:YES];
                });
                
                it(@"should have the correct number of rows", ^{
                    [subject.timelineTableView numberOfRowsInSection:0] should equal(0);
                });
                
                it(@"should fetch punches after a delay when the view will appear", ^{
                    delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject,(float)0.0);
                });
            });
        });

        context(@"for supervisor context", ^{
            context(@"when canedit permission is not enabled", ^{
                beforeEach(^{
                    date = nice_fake_for([NSDate class]);
                    delegate = nice_fake_for(@protocol(TimesheetDayTimeLineControllerDelegate));
                    delegate stub_method(@selector(timesheetDayTimeLineControllerDidRequestDate:))
                    .with(subject)
                    .and_return(date);
                    serverDidFinishPunchDeferred = [[KSDeferred alloc] init];
                    punchesWithServerDidFinishPunchDeferred = [[KSDeferred alloc] init];
                    userURI  = @"some-fancy-user-uri";
                    [subject setupWithPunchChangeObserverDelegate:nil
                                      serverDidFinishPunchPromise:serverDidFinishPunchDeferred.promise
                                                         delegate:delegate
                                                          userURI:userURI
                                                         flowType:SupervisorFlowContext
                                                          punches:@[]
                                                timeLinePunchFlow:DayControllerTimeLinePunchFlowContext];
                    navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                    spy_on(navigationController);
                    navigationController stub_method(@selector(presentedViewController)).and_return(nil);
                    navigationController stub_method(@selector(viewControllers)).and_return(@[[[UIViewController alloc]init]]);
                    
                    subject.view should_not be_nil;
                    [subject viewWillAppear:YES];
                });
                
                it(@"should have the correct number of rows", ^{
                    [subject.timelineTableView numberOfRowsInSection:0] should equal(1);
                });
                
                it(@"should fetch punches after a delay when the view will appear", ^{
                    delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject,(float)0.0);
                });
            });

            
            context(@"when canedit permission is enabled", ^{
                beforeEach(^{
                    punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
                    date = nice_fake_for([NSDate class]);
                    delegate = nice_fake_for(@protocol(TimesheetDayTimeLineControllerDelegate));
                    delegate stub_method(@selector(timesheetDayTimeLineControllerDidRequestDate:))
                    .with(subject)
                    .and_return(date);
                    serverDidFinishPunchDeferred = [[KSDeferred alloc] init];
                    punchesWithServerDidFinishPunchDeferred = [[KSDeferred alloc] init];
                    userURI  = @"some-fancy-user-uri";
                    [subject setupWithPunchChangeObserverDelegate:nil
                                      serverDidFinishPunchPromise:serverDidFinishPunchDeferred.promise
                                                         delegate:delegate
                                                          userURI:userURI
                                                         flowType:SupervisorFlowContext
                                                          punches:@[]
                                                timeLinePunchFlow:DayControllerTimeLinePunchFlowContext];
                    navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                    spy_on(navigationController);
                    navigationController stub_method(@selector(presentedViewController)).and_return(nil);
                    navigationController stub_method(@selector(viewControllers)).and_return(@[[[UIViewController alloc]init]]);
                    
                    subject.view should_not be_nil;
                    [subject viewWillAppear:YES];
                });
                
                it(@"should have the correct number of rows", ^{
                    [subject.timelineTableView numberOfRowsInSection:0] should equal(2);
                });
                
                it(@"should fetch punches after a delay when the view will appear", ^{
                    delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject,(float)0.0);
                });
            });

        });
    });
    
    context(@"when reachability not there", ^{
        __block KSDeferred *serverDidFinishPunchDeferred;
        __block KSDeferred *punchesWithServerDidFinishPunchDeferred;
        __block id<TimesheetDayTimeLineControllerDelegate, CedarDouble> delegate;
        __block NSDate *date;
        __block NSString *userURI;
        __block UINavigationController *navigationController;
        __block RemotePunch *punch1;
        __block RemotePunch *punch2;
        beforeEach(^{
            punch1 = nice_fake_for([RemotePunch class]);
            punch1 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
            punch1 stub_method(@selector(syncedWithServer)).and_return(YES);
            punch1 stub_method(@selector(uri)).and_return(@"some-punch-uri-1");
            punch2 = nice_fake_for([RemotePunch class]);
            punch2 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
            punch2 stub_method(@selector(syncedWithServer)).and_return(YES);
            punch2 stub_method(@selector(uri)).and_return(@"some-punch-uri-2");

            reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(NO);
            date = nice_fake_for([NSDate class]);
            delegate = nice_fake_for(@protocol(TimesheetDayTimeLineControllerDelegate));
            delegate stub_method(@selector(timesheetDayTimeLineControllerDidRequestDate:))
            .with(subject)
            .and_return(date);
            serverDidFinishPunchDeferred = [[KSDeferred alloc] init];
            punchesWithServerDidFinishPunchDeferred = [[KSDeferred alloc] init];
            userURI  = @"some-fancy-user-uri";
            [subject setupWithPunchChangeObserverDelegate:nil
                              serverDidFinishPunchPromise:serverDidFinishPunchDeferred.promise
                                                 delegate:delegate
                                                  userURI:userURI
                                                 flowType:UserFlowContext
                                                  punches:@[]
                                        timeLinePunchFlow:CardTimeLinePunchFlowContext];
            navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
            spy_on(navigationController);
            navigationController stub_method(@selector(presentedViewController)).and_return(nil);
            navigationController stub_method(@selector(viewControllers)).and_return(@[[[UIViewController alloc]init]]);
            
            subject.view should_not be_nil;
            [subject viewWillAppear:YES];
        });
        
        it(@"should have the correct number of rows", ^{
            [subject.timelineTableView numberOfRowsInSection:0] should equal(0);
        });
        
        it(@"should not have any punch", ^{
            subject.punches.count should equal(0);
        });
        
        it(@"should not fetch audithistory", ^{
            auditHistoryRepository should_not have_received(@selector(fetchPunchLogs:));
        });
        
        it(@"should set height to 0", ^{
            delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject,(float)0.0);
        });
        
    });

    context(@"when set up with punches array", ^{
        __block id<TimesheetDayTimeLineControllerDelegate, CedarDouble> delegate;
        __block NSDate *date;
        __block NSString *userURI;
        __block id <PunchChangeObserverDelegate> punchChangeObserverDelegate;
        __block UINavigationController *navigationController;
        __block RemotePunch *punch1;
        __block RemotePunch *punch2;
        __block KSDeferred *auditHistoryDeferred;
        __block AuditHistory *history1;
        __block AuditHistory *history2;

        beforeEach(^{
            auditHistoryDeferred = [[KSDeferred alloc] init];
            punch1 = nice_fake_for([RemotePunch class]);
            punch1 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
            punch1 stub_method(@selector(syncedWithServer)).and_return(YES);
            punch1 stub_method(@selector(uri)).and_return(@"some-punch-uri-1");
            punch2 = nice_fake_for([RemotePunch class]);
            punch2 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
            punch2 stub_method(@selector(syncedWithServer)).and_return(YES);
            punch2 stub_method(@selector(uri)).and_return(@"some-punch-uri-2");
            date = nice_fake_for([NSDate class]);
            punchChangeObserverDelegate = nice_fake_for(@protocol(PunchChangeObserverDelegate));
            delegate = nice_fake_for(@protocol(TimesheetDayTimeLineControllerDelegate));
            delegate stub_method(@selector(timesheetDayTimeLineControllerDidRequestDate:))
                .with(subject)
                .and_return(date);
            userURI = @"my-special-user-uri";
            
            history1 = nice_fake_for([AuditHistory class]);
            history2 = nice_fake_for([AuditHistory class]);
            
            auditHistoryRepository stub_method(@selector(fetchPunchLogs:)).with(@[@"some-punch-uri-1", @"some-punch-uri-2"]).and_return(auditHistoryDeferred.promise);
            
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                              serverDidFinishPunchPromise:nil
                                                 delegate:delegate
                                                  userURI:userURI
                                                 flowType:UserFlowContext
                                                  punches:@[punch1, punch2]
                                        timeLinePunchFlow:CardTimeLinePunchFlowContext];
            
            navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
            spy_on(navigationController);
            navigationController stub_method(@selector(presentedViewController)).and_return(nil);
            navigationController stub_method(@selector(viewControllers)).and_return(@[[[UIViewController alloc]init]]);
        });
        
        context(@"when the user can not add punches with no punches", ^{
            beforeEach(^{
                punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(NO);
                
                [subject view];
                [subject viewWillAppear:NO];
            });
            
            it(@"should initially set its presentation height to 0", ^{
                delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, (CGFloat)0.0f);
            });
        });


        describe(@"showing a timeline of punches for a given date", ^{
          
            context(@"when the user can add punches", ^{

                beforeEach(^{
                    punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
                    [subject view];
                    [subject viewWillAppear:NO];

                    navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                });

                it(@"should initially set its presentation height to only include the add punch button", ^{
                    delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, (CGFloat)0.0f);
                });
                
                it(@"should fetch audit history for punches", ^{
                    auditHistoryRepository should have_received(@selector(fetchPunchLogs:)).with(@[@"some-punch-uri-1", @"some-punch-uri-2"]);
                });

                describe(@"the timeline table when there are punches", ^{
                    beforeEach(^{
                        [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                          serverDidFinishPunchPromise:nil
                                                             delegate:delegate
                                                              userURI:userURI
                                                             flowType:UserFlowContext
                                                              punches:@[punch1, punch2]
                                                    timeLinePunchFlow:CardTimeLinePunchFlowContext];

                        [delegate reset_sent_messages];
                        [subject view];
                        [subject viewWillAppear:NO];
                        [subject.timelineTableView layoutIfNeeded];
                    });

                    it(@"should have the correct number of rows", ^{
                        [subject.timelineTableView numberOfRowsInSection:0] should equal(3);
                    });

                    it(@"should initially set its presentation height to only include the add punch button", ^{
                        delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, Arguments::anything);
                    });
                    
                    describe(@"when canedit permission is enabled", ^{
                        __block AddPunchTimeLineCell *addPunchTimeLineCell;
                        __block UITableView *tableView;
                        __block id <AddPunchTimeLineCellDelegate> receivedDelegate;
                        __block CGFloat receivedPadding;
                        beforeEach(^{
                            addPunchTimeLineCell = nice_fake_for([AddPunchTimeLineCell class]);
                            tableView = nice_fake_for([UITableView class]);
                            tableView stub_method(@selector(dequeueReusableCellWithIdentifier:forIndexPath:)).with(@"AddPunchTimeLineCellIdentifier",[NSIndexPath indexPathForRow:2 inSection:0]).and_return(addPunchTimeLineCell);
                            
                            addPunchTimeLineCell stub_method(@selector(setUpWithDelegate:topConstraint:)).and_do_block(^void(id <AddPunchTimeLineCellDelegate> delegate, CGFloat padding) {
                                receivedDelegate = delegate;
                                receivedPadding = padding;
                            });
                            
                            subject.view should_not be_nil;
                            [subject viewWillAppear:YES];
                        });
                        
                        it(@"should have the correct number of rows", ^{
                            [subject tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                            addPunchTimeLineCell should have_received(@selector(setUpWithDelegate:topConstraint:));
                            receivedDelegate should be_same_instance_as(subject);
                            receivedPadding should equal(20);
                        });
                    });

                    describe(@"the punch row", ^{
                        __block DayTimeLineCell *dayTimeLineCell1;
                        __block DayTimeLineCell *dayTimeLineCell2;
                        beforeEach(^{
                            dayTimeLineCell1 = (id)subject.timelineTableView.visibleCells[0];
                            dayTimeLineCell2 = (id)subject.timelineTableView.visibleCells[1];
                        });

                        it(@"should be the correct type", ^{
                            dayTimeLineCell1 should be_instance_of([DayTimeLineCell class]);
                            dayTimeLineCell2 should be_instance_of([DayTimeLineCell class]);
                        });
                    });

                    describe(@"the add missing punch row", ^{
                        __block AddPunchTimeLineCell *addPunchTimeLineCell;
                        beforeEach(^{
                            addPunchTimeLineCell = (id)subject.timelineTableView.visibleCells[2];
                        });

                        it(@"should be the correct type", ^{
                            addPunchTimeLineCell should be_instance_of([AddPunchTimeLineCell class]);
                        });

                        it(@"should correctly configure the add punch row", ^{
                            buttonStylist should have_received(@selector(styleButton:title:titleColor:backgroundColor:borderColor:)).with(addPunchTimeLineCell.addPunchBtn, AddPunch_Title, [UIColor orangeColor], [UIColor yellowColor], [UIColor redColor]);
                        });

                        describe(@"tapping the cell", ^{
                            __block UINavigationController *navigationController;
                            __block AddPunchController *addPunchController;

                            beforeEach(^{
                                addPunchController = [[AddPunchController alloc]
                                                                          initWithPunchImagePickerControllerProvider:nil
                                                                                          reporteePermissionsStorage:nil
                                                                                          daySummaryDateTimeProvider:NULL
                                                                                             segmentedControlStylist:nil
                                                                                              allowAccessAlertHelper:nil
                                                                                               childControllerHelper:nil
                                                                                                tableViewCellStylist:nil
                                                                                                 breakTypeRepository:nil
                                                                                                 reachabilityMonitor:nil
                                                                                                  notificationCenter:nil
                                                                                                   punchRulesStorage:nil
                                                                                                     imageNormalizer:nil
                                                                                                     punchRepository:nil
                                                                                                     spinnerDelegate:nil
                                                                                                     oefTypesStorage:nil
                                                                                                       dateFormatter:nil
                                                                                                         userSession:nil
                                                                                                        guidProvider:NULL
                                                                                                          punchClock:nil
                                                                                                               theme:nil];
                                spy_on(addPunchController);
                                [injector bind:[AddPunchController class] toInstance:addPunchController];

                                navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                                [addPunchTimeLineCell.addPunchBtn tap];
                            });

                            it(@"should configure the AddPunchController correctly", ^{
                                addPunchController should have_received(@selector(setupWithPunchChangeObserverDelegate:userURI:date:)).with(punchChangeObserverDelegate,@"my-special-user-uri", date);
                            });

                            it(@"should navigate to the AddPunchController", ^{
                                navigationController.topViewController should be_same_instance_as(addPunchController);
                            });

                            it(@"should update the time punches", ^{
                               // timeLinePunchesStorage should have_received(@selector(storeRemotePunch:)).with(firstPunch);

                            });
                        });
                    });
                });

                describe(@"the timeline table when there are no punches", ^{

                    beforeEach(^{
                        [subject setupWithPunchChangeObserverDelegate:nil
                                          serverDidFinishPunchPromise:nil
                                                             delegate:delegate
                                                              userURI:userURI
                                                             flowType:UserFlowContext
                                                              punches:@[]
                                                    timeLinePunchFlow:CardTimeLinePunchFlowContext];
                        [subject view];
                        [subject viewWillAppear:NO];
                    });

                    it(@"should have the correct number of rows", ^{
                        [subject.timelineTableView numberOfRowsInSection:0] should equal(1);
                    });

                    describe(@"the add punch row", ^{
                        __block AddPunchTimeLineCell *addPunchTimeLineCell;
                        beforeEach(^{
                            addPunchTimeLineCell = (id)subject.timelineTableView.visibleCells[0];
                        });

                        it(@"should be the correct type", ^{
                            addPunchTimeLineCell should be_instance_of([AddPunchTimeLineCell class]);
                        });

                        it(@"should correctly configure the add punch row", ^{
                            buttonStylist should have_received(@selector(styleButton:title:titleColor:backgroundColor:borderColor:)).with(addPunchTimeLineCell.addPunchBtn, AddPunch_Title, [UIColor orangeColor], [UIColor yellowColor], [UIColor redColor]);
                        });
                    });
                });
                
                describe(@"the timeline table when there are no punches with viewmytimesheet flow", ^{
                    
                    beforeEach(^{
                        [subject setupWithPunchChangeObserverDelegate:nil
                                          serverDidFinishPunchPromise:nil
                                                             delegate:delegate
                                                              userURI:userURI
                                                             flowType:UserFlowContext
                                                              punches:@[]
                                                    timeLinePunchFlow:DayControllerTimeLinePunchFlowContext];
                        [subject view];
                        [subject viewWillAppear:NO];
                    });
                    
                    it(@"should have the correct number of rows", ^{
                        [subject.timelineTableView numberOfRowsInSection:0] should equal(2);
                    });
                    
                    describe(@"the add missing punch row", ^{
                        __block AddPunchTimeLineCell *addPunchTimeLineCell;
                        __block PunchEmptyStateCell *punchEmptyStateCell;

                        beforeEach(^{
                            addPunchTimeLineCell = (id)subject.timelineTableView.visibleCells[1];
                            punchEmptyStateCell = (id)subject.timelineTableView.visibleCells[0];
                        });
                        
                        it(@"should be the correct type", ^{
                            addPunchTimeLineCell should be_instance_of([AddPunchTimeLineCell class]);
                            punchEmptyStateCell should be_instance_of([PunchEmptyStateCell class]);
                        });
                        
                        it(@"should correctly configure the add punch row", ^{
                            buttonStylist should have_received(@selector(styleButton:title:titleColor:backgroundColor:borderColor:)).with(addPunchTimeLineCell.addPunchBtn, AddPunch_Title, [UIColor orangeColor], [UIColor yellowColor], [UIColor redColor]);
                        });
                    });
                });


                context(@"when the view appears again", ^{
                    beforeEach(^{
                        [delegate reset_sent_messages];
                        [subject viewWillAppear:YES];
                    });

                    it(@"should reset its presentation height", ^{
                         delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, (CGFloat)0.0f);
                    });
                });
            });
            
            context(@"when user has client project and task", ^{
                context(@"when fetching all today's punches succeeds", ^{
                    __block RemotePunch *firstPunch;
                    __block KSDeferred *auditHistoryDeferred;
                    __block AuditHistory *auditHistory;
                    
                    beforeEach(^{
                        auditHistoryDeferred = [[KSDeferred alloc] init];
                        
                        auditHistory = nice_fake_for([AuditHistory class]);
                        auditHistory stub_method(@selector(history)).and_return(@[@"someText"]);
                        auditHistory stub_method(@selector(uri)).and_return(@"uriD");
                        
                        punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(NO);
                        
                        ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project-Name" uri:@"Project-Uri"];
                        ClientType *client = [[ClientType alloc]initWithName:@"Client-Name" uri:@"Client-Uri"];
                        TaskType *task = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task-Name" uri:@"Task-Uri"];
                        NSDateComponents *dateComponentsA = [[NSDateComponents alloc] init];
                        dateComponentsA.hour = 0;
                        dateComponentsA.minute = 1;
                        dateComponentsA.second = 0;
                        
                        firstPunch = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                           nonActionedValidations:0
                                                              previousPunchStatus:Ticking
                                                                  nextPunchStatus:Ticking
                                                                    sourceOfPunch:Mobile
                                                                       actionType:PunchActionTypePunchIn
                                                                    oefTypesArray:nil
                                                                     lastSyncTime:NULL
                                                                          project:project
                                                                      auditHstory:nil
                                                                        breakType:nil
                                                                         location:nil
                                                                       violations:@[@"some-violation"]
                                                                        requestID:NULL
                                                                         activity:nil
                                                                         duration:dateComponentsA
                                                                           client:client
                                                                          address:@"some-address"
                                                                          userURI:@"user-uri"
                                                                         imageURL:nil
                                                                             date:[NSDate date]
                                                                             task:task
                                                                              uri:@"uriD"
                                                             isTimeEntryAvailable:NO
                                                                 syncedWithServer:YES
                                                                   isMissingPunch:NO
                                                          previousPunchActionType:PunchActionTypeUnknown];
                        
                        punchPresenter stub_method(@selector(sourceOfPunchLabelTextWithPunch:)).with(firstPunch).and_return(@"via Mobile");
                        
                        punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:)).with(firstPunch).and_return(@"Clocked In");
                        
                        punchPresenter stub_method(@selector(timeWithAmPmLabelTextForPunch:)).with(firstPunch).and_return(@"12:34 AM");
                        
                        punchPresenter stub_method(@selector(descriptionLabelForDayTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:)).with(firstPunch,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything).and_return([[NSAttributedString alloc]initWithString:@"Client-Name\nProject-Name\nTask-Name"]);
                        
                        auditHistoryRepository stub_method(@selector(fetchPunchLogs:)).with(@[@"uriD"]).and_return(auditHistoryDeferred.promise);
                        
                        
                        durationStringPresenter stub_method(@selector(durationStringWithHours:minutes:)).and_return(@"0h:01m");
                        
                        
                        [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                          serverDidFinishPunchPromise:nil
                                                             delegate:delegate
                                                              userURI:userURI
                                                             flowType:UserFlowContext
                                                              punches:@[firstPunch]
                                                    timeLinePunchFlow:CardTimeLinePunchFlowContext];
                        
                        
                        [subject view];
                        [subject viewWillAppear:NO];
                        
                        [auditHistoryDeferred resolveWithValue:@[auditHistory]];
                    });
                    
                    it(@"should have the correct number of rows", ^{
                        [subject.timelineTableView.dataSource tableView:subject.timelineTableView numberOfRowsInSection:0] should equal(1);
                    });
                    
                    it(@"should notify its delegate to update its height", ^{
                        delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, Arguments::anything);
                    });
                    
                    it(@"should call fetchPunchLogs:", ^{
                        auditHistoryRepository should have_received(@selector(fetchPunchLogs:)).with(@[@"uriD"]);
                    });
                    
                    it(@"should show data on cell", ^{
                        DayTimeLineCell *cell = [subject.timelineTableView.visibleCells firstObject];
                        cell.punchType.text should equal(@"Clocked In");
                        punchPresenter should have_received(@selector(timeWithAmPmLabelTextForPunch:));
                        cell.punchActualTime.text should equal(@"12:34 AM");
                        NSString *attributedText = [cell.metaDataLabel.attributedText string];
                        attributedText should equal(@"Client-Name\nProject-Name\nTask-Name");
                        cell.violationDetais.text should equal(@"1 validation resolved");
                        cell.agentType.text should equal(@"via Mobile");
                        cell.address.text should equal(@"some-address");
                        cell.auditHistory.text should equal(@"someText");
                        cell.duration.text should equal(@"0h:01m");
                    });
                    
                    
                    context(@"when the view appears again", ^{
                        beforeEach(^{
                            [delegate reset_sent_messages];
                            [subject viewWillAppear:YES];
                        });
                        
                        it(@"should set its presentation height back to 0", ^{
                            delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, (CGFloat)0.0f);
                        });
                        
                        
                    });
                });
            });
            
            context(@"when user has client project and task is nil", ^{
                context(@"when fetching all today's punches succeeds", ^{
                    __block RemotePunch *firstPunch;
                    __block KSDeferred *auditHistoryDeferred;
                    __block AuditHistory *auditHistory;
                    beforeEach(^{
                        punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(NO);
                        
                        auditHistoryDeferred = [[KSDeferred alloc] init];
                        
                        auditHistory = nice_fake_for([AuditHistory class]);
                        auditHistory stub_method(@selector(history)).and_return(@[@"someText"]);
                        auditHistory stub_method(@selector(uri)).and_return(@"uriE");
                        
                        
                        NSDateComponents *dateComponentsA = [[NSDateComponents alloc] init];
                        dateComponentsA.hour = 0;
                        dateComponentsA.minute = 1;
                        dateComponentsA.second = 0;
                        
                        ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project-Name" uri:@"Project-Uri"];
                        ClientType *client = [[ClientType alloc]initWithName:@"Client-Name" uri:@"Client-Uri"];
                        
                        firstPunch = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                           nonActionedValidations:0
                                                              previousPunchStatus:Ticking
                                                                  nextPunchStatus:Ticking
                                                                    sourceOfPunch:UnknownSourceOfPunch
                                                                       actionType:PunchActionTypePunchIn
                                                                    oefTypesArray:nil
                                                                     lastSyncTime:NULL
                                                                          project:project
                                                                      auditHstory:nil
                                                                        breakType:nil
                                                                         location:nil
                                                                       violations:@[@"some-violation"]
                                                                        requestID:NULL
                                                                         activity:nil
                                                                         duration:dateComponentsA
                                                                           client:client
                                                                          address:nil
                                                                          userURI:@"user-uri"
                                                                         imageURL:nil
                                                                             date:[NSDate date]
                                                                             task:nil
                                                                              uri:@"uriE"
                                                             isTimeEntryAvailable:NO
                                                                 syncedWithServer:YES
                                                                   isMissingPunch:NO
                                                          previousPunchActionType:PunchActionTypeUnknown];
                        punchPresenter stub_method(@selector(sourceOfPunchLabelTextWithPunch:)).with(firstPunch).and_return(@"via Mobile");
                        
                        punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:)).with(firstPunch).and_return(@"Clocked In");
                        
                        punchPresenter stub_method(@selector(timeWithAmPmLabelTextForPunch:)).with(firstPunch).and_return(@"12:34 AM");
                        
                        punchPresenter stub_method(@selector(descriptionLabelForDayTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:)).with(firstPunch,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything).and_return([[NSAttributedString alloc]initWithString:@"Client-Name\nProject-Name"]);
                        
                        auditHistoryRepository stub_method(@selector(fetchPunchLogs:)).with(@[@"uriE"]).and_return(auditHistoryDeferred.promise);
                        
                        
                        durationStringPresenter stub_method(@selector(durationStringWithHours:minutes:)).and_return(@"0h:01m");
                        
                        
                        [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                          serverDidFinishPunchPromise:nil
                                                             delegate:delegate
                                                              userURI:userURI
                                                             flowType:UserFlowContext
                                                              punches:@[firstPunch]
                                                    timeLinePunchFlow:CardTimeLinePunchFlowContext];
                        
                        [subject view];
                        [subject viewWillAppear:NO];
                        [subject.timelineTableView layoutIfNeeded];
                        
                        [auditHistoryDeferred resolveWithValue:@[auditHistory]];
                    });
                    
                    it(@"should have the correct number of rows", ^{
                        [subject.timelineTableView.dataSource tableView:subject.timelineTableView numberOfRowsInSection:0] should equal(1);
                    });
                    
                    it(@"should notify its delegate to update its height", ^{
                        delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, Arguments::anything);
                    });
                    
                    it(@"should call fetchPunchLogs:", ^{
                        auditHistoryRepository should have_received(@selector(fetchPunchLogs:)).with(@[@"uriE"]);
                    });
                    
                    it(@"should show data on cell", ^{
                        DayTimeLineCell *cell = [subject.timelineTableView.visibleCells firstObject];
                        cell.punchType.text should equal(@"Clocked In");
                        punchPresenter should have_received(@selector(timeWithAmPmLabelTextForPunch:));
                        cell.punchActualTime.text should equal(@"12:34 AM");
                        NSString *attributedText = [cell.metaDataLabel.attributedText string];
                        attributedText should equal(@"Client-Name\nProject-Name");
                        cell.violationDetais.text should equal(@"1 validation resolved");
                        cell.agentType.text should equal(@"via Mobile");
                        cell.address.text should equal(@"Address unavailable");
                        cell.auditHistory.text should equal(@"someText");
                        cell.duration.text should equal(@"0h:01m");
                    });
                    
                    
                    context(@"when the view appears again", ^{
                        beforeEach(^{
                            [delegate reset_sent_messages];
                            [subject viewWillAppear:YES];
                        });
                        
                        it(@"should set its presentation height back to 0", ^{
                            delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, (CGFloat)0.0f);
                        });
                        
                    });
                });
            });
            
            context(@"when user don't have client permission", ^{
                context(@"when fetching all today's punches succeeds", ^{
                    __block RemotePunch *firstPunch;
                    __block KSDeferred *auditHistoryDeferred;
                    __block AuditHistory *auditHistory;
                    
                    beforeEach(^{
                        
                        punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(NO);
                        punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                        
                        auditHistoryDeferred = [[KSDeferred alloc] init];
                        
                        auditHistory = nice_fake_for([AuditHistory class]);
                        auditHistory stub_method(@selector(history)).and_return(@[@"someText"]);
                        auditHistory stub_method(@selector(uri)).and_return(@"uriE");
                        
                        ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project-Name" uri:@"Project-Uri"];
                        TaskType *task = [[TaskType alloc]initWithProjectUri:@"Project-Uri" taskPeriod:nil name:@"task-name" uri:@"task-uri"];
                        
                        NSDateComponents *dateComponentsA = [[NSDateComponents alloc] init];
                        dateComponentsA.hour = 0;
                        dateComponentsA.minute = 1;
                        dateComponentsA.second = 0;
                        
                        
                        firstPunch = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                           nonActionedValidations:0
                                                              previousPunchStatus:Ticking
                                                                  nextPunchStatus:Ticking
                                                                    sourceOfPunch:UnknownSourceOfPunch
                                                                       actionType:PunchActionTypePunchIn
                                                                    oefTypesArray:nil
                                                                     lastSyncTime:NULL
                                                                          project:project
                                                                      auditHstory:nil
                                                                        breakType:nil
                                                                         location:nil
                                                                       violations:@[@"some-violation"]
                                                                        requestID:NULL
                                                                         activity:nil
                                                                         duration:dateComponentsA
                                                                           client:nil
                                                                          address:nil
                                                                          userURI:@"user-uri"
                                                                         imageURL:nil
                                                                             date:[NSDate date]
                                                                             task:task
                                                                              uri:@"uriE"
                                                             isTimeEntryAvailable:NO
                                                                 syncedWithServer:YES
                                                                   isMissingPunch:NO
                                                          previousPunchActionType:PunchActionTypeUnknown];
                        
                        punchPresenter stub_method(@selector(sourceOfPunchLabelTextWithPunch:)).with(firstPunch).and_return(@"via Mobile");
                        
                        punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:)).with(firstPunch).and_return(@"Clocked In");
                        
                        punchPresenter stub_method(@selector(timeWithAmPmLabelTextForPunch:)).with(firstPunch).and_return(@"12:34 AM");
                        
                        punchPresenter stub_method(@selector(descriptionLabelForDayTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:)).with(firstPunch,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything).and_return([[NSAttributedString alloc]initWithString:@"Project-Name\nTask-Name"]);
                        
                        auditHistoryRepository stub_method(@selector(fetchPunchLogs:)).with(@[@"uriE"]).and_return(auditHistoryDeferred.promise);
                        
                        
                        durationStringPresenter stub_method(@selector(durationStringWithHours:minutes:)).and_return(@"0h:01m");
                        
                        
                        [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                          serverDidFinishPunchPromise:nil
                                                             delegate:delegate
                                                              userURI:userURI
                                                             flowType:UserFlowContext
                                                              punches:@[firstPunch]
                                                    timeLinePunchFlow:CardTimeLinePunchFlowContext];
                        
                        [subject view];
                        [subject viewWillAppear:NO];
                        [subject.timelineTableView layoutIfNeeded];
                        
                        [auditHistoryDeferred resolveWithValue:@[auditHistory]];
                    });
                    
                    it(@"should have the correct number of rows", ^{
                        [subject.timelineTableView.dataSource tableView:subject.timelineTableView numberOfRowsInSection:0] should equal(1);
                    });
                    
                    it(@"should call fetchPunchLogs:", ^{
                        auditHistoryRepository should have_received(@selector(fetchPunchLogs:)).with(@[@"uriE"]);
                    });
                    
                    it(@"should show data on cell", ^{
                        DayTimeLineCell *cell = [subject.timelineTableView.visibleCells firstObject];
                        cell.punchType.text should equal(@"Clocked In");
                        punchPresenter should have_received(@selector(timeWithAmPmLabelTextForPunch:));
                        cell.punchActualTime.text should equal(@"12:34 AM");
                        NSString *attributedText = [cell.metaDataLabel.attributedText string];
                        attributedText should equal(@"Project-Name\nTask-Name");
                        cell.violationDetais.text should equal(@"1 validation resolved");
                        cell.agentType.text should equal(@"via Mobile");
                        cell.address.text should equal(@"Address unavailable");
                        cell.auditHistory.text should equal(@"someText");
                        cell.duration.text should equal(@"0h:01m");
                    });
                    
                    
                    it(@"should notify its delegate to update its height", ^{
                        delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, Arguments::anything);
                    });
                    
                    context(@"when the view appears again", ^{
                        beforeEach(^{
                            [delegate reset_sent_messages];
                            [subject viewWillAppear:YES];
                        });
                        
                        it(@"should set its presentation height back to 0", ^{
                            delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, (CGFloat)0.0f);
                        });
                    });
                });
            });
            
            context(@"when fetching all today's punches succeeds in 12 hours format", ^{
                __block UIImage *firstImage;
                __block UIImage *secondImage;
                __block UIImage *thirdImage;
                __block UIImage *downloadedImage;
                __block RemotePunch *firstPunch;
                __block RemotePunch *secondPunch;
                __block RemotePunch *thirdPunch;
                __block DayTimeLineCell *firstCell;
                __block DayTimeLineCell *secondCell;
                __block DayTimeLineCell *thirdCell;
                __block AuditHistory *auditHistory1;
                __block AuditHistory *auditHistory2;
                __block AuditHistory *auditHistory3;
                __block Violation *violation1;
                __block Violation *violation2;
                __block Violation *violation3;
                __block NSDate *dateA;
                __block NSDate *dateB;
                __block CLLocation *locationA;
                __block CLLocation *locationB;
                __block NSString *addressA;
                __block NSString *addressB;
                __block BreakType *breakTypeA;
                __block NSString *uriA;
                __block NSString *uriB;
                __block NSString *uriC;
                __block NSString *userUriA;
                __block NSString *userUriB;
                __block NSString *userUriC;
                __block NSString *punchARequestId;
                __block NSString *punchBRequestId;
                __block NSString *punchCRequestId;
                __block NSURL *imageURLA;
                __block NSURL *imageURLB;
                __block NSURL *imageURLC;
                
                __block KSDeferred *auditHistoryDeferred;
                __block KSDeferred *imageADeferred;
                __block KSDeferred *imageBDeferred;
                __block KSDeferred *imageCDeferred;
                
                beforeEach(^{
                    auditHistoryDeferred = [[KSDeferred alloc] init];
                    imageADeferred = [[KSDeferred alloc] init];
                    imageBDeferred = [[KSDeferred alloc] init];
                    imageCDeferred = [[KSDeferred alloc] init];
                    
                    
                    breakTypeA = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
                    punchARequestId = [[NSUUID UUID] UUIDString];
                    punchBRequestId = [[NSUUID UUID] UUIDString];
                    punchCRequestId = [[NSUUID UUID] UUIDString];
                    
                    dateA = [NSDate dateWithTimeIntervalSince1970:100];
                    dateB = [NSDate dateWithTimeIntervalSince1970:100];
                    CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                    locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                    
                    CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                    locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                    
                    imageURLA = [NSURL URLWithString:@"http://example.org/fakeA"];
                    imageURLB = [NSURL URLWithString:@"http://example.org/fakeB"];
                    imageURLC = [NSURL URLWithString:@"http://example.org/fakeC"];
                    
                    
                    addressA = @"Calgary";
                    addressB = @"Calgary";
                    
                    uriA = @"uriA";
                    uriB = @"uriB";
                    uriC = @"uriC";
                    
                    userUriA = @"user-uri";
                    userUriB = @"user-uri";
                    userUriC = @"user-uri";
                    
                    downloadedImage =  nice_fake_for([UIImage class]);
                    imageFetcher stub_method(@selector(promiseWithImageURL:)).with(imageURLA).and_return(imageADeferred.promise);
                    imageFetcher stub_method(@selector(promiseWithImageURL:)).with(imageURLB).and_return(imageBDeferred.promise);
                    imageFetcher stub_method(@selector(promiseWithImageURL:)).with(imageURLC).and_return(imageCDeferred.promise);
                    
                });
                
                
                context(@"when all extras are present", ^{
                    beforeEach(^{
                        violation1 = nice_fake_for([Violation class]);
                        violation1 stub_method(@selector(title)).and_return(@[@"someText"]);
                        
                        violation2 = nice_fake_for([Violation class]);
                        violation2 stub_method(@selector(title)).and_return(@[@"someText"]);
                        
                        violation3 = nice_fake_for([Violation class]);
                        violation3 stub_method(@selector(title)).and_return(@[@"someText"]);
                        
                        
                        NSDateComponents *dateComponentsA = [[NSDateComponents alloc] init];
                        dateComponentsA.hour = 0;
                        dateComponentsA.minute = 1;
                        dateComponentsA.second = 0;
                        
                        firstPunch = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                           nonActionedValidations:0
                                                              previousPunchStatus:Ticking
                                                                  nextPunchStatus:Present
                                                                    sourceOfPunch:Mobile
                                                                       actionType:PunchActionTypePunchIn
                                                                    oefTypesArray:nil
                                                                     lastSyncTime:nil
                                                                          project:nil
                                                                      auditHstory:nil
                                                                        breakType:nil
                                                                         location:nil
                                                                       violations:@[violation1]
                                                                        requestID:NULL
                                                                         activity:nil
                                                                         duration:dateComponentsA
                                                                           client:nil
                                                                          address:addressA
                                                                          userURI:nil
                                                                         imageURL:imageURLA
                                                                             date:dateA
                                                                             task:nil
                                                                              uri:uriA
                                                             isTimeEntryAvailable:NO
                                                                 syncedWithServer:YES
                                                                   isMissingPunch:NO
                                                          previousPunchActionType:PunchActionTypeUnknown];
                        
                        secondPunch = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                            nonActionedValidations:0
                                                               previousPunchStatus:Ticking
                                                                   nextPunchStatus:Present
                                                                     sourceOfPunch:Mobile
                                                                        actionType:PunchActionTypePunchOut
                                                                     oefTypesArray:nil
                                                                      lastSyncTime:NULL
                                                                           project:nil
                                                                       auditHstory:nil
                                                                         breakType:nil
                                                                          location:nil
                                                                        violations:@[violation2]
                                                                         requestID:NULL
                                                                          activity:nil
                                                                          duration:nil
                                                                            client:nil
                                                                           address:addressB
                                                                           userURI:userUriB
                                                                          imageURL:imageURLB
                                                                              date:dateB
                                                                              task:nil
                                                                               uri:uriB
                                                              isTimeEntryAvailable:NO
                                                                  syncedWithServer:YES
                                                                    isMissingPunch:NO
                                                           previousPunchActionType:PunchActionTypeUnknown];
                        
                        thirdPunch = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                           nonActionedValidations:0
                                                              previousPunchStatus:Ticking
                                                                  nextPunchStatus:Ticking
                                                                    sourceOfPunch:Mobile
                                                                       actionType:PunchActionTypeStartBreak
                                                                    oefTypesArray:nil
                                                                     lastSyncTime:NULL
                                                                          project:nil
                                                                      auditHstory:nil
                                                                        breakType:breakTypeA
                                                                         location:nil
                                                                       violations:@[violation3]
                                                                        requestID:NULL
                                                                         activity:nil
                                                                         duration:dateComponentsA
                                                                           client:nil
                                                                          address:addressB
                                                                          userURI:userUriC
                                                                         imageURL:imageURLC
                                                                             date:dateB
                                                                             task:nil
                                                                              uri:uriC
                                                             isTimeEntryAvailable:NO
                                                                 syncedWithServer:YES
                                                                   isMissingPunch:NO
                                                          previousPunchActionType:PunchActionTypeUnknown];
                        
                        
                        
                        auditHistory1 = nice_fake_for([AuditHistory class]);
                        auditHistory1 stub_method(@selector(history)).and_return(@[@"someText"]);
                        auditHistory1 stub_method(@selector(uri)).and_return(@"uriA");
                        
                        auditHistory2 = nice_fake_for([AuditHistory class]);
                        auditHistory2 stub_method(@selector(history)).and_return(@[@"someText"]);
                        auditHistory2 stub_method(@selector(uri)).and_return(@"uriB");
                        
                        auditHistory3 = nice_fake_for([AuditHistory class]);
                        auditHistory3 stub_method(@selector(history)).and_return(@[@"someText"]);
                        auditHistory3 stub_method(@selector(uri)).and_return(@"uriC");
                        
                        auditHistoryRepository stub_method(@selector(fetchPunchLogs:)).with(@[@"uriA", @"uriB", @"uriC"]).and_return(auditHistoryDeferred.promise);
                        
                        firstImage = [[UIImage alloc] init];
                        secondImage = [[UIImage alloc] init];
                        thirdImage = [[UIImage alloc] init];
                        
                        punchPresenter stub_method(@selector(timeWithAmPmLabelTextForPunch:)).with(firstPunch).and_return(@"12:34 AM");
                        punchPresenter stub_method(@selector(punchActionIconImageWithPunch:)).with(firstPunch).and_return(firstImage);
                        
                        punchPresenter stub_method(@selector(timeWithAmPmLabelTextForPunch:)).with(secondPunch).and_return(@"5:25 PM");
                        punchPresenter stub_method(@selector(timeWithAmPmLabelTextForPunch:)).with(thirdPunch).and_return(@"5:26 PM");
                        
                        punchPresenter stub_method(@selector(punchActionIconImageWithPunch:)).with(secondPunch).and_return(secondImage);
                        punchPresenter stub_method(@selector(punchActionIconImageWithPunch:)).with(thirdPunch).and_return(thirdImage);
                        
                        
                        punchPresenter stub_method(@selector(sourceOfPunchLabelTextWithPunch:)).with(secondPunch).and_return(@"via Mobile");
                        punchPresenter stub_method(@selector(sourceOfPunchLabelTextWithPunch:)).with(firstPunch).and_return(@"via Mobile");
                        punchPresenter stub_method(@selector(sourceOfPunchLabelTextWithPunch:)).with(thirdPunch).and_return(@"via Mobile");
                        
                        punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:)).with(firstPunch).and_return(@"Clocked In");
                        punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:)).with(secondPunch).and_return(@"Clocked Out");
                        punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:)).with(thirdPunch).and_return(@"Break");
                        
                        punchPresenter stub_method(@selector(descriptionLabelForDayTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:)).with(firstPunch,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything).and_return([[NSAttributedString alloc]initWithString:@"Description Label text 1"]);
                        punchPresenter stub_method(@selector(descriptionLabelForDayTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:)).with(secondPunch,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything).and_return([[NSAttributedString alloc]initWithString:@""]);
                        punchPresenter stub_method(@selector(descriptionLabelForDayTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:)).with(thirdPunch,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything).and_return([[NSAttributedString alloc]initWithString:@"Meal Break"]);
                        
                        durationStringPresenter stub_method(@selector(durationStringWithHours:minutes:)).and_return(@"0h:01m");
                        
                        
                        subject stub_method(@selector(timeIsIn12HourFormat)).and_return(YES);
                        
                        [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                          serverDidFinishPunchPromise:nil
                                                             delegate:delegate
                                                              userURI:userURI
                                                             flowType:UserFlowContext
                                                              punches:@[firstPunch,secondPunch, thirdPunch]
                                                    timeLinePunchFlow:CardTimeLinePunchFlowContext];
                        
                        
                        [subject view];
                        [subject viewWillAppear:NO];
                        [subject.timelineTableView layoutIfNeeded];
                        
                        [auditHistoryDeferred resolveWithValue:@[auditHistory1, auditHistory2, auditHistory3]];
                        
                        firstCell = subject.timelineTableView.visibleCells[0];
                        secondCell = subject.timelineTableView.visibleCells[1];
                        thirdCell = subject.timelineTableView.visibleCells[2];
                    });
                    
                    it(@"should have the correct number of rows", ^{
                        [subject.timelineTableView.dataSource tableView:subject.timelineTableView numberOfRowsInSection:0] should equal(3);
                    });
                    
                    it(@"should call fetchPunchLogs:", ^{
                        auditHistoryRepository should have_received(@selector(fetchPunchLogs:)).with(@[@"uriA", @"uriB", @"uriC"]);
                    });
                    
                    it(@"should show downloaded image:", ^{
                        [imageADeferred resolveWithValue:downloadedImage];
                        firstCell.punchUserImageView.image should be_same_instance_as(downloadedImage);
                        firstCell.punchUserImageView.layer.borderColor should equal([UIColor redColor].CGColor);
                    });
                    
                    it(@"should style the cells appropriately", ^{
                        timeLineCellStylist should have_received(@selector(applyStyleToDayTimeLineCell:hidesDescendingLine:)).with(firstCell, NO);
                        timeLineCellStylist should have_received(@selector(applyStyleToDayTimeLineCell:hidesDescendingLine:)).with(secondCell, NO);
                        timeLineCellStylist should have_received(@selector(applyStyleToDayTimeLineCell:hidesDescendingLine:)).with(thirdCell, NO);
                    });
                    
                    context(@"should display the data properly on table cells", ^{
                        
                        it(@"should show the info for the first punch on the tableview", ^{
                            firstCell.punchType.text should equal(@"Clocked In");
                            punchPresenter should have_received(@selector(timeWithAmPmLabelTextForPunch:));
                            firstCell.punchActualTime.text should equal(@"12:34 AM");
                            NSString *attributedText = [firstCell.metaDataLabel.attributedText string];
                            attributedText should equal(@"Description Label text 1");
                            firstCell.punchUserImageView.image should be_same_instance_as(firstImage);
                            firstCell.punchUserImageView.layer.borderColor should equal([UIColor redColor].CGColor);
                            firstCell.punchUserImageView.layer.borderWidth should equal(2.0f);
                            firstCell.violationDetais.text should equal(@"1 validation resolved");
                            firstCell.agentType.text should equal(@"via Mobile");
                            firstCell.address.text should equal(@"Calgary");
                            firstCell.auditHistory.text should equal(@"someText");
                            firstCell.duration.text should equal(@"0h:01m");
                            firstCell.descendingLineView.hidden should be_falsy;
                            firstCell.selectedBackgroundView.backgroundColor should equal([UIColor grayColor]);
                        });
                        
                        it(@"should show the info for the second punch on the tableview", ^{
                            secondCell.punchType.text should equal(@"Clocked Out");
                            punchPresenter should have_received(@selector(timeWithAmPmLabelTextForPunch:));
                            secondCell.punchActualTime.text should equal(@"5:25 PM");
                            secondCell.punchUserImageView.image should be_same_instance_as(secondImage);
                            secondCell.punchUserImageView.layer.borderColor should equal([UIColor greenColor].CGColor);;
                            secondCell.punchTypeToMetaDataSpacerHeight.constant should equal(0);
                            secondCell.punchTypeImageView.hidden should be_truthy;
                            secondCell.violationDetais.text should equal(@"1 validation resolved");
                            secondCell.agentType.text should equal(@"via Mobile");
                            secondCell.address.text should equal(@"Calgary");
                            secondCell.auditHistory.text should equal(@"someText");
                            secondCell.duration.text should equal(@"");
                            secondCell.descendingLineView.hidden should be_falsy;
                            secondCell.selectedBackgroundView.backgroundColor should equal([UIColor grayColor]);
                        });
                        
                        it(@"should show the info for the third punch on the tableview", ^{
                            thirdCell.punchType.text should equal(@"Break");
                            punchPresenter should have_received(@selector(timeWithAmPmLabelTextForPunch:));
                            thirdCell.punchActualTime.text should equal(@"5:26 PM");
                            NSString *attributedText = [thirdCell.metaDataLabel.attributedText string];
                            attributedText should equal(@"Meal Break");
                            thirdCell.punchUserImageView.image should be_same_instance_as(thirdImage);
                            thirdCell.violationDetais.text should equal(@"1 validation resolved");
                            thirdCell.agentType.text should equal(@"via Mobile");
                            thirdCell.address.text should equal(@"Calgary");
                            thirdCell.auditHistory.text should equal(@"someText");
                            thirdCell.duration.text should equal(@"0h:01m");
                            thirdCell.descendingLineView.backgroundColor should equal([UIColor clearColor]);
                            thirdCell.descendingLineView.hidden should be_falsy;
                            thirdCell.selectedBackgroundView.backgroundColor should equal([UIColor grayColor]);
                        });
                    });
                    
                    context(@"should show the correct set of downloaded images on the cell correctly", ^{
                        
                        __block UIImage *downloadedImageForCellA;
                        __block UIImage *downloadedImageForCellB;
                        __block UIImage *downloadedImageForCellC;
                        
                        beforeEach(^{
                            
                            downloadedImageForCellA = nice_fake_for([UIImage class]);
                            downloadedImageForCellB = nice_fake_for([UIImage class]);
                            downloadedImageForCellC = nice_fake_for([UIImage class]);
                            
                            [imageBDeferred resolveWithValue:downloadedImageForCellB];
                            [imageADeferred resolveWithValue:downloadedImageForCellA];
                            [imageCDeferred resolveWithValue:downloadedImageForCellC];
                            
                            [subject.timelineTableView layoutIfNeeded];
                            firstCell = subject.timelineTableView.visibleCells[0];
                            secondCell = subject.timelineTableView.visibleCells[1];
                            thirdCell = subject.timelineTableView.visibleCells[2];
                        });
                        
                        it(@"should display images", ^{
                            firstCell.punchUserImageView.image should be_same_instance_as(downloadedImageForCellA);
                            secondCell.punchUserImageView.image should be_same_instance_as(downloadedImageForCellB);
                            thirdCell.punchUserImageView.image should be_same_instance_as(downloadedImageForCellC);
                        });
                    });
                    
                    it(@"should notify its delegate to update its height", ^{
                        delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, Arguments::anything);
                    });
                    
                    context(@"when the view appears again", ^{
                        beforeEach(^{
                            [delegate reset_sent_messages];
                            [subject viewWillAppear:YES];
                        });
                        
                        it(@"should set its presentation height back to 0", ^{
                            delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, (CGFloat)0.0f);
                        });
                        
                    });
                });
                
                context(@"when violations not present", ^{
                    beforeEach(^{
                        NSDateComponents *dateComponentsA = [[NSDateComponents alloc] init];
                        dateComponentsA.hour = 0;
                        dateComponentsA.minute = 1;
                        dateComponentsA.second = 0;
                        
                        firstPunch = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                           nonActionedValidations:0
                                                              previousPunchStatus:Ticking
                                                                  nextPunchStatus:Ticking
                                                                    sourceOfPunch:Mobile
                                                                       actionType:PunchActionTypePunchIn
                                                                    oefTypesArray:nil
                                                                     lastSyncTime:nil
                                                                          project:nil
                                                                      auditHstory:nil
                                                                        breakType:nil
                                                                         location:nil
                                                                       violations:@[]
                                                                        requestID:NULL
                                                                         activity:nil
                                                                         duration:dateComponentsA
                                                                           client:nil
                                                                          address:addressA
                                                                          userURI:nil
                                                                         imageURL:nil
                                                                             date:dateA
                                                                             task:nil
                                                                              uri:uriA
                                                             isTimeEntryAvailable:NO
                                                                 syncedWithServer:YES
                                                                   isMissingPunch:NO
                                                          previousPunchActionType:PunchActionTypeUnknown];
                        secondPunch = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                            nonActionedValidations:0
                                                               previousPunchStatus:Ticking
                                                                   nextPunchStatus:Ticking
                                                                     sourceOfPunch:Mobile
                                                                        actionType:PunchActionTypePunchOut
                                                                     oefTypesArray:nil
                                                                      lastSyncTime:NULL
                                                                           project:nil
                                                                       auditHstory:nil
                                                                         breakType:nil
                                                                          location:nil
                                                                        violations:@[]
                                                                         requestID:NULL
                                                                          activity:nil
                                                                          duration:nil
                                                                            client:nil
                                                                           address:addressB
                                                                           userURI:userUriB
                                                                          imageURL:nil
                                                                              date:dateB
                                                                              task:nil
                                                                               uri:uriB
                                                              isTimeEntryAvailable:NO
                                                                  syncedWithServer:YES
                                                                    isMissingPunch:NO
                                                           previousPunchActionType:PunchActionTypeUnknown];
                        
                        
                        thirdPunch = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                           nonActionedValidations:0
                                                              previousPunchStatus:Ticking
                                                                  nextPunchStatus:Ticking
                                                                    sourceOfPunch:Mobile
                                                                       actionType:PunchActionTypeStartBreak
                                                                    oefTypesArray:nil
                                                                     lastSyncTime:NULL
                                                                          project:nil
                                                                      auditHstory:nil
                                                                        breakType:breakTypeA
                                                                         location:nil
                                                                       violations:@[]
                                                                        requestID:NULL
                                                                         activity:nil
                                                                         duration:dateComponentsA
                                                                           client:nil
                                                                          address:addressB
                                                                          userURI:userUriC
                                                                         imageURL:nil
                                                                             date:dateB
                                                                             task:nil
                                                                              uri:uriC
                                                             isTimeEntryAvailable:NO
                                                                 syncedWithServer:YES
                                                                   isMissingPunch:NO
                                                          previousPunchActionType:PunchActionTypeUnknown];
                        
                        
                        
                        auditHistory1 = nice_fake_for([AuditHistory class]);
                        auditHistory1 stub_method(@selector(history)).and_return(@[@"someText"]);
                        auditHistory1 stub_method(@selector(uri)).and_return(@"uriA");
                        
                        auditHistory2 = nice_fake_for([AuditHistory class]);
                        auditHistory2 stub_method(@selector(history)).and_return(@[@"someText"]);
                        auditHistory2 stub_method(@selector(uri)).and_return(@"uriB");
                        
                        auditHistory3 = nice_fake_for([AuditHistory class]);
                        auditHistory3 stub_method(@selector(history)).and_return(@[@"someText"]);
                        auditHistory3 stub_method(@selector(uri)).and_return(@"uriC");
                        
                        auditHistoryRepository stub_method(@selector(fetchPunchLogs:)).with(@[@"uriA", @"uriB", @"uriC"]).and_return(auditHistoryDeferred.promise);
                        
                        firstImage = [[UIImage alloc] init];
                        secondImage = [[UIImage alloc] init];
                        thirdImage = [[UIImage alloc] init];
                        
                        punchPresenter stub_method(@selector(timeWithAmPmLabelTextForPunch:)).with(firstPunch).and_return(@"12:34 AM");
                        punchPresenter stub_method(@selector(punchActionIconImageWithPunch:)).with(firstPunch).and_return(firstImage);
                        
                        punchPresenter stub_method(@selector(timeWithAmPmLabelTextForPunch:)).with(secondPunch).and_return(@"5:25 PM");
                        punchPresenter stub_method(@selector(timeWithAmPmLabelTextForPunch:)).with(thirdPunch).and_return(@"5:26 PM");
                        
                        punchPresenter stub_method(@selector(punchActionIconImageWithPunch:)).with(secondPunch).and_return(secondImage);
                        
                        punchPresenter stub_method(@selector(punchActionIconImageWithPunch:)).with(thirdPunch).and_return(thirdImage);
                        
                        
                        punchPresenter stub_method(@selector(sourceOfPunchLabelTextWithPunch:)).with(secondPunch).and_return(@"via Mobile");
                        punchPresenter stub_method(@selector(sourceOfPunchLabelTextWithPunch:)).with(firstPunch).and_return(@"via Mobile");
                        punchPresenter stub_method(@selector(sourceOfPunchLabelTextWithPunch:)).with(thirdPunch).and_return(@"via Mobile");
                        
                        punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:)).with(firstPunch).and_return(@"Clocked In");
                        punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:)).with(secondPunch).and_return(@"Clocked Out");
                        punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:)).with(thirdPunch).and_return(@"Break");
                        
                        punchPresenter stub_method(@selector(descriptionLabelForDayTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:)).with(firstPunch,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything).and_return([[NSAttributedString alloc]initWithString:@"Description Label text 1"]);
                        punchPresenter stub_method(@selector(descriptionLabelForDayTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:)).with(secondPunch,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything).and_return([[NSAttributedString alloc]initWithString:@""]);
                        punchPresenter stub_method(@selector(descriptionLabelForDayTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:)).with(thirdPunch,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything).and_return([[NSAttributedString alloc]initWithString:@"Meal Break"]);
                        
                        durationStringPresenter stub_method(@selector(durationStringWithHours:minutes:)).and_return(@"0h:01m");
                        
                        
                        subject stub_method(@selector(timeIsIn12HourFormat)).and_return(YES);
                        
                        [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                          serverDidFinishPunchPromise:nil
                                                             delegate:delegate
                                                              userURI:userURI
                                                             flowType:UserFlowContext
                                                              punches:@[firstPunch,secondPunch, thirdPunch]
                                                    timeLinePunchFlow:CardTimeLinePunchFlowContext];
                        
                        
                        [subject view];
                        [subject viewWillAppear:NO];
                        [subject.timelineTableView layoutIfNeeded];
                        
                        [auditHistoryDeferred resolveWithValue:@[auditHistory1, auditHistory2, auditHistory3]];
                        
                        firstCell = subject.timelineTableView.visibleCells[0];
                        secondCell = subject.timelineTableView.visibleCells[1];
                        thirdCell = subject.timelineTableView.visibleCells[2];
                    });
                    
                    it(@"should have the correct number of rows", ^{
                        [subject.timelineTableView.dataSource tableView:subject.timelineTableView numberOfRowsInSection:0] should equal(3);
                    });
                    
                    
                    it(@"should style the cells appropriately", ^{
                        timeLineCellStylist should have_received(@selector(applyStyleToDayTimeLineCell:hidesDescendingLine:)).with(firstCell, NO);
                        timeLineCellStylist should have_received(@selector(applyStyleToDayTimeLineCell:hidesDescendingLine:)).with(secondCell, NO);
                        timeLineCellStylist should have_received(@selector(applyStyleToDayTimeLineCell:hidesDescendingLine:)).with(thirdCell, NO);
                    });
                    
                    it(@"should call fetchPunchLogs:", ^{
                        auditHistoryRepository should have_received(@selector(fetchPunchLogs:)).with(@[@"uriA", @"uriB", @"uriC"]);
                    });
                    
                    context(@"should display the data properly on table cells", ^{
                        
                        it(@"should show the info for the first punch on the tableview", ^{
                            firstCell.punchType.text should equal(@"Clocked In");
                            punchPresenter should have_received(@selector(timeWithAmPmLabelTextForPunch:));
                            firstCell.punchActualTime.text should equal(@"12:34 AM");
                            NSString *attributedText = [firstCell.metaDataLabel.attributedText string];
                            attributedText should equal(@"Description Label text 1");
                            firstCell.punchUserImageView.image should be_same_instance_as(firstImage);
                            firstCell.violationDetais.text should equal(@"");
                            firstCell.agentType.text should equal(@"via Mobile");
                            firstCell.address.text should equal(@"Calgary");
                            firstCell.auditHistory.text should equal(@"someText");
                            firstCell.duration.text should equal(@"0h:01m");
                        });
                        
                        it(@"should show the info for the second punch on the tableview", ^{
                            secondCell.punchType.text should equal(@"Clocked Out");
                            punchPresenter should have_received(@selector(timeWithAmPmLabelTextForPunch:));
                            secondCell.punchActualTime.text should equal(@"5:25 PM");
                            secondCell.punchTypeToMetaDataSpacerHeight.constant should equal(0);
                            secondCell.punchTypeImageView.hidden should be_truthy;
                            secondCell.punchUserImageView.image should be_same_instance_as(secondImage);
                            secondCell.violationDetais.text should equal(@"");
                            secondCell.agentType.text should equal(@"via Mobile");
                            secondCell.address.text should equal(@"Calgary");
                            secondCell.auditHistory.text should equal(@"someText");
                            secondCell.duration.text should equal(@"");
                        });
                        
                        it(@"should show the info for the third punch on the tableview", ^{
                            thirdCell.punchType.text should equal(@"Break");
                            punchPresenter should have_received(@selector(timeWithAmPmLabelTextForPunch:));
                            thirdCell.punchActualTime.text should equal(@"5:26 PM");
                            NSString *attributedText = [thirdCell.metaDataLabel.attributedText string];
                            attributedText should equal(@"Meal Break");
                            thirdCell.punchUserImageView.image should be_same_instance_as(thirdImage);
                            thirdCell.violationDetais.text should equal(@"");
                            thirdCell.agentType.text should equal(@"via Mobile");
                            thirdCell.address.text should equal(@"Calgary");
                            thirdCell.auditHistory.text should equal(@"someText");
                            thirdCell.duration.text should equal(@"0h:01m");
                        });
                        
                    });
                    
                    
                    it(@"should notify its delegate to update its height", ^{
                        delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, Arguments::anything);
                    });
                    
                    context(@"when the view appears again", ^{
                        beforeEach(^{
                            [delegate reset_sent_messages];
                            [subject viewWillAppear:YES];
                        });
                        
                        it(@"should set its presentation height back to 0", ^{
                            delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, (CGFloat)0.0f);
                        });
                        
                    });
                });
                
            });
            
            context(@"when fetching all today's punches succeeds in 24 hours format", ^{
                __block UIImage *firstImage;
                __block UIImage *secondImage;
                __block UIImage *thirdImage;
                __block RemotePunch *firstPunch;
                __block RemotePunch *secondPunch;
                __block RemotePunch *thirdPunch;
                __block DayTimeLineCell *firstCell;
                __block DayTimeLineCell *secondCell;
                __block DayTimeLineCell *thirdCell;
                __block AuditHistory *auditHistory1;
                __block AuditHistory *auditHistory2;
                __block AuditHistory *auditHistory3;
                __block Violation *violation1;
                __block Violation *violation2;
                __block Violation *violation3;
                __block NSDate *dateA;
                __block NSDate *dateB;
                __block CLLocation *locationA;
                __block CLLocation *locationB;
                __block NSString *addressA;
                __block NSString *addressB;
                __block BreakType *breakTypeA;
                __block NSString *uriA;
                __block NSString *uriB;
                __block NSString *uriC;
                __block NSString *userUriA;
                __block NSString *userUriB;
                __block NSString *userUriC;
                __block NSString *punchARequestId;
                __block NSString *punchBRequestId;
                __block NSString *punchCRequestId;
                __block NSURL *imageURL;
                __block KSDeferred *auditHistoryDeferred;
                
                beforeEach(^{
                    auditHistoryDeferred = [[KSDeferred alloc] init];
                    breakTypeA = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
                    punchARequestId = [[NSUUID UUID] UUIDString];
                    punchBRequestId = [[NSUUID UUID] UUIDString];
                    punchCRequestId = [[NSUUID UUID] UUIDString];
                    
                    dateA = [NSDate dateWithTimeIntervalSince1970:100];
                    dateB = [NSDate dateWithTimeIntervalSince1970:100];
                    CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                    locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                    
                    CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                    locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                    
                    imageURL = [NSURL URLWithString:@"http://example.org/fake"];
                    
                    addressA = @"Calgary";
                    addressB = @"Calgary";
                    
                    uriA = @"uriA";
                    uriB = @"uriB";
                    uriC = @"uriC";
                    
                    userUriA = @"user-uri";
                    userUriB = @"user-uri";
                    userUriC = @"user-uri";
                });
                
                
                context(@"when all extras are present", ^{
                    beforeEach(^{
                        violation1 = nice_fake_for([Violation class]);
                        violation1 stub_method(@selector(title)).and_return(@[@"someText"]);
                        
                        violation2 = nice_fake_for([Violation class]);
                        violation2 stub_method(@selector(title)).and_return(@[@"someText"]);
                        
                        violation3 = nice_fake_for([Violation class]);
                        violation3 stub_method(@selector(title)).and_return(@[@"someText"]);
                        
                        NSDateComponents *dateComponentsA = [[NSDateComponents alloc] init];
                        dateComponentsA.hour = 0;
                        dateComponentsA.minute = 1;
                        dateComponentsA.second = 0;
                        
                        firstPunch = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                           nonActionedValidations:0
                                                              previousPunchStatus:Ticking
                                                                  nextPunchStatus:Ticking
                                                                    sourceOfPunch:Mobile
                                                                       actionType:PunchActionTypePunchIn
                                                                    oefTypesArray:nil
                                                                     lastSyncTime:nil
                                                                          project:nil
                                                                      auditHstory:nil
                                                                        breakType:nil
                                                                         location:nil
                                                                       violations:@[violation1]
                                                                        requestID:NULL
                                                                         activity:nil
                                                                         duration:dateComponentsA
                                                                           client:nil
                                                                          address:addressA
                                                                          userURI:nil
                                                                         imageURL:nil
                                                                             date:dateA
                                                                             task:nil
                                                                              uri:uriA
                                                             isTimeEntryAvailable:NO
                                                                 syncedWithServer:YES
                                                                   isMissingPunch:NO
                                                          previousPunchActionType:PunchActionTypeUnknown];
                        
                        secondPunch = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                            nonActionedValidations:0
                                                               previousPunchStatus:Ticking
                                                                   nextPunchStatus:Ticking
                                                                     sourceOfPunch:Mobile
                                                                        actionType:PunchActionTypePunchOut
                                                                     oefTypesArray:nil
                                                                      lastSyncTime:NULL
                                                                           project:nil
                                                                       auditHstory:nil
                                                                         breakType:nil
                                                                          location:nil
                                                                        violations:@[violation2]
                                                                         requestID:NULL
                                                                          activity:nil
                                                                          duration:nil
                                                                            client:nil
                                                                           address:addressB
                                                                           userURI:userUriB
                                                                          imageURL:nil
                                                                              date:dateB
                                                                              task:nil
                                                                               uri:uriB
                                                              isTimeEntryAvailable:NO
                                                                  syncedWithServer:YES
                                                                    isMissingPunch:NO
                                                           previousPunchActionType:PunchActionTypeUnknown];
                        
                        thirdPunch = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                           nonActionedValidations:0
                                                              previousPunchStatus:Ticking
                                                                  nextPunchStatus:Ticking
                                                                    sourceOfPunch:Mobile
                                                                       actionType:PunchActionTypeStartBreak
                                                                    oefTypesArray:nil
                                                                     lastSyncTime:NULL
                                                                          project:nil
                                                                      auditHstory:nil
                                                                        breakType:breakTypeA
                                                                         location:nil
                                                                       violations:@[violation3]
                                                                        requestID:NULL
                                                                         activity:nil
                                                                         duration:dateComponentsA
                                                                           client:nil
                                                                          address:addressB
                                                                          userURI:userUriC
                                                                         imageURL:nil
                                                                             date:dateB
                                                                             task:nil
                                                                              uri:uriC
                                                             isTimeEntryAvailable:NO
                                                                 syncedWithServer:YES
                                                                   isMissingPunch:NO
                                                          previousPunchActionType:PunchActionTypeUnknown];
                        
                        
                        
                        auditHistory1 = nice_fake_for([AuditHistory class]);
                        auditHistory1 stub_method(@selector(history)).and_return(@[@"someText"]);
                        auditHistory1 stub_method(@selector(uri)).and_return(@"uriA");
                        
                        auditHistory2 = nice_fake_for([AuditHistory class]);
                        auditHistory2 stub_method(@selector(history)).and_return(@[@"someText"]);
                        auditHistory2 stub_method(@selector(uri)).and_return(@"uriB");
                        
                        auditHistory3 = nice_fake_for([AuditHistory class]);
                        auditHistory3 stub_method(@selector(history)).and_return(@[@"someText"]);
                        auditHistory3 stub_method(@selector(uri)).and_return(@"uriC");
                        
                        auditHistoryRepository stub_method(@selector(fetchPunchLogs:)).with(@[@"uriA", @"uriB", @"uriC"]).and_return(auditHistoryDeferred.promise);
                        
                        firstImage = [[UIImage alloc] init];
                        secondImage = [[UIImage alloc] init];
                        thirdImage = [[UIImage alloc] init];
                        
                        punchPresenter stub_method(@selector(timeLabelTextWithPunch:)).with(firstPunch).and_return(@"12:34");
                        punchPresenter stub_method(@selector(punchActionIconImageWithPunch:)).with(firstPunch).and_return(firstImage);
                        
                        punchPresenter stub_method(@selector(timeLabelTextWithPunch:)).with(secondPunch).and_return(@"5:25");
                        punchPresenter stub_method(@selector(timeLabelTextWithPunch:)).with(thirdPunch).and_return(@"5:26");
                        
                        punchPresenter stub_method(@selector(punchActionIconImageWithPunch:)).with(secondPunch).and_return(secondImage);
                        punchPresenter stub_method(@selector(punchActionIconImageWithPunch:)).with(thirdPunch).and_return(thirdImage);
                        
                        punchPresenter stub_method(@selector(sourceOfPunchLabelTextWithPunch:)).with(secondPunch).and_return(@"via Mobile");
                        punchPresenter stub_method(@selector(sourceOfPunchLabelTextWithPunch:)).with(firstPunch).and_return(@"via Mobile");
                        punchPresenter stub_method(@selector(sourceOfPunchLabelTextWithPunch:)).with(thirdPunch).and_return(@"via Mobile");
                        
                        punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:)).with(firstPunch).and_return(@"Clocked In");
                        punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:)).with(secondPunch).and_return(@"Clocked Out");
                        punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:)).with(thirdPunch).and_return(@"Break");
                        
                        punchPresenter stub_method(@selector(descriptionLabelForDayTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:)).with(firstPunch,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything).and_return([[NSAttributedString alloc]initWithString:@"Description Label text 1"]);
                        punchPresenter stub_method(@selector(descriptionLabelForDayTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:)).with(secondPunch,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything).and_return([[NSAttributedString alloc]initWithString:@""]);
                        punchPresenter stub_method(@selector(descriptionLabelForDayTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:)).with(thirdPunch,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything).and_return([[NSAttributedString alloc]initWithString:@"Meal Break"]);
                        
                        durationStringPresenter stub_method(@selector(durationStringWithHours:minutes:)).and_return(@"0h:01m");
                        
                        
                        subject stub_method(@selector(timeIsIn12HourFormat)).and_return(NO);
                        
                        [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                          serverDidFinishPunchPromise:nil
                                                             delegate:delegate
                                                              userURI:userURI
                                                             flowType:UserFlowContext
                                                              punches:@[firstPunch,secondPunch, thirdPunch]
                                                    timeLinePunchFlow:CardTimeLinePunchFlowContext];
                        
                        
                        [subject view];
                        [subject viewWillAppear:NO];
                        [subject.timelineTableView layoutIfNeeded];
                        
                        [auditHistoryDeferred resolveWithValue:@[auditHistory1, auditHistory2, auditHistory3]];
                        
                        firstCell = subject.timelineTableView.visibleCells[0];
                        secondCell = subject.timelineTableView.visibleCells[1];
                        thirdCell = subject.timelineTableView.visibleCells[2];
                    });
                    
                    it(@"should have the correct number of rows", ^{
                        [subject.timelineTableView.dataSource tableView:subject.timelineTableView numberOfRowsInSection:0] should equal(3);
                    });
                    
                    it(@"should call fetchPunchLogs:", ^{
                        auditHistoryRepository should have_received(@selector(fetchPunchLogs:)).with(@[@"uriA", @"uriB", @"uriC"]);
                    });
                    
                    it(@"should style the cells appropriately", ^{
                        timeLineCellStylist should have_received(@selector(applyStyleToDayTimeLineCell:hidesDescendingLine:)).with(firstCell, NO);
                        timeLineCellStylist should have_received(@selector(applyStyleToDayTimeLineCell:hidesDescendingLine:)).with(secondCell, NO);
                        timeLineCellStylist should have_received(@selector(applyStyleToDayTimeLineCell:hidesDescendingLine:)).with(thirdCell, NO);
                    });
                    
                    context(@"should display the data properly on table cells", ^{
                        
                        it(@"should show the info for the first punch on the tableview", ^{
                            firstCell.punchType.text should equal(@"Clocked In");
                            punchPresenter should have_received(@selector(timeLabelTextWithPunch:));
                            firstCell.punchActualTime.text should equal(@"12:34");
                            NSString *attributedText = [firstCell.metaDataLabel.attributedText string];
                            attributedText should equal(@"Description Label text 1");
                            firstCell.punchUserImageView.image should be_same_instance_as(firstImage);
                            firstCell.violationDetais.text should equal(@"1 validation resolved");
                            firstCell.agentType.text should equal(@"via Mobile");
                            firstCell.address.text should equal(@"Calgary");
                            firstCell.auditHistory.text should equal(@"someText");
                            firstCell.duration.text should equal(@"0h:01m");
                        });
                        
                        it(@"should show the info for the second punch on the tableview", ^{
                            secondCell.punchType.text should equal(@"Clocked Out");
                            punchPresenter should have_received(@selector(timeLabelTextWithPunch:));
                            secondCell.punchActualTime.text should equal(@"5:25");
                            secondCell.punchUserImageView.image should be_same_instance_as(secondImage);
                            secondCell.punchTypeToMetaDataSpacerHeight.constant should equal(0);
                            secondCell.punchTypeImageView.hidden should be_truthy;
                            secondCell.violationDetais.text should equal(@"1 validation resolved");
                            secondCell.agentType.text should equal(@"via Mobile");
                            secondCell.address.text should equal(@"Calgary");
                            secondCell.auditHistory.text should equal(@"someText");
                            secondCell.duration.text should equal(@"");
                        });
                        
                        it(@"should show the info for the third punch on the tableview", ^{
                            thirdCell.punchType.text should equal(@"Break");
                            punchPresenter should have_received(@selector(timeLabelTextWithPunch:));
                            thirdCell.punchActualTime.text should equal(@"5:26");
                            NSString *attributedText = [thirdCell.metaDataLabel.attributedText string];
                            attributedText should equal(@"Meal Break");
                            thirdCell.punchUserImageView.image should be_same_instance_as(thirdImage);
                            thirdCell.violationDetais.text should equal(@"1 validation resolved");
                            thirdCell.agentType.text should equal(@"via Mobile");
                            thirdCell.address.text should equal(@"Calgary");
                            thirdCell.auditHistory.text should equal(@"someText");
                            thirdCell.duration.text should equal(@"0h:01m");
                        });
                        
                    });
                    
                    
                    it(@"should notify its delegate to update its height", ^{
                        delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, Arguments::anything);
                    });
                    
                    context(@"when the view appears again", ^{
                        beforeEach(^{
                            [delegate reset_sent_messages];
                            [subject viewWillAppear:YES];
                        });
                        
                        it(@"should set its presentation height back to 0", ^{
                            delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, (CGFloat)0.0f);
                        });
                        
                    });
                });
                
                context(@"when violations not present", ^{
                    beforeEach(^{
                        NSDateComponents *dateComponentsA = [[NSDateComponents alloc] init];
                        dateComponentsA.hour = 0;
                        dateComponentsA.minute = 1;
                        dateComponentsA.second = 0;
                        
                        firstPunch = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                           nonActionedValidations:0
                                                              previousPunchStatus:Ticking
                                                                  nextPunchStatus:Ticking
                                                                    sourceOfPunch:Mobile
                                                                       actionType:PunchActionTypePunchIn
                                                                    oefTypesArray:nil
                                                                     lastSyncTime:nil
                                                                          project:nil
                                                                      auditHstory:nil
                                                                        breakType:nil
                                                                         location:nil
                                                                       violations:@[]
                                                                        requestID:NULL
                                                                         activity:nil
                                                                         duration:dateComponentsA
                                                                           client:nil
                                                                          address:addressA
                                                                          userURI:nil
                                                                         imageURL:nil
                                                                             date:dateA
                                                                             task:nil
                                                                              uri:uriA
                                                             isTimeEntryAvailable:NO
                                                                 syncedWithServer:YES
                                                                   isMissingPunch:NO
                                                          previousPunchActionType:PunchActionTypeUnknown];
                        secondPunch = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                            nonActionedValidations:0
                                                               previousPunchStatus:Ticking
                                                                   nextPunchStatus:Ticking
                                                                     sourceOfPunch:Mobile
                                                                        actionType:PunchActionTypePunchOut
                                                                     oefTypesArray:nil
                                                                      lastSyncTime:NULL
                                                                           project:nil
                                                                       auditHstory:nil
                                                                         breakType:nil
                                                                          location:nil
                                                                        violations:@[]
                                                                         requestID:NULL
                                                                          activity:nil
                                                                          duration:nil
                                                                            client:nil
                                                                           address:addressB
                                                                           userURI:userUriB
                                                                          imageURL:nil
                                                                              date:dateB
                                                                              task:nil
                                                                               uri:uriB
                                                              isTimeEntryAvailable:NO
                                                                  syncedWithServer:YES
                                                                    isMissingPunch:NO
                                                           previousPunchActionType:PunchActionTypeUnknown];
                        
                        
                        thirdPunch = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                           nonActionedValidations:0
                                                              previousPunchStatus:Ticking
                                                                  nextPunchStatus:Ticking
                                                                    sourceOfPunch:Mobile
                                                                       actionType:PunchActionTypeStartBreak
                                                                    oefTypesArray:nil
                                                                     lastSyncTime:NULL
                                                                          project:nil
                                                                      auditHstory:nil
                                                                        breakType:breakTypeA
                                                                         location:nil
                                                                       violations:@[]
                                                                        requestID:NULL
                                                                         activity:nil
                                                                         duration:dateComponentsA
                                                                           client:nil
                                                                          address:addressB
                                                                          userURI:userUriC
                                                                         imageURL:nil
                                                                             date:dateB
                                                                             task:nil
                                                                              uri:uriC
                                                             isTimeEntryAvailable:NO
                                                                 syncedWithServer:YES
                                                                   isMissingPunch:NO
                                                          previousPunchActionType:PunchActionTypeUnknown];
                        
                        
                        
                        auditHistory1 = nice_fake_for([AuditHistory class]);
                        auditHistory1 stub_method(@selector(history)).and_return(@[@"someText"]);
                        auditHistory1 stub_method(@selector(uri)).and_return(@"uriA");
                        
                        auditHistory2 = nice_fake_for([AuditHistory class]);
                        auditHistory2 stub_method(@selector(history)).and_return(@[@"someText"]);
                        auditHistory2 stub_method(@selector(uri)).and_return(@"uriB");
                        
                        auditHistory3 = nice_fake_for([AuditHistory class]);
                        auditHistory3 stub_method(@selector(history)).and_return(@[@"someText"]);
                        auditHistory3 stub_method(@selector(uri)).and_return(@"uriC");
                        
                        auditHistoryRepository stub_method(@selector(fetchPunchLogs:)).with(@[@"uriA", @"uriB", @"uriC"]).and_return(auditHistoryDeferred.promise);
                        
                        firstImage = [[UIImage alloc] init];
                        secondImage = [[UIImage alloc] init];
                        thirdImage = [[UIImage alloc] init];
                        
                        punchPresenter stub_method(@selector(timeLabelTextWithPunch:)).with(firstPunch).and_return(@"12:34");
                        punchPresenter stub_method(@selector(punchActionIconImageWithPunch:)).with(firstPunch).and_return(firstImage);
                        
                        punchPresenter stub_method(@selector(timeLabelTextWithPunch:)).with(secondPunch).and_return(@"5:25");
                        punchPresenter stub_method(@selector(timeLabelTextWithPunch:)).with(thirdPunch).and_return(@"5:26");
                        
                        punchPresenter stub_method(@selector(punchActionIconImageWithPunch:)).with(secondPunch).and_return(secondImage);
                        
                        punchPresenter stub_method(@selector(punchActionIconImageWithPunch:)).with(thirdPunch).and_return(thirdImage);
                        
                        
                        punchPresenter stub_method(@selector(sourceOfPunchLabelTextWithPunch:)).with(secondPunch).and_return(@"via Mobile");
                        punchPresenter stub_method(@selector(sourceOfPunchLabelTextWithPunch:)).with(firstPunch).and_return(@"via Mobile");
                        punchPresenter stub_method(@selector(sourceOfPunchLabelTextWithPunch:)).with(thirdPunch).and_return(@"via Mobile");
                        
                        punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:)).with(firstPunch).and_return(@"Clocked In");
                        punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:)).with(secondPunch).and_return(@"Clocked Out");
                        punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:)).with(thirdPunch).and_return(@"Break");
                        
                        punchPresenter stub_method(@selector(descriptionLabelForDayTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:)).with(firstPunch,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything).and_return([[NSAttributedString alloc]initWithString:@"Description Label text 1"]);
                        punchPresenter stub_method(@selector(descriptionLabelForDayTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:)).with(secondPunch,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything).and_return([[NSAttributedString alloc]initWithString:@""]);
                        punchPresenter stub_method(@selector(descriptionLabelForDayTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:)).with(thirdPunch,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything).and_return([[NSAttributedString alloc]initWithString:@"Meal Break"]);
                        
                        durationStringPresenter stub_method(@selector(durationStringWithHours:minutes:)).and_return(@"0h:01m");
                        
                        
                        subject stub_method(@selector(timeIsIn12HourFormat)).and_return(NO);
                        
                        [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                          serverDidFinishPunchPromise:nil
                                                             delegate:delegate
                                                              userURI:userURI
                                                             flowType:UserFlowContext
                                                              punches:@[firstPunch,secondPunch, thirdPunch]
                                                    timeLinePunchFlow:CardTimeLinePunchFlowContext];
                        
                        
                        [subject view];
                        [subject viewWillAppear:NO];
                        [subject.timelineTableView layoutIfNeeded];
                        
                        [auditHistoryDeferred resolveWithValue:@[auditHistory1, auditHistory2, auditHistory3]];
                        
                        firstCell = subject.timelineTableView.visibleCells[0];
                        secondCell = subject.timelineTableView.visibleCells[1];
                        thirdCell = subject.timelineTableView.visibleCells[2];
                    });
                    
                    it(@"should have the correct number of rows", ^{
                        [subject.timelineTableView.dataSource tableView:subject.timelineTableView numberOfRowsInSection:0] should equal(3);
                    });
                    
                    it(@"should call fetchPunchLogs:", ^{
                        auditHistoryRepository should have_received(@selector(fetchPunchLogs:)).with(@[@"uriA", @"uriB", @"uriC"]);
                    });
                    
                    
                    it(@"should style the cells appropriately", ^{
                        timeLineCellStylist should have_received(@selector(applyStyleToDayTimeLineCell:hidesDescendingLine:)).with(firstCell, NO);
                        timeLineCellStylist should have_received(@selector(applyStyleToDayTimeLineCell:hidesDescendingLine:)).with(secondCell, NO);
                        timeLineCellStylist should have_received(@selector(applyStyleToDayTimeLineCell:hidesDescendingLine:)).with(thirdCell, NO);
                    });
                    
                    context(@"should display the data properly on table cells", ^{
                        
                        it(@"should show the info for the first punch on the tableview", ^{
                            firstCell.punchType.text should equal(@"Clocked In");
                            punchPresenter should have_received(@selector(timeLabelTextWithPunch:));
                            firstCell.punchActualTime.text should equal(@"12:34");
                            NSString *attributedText = [firstCell.metaDataLabel.attributedText string];
                            attributedText should equal(@"Description Label text 1");
                            firstCell.punchUserImageView.image should be_same_instance_as(firstImage);
                            firstCell.violationDetais.text should equal(@"");
                            firstCell.agentType.text should equal(@"via Mobile");
                            firstCell.address.text should equal(@"Calgary");
                            firstCell.auditHistory.text should equal(@"someText");
                            firstCell.duration.text should equal(@"0h:01m");
                        });
                        
                        it(@"should show the info for the second punch on the tableview", ^{
                            secondCell.punchType.text should equal(@"Clocked Out");
                            punchPresenter should have_received(@selector(timeLabelTextWithPunch:));
                            secondCell.punchActualTime.text should equal(@"5:25");
                            secondCell.punchTypeToMetaDataSpacerHeight.constant should equal(0);
                            secondCell.punchTypeImageView.hidden should be_truthy;
                            secondCell.punchUserImageView.image should be_same_instance_as(secondImage);
                            secondCell.violationDetais.text should equal(@"");
                            secondCell.agentType.text should equal(@"via Mobile");
                            secondCell.address.text should equal(@"Calgary");
                            secondCell.auditHistory.text should equal(@"someText");
                            secondCell.duration.text should equal(@"");
                        });
                        
                        it(@"should show the info for the third punch on the tableview", ^{
                            thirdCell.punchType.text should equal(@"Break");
                            punchPresenter should have_received(@selector(timeLabelTextWithPunch:));
                            thirdCell.punchActualTime.text should equal(@"5:26");
                            NSString *attributedText = [thirdCell.metaDataLabel.attributedText string];
                            attributedText should equal(@"Meal Break");
                            thirdCell.punchUserImageView.image should be_same_instance_as(thirdImage);
                            thirdCell.violationDetais.text should equal(@"");
                            thirdCell.agentType.text should equal(@"via Mobile");
                            thirdCell.address.text should equal(@"Calgary");
                            thirdCell.auditHistory.text should equal(@"someText");
                            thirdCell.duration.text should equal(@"0h:01m");
                        });
                        
                    });
                    
                    
                    it(@"should notify its delegate to update its height", ^{
                        delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, Arguments::anything);
                    });
                    
                    context(@"when the view appears again", ^{
                        beforeEach(^{
                            [delegate reset_sent_messages];
                            [subject viewWillAppear:YES];
                        });
                        
                        it(@"should set its presentation height back to 0", ^{
                            delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, (CGFloat)0.0f);
                        });
                        
                    });
                });
            });
        });

        describe(@"viewing detail about a particular punch in user Context", ^{
            __block UINavigationController *navigationController;
            beforeEach(^{

                [subject view];
                [subject viewWillAppear:NO];

                navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
            });

            context(@"when fetching punches succeeds", ^{
                __block UIImage *image;
                __block RemotePunch *punch;

                beforeEach(^{
                    punch = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                       nonActionedValidations:0
                                                          previousPunchStatus:Ticking
                                                              nextPunchStatus:Ticking
                                                                sourceOfPunch:UnknownSourceOfPunch
                                                                   actionType:PunchActionTypePunchIn
                                                                oefTypesArray:nil
                                                                 lastSyncTime:NULL
                                                                      project:nil
                                                                  auditHstory:nil
                                                                    breakType:nil
                                                                     location:nil
                                                                   violations:nil
                                                                    requestID:NULL
                                                                     activity:nil
                                                                     duration:nil
                                                                       client:nil
                                                                      address:nil
                                                                      userURI:@"user-uri"
                                                                     imageURL:nil
                                                                         date:[NSDate date]
                                                                         task:nil
                                                                          uri:@"some:punch:uri"
                                                         isTimeEntryAvailable:NO
                                                             syncedWithServer:YES
                                                               isMissingPunch:NO
                                                      previousPunchActionType:PunchActionTypeUnknown];

                    image = [[UIImage alloc] init];

                    punchPresenter stub_method(@selector(punchActionIconImageWithPunch:)).with(punch).and_return(image);

                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                      serverDidFinishPunchPromise:nil
                                                         delegate:delegate
                                                          userURI:userURI
                                                         flowType:UserFlowContext
                                                          punches:@[punch]
                                                timeLinePunchFlow:CardTimeLinePunchFlowContext];
                    
                    [subject view];
                    [subject viewWillAppear:NO];
                });


                context(@"when the punch row is tapped", ^{
                    __block PunchOverviewController *punchOverviewController;

                    beforeEach(^{
                        punchOverviewController = [[PunchOverviewController alloc] initWithChildControllerHelper:nil violationRepository:nil breakTypeRepository:nil punchRulesStorage:nil punchRepository:NULL spinnerDelegate:nil theme:nil notificationCenter:nil reachabilityMonitor:nil];
                        [injector bind:[PunchOverviewController class] toInstance:punchOverviewController];

                        spy_on(punchOverviewController);

                        NSIndexPath *firstRow = [NSIndexPath indexPathForRow:0 inSection:0];
                        DayTimeLineCell *cell = (DayTimeLineCell *)[subject.timelineTableView cellForRowAtIndexPath:firstRow];
                        [cell tap];
                    });

                    it(@"should present a PunchOverviewController", ^{
                        subject.navigationController.topViewController should be_same_instance_as(punchOverviewController);
                    });

                    it(@"should configure the PunchOverviewController correctly", ^{
                        punchOverviewController.punch should be_same_instance_as(punch);
                    });

                    it(@"should deselect the tapped cell", ^{
                        [subject.timelineTableView indexPathsForSelectedRows] should be_nil;
                    });

                    it(@"should set up the punchOverviewController correctly", ^{
                        punchOverviewController should have_received(@selector(setupWithPunchChangeObserverDelegate:punch:flowType:userUri:)).with(punchChangeObserverDelegate,punch,UserFlowContext,@"my-special-user-uri");
                    });

                    it(@"should update the time punches", ^{
                        timeLinePunchesStorage should have_received(@selector(storeRemotePunch:)).with(punch);

                    });
                });

                it(@"should notify its delegate to update its height", ^{
                    delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, Arguments::anything);
                });
            });
        });
        
        describe(@"viewing detail about a particular punch in Supervisor Context", ^{

            __block UINavigationController *navigationController;
            beforeEach(^{
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                  serverDidFinishPunchPromise:nil
                                                     delegate:delegate
                                                      userURI:userURI
                                                     flowType:SupervisorFlowContext
                                                      punches:@[]
                                            timeLinePunchFlow:DayControllerTimeLinePunchFlowContext];


                [subject view];
                [subject viewWillAppear:NO];

                navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
            });

            context(@"when fetching punches succeeds", ^{
                __block UIImage *image;
                __block RemotePunch *punch;

                beforeEach(^{
                    punch = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                  nonActionedValidations:0
                                                     previousPunchStatus:Ticking
                                                         nextPunchStatus:Ticking
                                                           sourceOfPunch:UnknownSourceOfPunch
                                                              actionType:PunchActionTypePunchIn
                                                           oefTypesArray:nil
                                                            lastSyncTime:NULL
                                                                 project:nil
                                                             auditHstory:nil
                                                               breakType:nil
                                                                location:nil
                                                              violations:nil
                                                               requestID:NULL
                                                                activity:nil
                                                                duration:nil
                                                                  client:nil
                                                                 address:nil
                                                                 userURI:@"my-special-user-uri"
                                                                imageURL:nil
                                                                    date:[NSDate date]
                                                                    task:nil
                                                                     uri:@"some:punch:uri"
                                                    isTimeEntryAvailable:NO
                                                        syncedWithServer:YES
                                                          isMissingPunch:NO
                                                 previousPunchActionType:PunchActionTypeUnknown];

                    image = [[UIImage alloc] init];
                    punchPresenter stub_method(@selector(punchActionIconImageWithPunch:)).with(punch).and_return(image);

                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                      serverDidFinishPunchPromise:nil
                                                         delegate:delegate
                                                          userURI:@"my-special-user-uri"
                                                         flowType:SupervisorFlowContext
                                                          punches:@[punch]
                                                timeLinePunchFlow:CardTimeLinePunchFlowContext];

                    [subject.timelineTableView layoutIfNeeded];
                });


                context(@"when the punch row is tapped", ^{
                    __block PunchOverviewController *punchOverviewController;

                    beforeEach(^{
                        punchOverviewController = [[PunchOverviewController alloc] initWithChildControllerHelper:nil violationRepository:nil breakTypeRepository:nil punchRulesStorage:nil punchRepository:NULL spinnerDelegate:nil theme:nil notificationCenter:nil reachabilityMonitor:nil];
                        [injector bind:[PunchOverviewController class] toInstance:punchOverviewController];

                        spy_on(punchOverviewController);

                        NSIndexPath *firstRow = [NSIndexPath indexPathForRow:0 inSection:0];
                        DayTimeLineCell *cell = (DayTimeLineCell *)[subject.timelineTableView cellForRowAtIndexPath:firstRow];
                        [cell tap];
                    });

                    it(@"should present a PunchOverviewController", ^{
                        subject.navigationController.topViewController should be_same_instance_as(punchOverviewController);
                    });

                    it(@"should configure the PunchOverviewController correctly", ^{
                        punchOverviewController.punch should be_same_instance_as(punch);
                    });

                    it(@"should deselect the tapped cell", ^{
                        [subject.timelineTableView indexPathsForSelectedRows] should be_nil;
                    });

                    it(@"should set up the punchOverviewController correctly", ^{
                        punchOverviewController should have_received(@selector(setupWithPunchChangeObserverDelegate:punch:flowType:userUri:)).with(punchChangeObserverDelegate,punch,SupervisorFlowContext,@"my-special-user-uri");
                    });

                    it(@"should update the time punches", ^{
                        timeLinePunchesStorage should have_received(@selector(storeRemotePunch:)).with(punch);

                    });
                });

                it(@"should notify its delegate to update its height", ^{
                    delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, Arguments::anything);
                });
            });
        });
        
        describe(@"when next punch is missing", ^{
            __block RemotePunch *firstPunch;
            __block RemotePunch *secondPunch;
            __block AuditHistory *auditHistory1;
            __block AuditHistory *auditHistory2;
            __block KSDeferred *auditHistoryDeferred;
            __block NSString *addressA;
            __block NSString *addressB;
            __block NSString *uriA;
            __block NSString *uriB;
            __block NSString *userUriA;
            __block NSString *userUriB;
            __block NSString *punchARequestId;
            __block NSString *punchBRequestId;
            __block NSString *punchCRequestId;
            __block NSURL *imageURL;
            __block NSDate *dateA;
            __block NSDate *dateB;
            __block UIImage *firstImage;
            __block UIImage *secondImage;
            __block DayTimeLineCell *firstCell;
            __block MissingPunchCell *secondCell;
            __block DayTimeLineCell *thirdCell;
            beforeEach(^{
                auditHistoryDeferred = [[KSDeferred alloc] init];
                
                punchARequestId = [[NSUUID UUID] UUIDString];
                punchBRequestId = [[NSUUID UUID] UUIDString];
                punchCRequestId = [[NSUUID UUID] UUIDString];
                
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                imageURL = [NSURL URLWithString:@"http://example.org/fake"];
                
                addressA = @"Calgary";
                addressB = @"Calgary";
                
                uriA = @"uriA";
                uriB = @"uriB";
                
                userUriA = @"user-uri";
                userUriB = @"user-uri";
            });
            
            beforeEach(^{
                NSDateComponents *dateComponentsA = [[NSDateComponents alloc] init];
                dateComponentsA.hour = 0;
                dateComponentsA.minute = 1;
                dateComponentsA.second = 0;
                
                firstImage = [[UIImage alloc] init];
                secondImage = [[UIImage alloc] init];
                
                firstPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                   nonActionedValidations:0
                                                      previousPunchStatus:Ticking
                                                          nextPunchStatus:Missing
                                                            sourceOfPunch:Mobile
                                                               actionType:PunchActionTypePunchIn
                                                            oefTypesArray:nil
                                                             lastSyncTime:nil
                                                                  project:nil
                                                              auditHstory:nil
                                                                breakType:nil
                                                                 location:nil
                                                               violations:@[]
                                                                requestID:NULL
                                                                 activity:nil
                                                                 duration:dateComponentsA
                                                                   client:nil
                                                                  address:addressA
                                                                  userURI:userUriA
                                                                 imageURL:nil
                                                                     date:dateA
                                                                     task:nil
                                                                      uri:uriA
                                                     isTimeEntryAvailable:NO
                                                         syncedWithServer:YES
                                                           isMissingPunch:NO
                                                  previousPunchActionType:PunchActionTypeUnknown];
                
                secondPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                    nonActionedValidations:0
                                                       previousPunchStatus:Present
                                                           nextPunchStatus:Present
                                                             sourceOfPunch:Mobile
                                                                actionType:PunchActionTypePunchIn
                                                             oefTypesArray:nil
                                                              lastSyncTime:NULL
                                                                   project:nil
                                                               auditHstory:nil
                                                                 breakType:nil
                                                                  location:nil
                                                                violations:@[]
                                                                 requestID:NULL
                                                                  activity:nil
                                                                  duration:dateComponentsA
                                                                    client:nil
                                                                   address:addressB
                                                                   userURI:userUriB
                                                                  imageURL:nil
                                                                      date:dateB
                                                                      task:nil
                                                                       uri:uriB
                                                      isTimeEntryAvailable:NO
                                                          syncedWithServer:YES
                                                            isMissingPunch:NO
                                                   previousPunchActionType:PunchActionTypeUnknown];
                
                auditHistory1 = nice_fake_for([AuditHistory class]);
                auditHistory1 stub_method(@selector(history)).and_return(@[@"someText"]);
                auditHistory1 stub_method(@selector(uri)).and_return(@"uriA");
                
                auditHistory2 = nice_fake_for([AuditHistory class]);
                auditHistory2 stub_method(@selector(history)).and_return(@[@"someText"]);
                auditHistory2 stub_method(@selector(uri)).and_return(@"uriB");
                
                auditHistoryRepository stub_method(@selector(fetchPunchLogs:)).with(@[@"uriA", @"uriB"]).and_return(auditHistoryDeferred.promise);
                
                firstImage = [[UIImage alloc] init];
                secondImage = [[UIImage alloc] init];
                
                punchPresenter stub_method(@selector(timeWithAmPmLabelTextForPunch:)).with(firstPunch).and_return(@"12:34 AM");
                punchPresenter stub_method(@selector(punchActionIconImageWithPunch:)).with(firstPunch).and_return(firstImage);
                
                punchPresenter stub_method(@selector(timeWithAmPmLabelTextForPunch:)).with(secondPunch).and_return(@"5:25 PM");
                punchPresenter stub_method(@selector(punchActionIconImageWithPunch:)).with(secondPunch).and_return(secondImage);
                
                punchPresenter stub_method(@selector(sourceOfPunchLabelTextWithPunch:)).with(secondPunch).and_return(@"via Mobile");
                punchPresenter stub_method(@selector(sourceOfPunchLabelTextWithPunch:)).with(firstPunch).and_return(@"via Mobile");
                
                punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:)).with(firstPunch).and_return(@"Clocked In");
                punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:)).with(secondPunch).and_return(@"Clocked In");
                
                punchPresenter stub_method(@selector(descriptionLabelForDayTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:)).with(firstPunch,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything).and_return([[NSAttributedString alloc]initWithString:@"Description Label text 1"]);
                punchPresenter stub_method(@selector(descriptionLabelForDayTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:)).with(secondPunch,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything).and_return([[NSAttributedString alloc]initWithString:@"Description Label text 2"]);
                
                durationStringPresenter stub_method(@selector(durationStringWithHours:minutes:)).and_return(@"0h:01m");
                
                subject stub_method(@selector(timeIsIn12HourFormat)).and_return(YES);
                
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                  serverDidFinishPunchPromise:nil
                                                     delegate:delegate
                                                      userURI:@"user-uri"
                                                     flowType:UserFlowContext
                                                      punches:@[firstPunch,secondPunch]
                                            timeLinePunchFlow:CardTimeLinePunchFlowContext];
                
                
                [subject view];
                [subject viewWillAppear:NO];
                [subject.timelineTableView layoutIfNeeded];
                
                [auditHistoryDeferred resolveWithValue:@[auditHistory1, auditHistory2]];
                
                firstCell = subject.timelineTableView.visibleCells[0];
                secondCell = subject.timelineTableView.visibleCells[1];
                thirdCell = subject.timelineTableView.visibleCells[2];
            });
            
            it(@"should have the correct number of rows", ^{
                [subject.timelineTableView.dataSource tableView:subject.timelineTableView numberOfRowsInSection:0] should equal(3);
            });
            
            it(@"should have correct cell", ^{
                secondCell should be_instance_of([MissingPunchCell class]);
                secondCell.punchType.text should equal(NSLocalizedString(@"Missing Punch", @""));
                secondCell.descendingLineView.hidden should be_falsy;
                secondCell.descendingLineView.backgroundColor should equal([UIColor greenColor]);
                secondCell.cellSeparator.hidden  should be_truthy;
            });
            
            it(@"should style the cells appropriately", ^{
                timeLineCellStylist should have_received(@selector(applyStyleToDayTimeLineCell:hidesDescendingLine:)).with(firstCell, NO);
            });
            
            it(@"should call fetchPunchLogs:", ^{
                auditHistoryRepository should have_received(@selector(fetchPunchLogs:)).with(@[@"uriA", @"uriB"]);
            });
            
            context(@"should display the data properly on table cells", ^{
                
                it(@"should show the info for the first punch on the tableview", ^{
                    firstCell.punchType.text should equal(@"Clocked In");
                    punchPresenter should have_received(@selector(timeWithAmPmLabelTextForPunch:));
                    firstCell.punchActualTime.text should equal(@"12:34 AM");
                    NSString *attributedText = [firstCell.metaDataLabel.attributedText string];
                    attributedText should equal(@"Description Label text 1");
                    firstCell.punchUserImageView.image should be_same_instance_as(firstImage);
                    firstCell.violationDetais.text should equal(@"");
                    firstCell.agentType.text should equal(@"via Mobile");
                    firstCell.address.text should equal(@"Calgary");
                    firstCell.auditHistory.text should equal(@"someText");
                    firstCell.duration.text should equal(@"0h:01m");
                });
                
                it(@"should show the info for the second punch on the tableview", ^{
                     thirdCell.punchType.text should equal(@"Clocked In");
                     punchPresenter should have_received(@selector(timeWithAmPmLabelTextForPunch:));
                     thirdCell.punchActualTime.text should equal(@"5:25 PM");
                     NSString *attributedText = [thirdCell.metaDataLabel.attributedText string];
                     attributedText should equal(@"Description Label text 2");
                     thirdCell.punchUserImageView.image should be_same_instance_as(secondImage);
                     thirdCell.violationDetais.text should equal(@"");
                     thirdCell.agentType.text should equal(@"via Mobile");
                     thirdCell.address.text should equal(@"Calgary");
                     thirdCell.auditHistory.text should equal(@"someText");
                     thirdCell.duration.text should equal(@"0h:01m");
                 });
            });
            
            it(@"should notify its delegate to update its height", ^{
                delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, Arguments::anything);
            });
            
            context(@"when the view appears again", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [subject viewWillAppear:YES];
                });
                
                it(@"should set its presentation height back to 0", ^{
                    delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, (CGFloat)0.0f);
                });
            });
        });
        
        describe(@"when previous punch is missing", ^{
            __block RemotePunch *firstPunch;
            __block AuditHistory *auditHistory1;
            __block KSDeferred *auditHistoryDeferred;
            __block NSString *addressA;
            __block NSString *uriA;
            __block NSString *userUriA;
            __block NSString *punchARequestId;
            __block NSURL *imageURL;
            __block NSDate *dateA;
            __block UIImage *firstImage;
            __block MissingPunchCell *firstCell;
            __block DayTimeLineCell *secondCell;
            beforeEach(^{
                auditHistoryDeferred = [[KSDeferred alloc] init];
                
                punchARequestId = [[NSUUID UUID] UUIDString];
                
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                imageURL = [NSURL URLWithString:@"http://example.org/fake"];
                
                addressA = @"Calgary";
                
                uriA = @"uriA";
                
                userUriA = @"user-uri";
            });
            
            beforeEach(^{
                NSDateComponents *dateComponentsA = [[NSDateComponents alloc] init];
                dateComponentsA.hour = 0;
                dateComponentsA.minute = 1;
                dateComponentsA.second = 0;
                
                firstImage = [[UIImage alloc] init];
                
                firstPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                   nonActionedValidations:0
                                                      previousPunchStatus:Missing
                                                          nextPunchStatus:Present
                                                            sourceOfPunch:Mobile
                                                               actionType:PunchActionTypePunchIn
                                                            oefTypesArray:nil
                                                             lastSyncTime:nil
                                                                  project:nil
                                                              auditHstory:nil
                                                                breakType:nil
                                                                 location:nil
                                                               violations:@[]
                                                                requestID:NULL
                                                                 activity:nil
                                                                 duration:dateComponentsA
                                                                   client:nil
                                                                  address:addressA
                                                                  userURI:userUriA
                                                                 imageURL:nil
                                                                     date:dateA
                                                                     task:nil
                                                                      uri:uriA
                                                     isTimeEntryAvailable:NO
                                                         syncedWithServer:YES
                                                           isMissingPunch:NO
                                                  previousPunchActionType:PunchActionTypeUnknown];
                
                
                auditHistory1 = nice_fake_for([AuditHistory class]);
                auditHistory1 stub_method(@selector(history)).and_return(@[@"someText"]);
                auditHistory1 stub_method(@selector(uri)).and_return(@"uriA");
                
                auditHistoryRepository stub_method(@selector(fetchPunchLogs:)).with(@[@"uriA"]).and_return(auditHistoryDeferred.promise);
                
                firstImage = [[UIImage alloc] init];
                
                punchPresenter stub_method(@selector(timeWithAmPmLabelTextForPunch:)).with(firstPunch).and_return(@"12:34 AM");
                punchPresenter stub_method(@selector(punchActionIconImageWithPunch:)).with(firstPunch).and_return(firstImage);
                
                punchPresenter stub_method(@selector(sourceOfPunchLabelTextWithPunch:)).with(firstPunch).and_return(@"via Mobile");
                
                punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:)).with(firstPunch).and_return(@"Clocked In");
                
                punchPresenter stub_method(@selector(descriptionLabelForDayTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:)).with(firstPunch,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything).and_return([[NSAttributedString alloc]initWithString:@"Description Label text 1"]);
                
                durationStringPresenter stub_method(@selector(durationStringWithHours:minutes:)).and_return(@"0h:01m");
                
                subject stub_method(@selector(timeIsIn12HourFormat)).and_return(YES);
                
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                  serverDidFinishPunchPromise:nil
                                                     delegate:delegate
                                                      userURI:@"user-uri"
                                                     flowType:UserFlowContext
                                                      punches:@[firstPunch]
                                            timeLinePunchFlow:CardTimeLinePunchFlowContext];
                
                
                [subject view];
                [subject viewWillAppear:NO];
                [subject.timelineTableView layoutIfNeeded];
                
                [auditHistoryDeferred resolveWithValue:@[auditHistory1]];
                
                firstCell = subject.timelineTableView.visibleCells[0];
                secondCell = subject.timelineTableView.visibleCells[1];
            });
            
            it(@"should have the correct number of rows", ^{
                [subject.timelineTableView.dataSource tableView:subject.timelineTableView numberOfRowsInSection:0] should equal(2);
            });
            
            it(@"should have correct cell", ^{
                firstCell should be_instance_of([MissingPunchCell class]);
                firstCell.punchType.text should equal(NSLocalizedString(@"Missing Punch", @""));
                firstCell.descendingLineView.hidden should be_falsy;
                firstCell.descendingLineView.backgroundColor should equal([UIColor greenColor]);
                firstCell.cellSeparator.hidden  should be_truthy;
            });
            
            it(@"should style the cells appropriately", ^{
                timeLineCellStylist should have_received(@selector(applyStyleToDayTimeLineCell:hidesDescendingLine:)).with(secondCell, NO);
            });
            
            it(@"should call fetchPunchLogs:", ^{
                auditHistoryRepository should have_received(@selector(fetchPunchLogs:)).with(@[@"uriA"]);
            });
            
            context(@"should display the data properly on table cells", ^{
                
                it(@"should show the info for the first punch on the tableview", ^{
                    secondCell.punchType.text should equal(@"Clocked In");
                    punchPresenter should have_received(@selector(timeWithAmPmLabelTextForPunch:));
                    secondCell.punchActualTime.text should equal(@"12:34 AM");
                    NSString *attributedText = [secondCell.metaDataLabel.attributedText string];
                    attributedText should equal(@"Description Label text 1");
                    secondCell.punchUserImageView.image should be_same_instance_as(firstImage);
                    secondCell.violationDetais.text should equal(@"");
                    secondCell.agentType.text should equal(@"via Mobile");
                    secondCell.address.text should equal(@"Calgary");
                    secondCell.auditHistory.text should equal(@"someText");
                    secondCell.duration.text should equal(@"0h:01m");
                });
            });
            
            it(@"should notify its delegate to update its height", ^{
                delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, Arguments::anything);
            });
            
            context(@"when the view appears again", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [subject viewWillAppear:YES];
                });
                
                it(@"should set its presentation height back to 0", ^{
                    delegate should have_received(@selector(timesheetDayTimeLineController:didUpdateHeight:)).with(subject, (CGFloat)0.0f);
                });
            });
        });

    });

    describe(@"when view loads show local cached punches", ^{
        __block RemotePunch *remotePunchA;
        __block RemotePunch *remotePunchB;
        __block id<TimesheetDayTimeLineControllerDelegate, CedarDouble> delegate;
        __block id <PunchChangeObserverDelegate> punchChangeObserverDelegate;
        __block NSDate *date;
        __block NSString *userURI;
        beforeEach(^{
            date = nice_fake_for([NSDate class]);
            punchChangeObserverDelegate = nice_fake_for(@protocol(PunchChangeObserverDelegate));
            delegate = nice_fake_for(@protocol(TimesheetDayTimeLineControllerDelegate));
            delegate stub_method(@selector(timesheetDayTimeLineControllerDidRequestDate:))
            .with(subject)
            .and_return(date);
            userURI = @"my-special-user-uri";
            punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);

            remotePunchA = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                 nonActionedValidations:0
                                                    previousPunchStatus:Ticking
                                                        nextPunchStatus:Ticking
                                                          sourceOfPunch:UnknownSourceOfPunch
                                                             actionType:PunchActionTypePunchIn
                                                          oefTypesArray:nil
                                                           lastSyncTime:NULL
                                                                project:NULL
                                                            auditHstory:nil
                                                              breakType:nil
                                                               location:nil
                                                             violations:nil
                                                              requestID:@"ABCD123"
                                                               activity:NULL
                                                               duration:nil
                                                                 client:NULL
                                                                address:nil
                                                                userURI:@"user:uri"
                                                               imageURL:nil
                                                                   date:[NSDate dateWithTimeIntervalSinceReferenceDate:1477098600]
                                                                   task:NULL
                                                                    uri:@"punch:uri"
                                                   isTimeEntryAvailable:NO
                                                       syncedWithServer:YES
                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];


            remotePunchB = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                 nonActionedValidations:0
                                                    previousPunchStatus:Ticking
                                                        nextPunchStatus:Ticking
                                                          sourceOfPunch:UnknownSourceOfPunch
                                                             actionType:PunchActionTypePunchIn
                                                          oefTypesArray:nil
                                                           lastSyncTime:NULL
                                                                project:NULL
                                                            auditHstory:nil
                                                              breakType:nil
                                                               location:nil
                                                             violations:nil
                                                              requestID:@"ABCD123456"
                                                               activity:NULL
                                                               duration:nil
                                                                 client:NULL
                                                                address:nil
                                                                userURI:@"user:uri"
                                                               imageURL:nil
                                                                   date:[NSDate dateWithTimeIntervalSinceReferenceDate:1477141800]
                                                                   task:NULL
                                                                    uri:@"punch:uri"
                                                   isTimeEntryAvailable:NO
                                                       syncedWithServer:YES
                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            timeLinePunchesStorage stub_method(@selector(allRemotePunchesForDay:userUri:)).with(date,@"user:uri").and_return(@[remotePunchA,remotePunchB]);

            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                              serverDidFinishPunchPromise:nil
                                                 delegate:delegate
                                                  userURI:@"user:uri"
                                                 flowType:UserFlowContext
                                                  punches:@[]
                                        timeLinePunchFlow:CardTimeLinePunchFlowContext];

            [subject view];
            [subject viewWillAppear:NO];
            [subject.timelineTableView layoutIfNeeded];

        });

        it(@"should have the correct number of rows", ^{
            [subject.timelineTableView numberOfRowsInSection:0] should equal(3);
        });

    });

    describe(@"when view loads show local cached punches With OEF values", ^{
        __block RemotePunch *remotePunchA;
        __block id<TimesheetDayTimeLineControllerDelegate, CedarDouble> delegate;
        __block id <PunchChangeObserverDelegate> punchChangeObserverDelegate;
        __block NSDate *date;
        __block NSString *userURI;
        __block DayTimeLineCell *cell1;
        __block OEFType *oefType1;
        __block OEFType *oefType2;
        __block OEFType *oefType3;
        __block NSMutableArray *oefTypesArray;
        beforeEach(^{
            date = nice_fake_for([NSDate class]);
            punchChangeObserverDelegate = nice_fake_for(@protocol(PunchChangeObserverDelegate));
            delegate = nice_fake_for(@protocol(TimesheetDayTimeLineControllerDelegate));
            delegate stub_method(@selector(timesheetDayTimeLineControllerDidRequestDate:))
            .with(subject)
            .and_return(date);
            userURI = @"my-special-user-uri";
            punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);

            oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"1230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

            oefTypesArray = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, nil];

            userURI = @"my-special-user-uri";
           

            Activity *activity1 = [[Activity alloc] initWithName:@"Perfromance Review1" uri:@"activity:uri1"];

            remotePunchA = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                 nonActionedValidations:0
                                                    previousPunchStatus:Ticking
                                                        nextPunchStatus:Ticking
                                                          sourceOfPunch:UnknownSourceOfPunch
                                                             actionType:PunchActionTypePunchIn
                                                          oefTypesArray:oefTypesArray
                                                           lastSyncTime:NULL
                                                                project:NULL
                                                            auditHstory:nil
                                                              breakType:nil
                                                               location:nil
                                                             violations:nil
                                                              requestID:@"ABCD123"
                                                               activity:activity1
                                                               duration:nil
                                                                 client:NULL
                                                                address:nil
                                                                userURI:@"user:uri"
                                                               imageURL:nil
                                                                   date:[NSDate dateWithTimeIntervalSinceReferenceDate:1477098600]
                                                                   task:NULL
                                                                    uri:@"punch:uri"
                                                   isTimeEntryAvailable:NO
                                                       syncedWithServer:YES
                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                              serverDidFinishPunchPromise:nil
                                                 delegate:delegate
                                                  userURI:userURI
                                                 flowType:SupervisorFlowContext
                                                  punches:@[remotePunchA]
                                        timeLinePunchFlow:CardTimeLinePunchFlowContext];


            punchPresenter stub_method(@selector(descriptionLabelForDayTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:)).with(remotePunchA,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything).and_return([[NSAttributedString alloc]initWithString:@"text 1:sample text, numeric 1:230.89, numeric 1:1230.89"]);

        
            [subject view];
            [subject viewWillAppear:NO];
            [subject.timelineTableView layoutIfNeeded];
            
            cell1 = [[subject.timelineTableView visibleCells] firstObject];
        });
        
        it(@"should have the correct number of rows", ^{
            [subject.timelineTableView numberOfRowsInSection:0] should equal(2);
        });

        it(@"should have called Punch Presenter descriptionLabelForTimelineCellTextWithPunch", ^{
            punchPresenter should have_received(@selector(descriptionLabelForDayTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:));

        });

        it(@"should have the Cell with correct Description label", ^{
            NSAttributedString *expectedString = [[NSAttributedString alloc] initWithString:@"text 1:sample text, numeric 1:230.89, numeric 1:1230.89"];
            cell1.metaDataLabel.attributedText should equal(expectedString);
        });

        it(@"should have the correct number of rows", ^{
            [[[subject.punches objectAtIndex:0] oefTypesArray] count] should equal(3);
        });
        
    });
    

});

SPEC_END
