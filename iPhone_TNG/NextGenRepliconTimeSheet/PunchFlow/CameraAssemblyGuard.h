#import <Foundation/Foundation.h>
#import "AssemblyGuard.h"


@class UserPermissionsStorage;


@interface CameraAssemblyGuard : NSObject<AssemblyGuard>

@property (nonatomic, readonly) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic, readonly) NSOperationQueue *mainQueue;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                     mainQueue:(NSOperationQueue *)mainQueue;

@end
