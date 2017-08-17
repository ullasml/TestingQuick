#import <Foundation/Foundation.h>
#import "AssemblyGuard.h"


@class UserPermissionsStorage;

@interface LocationAssemblyGuard : NSObject<AssemblyGuard>

@property (nonatomic, readonly) UserPermissionsStorage *userPermissionsStorage;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype) initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage NS_DESIGNATED_INITIALIZER;


@end
