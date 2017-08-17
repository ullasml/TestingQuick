#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "ProjectCreatePunchCardController.h"
#import "Theme.h"
#import "InjectorProvider.h"
#import "ChildControllerHelper.h"
#import "InjectorKeys.h"
#import "UIControl+Spec.h"
#import "PunchCardObject.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ProjectCreatePunchCardControllerSpec)

describe(@"ProjectCreatePunchCardController", ^{
    __block ProjectCreatePunchCardController *subject;
    __block id<ProjectCreatePunchCardControllerDelegate> delegate;
    __block ChildControllerHelper *childControllerHelper;
    __block id<Theme> theme;
    __block id<BSBinder, BSInjector> injector;
    
    beforeEach(^{
        injector = [InjectorProvider injector];

        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        delegate = nice_fake_for(@protocol(ProjectCreatePunchCardControllerDelegate));
        theme = nice_fake_for(@protocol(Theme));

        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        [injector bind:@protocol(Theme) toInstance:theme];

        subject = [injector getInstance:[ProjectCreatePunchCardController class]];
        
        [subject setupWithDelegate:delegate];
    });

    describe(@"As a <PunchCardControllerDelegate>", ^{
        context(@"projectCreatePunchCardController:didChooseToCreatePunchCardWithObject", ^{
            __block PunchCardObject *cardObject;
            __block ClientType *client;
            __block ProjectType *project;
            __block TaskType *task;
            beforeEach(^{
                
                client = [[ClientType alloc]initWithName:@"client-name"
                                                     uri:@"client-uri"];
                
                
                project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                              isTimeAllocationAllowed:NO
                                                                        projectPeriod:nil
                                                                           clientType:nil
                                                                                 name:@"project-name"
                                                                                  uri:@"project-uri"];
                
                task = [[TaskType alloc]initWithProjectUri:nil
                                                taskPeriod:nil
                                                      name:@"task-name"
                                                       uri:@"task-uri"];;
                
                cardObject = nice_fake_for([PunchCardObject class]);
                cardObject stub_method(@selector(clientType)).and_return(client);
                cardObject stub_method(@selector(projectType)).and_return(project);
                cardObject stub_method(@selector(taskType)).and_return(task);
                
                subject.view should_not be_nil;
                
                [subject punchCardController:nil didChooseToCreatePunchCardWithObject:cardObject];
            });
            
            it(@"should tell its delegate that the user wants to create punch card", ^{
                delegate should have_received(@selector(projectCreatePunchCardController:didChooseToCreatePunchCardWithObject:)).with(subject,Arguments::anything);
                
                cardObject.clientType should equal(client);
                cardObject.projectType should equal(project);
                cardObject.taskType should equal(task);
                
            });
        });
        
        context(@"-punchCardController:didUpdateHeight:", ^{
            beforeEach(^{
                subject.view should_not be_nil;
                
                [subject punchCardController:nil didUpdateHeight:150.0];
            });

            it(@"should update punch card height", ^{
                subject.punchCardHeightConstraint.constant should equal(150.0);
            });
        });
    });

    describe(@"the view hierarchy", ^{
        beforeEach(^{
            [subject view];
        });

        it(@"should add scroll view as the subview of the view", ^{
            [[subject.view subviews] count] should equal(1);
        });
    });
});

SPEC_END


