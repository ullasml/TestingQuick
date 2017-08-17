#import <Foundation/Foundation.h>
#import "LocalPunch.h"


@class KSPromise;
@class UserPermissionsStorage;
@class DateProvider;
@class PunchAssemblyWorkflow;
@class Geolocator;
@class PunchAssembler;
@class DateProvider;
@protocol PunchAssemblyWorkflowDelegate;
@class PunchAssemblyGuard;
@class PunchOutboxStorage;


@interface PunchAssemblyWorkflow : NSObject

@property (nonatomic, readonly) UserPermissionsStorage *punchRulesStorage;
@property (nonatomic, readonly) PunchAssemblyGuard *punchAssemblyGuard;
@property (nonatomic, readonly) Geolocator *geolocator;
@property (nonatomic, readonly) PunchOutboxStorage *punchOutboxStorage;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithPunchRulesStorage:(UserPermissionsStorage *)punchRulesStorage punchAssemblyGuard:(PunchAssemblyGuard *)punchAssemblyGuard geolocator:(Geolocator *)geolocator punchOutboxStorage:(PunchOutboxStorage *)punchOutboxStorage;

- (KSPromise *)assembleIncompletePunch:(LocalPunch *)incompletePunch
           serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
                              delegate:(id<PunchAssemblyWorkflowDelegate>)delegate;

- (KSPromise *)assembleManualIncompletePunch:(LocalPunch *)incompletePunch
                 serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
                                    delegate:(id<PunchAssemblyWorkflowDelegate>)delegate;


@end


@protocol PunchAssemblyWorkflowDelegate

- (KSPromise *)punchAssemblyWorkflowNeedsImage;

- (void)      punchAssemblyWorkflow:(PunchAssemblyWorkflow *)workflow
willEventuallyFinishIncompletePunch:(LocalPunch *)incompletePunch
              assembledPunchPromise:(KSPromise *)assembledPunchPromise
        serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise;

- (void)   punchAssemblyWorkflow:(PunchAssemblyWorkflow *)workflow
didFailToAssembleIncompletePunch:(LocalPunch *)incompletePunch
                          errors:(NSArray *)errors;



@end
