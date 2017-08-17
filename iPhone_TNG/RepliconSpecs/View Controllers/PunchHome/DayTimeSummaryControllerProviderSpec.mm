#import <Cedar/Cedar.h>
#import "DayTimeSummaryControllerProvider.h"
#import "TimeSummaryPresenter.h"
#import "DelayedTimeSummaryFetcher.h"
#import <KSDeferred/KSDeferred.h>
#import "WorkHoursDeferred.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "InjectorKeys.h"
#import "DayTimeSummaryController.h"
#import "TimeSummaryRepository.h"

#import "UserPermissionsStorage.h"
using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(DayTimeSummaryControllerProviderSpec)

describe(@"DayTimeSummaryControllerProvider", ^{
    __block DayTimeSummaryControllerProvider *subject;
    __block id<Theme> theme;
    __block TimeSummaryPresenter *timeSummaryPresenter;
    __block DayTimeSummaryController *dayTimeSummaryController;
    __block id <BSBinder,BSInjector> injector;
    __block id <WorkHours> placeHolderWorkHours;
    __block id <DayTimeSummaryUpdateDelegate> delegate;
    __block TimeSummaryRepository *timeSummaryRepository;
    __block KSDeferred *repositoryDeferred;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block id<UserSession> userSession;
    
    beforeEach(^{
        injector = [InjectorProvider injector];
        delegate = nice_fake_for(@protocol(DayTimeSummaryUpdateDelegate));
        placeHolderWorkHours = nice_fake_for(@protocol(WorkHours));
        placeHolderWorkHours stub_method(@selector(isScheduledDay)).and_return(YES);
        theme = nice_fake_for(@protocol(Theme));
        timeSummaryPresenter = nice_fake_for([TimeSummaryPresenter class]);

        [injector bind:[TimeSummaryPresenter class] toInstance:timeSummaryPresenter];
        [injector bind:@protocol(Theme) toInstance:theme];
        
        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        [injector bind:[UserPermissionsStorage class] toInstance:userPermissionsStorage];
        
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
        userPermissionsStorage stub_method(@selector(userSession)).and_return(userSession);

        timeSummaryRepository = nice_fake_for([TimeSummaryRepository class]);
        
        repositoryDeferred = [[KSDeferred alloc] init];
        timeSummaryRepository stub_method(@selector(timeSummaryForToday)).and_return(repositoryDeferred.promise);

        [injector bind:[TimeSummaryRepository class] toInstance:timeSummaryRepository];

        dayTimeSummaryController = [[DayTimeSummaryController alloc] initWithWorkHoursPresenterProvider:timeSummaryPresenter theme:theme todaysDateControllerProvider:nil childControllerHelper:nil];
        [injector bind:[DayTimeSummaryController class] toInstance:dayTimeSummaryController];
        
        

        subject = [injector getInstance:[DayTimeSummaryControllerProvider class]];
    });

    describe(@"providing an instance with the server did finish punch promise", ^{

        context(@"when there is a promise", ^{
            __block KSDeferred *serverDidFinishPunchDeferred;
            __block DayTimeSummaryController *expectedWorkHoursController;


            beforeEach(^{
                serverDidFinishPunchDeferred = [[KSDeferred alloc] init];
                expectedWorkHoursController = [subject provideInstanceWithPromise:serverDidFinishPunchDeferred.promise
                                                             placeholderWorkHours:placeHolderWorkHours
                                                                         delegate:delegate];

            });

            it(@"should be the correct type", ^{
                expectedWorkHoursController should be_instance_of([DayTimeSummaryController class]);
            });



            it(@"should resolve the dependencies correctly", ^{
                expectedWorkHoursController.timeSummaryPresenter should be_same_instance_as(timeSummaryPresenter);
                expectedWorkHoursController.theme should be_same_instance_as(theme);
                expectedWorkHoursController.delegate should be_same_instance_as(delegate);
                expectedWorkHoursController.isScheduledDay should be_truthy;
                expectedWorkHoursController.todaysDateContainerHeight should equal(CGFloat(44.0f));
            });

            context(@"when the server did finish punch deferred is resolved", ^{
                beforeEach(^{
                    [serverDidFinishPunchDeferred resolveWithValue:(id)[NSNull null]];
                    [repositoryDeferred resolveWithValue:@123];
                });

                it(@"should setup WorkHoursController correctly", ^{
                    expectedWorkHoursController.workHours should be_same_instance_as(placeHolderWorkHours);
                });

                it(@"should provide a value to the promise passed into the controller", ^{
                    expectedWorkHoursController.workHoursPromise.value should equal(@123);
                });
            });
            
            context(@"before the server did finish punch deferred is resolved", ^{
                it(@"should not provide a value to the promise passed into the controller", ^{
                    expectedWorkHoursController.workHoursPromise.value should be_nil;
                });
            });
            
            context(@"after the server did finish punch deferred is resolved, but before the repository deferred is resolved", ^{
                it(@"should not provide a value to the promise passed into the controller", ^{
                    expectedWorkHoursController.workHoursPromise.value should be_nil;
                });
            });

        });

        context(@"when there is no server did finish punch promise", ^{
            __block DayTimeSummaryController *expectedWorkHoursController;
            beforeEach(^{
                expectedWorkHoursController = [subject provideInstanceWithPromise:nil
                                                             placeholderWorkHours:placeHolderWorkHours
                                                                         delegate:delegate];
            });

            it(@"should be the correct type", ^{
                expectedWorkHoursController should be_instance_of([DayTimeSummaryController class]);
            });

            it(@"should setup WorkHoursController correctly", ^{
                expectedWorkHoursController.workHours should be_same_instance_as(placeHolderWorkHours);
                expectedWorkHoursController.workHoursPromise should be_same_instance_as(repositoryDeferred.promise);
            });

            it(@"should resolve the dependencies correctly", ^{
                expectedWorkHoursController.timeSummaryPresenter should be_same_instance_as(timeSummaryPresenter);
                expectedWorkHoursController.theme should be_same_instance_as(theme);
                expectedWorkHoursController.delegate should be_same_instance_as(delegate);
                expectedWorkHoursController.isScheduledDay should be_truthy;
                expectedWorkHoursController.todaysDateContainerHeight should equal(CGFloat(44.0f));
            });
        });
    });
});

SPEC_END
