#import <Foundation/Foundation.h>
#import "PunchAssemblyWorkflow.h"

@class LocalPunch;
@class BreakType;
@class PunchClock;
@class DateProvider;
@class PunchAssemblyWorkflow;
@class PunchRepository;
@class Activity;
@protocol UserSession;
@class GUIDProvider;


@interface PunchClock : NSObject

@property (nonatomic, readonly) PunchRepository *punchRepository;
@property (nonatomic, readonly) PunchAssemblyWorkflow *punchAssemblyWorkflow;
@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic, readonly) id<UserSession> userSession;
@property (nonatomic, readonly) GUIDProvider *guidProvider;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithPunchRepository:(PunchRepository *)punchRepository
                  punchAssemblyWorkflow:(PunchAssemblyWorkflow *)punchAssemblyWorkflow
                            userSession:(id <UserSession>)userSession
                           dateProvider:(DateProvider *)dateProvider
                           guidProvider:(GUIDProvider *)guidProvider;

- (void)punchInWithPunchAssemblyWorkflowDelegate:(id<PunchAssemblyWorkflowDelegate>)punchAssemblyWorkflowDelegate oefData:(NSArray*)oefData;

- (void)punchOutWithPunchAssemblyWorkflowDelegate:(id<PunchAssemblyWorkflowDelegate>)punchAssemblyWorkflowDelegate oefData:(NSArray*)oefData;

- (void)takeBreakWithBreakDate:(NSDate *)breakDate
                     breakType:(BreakType *)breakType
 punchAssemblyWorkflowDelegate:(id<PunchAssemblyWorkflowDelegate>)punchAssemblyWorkflowDelegate;

- (void)takeBreakWithBreakDateAndOEF:(NSDate *)breakDate
                     breakType:(BreakType *)breakType
                       oefData:(NSArray*)oefData
 punchAssemblyWorkflowDelegate:(id<PunchAssemblyWorkflowDelegate>)punchAssemblyWorkflowDelegate;


- (KSPromise *)punchWithManualLocalPunch:(LocalPunch *)punch punchAssemblyWorkflowDelegate:(id<PunchAssemblyWorkflowDelegate>)punchAssemblyWorkflowDelegate;

- (void)resumeWorkWithPunchAssemblyWorkflowDelegate:(id<PunchAssemblyWorkflowDelegate>)punchAssemblyWorkflowDelegate oefData:(NSArray*)oefData;

- (void)punchInWithPunchAssemblyWorkflowDelegate:(id <PunchAssemblyWorkflowDelegate>)punchAssemblyWorkflowDelegate clientType:(ClientType *)client projectType:(ProjectType *)project taskType:(TaskType *)task activity:(Activity *)activity oefTypesArray:(NSArray *)oefTypesArray;

- (void)resumeWorkWithPunchProjectAssemblyWorkflowDelegate:(id <PunchAssemblyWorkflowDelegate>)punchAssemblyWorkflowDelegate clientType:(ClientType *)client projectType:(ProjectType *)project taskType:(TaskType *)task oefTypesArray:(NSArray *)oefTypesArray;

- (void)resumeWorkWithActivityAssemblyWorkflowDelegate:(id <PunchAssemblyWorkflowDelegate>)punchAssemblyWorkflowDelegate activity:(Activity *)activity oefTypesArray:(NSArray *)oefTypesArray;
@end
