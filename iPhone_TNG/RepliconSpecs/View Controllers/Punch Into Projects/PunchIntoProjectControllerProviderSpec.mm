#import <Cedar/Cedar.h>
#import "PunchIntoProjectControllerProvider.h"
#import "LocalPunch.h"
#import <KSDeferred/KSPromise.h>
#import "PunchInController.h"
#import "PunchOutController.h"
#import "OnBreakController.h"
#import "AddressControllerPresenterProvider.h"
#import "AddressControllerPresenter.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "InjectorProvider.h"
#import "ProjectPunchInController.h"
#import "ProjectPunchOutController.h"
#import "ProjectOnBreakController.h"
#import "ProjectCreatePunchCardController.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchIntoProjectControllerProviderSpec)

describe(@"PunchIntoProjectControllerProvider", ^{
    __block PunchIntoProjectControllerProvider *subject;

    __block ProjectPunchInController *punchInController;
    __block ProjectPunchOutController *punchOutController;
    __block ProjectOnBreakController *onBreakController;
    __block ProjectCreatePunchCardController *createPunchCardController;


    __block AddressControllerPresenterProvider *addressControllerPresenterProvider;
    __block AddressControllerPresenter *addressControllerPresenter;
    __block id<BSBinder, BSInjector> injector;

    beforeEach(^{
        injector = [InjectorProvider injector];

        createPunchCardController = [[ProjectCreatePunchCardController alloc]
                                                                       initWithChildControllerHelper:nil
                                                                                               theme:nil];

        punchInController = [[ProjectPunchInController alloc] initWithTimesheetButtonControllerPresenter:nil
                                                                        dayTimeSummaryControllerProvider:nil
                                                                                   childControllerHelper:nil
                                                                                     violationRepository:nil
                                                                                        workHoursStorage:nil
                                                                                        punchCardStorage:NULL
                                                                                            dateProvider:nil
                                                                                             userSession:nil
                                                                                                   theme:nil
                                                                                      notificationCenter:nil
                                                                                          oefTypeStorage:nil
                                                                                  userPermissionsStorage:nil
                                                                                                defaults:nil];
        punchOutController = [[ProjectPunchOutController alloc] initWithTimesheetButtonControllerPresenter:nil
                                                                               lastPunchLabelTextPresenter:nil
                                                                          dayTimeSummaryControllerProvider:nil
                                                                                   durationStringPresenter:nil
                                                                                     childControllerHelper:nil
                                                                                       breakTypeRepository:nil
                                                                                        durationCalculator:nil
                                                                                       violationRepository:nil
                                                                                         punchRulesStorage:nil
                                                                                          workHoursStorage:NULL
                                                                                            oefTypeStorage:NULL
                                                                                             buttonStylist:nil
                                                                                             timerProvider:nil
                                                                                              dateProvider:nil
                                                                                               userSession:nil
                                                                                                  defaults:nil
                                                                                                     theme:nil];

        onBreakController = [[ProjectOnBreakController alloc] initWithTimesheetButtonControllerPresenter:nil
                                                                             lastPunchLabelTextPresenter:nil
                                                                        dayTimeSummaryControllerProvider:nil
                                                                                 durationStringPresenter:nil
                                                                                   childControllerHelper:nil
                                                                                     violationRepository:nil
                                                                                      durationCalculator:nil
                                                                                        workHoursStorage:NULL
                                                                                           buttonStylist:nil
                                                                                           timerProvider:nil
                                                                                            dateProvider:nil
                                                                                             userSession:nil
                                                                                                defaults:nil
                                                                                                   theme:nil];




        addressControllerPresenter = nice_fake_for([AddressControllerPresenter class]);
        addressControllerPresenterProvider = nice_fake_for([AddressControllerPresenterProvider class]);
        addressControllerPresenterProvider stub_method(@selector(provideInstanceWith:)).and_return(addressControllerPresenter);

        [injector bind:[ProjectCreatePunchCardController class] toInstance:createPunchCardController];
        [injector bind:[ProjectPunchInController class] toInstance:punchInController];
        [injector bind:[AddressControllerPresenterProvider class] toInstance:addressControllerPresenterProvider];
        [injector bind:[ProjectPunchOutController class] toInstance:punchOutController];
        [injector bind:[ProjectOnBreakController class] toInstance:onBreakController];

        subject = [injector getInstance:[PunchIntoProjectControllerProvider class]];
    });

    describe(@"-punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:", ^{
        __block id<ProjectPunchInControllerDelegate, ProjectPunchOutControllerDelegate, ProjectOnBreakControllerDelegate> delegate;
        __block LocalPunch *punch;
        __block KSPromise *assembledPunchPromise;
        __block KSPromise *serverPunchPromise;
        __block KSPromise *punchesPromise;
        __block UIViewController *controller;

        beforeEach(^{
            delegate = nice_fake_for(@protocol(ProjectPunchInControllerDelegate), @protocol(ProjectPunchOutControllerDelegate), @protocol(ProjectOnBreakControllerDelegate));
            punch = nice_fake_for([LocalPunch class]);
            assembledPunchPromise = nice_fake_for([KSPromise class]);
            serverPunchPromise = nice_fake_for([KSPromise class]);
            punchesPromise = nice_fake_for([KSPromise class]);
        });

        UIViewController *(^doSubjectAction)(LocalPunch *, KSPromise *) = ^(LocalPunch *aPunch, KSPromise *serverDidFinishPunchPromise){
            return [subject punchControllerWithDelegate:delegate
                            serverDidFinishPunchPromise:serverDidFinishPunchPromise
                                  assembledPunchPromise:assembledPunchPromise
                                        punchCardObject:nil 
                                                  punch:aPunch
                                         punchesPromise:punchesPromise];
        };

        context(@"when there is no punch", ^{
            beforeEach(^{
                controller = doSubjectAction(nil, serverPunchPromise);
            });

            it(@"should return a correctly configured punch in controller", ^{
                punchInController.serverDidFinishPunchPromise should be_same_instance_as(serverPunchPromise);
                punchInController.delegate should be_same_instance_as(delegate);
            });

            it(@"should be a punch in controller", ^{
                controller should be_same_instance_as(punchInController);
            });
        });

        context(@"when there is a punch with action type PunchActionTypePunchOut", ^{
            beforeEach(^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);

                controller = doSubjectAction(punch, nil);
            });

            it(@"should return a correctly configured punch in controller", ^{
                punchInController.serverDidFinishPunchPromise should be_nil;
                punchInController.delegate should be_same_instance_as(delegate);
            });

            it(@"should be a punch in controller", ^{
                controller should be_same_instance_as(punchInController);
            });
        });

        context(@"when there is a punch with action type PunchActionTypeStartBreak", ^{
            beforeEach(^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);

                controller = doSubjectAction(punch, serverPunchPromise);
            });

            it(@"should create the address controller presenter with the local punch promise", ^{
                addressControllerPresenterProvider should have_received(@selector(provideInstanceWith:)).with(assembledPunchPromise);
            });

            it(@"should return an on break controller", ^{
                onBreakController.addressControllerPresenter should be_same_instance_as(addressControllerPresenter);
                onBreakController.serverDidFinishPunchPromise should be_same_instance_as(serverPunchPromise);
                onBreakController.delegate should be_same_instance_as(delegate);
                onBreakController.punch should be_same_instance_as(punch);
            });

            it(@"should return an on break controller", ^{
                controller should be_same_instance_as(onBreakController);
            });
        });

        context(@"when there is a punch with action type PunchActionTypePunchIn", ^{
            beforeEach(^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                punch stub_method(@selector(isTimeEntryAvailable)).and_return(YES);

                controller = doSubjectAction(punch, serverPunchPromise);
            });

            it(@"should return a correctly configured punch out controller", ^{
                PunchOutController *returnedPunchOutController = (PunchOutController *)controller;

                returnedPunchOutController should be_same_instance_as(punchOutController);

                [returnedPunchOutController delegate] should be_same_instance_as(delegate);
                [returnedPunchOutController punch] should be_same_instance_as(punch);
                [returnedPunchOutController serverDidFinishPunchPromise] should be_same_instance_as(serverPunchPromise);
                [returnedPunchOutController addressControllerPresenter] should be_same_instance_as(addressControllerPresenter);
            });
        });

        context(@"when there is a punch with action type PunchActionTypeTransfer", ^{
            beforeEach(^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypeTransfer);
                punch stub_method(@selector(isTimeEntryAvailable)).and_return(YES);

                controller = doSubjectAction(punch, serverPunchPromise);
            });

            it(@"should return a correctly configured punch out controller", ^{
                PunchOutController *returnedPunchOutController = (PunchOutController *)controller;

                returnedPunchOutController should be_same_instance_as(punchOutController);

                [returnedPunchOutController delegate] should be_same_instance_as(delegate);
                [returnedPunchOutController punch] should be_same_instance_as(punch);
                [returnedPunchOutController serverDidFinishPunchPromise] should be_same_instance_as(serverPunchPromise);
                [returnedPunchOutController addressControllerPresenter] should be_same_instance_as(addressControllerPresenter);
            });
        });

        context(@"when there is a unexpected punch state", ^{
            beforeEach(^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypeUnknown);

                controller = doSubjectAction(punch, serverPunchPromise);
            });

            it(@"should return a correctly configured punch in controller", ^{
                punchInController.serverDidFinishPunchPromise should be_same_instance_as(serverPunchPromise);
                punchInController.delegate should be_same_instance_as(delegate);
            });

            it(@"should return a punch in controller", ^{
                controller should be_same_instance_as(punchInController);
            });
        });

        context(@"when there should be no delay for showing the time summary when punching in", ^{
            beforeEach(^{
                controller = doSubjectAction(nil, nil);
            });

            it(@"should return a correctly configured punch in controller", ^{
                punchInController.serverDidFinishPunchPromise should be_nil;
                punchInController.delegate should be_same_instance_as(delegate);
            });
        });

        context(@"when there should be a delay for showing the time summary (until after the punch has finished) when punching in", ^{
            beforeEach(^{
                controller = doSubjectAction(nil, serverPunchPromise);
            });

            it(@"should return a correctly configured punch in controller", ^{
                punchInController.serverDidFinishPunchPromise should be_same_instance_as(serverPunchPromise);
                punchInController.delegate should be_same_instance_as(delegate);
            });
        });

        context(@"when there should be no delay for showing the time summary when punching out", ^{
            beforeEach(^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                punch stub_method(@selector(isTimeEntryAvailable)).and_return(YES);
                controller = doSubjectAction(punch, serverPunchPromise);
            });

            it(@"should return a correctly configured punch out controller", ^{
                PunchOutController *returnedPunchOutController = (PunchOutController *)controller;

                returnedPunchOutController should be_same_instance_as(punchOutController);

                [returnedPunchOutController delegate] should be_same_instance_as(delegate);
                [returnedPunchOutController punch] should be_same_instance_as(punch);
                [returnedPunchOutController serverDidFinishPunchPromise] should be_same_instance_as(serverPunchPromise);
                [returnedPunchOutController addressControllerPresenter] should be_same_instance_as(addressControllerPresenter);
            });
        });

        context(@"when there should be no delay for showing the time summary when punching out", ^{
            beforeEach(^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                punch stub_method(@selector(isTimeEntryAvailable)).and_return(NO);
                controller = doSubjectAction(punch, serverPunchPromise);
            });

            it(@"should return a correctly configured punch out controller", ^{
                PunchInController *returnedPunchInController = (PunchInController *)controller;

                returnedPunchInController should be_same_instance_as(punchInController);
                [returnedPunchInController delegate] should be_same_instance_as(delegate);
                [returnedPunchInController serverDidFinishPunchPromise] should be_same_instance_as(serverPunchPromise);
            });
        });

        context(@"when there should be a delay for showing the time summary (until after the punch has finished) when punching out", ^{
            beforeEach(^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                punch stub_method(@selector(isTimeEntryAvailable)).and_return(YES);
                controller = doSubjectAction(punch, serverPunchPromise);
            });

            it(@"should return a correctly configured punch out controller", ^{
                PunchOutController *returnedPunchOutController = (PunchOutController *)controller;

                returnedPunchOutController should be_same_instance_as(punchOutController);

                [returnedPunchOutController delegate] should be_same_instance_as(delegate);
                [returnedPunchOutController punch] should be_same_instance_as(punch);
                [returnedPunchOutController serverDidFinishPunchPromise] should be_same_instance_as(serverPunchPromise);
                [returnedPunchOutController addressControllerPresenter] should be_same_instance_as(addressControllerPresenter);
            });
        });

        context(@"when there should be no delay for showing the time summary when taking a break", ^{
            beforeEach(^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);
                controller = doSubjectAction(punch, serverPunchPromise);
            });

            it(@"should return an on break controller", ^{
                onBreakController.addressControllerPresenter should be_same_instance_as(addressControllerPresenter);
                onBreakController.serverDidFinishPunchPromise should be_same_instance_as(serverPunchPromise);
                onBreakController.delegate should be_same_instance_as(delegate);
                onBreakController.punch should be_same_instance_as(punch);
            });
        });

        context(@"when there should be a delay for showing the time summary (until after the punch has finished) when taking a break", ^{
            beforeEach(^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);
                controller = doSubjectAction(punch, serverPunchPromise);
            });
            
            it(@"should return an on break controller", ^{
                onBreakController.addressControllerPresenter should be_same_instance_as(addressControllerPresenter);
                onBreakController.serverDidFinishPunchPromise should be_same_instance_as(serverPunchPromise);
                onBreakController.delegate should be_same_instance_as(delegate);
                onBreakController.punch should be_same_instance_as(punch);
            });
        });
    });
});

SPEC_END

