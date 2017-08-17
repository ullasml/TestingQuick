#import <Cedar/Cedar.h>
#import "PunchValidator.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "InjectorProvider.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "UserPermissionsStorage.h"
#import "Constants.h"
#import "ReporteePermissionsStorage.h"
#import "ClientType.h"
#import "Activity.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PunchValidatorSpec)

describe(@"PunchValidator", ^{
    __block PunchValidator *subject;
    __block id<BSBinder, BSInjector> injector;
    __block UserPermissionsStorage* userPermissionsStorage;
    __block ReporteePermissionsStorage *reporteePermissionStorage;
    
    beforeEach(^{
        injector = [InjectorProvider injector];

        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        [injector bind:[UserPermissionsStorage class] toInstance:userPermissionsStorage];

        reporteePermissionStorage = nice_fake_for([ReporteePermissionsStorage class]);
        [injector bind:[ReporteePermissionsStorage class] toInstance:reporteePermissionStorage];
        
        subject = [injector getInstance:[PunchValidator class]];
        spy_on(subject);
    });

    context(@"validate for valid project and task info for a user", ^{
        __block ProjectType *project;
        __block TaskType *task;

        beforeEach(^{
            project = nice_fake_for([ProjectType class]);
            project stub_method(@selector(name)).and_return(@"some:project");
            task = nice_fake_for([TaskType class]);
            task stub_method(@selector(name)).and_return(@"some:task");
        });

        it(@"No project access, ProjectTaskSelection not required", ^{
            userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
            userPermissionsStorage stub_method(@selector(isProjectTaskSelectionRequired)).and_return(NO);

            NSError *error = [subject validatePunchWithClientType:nil projectType:project taskType:task activityType:nil userUri:nil];
            error.description should be_nil;
        });

        it(@"Project access, ProjectTaskSelection is required", ^{
            userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
            userPermissionsStorage stub_method(@selector(isProjectTaskSelectionRequired)).and_return(YES);

             NSError *error = [subject validatePunchWithClientType:nil projectType:project taskType:task activityType:nil userUri:nil];
             error.description should be_nil;
        });

        it(@"Project access without any name, ProjectTaskSelection is required", ^{
            userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
            userPermissionsStorage stub_method(@selector(isProjectTaskSelectionRequired)).and_return(YES);

            NSError *error = [subject validatePunchWithClientType:nil projectType:nice_fake_for([ProjectType class]) taskType:task activityType:nil userUri:nil];
            error.localizedDescription should equal(RPLocalizedString(InvalidProjectSelectedError,nil));
        });

        it(@"Project access, ProjectTaskSelection not required", ^{
            userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
            userPermissionsStorage stub_method(@selector(isProjectTaskSelectionRequired)).and_return(NO);

            NSError *error = [subject validatePunchWithClientType:nil projectType:project taskType:task activityType:nil userUri:nil];
             error.localizedDescription should be_nil;
        });

        it(@"Project access, ProjectTaskSelection is required, no project selected, no task selected", ^{
            userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
            userPermissionsStorage stub_method(@selector(isProjectTaskSelectionRequired)).and_return(YES);

            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nil activityType:nil userUri:nil];
             error.localizedDescription should equal(RPLocalizedString(InvalidProjectSelectedError,nil));
        });

        it(@"Project access, ProjectTaskSelection is required, project selected without any project name, no task selected", ^{
            userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
            userPermissionsStorage stub_method(@selector(isProjectTaskSelectionRequired)).and_return(YES);

            NSError *error = [subject validatePunchWithClientType:nil projectType:nice_fake_for([ProjectType class]) taskType:nil activityType:nil userUri:nil];
            error.localizedDescription should equal(RPLocalizedString(InvalidProjectSelectedError,nil));
        });

        it(@"Project access, ProjectTaskSelection is required, no project selected, task selected", ^{
            userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
            userPermissionsStorage stub_method(@selector(isProjectTaskSelectionRequired)).and_return(YES);

            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:task activityType:nil userUri:nil];
             error.localizedDescription should equal(RPLocalizedString(InvalidProjectSelectedError,nil));
        });

        it(@"Project access, ProjectTaskSelection is required, no project selected, task selected without any name", ^{
            userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
            userPermissionsStorage stub_method(@selector(isProjectTaskSelectionRequired)).and_return(YES);

            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nice_fake_for([TaskType class]) activityType:nil userUri:nil];
            error.localizedDescription should equal(RPLocalizedString(InvalidProjectSelectedError,nil));
        });

        it(@"Project access, ProjectTaskSelection is required, project selected, no task selected", ^{
            userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
            userPermissionsStorage stub_method(@selector(isProjectTaskSelectionRequired)).and_return(YES);

            NSError *error = [subject validatePunchWithClientType:nil projectType:project taskType:nil activityType:nil userUri:nil];
             error.localizedDescription should equal(RPLocalizedString(InvalidTaskSelectedError,nil));
        });

        it(@"Project access, ProjectTaskSelection is required, project selected, task selected without any task name", ^{
            userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
            userPermissionsStorage stub_method(@selector(isProjectTaskSelectionRequired)).and_return(YES);

            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nice_fake_for([TaskType class]) activityType:nil userUri:nil];
            error.localizedDescription should equal(RPLocalizedString(InvalidProjectSelectedError,nil));
        });

    });
    
    context(@"validate for valid project and task for reportee", ^{
        __block ProjectType *project;
        __block TaskType *task;
        
        beforeEach(^{
            project = nice_fake_for([ProjectType class]);
            project stub_method(@selector(name)).and_return(@"some:project");
            task = nice_fake_for([TaskType class]);
            task stub_method(@selector(name)).and_return(@"some:task");
        });
        
        it(@"Project is not nil and task not nil, ProjectTaskSelection not required", ^{
            reporteePermissionStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"some-uri").and_return(NO);
            reporteePermissionStorage stub_method(@selector(isReporteeProjectTaskSelectionRequired:)).and_return(NO);
            
            NSError *error = [subject validatePunchWithClientType:nil projectType:project taskType:task activityType:nil userUri:@"some-uri"];
            
             error.localizedDescription should be_nil;
        });
        
        it(@"When task is nil and has project", ^{
            reporteePermissionStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"some-uri").and_return(YES);
            reporteePermissionStorage stub_method(@selector(isReporteeProjectTaskSelectionRequired:)).and_return(YES);
            
            NSError *error = [subject validatePunchWithClientType:nil projectType:project taskType:nil activityType:nil userUri:@"some-uri"];
             error.localizedDescription should equal(RPLocalizedString(InvalidTaskSelectedError,nil));
        });

        it(@"When task is nil and has project without any name", ^{
            reporteePermissionStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"some-uri").and_return(YES);
            reporteePermissionStorage stub_method(@selector(isReporteeProjectTaskSelectionRequired:)).and_return(YES);

            NSError *error = [subject validatePunchWithClientType:nil projectType:nice_fake_for([ProjectType class]) taskType:nil activityType:nil userUri:@"some-uri"];
            error.localizedDescription should equal(RPLocalizedString(InvalidProjectSelectedError,nil));
        });
        
        it(@"when project is nil, and has task", ^{
            reporteePermissionStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"some-uri").and_return(YES);
            reporteePermissionStorage stub_method(@selector(isReporteeProjectTaskSelectionRequired:)).and_return(YES);
            
            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:task activityType:nil userUri:@"some-uri"];
             error.localizedDescription should equal(RPLocalizedString(InvalidProjectSelectedError,nil));
        });

        it(@"when project is nil, and has task without any name", ^{
            reporteePermissionStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"some-uri").and_return(YES);
            reporteePermissionStorage stub_method(@selector(isReporteeProjectTaskSelectionRequired:)).and_return(YES);

            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nice_fake_for([TaskType class]) activityType:nil userUri:@"some-uri"];
            error.localizedDescription should equal(RPLocalizedString(InvalidProjectSelectedError,nil));
        });
        
        it(@"when punch has project, and has task and ProjectTaskSelection not required", ^{
            reporteePermissionStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"some-uri").and_return(YES);
            reporteePermissionStorage stub_method(@selector(isReporteeProjectTaskSelectionRequired:)).and_return(NO);
            
            NSError *error = [subject validatePunchWithClientType:nil projectType:project taskType:task activityType:nil userUri:@"some-uri"];
             error.localizedDescription should be_nil;
        });

        it(@"when punch has project without any name, and has task without any name and ProjectTaskSelection not required", ^{
            reporteePermissionStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"some-uri").and_return(YES);
            reporteePermissionStorage stub_method(@selector(isReporteeProjectTaskSelectionRequired:)).and_return(NO);

            NSError *error = [subject validatePunchWithClientType:nil projectType:nice_fake_for([ProjectType class]) taskType:nice_fake_for([TaskType class]) activityType:nil userUri:@"some-uri"];
           error.localizedDescription should be_nil;
        });
    });
    
    context(@"validate for valid client, project and task info for a user", ^{
        __block ProjectType *project;
        __block TaskType *task;
        __block ClientType *client;
        beforeEach(^{
            client = nice_fake_for([ClientType class]);
            client stub_method(@selector(name)).and_return(@"some:client");
            project = nice_fake_for([ProjectType class]);
            project stub_method(@selector(name)).and_return(@"some:project");
            task = nice_fake_for([TaskType class]);
            task stub_method(@selector(name)).and_return(@"some:task");
        });
        
        
        context(@"when user has client access", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
            });
            
            it(@"no client, no project and no task ", ^{
                NSError *error = [subject validatePunchWithClientType:nil
                                                          ProjectType:nil
                                                             taskType:nil];
                error.description should_not be_nil;
                error.localizedDescription should equal(RPLocalizedString(clientProjectTaskSelectionErrorMsg,nil));
            });
            
            it(@"client, project and task values are there ", ^{
                NSError *error = [subject validatePunchWithClientType:client
                                                          ProjectType:project
                                                             taskType:task];
                error.description should be_nil;
            });

            it(@"client without name, project and task values are there ", ^{
                NSError *error = [subject validatePunchWithClientType:nice_fake_for([ClientType class])
                                                          ProjectType:project
                                                             taskType:task];
                error.description should be_nil;
            });

            it(@"client,project and task values are there without name", ^{
                NSError *error = [subject validatePunchWithClientType:nice_fake_for([ClientType class])
                                                          ProjectType:nice_fake_for([ProjectType class])
                                                             taskType:nice_fake_for([TaskType class])];
                error.localizedDescription should equal(RPLocalizedString(clientProjectTaskSelectionErrorMsg,nil));
            });

        });
        
        
        it(@"No project but task value is there", ^{
            NSError *error = [subject validatePunchWithClientType:nil
                                                      ProjectType:nil
                                                         taskType:task];
            error.description should_not be_nil;
            error.localizedDescription should equal(RPLocalizedString(InvalidProjectSelectedError,nil));
        });

        it(@"No project but task value is there without any name", ^{
            NSError *error = [subject validatePunchWithClientType:nil
                                                      ProjectType:nil
                                                         taskType:nice_fake_for([TaskType class])];
            error.description should_not be_nil;
            error.localizedDescription should equal(RPLocalizedString(InvalidProjectSelectedError,nil));
        });
        
        it(@"project and task values are there", ^{
            NSError *error = [subject validatePunchWithClientType:nil
                                                      ProjectType:project
                                                         taskType:task];
            error.description should be_nil;
        });

        it(@"project and task values are there but without name", ^{
            NSError *error = [subject validatePunchWithClientType:nil
                                                      ProjectType:nice_fake_for([ProjectType class])
                                                         taskType:nice_fake_for([TaskType class])];
            error.localizedDescription should equal(RPLocalizedString(InvalidProjectSelectedError,nil));
        });

        
        context(@"ProjectTaskSelection is required", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(isProjectTaskSelectionRequired)).and_return(YES);
            });
            it(@"client is there but no project and no task values", ^{
                NSError *error = [subject validatePunchWithClientType:client
                                                          ProjectType:nil
                                                             taskType:nil];
                error.description should_not be_nil;
                error.localizedDescription should equal(RPLocalizedString(projectAndTaskSelectionErrorMsg,nil));
            });

            it(@"client is there without any name but no project and no task values", ^{
                NSError *error = [subject validatePunchWithClientType:nice_fake_for([ClientType class])
                                                          ProjectType:nil
                                                             taskType:nil];
                error.description should_not be_nil;
                error.localizedDescription should equal(RPLocalizedString(projectAndTaskSelectionErrorMsg,nil));
            });
            
            it(@"no client, no project and no task values", ^{
                NSError *error = [subject validatePunchWithClientType:nil
                                                          ProjectType:nil
                                                             taskType:nil];
                error.description should_not be_nil;
                error.localizedDescription should equal(RPLocalizedString(projectAndTaskSelectionErrorMsg,nil));
            });
            
            it(@"no client but project and task values are present", ^{
                NSError *error = [subject validatePunchWithClientType:nil
                                                          ProjectType:project
                                                             taskType:task];
                error.description should be_nil;
            });

            it(@"no client but project and task values are present without any name", ^{
                NSError *error = [subject validatePunchWithClientType:nil
                                                          ProjectType:nice_fake_for([ProjectType class])
                                                             taskType:nice_fake_for([TaskType class])];
                error.localizedDescription should equal(RPLocalizedString(projectAndTaskSelectionErrorMsg,nil));
            });

            it(@"Project access, ProjectTaskSelection is required, project selected, no task selected", ^{

                NSError *error = [subject validatePunchWithClientType:nil ProjectType:project taskType:nil];
                error.localizedDescription should equal(RPLocalizedString(InvalidTaskSelectedError,nil));
            });

            it(@"Project access, ProjectTaskSelection is required, project selected without any name, no task selected", ^{

                NSError *error = [subject validatePunchWithClientType:nil ProjectType:nice_fake_for([ProjectType class]) taskType:nil];
                error.localizedDescription should equal(RPLocalizedString(projectAndTaskSelectionErrorMsg,nil));
            });
        });
        
        context(@"ProjectTaskSelection is not required", ^{
            it(@"client is there but no project and no task values", ^{
                NSError *error = [subject validatePunchWithClientType:client
                                                          ProjectType:nil
                                                             taskType:nil];
                error.description should_not be_nil;
                error.localizedDescription should equal(RPLocalizedString(InvalidProjectSelectedError,nil));
            });

            it(@"client is there without any name but no project and no task values", ^{
                NSError *error = [subject validatePunchWithClientType:nice_fake_for([ClientType class])
                                                          ProjectType:nil
                                                             taskType:nil];
                error.description should_not be_nil;
                error.localizedDescription should equal(RPLocalizedString(InvalidProjectSelectedError,nil));
            });
            
            it(@"no client, no project and no task values", ^{
                NSError *error = [subject validatePunchWithClientType:nil
                                                          ProjectType:nil
                                                             taskType:nil];
                error.description should_not be_nil;
                error.localizedDescription should equal(RPLocalizedString(InvalidProjectSelectedError,nil));
            });
            
            it(@"no client but project and task values are present", ^{
                NSError *error = [subject validatePunchWithClientType:nil
                                                          ProjectType:project
                                                             taskType:task];
                error.description should be_nil;
            });

            it(@"no client but project and task values are present without any name", ^{
                NSError *error = [subject validatePunchWithClientType:nil
                                                          ProjectType:nice_fake_for([ProjectType class])
                                                             taskType:nice_fake_for([TaskType class])];
                error.localizedDescription should equal(RPLocalizedString(InvalidProjectSelectedError,nil));
            });
        });
        
    context(@"Validate for valid Activity info for User", ^{
        __block Activity *activity;
        beforeEach(^{
            activity = nice_fake_for([Activity class]);
            activity stub_method(@selector(name)).and_return(@"some:activity");

        });
        
        it(@"Has Activity access and activitySelectionRequired is optional and activity object is not nil", ^{
            userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
            userPermissionsStorage stub_method(@selector(isActivitySelectionRequired)).and_return(NO);
            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nil activityType:activity userUri:nil];
            error.localizedDescription should be_nil;
        });

        it(@"Has Activity access and activitySelectionRequired is optional and activity object is there without any name", ^{
            userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
            userPermissionsStorage stub_method(@selector(isActivitySelectionRequired)).and_return(NO);
            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nil activityType:nice_fake_for([Activity class]) userUri:nil];
             error.localizedDescription should be_nil;
        });
        
        it(@"Has Activity access and activitySelectionRequired is optional and activity object is nil", ^{
            userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
            userPermissionsStorage stub_method(@selector(isActivitySelectionRequired)).and_return(NO);
            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nil activityType:nil userUri:nil];
            error.localizedDescription should be_nil;
        });
        
        it(@"Has Activity access and activitySelectionRequired is required and activity object is nil", ^{
            userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
            userPermissionsStorage stub_method(@selector(isActivitySelectionRequired)).and_return(YES);
            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nil activityType:nil userUri:nil];
            error.localizedDescription should equal(RPLocalizedString(InvalidActivitySelectedError, nil));
        });
        
        it(@"Has Activity access and activitySelectionRequired is required and activity object is not nil", ^{
            userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
            userPermissionsStorage stub_method(@selector(isActivitySelectionRequired)).and_return(YES);
            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nil activityType:activity userUri:nil];
            error.localizedDescription should be_nil;
        });
        
        it(@"Has no Activity access and activity object is nil", ^{
            userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
            userPermissionsStorage stub_method(@selector(isActivitySelectionRequired)).and_return(YES);
            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nil activityType:nil userUri:nil];
            error.localizedDescription should be_nil;
        });
        
        it(@"Has no Activity access and activity object is not nil", ^{
            userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
            userPermissionsStorage stub_method(@selector(isActivitySelectionRequired)).and_return(YES);
            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nil activityType:activity userUri:nil];
            error.localizedDescription should be_nil;
        });

        it(@"Has no Activity access and activity object is present without any name", ^{
            userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
            userPermissionsStorage stub_method(@selector(isActivitySelectionRequired)).and_return(YES);
            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nil activityType:nice_fake_for([Activity class]) userUri:nil];
            error.localizedDescription should be_nil;
        });
        
    });
    
    context(@"Validate for valid Activity info for reportee (Supervisor flow context)", ^{
        __block Activity *activity;
        __block NSString *userURI;
        
        beforeEach(^{
            activity = nice_fake_for([Activity class]);
            activity stub_method(@selector(name)).and_return(@"some:activity");
            userURI = @"some-uri";
        });
        
        it(@"Has Activity access and activitySelectionRequired is optional and activity object is not nil", ^{
            reporteePermissionStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(userURI).and_return(YES);
            reporteePermissionStorage stub_method(@selector(isReporteeActivitySelectionRequired:)).and_return(NO);
            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nil activityType:activity userUri:userURI];
            error.localizedDescription should be_nil;
        });

        it(@"Has Activity access and activitySelectionRequired is optional and activity object present without any name", ^{
            reporteePermissionStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(userURI).and_return(YES);
            reporteePermissionStorage stub_method(@selector(isReporteeActivitySelectionRequired:)).and_return(NO);
            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nil activityType:nice_fake_for([Activity class]) userUri:userURI];
             error.localizedDescription should be_nil;
        });
        
        it(@"Has Activity access and activitySelectionRequired is optional and activity object is nil", ^{
            reporteePermissionStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(userURI).and_return(YES);
            reporteePermissionStorage stub_method(@selector(isReporteeActivitySelectionRequired:)).and_return(NO);
            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nil activityType:nil userUri:userURI];
            error.localizedDescription should be_nil;
        });
        
        it(@"Has Activity access and activitySelectionRequired is required and activity object is nil", ^{
            reporteePermissionStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(userURI).and_return(YES);
            reporteePermissionStorage stub_method(@selector(isReporteeActivitySelectionRequired:)).and_return(YES);
            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nil activityType:nil userUri:userURI];
            error.localizedDescription should equal(RPLocalizedString(InvalidActivitySelectedError, nil));
        });
        
        it(@"Has Activity access and activitySelectionRequired is required and activity object is not nil", ^{
            reporteePermissionStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(userURI).and_return(YES);
            reporteePermissionStorage stub_method(@selector(isReporteeActivitySelectionRequired:)).and_return(YES);
            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nil activityType:activity userUri:userURI];
            error.localizedDescription should be_nil;
        });

        it(@"Has Activity access and activitySelectionRequired is required and activity object is present without any name", ^{
            reporteePermissionStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(userURI).and_return(YES);
            reporteePermissionStorage stub_method(@selector(isReporteeActivitySelectionRequired:)).and_return(YES);
            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nil activityType:nice_fake_for([Activity class]) userUri:userURI];
            error.localizedDescription should equal(RPLocalizedString(InvalidActivitySelectedError, nil));
        });
        
        it(@"Has no Activity access and activity object is nil", ^{
            reporteePermissionStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(userURI).and_return(NO);
            reporteePermissionStorage stub_method(@selector(isReporteeActivitySelectionRequired:)).and_return(YES);
            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nil activityType:nil userUri:userURI];
            error.localizedDescription should be_nil;
        });
        
        it(@"Has no Activity access and activity object is not nil", ^{
            reporteePermissionStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(userURI).and_return(NO);
            reporteePermissionStorage stub_method(@selector(isReporteeActivitySelectionRequired:)).and_return(YES);
            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nil activityType:activity userUri:userURI];
            error.localizedDescription should be_nil;
        });

        it(@"Has no Activity access and activity object is present without name", ^{
            reporteePermissionStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(userURI).and_return(NO);
            reporteePermissionStorage stub_method(@selector(isReporteeActivitySelectionRequired:)).and_return(YES);
            NSError *error = [subject validatePunchWithClientType:nil projectType:nil taskType:nil activityType:nice_fake_for([Activity class]) userUri:userURI];
            error.localizedDescription should be_nil;
        });
    });
});
});

SPEC_END
