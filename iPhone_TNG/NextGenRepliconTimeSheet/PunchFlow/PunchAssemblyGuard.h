#import <Foundation/Foundation.h>
#import "Constants.h"
#import <KSDeferred/KSPromise.h>
#import "AssemblyGuard.h"


@class UserPermissionsStorage;


@interface PunchAssemblyGuard : NSObject<AssemblyGuard>

@property (nonatomic, readonly) NSArray                *childAssemblyGuards;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary NS_UNAVAILABLE;

- (instancetype)initWithChildAssemblyGuards:(NSArray *)childAssemblyGuards NS_DESIGNATED_INITIALIZER;

@end
