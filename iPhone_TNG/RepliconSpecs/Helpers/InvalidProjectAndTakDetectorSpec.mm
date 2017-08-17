#import <Cedar/Cedar.h>
#import "InvalidProjectAndTakDetector.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "Constants.h"
#import "TimeLinePunchesStorage.h"
#import "PunchCardStorage.h"
#import "RemotePunch.h"
#import "BreakType.h"
#import "LocalPunch.h"
#import "ProjectType.h"
#import "ClientType.h"
#import "TaskType.h"
#import "OEFType.h"
#import "PunchCardObject.h"
#import "Constants.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(InvalidProjectAndTakDetectorSpec)

describe(@"InvalidProjectAndTakDetector", ^{
    __block InvalidProjectAndTakDetector *subject;
    __block TimeLinePunchesStorage *timeLinePunchesStorage;
    __block PunchCardStorage *punchCardStorage;
    __block id<BSInjector, BSBinder> injector;
    
    beforeEach(^{
        injector = [InjectorProvider injector];
        
        timeLinePunchesStorage =  nice_fake_for([TimeLinePunchesStorage class]);
        [injector bind:[TimeLinePunchesStorage class] toInstance:timeLinePunchesStorage];
        
        punchCardStorage =  nice_fake_for([PunchCardStorage class]);
        [injector bind:[PunchCardStorage class] toInstance:punchCardStorage];
        
        subject = [injector getInstance:[InvalidProjectAndTakDetector class]];
    });
    
    describe(@"when the punch is inavlid ", ^{
        
        context(@"with project/task ", ^{
            context(@"when punchcard information used by previous punches", ^{
                __block LocalPunch *punchToPersist;
                beforeEach(^{
                    
                    UIImage *image = [UIImage imageNamed:@"icon_comments_blue"];
                    
                    BreakType *breakType = [[BreakType alloc] initWithName:@"My Special Name" uri:@"My Special URI"];
                    
                    CLLocation *location = [[CLLocation alloc] initWithLatitude:12 longitude:34];
                    
                    ClientType *clientType = nice_fake_for([ClientType class]);
                    
                    ProjectType *projectType = nice_fake_for([ProjectType class]);
                    
                    TaskType *taskType = nice_fake_for([TaskType class]);
                    
                    clientType stub_method(@selector(uri)).and_return(@"some-uri");
                    projectType stub_method(@selector(uri)).and_return(@"some-uri");
                    taskType stub_method(@selector(uri)).and_return(@"some-uri");
                    
                    OEFType *oefType1 = nice_fake_for([OEFType class]);
                    OEFType *oefType2 = nice_fake_for([OEFType class]);
                    
                    punchToPersist= [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakType location:location project:projectType requestID:NULL activity:nil client:clientType oefTypes:@[oefType1, oefType2] address:@"My Special Address" userURI:@"My:Special:User" image:image task:taskType date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
                });
                
                beforeEach(^{
                    RemotePunch *remotePunchA = [[RemotePunch alloc] initWithPunchSyncStatus:punchToPersist.punchSyncStatus
                                                                      nonActionedValidations:0
                                                                         previousPunchStatus:Unknown
                                                                             nextPunchStatus:Unknown
                                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                                  actionType:punchToPersist.actionType
                                                                               oefTypesArray:punchToPersist.oefTypesArray
                                                                                lastSyncTime:punchToPersist.lastSyncTime
                                                                                     project:punchToPersist.project
                                                                                 auditHstory:nil
                                                                                   breakType:punchToPersist.breakType
                                                                                    location:punchToPersist.location
                                                                                  violations:nil
                                                                                   requestID:punchToPersist.requestID
                                                                                    activity:punchToPersist.activity
                                                                                    duration:nil
                                                                                      client:punchToPersist.client
                                                                                     address:punchToPersist.address
                                                                                     userURI:punchToPersist.userURI
                                                                                    imageURL:nil
                                                                                        date:punchToPersist.date
                                                                                        task:punchToPersist.task
                                                                                         uri:nil
                                                                        isTimeEntryAvailable:YES
                                                                            syncedWithServer:YES
                                                                              isMissingPunch:NO
                                                                     previousPunchActionType:PunchActionTypeUnknown];
                    
                    TaskType *task = [[TaskType alloc] initWithProjectUri:@"project-uri" taskPeriod:nil name:@"task-name" uri:@"task-uri"];
                    
                    RemotePunch *remotePunchB = [[RemotePunch alloc] initWithPunchSyncStatus:punchToPersist.punchSyncStatus
                                                                      nonActionedValidations:0
                                                                         previousPunchStatus:Unknown
                                                                             nextPunchStatus:Unknown
                                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                                  actionType:punchToPersist.actionType
                                                                               oefTypesArray:punchToPersist.oefTypesArray
                                                                                lastSyncTime:punchToPersist.lastSyncTime
                                                                                     project:punchToPersist.project
                                                                                 auditHstory:nil
                                                                                   breakType:punchToPersist.breakType
                                                                                    location:punchToPersist.location
                                                                                  violations:nil
                                                                                   requestID:punchToPersist.requestID
                                                                                    activity:punchToPersist.activity
                                                                                    duration:nil
                                                                                      client:punchToPersist.client
                                                                                     address:punchToPersist.address
                                                                                     userURI:punchToPersist.userURI
                                                                                    imageURL:nil
                                                                                        date:punchToPersist.date
                                                                                        task:task
                                                                                         uri:nil
                                                                        isTimeEntryAvailable:NO
                                                                            syncedWithServer:YES
                                                                              isMissingPunch:NO
                                                                     previousPunchActionType:PunchActionTypeUnknown];
                    
                    timeLinePunchesStorage stub_method(@selector(recentTwoPunches)).and_return(@[remotePunchA, remotePunchB]);
                    
                    [subject validatePunchAndUpdate:punchToPersist withError:@{@"failureUri":invalidProjectFailureUri}];
                });
                
                it(@"should persist the remote punch in timeline storage", ^{
                    RemotePunch *remotePunchActual = [[RemotePunch alloc] initWithPunchSyncStatus:punchToPersist.punchSyncStatus
                                                                           nonActionedValidations:0
                                                                              previousPunchStatus:Unknown
                                                                                  nextPunchStatus:Unknown
                                                                                    sourceOfPunch:UnknownSourceOfPunch
                                                                                       actionType:punchToPersist.actionType
                                                                                    oefTypesArray:punchToPersist.oefTypesArray
                                                                                     lastSyncTime:punchToPersist.lastSyncTime
                                                                                          project:punchToPersist.project
                                                                                      auditHstory:nil
                                                                                        breakType:punchToPersist.breakType
                                                                                         location:punchToPersist.location
                                                                                       violations:nil
                                                                                        requestID:punchToPersist.requestID
                                                                                         activity:punchToPersist.activity
                                                                                         duration:nil
                                                                                           client:punchToPersist.client
                                                                                          address:punchToPersist.address
                                                                                          userURI:punchToPersist.userURI
                                                                                         imageURL:nil
                                                                                             date:punchToPersist.date
                                                                                             task:punchToPersist.task
                                                                                              uri:nil
                                                                             isTimeEntryAvailable:NO
                                                                                 syncedWithServer:YES
                                                                                   isMissingPunch:NO
                                                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    timeLinePunchesStorage should have_received(@selector(storeRemotePunch:)).with(remotePunchActual);
                });
            });
            
            context(@"when punchcard information not used by previous punches", ^{
                __block LocalPunch *punchToPersist;
                __block PunchCardObject *punchCardObject;
                beforeEach(^{
                    
                    UIImage *image = [UIImage imageNamed:@"icon_comments_blue"];
                    
                    BreakType *breakType = [[BreakType alloc] initWithName:@"My Special Name" uri:@"My Special URI"];
                    
                    CLLocation *location = [[CLLocation alloc] initWithLatitude:12 longitude:34];
                    
                    ClientType *clientType = nice_fake_for([ClientType class]);
                    
                    ProjectType *projectType = nice_fake_for([ProjectType class]);
                    
                    TaskType *taskType = nice_fake_for([TaskType class]);
                    
                    clientType stub_method(@selector(uri)).and_return(@"some-uri");
                    projectType stub_method(@selector(uri)).and_return(@"some-uri");
                    taskType stub_method(@selector(uri)).and_return(@"some-uri");
                    
                    punchCardObject = nice_fake_for([PunchCardObject class]);
                    
                    punchCardStorage stub_method(@selector(getPunchCardObjectWithClientUri:projectUri:taskUri:)).with(@"some-uri", @"some-uri", @"some-uri").and_return(punchCardObject);
                    
                    OEFType *oefType1 = nice_fake_for([OEFType class]);
                    OEFType *oefType2 = nice_fake_for([OEFType class]);
                    
                    punchToPersist= [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakType location:location project:projectType requestID:NULL activity:nil client:clientType oefTypes:@[oefType1, oefType2] address:@"My Special Address" userURI:@"My:Special:User" image:image task:taskType date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
                });
                
                beforeEach(^{
                    timeLinePunchesStorage stub_method(@selector(recentTwoPunches)).and_return(@[punchToPersist]);
                    [subject validatePunchAndUpdate:punchToPersist withError:@{@"failureUri":invalidProjectFailureUri}];
                });
                
                it(@"should store updated punchcard", ^{
                    punchCardStorage should have_received(@selector(storePunchCard:)).with(punchCardObject);
                });
            });
        });
        
        context(@"with some other error", ^{
            __block LocalPunch *punchToPersist;
            beforeEach(^{
                
                UIImage *image = [UIImage imageNamed:@"icon_comments_blue"];
                
                BreakType *breakType = [[BreakType alloc] initWithName:@"My Special Name" uri:@"My Special URI"];
                
                CLLocation *location = [[CLLocation alloc] initWithLatitude:12 longitude:34];
                
                ClientType *clientType = nice_fake_for([ClientType class]);
                
                ProjectType *projectType = nice_fake_for([ProjectType class]);
                
                TaskType *taskType = nice_fake_for([TaskType class]);
                
                OEFType *oefType1 = nice_fake_for([OEFType class]);
                OEFType *oefType2 = nice_fake_for([OEFType class]);
                
                punchToPersist= [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakType location:location project:projectType requestID:NULL activity:nil client:clientType oefTypes:@[oefType1, oefType2] address:@"My Special Address" userURI:@"My:Special:User" image:image task:taskType date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
            });
            
            beforeEach(^{
                RemotePunch *remotePunchA = [[RemotePunch alloc] initWithPunchSyncStatus:punchToPersist.punchSyncStatus
                                                                  nonActionedValidations:0
                                                                     previousPunchStatus:Unknown
                                                                         nextPunchStatus:Unknown
                                                                           sourceOfPunch:UnknownSourceOfPunch
                                                                              actionType:punchToPersist.actionType
                                                                           oefTypesArray:punchToPersist.oefTypesArray
                                                                            lastSyncTime:punchToPersist.lastSyncTime
                                                                                 project:punchToPersist.project
                                                                             auditHstory:nil
                                                                               breakType:punchToPersist.breakType
                                                                                location:punchToPersist.location
                                                                              violations:nil
                                                                               requestID:punchToPersist.requestID
                                                                                activity:punchToPersist.activity
                                                                                duration:nil
                                                                                  client:punchToPersist.client
                                                                                 address:punchToPersist.address
                                                                                 userURI:punchToPersist.userURI
                                                                                imageURL:nil
                                                                                    date:punchToPersist.date
                                                                                    task:punchToPersist.task
                                                                                     uri:nil
                                                                    isTimeEntryAvailable:YES
                                                                        syncedWithServer:YES
                                                                          isMissingPunch:NO
                                                                 previousPunchActionType:PunchActionTypeUnknown];
                
                TaskType *task = [[TaskType alloc] initWithProjectUri:@"project-uri" taskPeriod:nil name:@"task-name" uri:@"task-uri"];
                
                RemotePunch *remotePunchB = [[RemotePunch alloc] initWithPunchSyncStatus:punchToPersist.punchSyncStatus
                                                                  nonActionedValidations:0
                                                                     previousPunchStatus:Unknown
                                                                         nextPunchStatus:Unknown
                                                                           sourceOfPunch:UnknownSourceOfPunch
                                                                              actionType:punchToPersist.actionType
                                                                           oefTypesArray:punchToPersist.oefTypesArray
                                                                            lastSyncTime:punchToPersist.lastSyncTime
                                                                                 project:punchToPersist.project
                                                                             auditHstory:nil
                                                                               breakType:punchToPersist.breakType
                                                                                location:punchToPersist.location
                                                                              violations:nil
                                                                               requestID:punchToPersist.requestID
                                                                                activity:punchToPersist.activity
                                                                                duration:nil
                                                                                  client:punchToPersist.client
                                                                                 address:punchToPersist.address
                                                                                 userURI:punchToPersist.userURI
                                                                                imageURL:nil
                                                                                    date:punchToPersist.date
                                                                                    task:task
                                                                                     uri:nil
                                                                    isTimeEntryAvailable:NO
                                                                        syncedWithServer:YES
                                                                          isMissingPunch:NO
                                                                 previousPunchActionType:PunchActionTypeUnknown];
                
                timeLinePunchesStorage stub_method(@selector(recentTwoPunches)).and_return(@[remotePunchA, remotePunchB]);
                
                [subject validatePunchAndUpdate:punchToPersist withError:@{@"failureUri":@"some-error"}];
            });
            
            it(@"should persist the remote punch in timeline storage", ^{
                RemotePunch *remotePunchActual = [[RemotePunch alloc] initWithPunchSyncStatus:punchToPersist.punchSyncStatus
                                                                       nonActionedValidations:0
                                                                          previousPunchStatus:Unknown
                                                                              nextPunchStatus:Unknown
                                                                                sourceOfPunch:UnknownSourceOfPunch
                                                                                   actionType:punchToPersist.actionType
                                                                                oefTypesArray:punchToPersist.oefTypesArray
                                                                                 lastSyncTime:punchToPersist.lastSyncTime
                                                                                      project:punchToPersist.project
                                                                                  auditHstory:nil
                                                                                    breakType:punchToPersist.breakType
                                                                                     location:punchToPersist.location
                                                                                   violations:nil
                                                                                    requestID:punchToPersist.requestID
                                                                                     activity:punchToPersist.activity
                                                                                     duration:nil
                                                                                       client:punchToPersist.client
                                                                                      address:punchToPersist.address
                                                                                      userURI:punchToPersist.userURI
                                                                                     imageURL:nil
                                                                                         date:punchToPersist.date
                                                                                         task:punchToPersist.task
                                                                                          uri:nil
                                                                         isTimeEntryAvailable:NO
                                                                             syncedWithServer:YES
                                                                               isMissingPunch:NO
                                                                      previousPunchActionType:PunchActionTypeUnknown];
                
                timeLinePunchesStorage should_not have_received(@selector(storeRemotePunch:)).with(remotePunchActual);
            });
        });

    });
});

SPEC_END
