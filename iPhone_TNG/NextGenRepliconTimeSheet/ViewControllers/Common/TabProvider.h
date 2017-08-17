#import <UIKit/UIKit.h>

@class UserPermissionsStorage;
@class GATracker;

@interface TabProvider : NSObject

@property (nonatomic, readonly) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic, readonly) GATracker *tracker;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary  UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUserPermissionStorage:(UserPermissionsStorage *)userPermissionsStorage;

- (NSArray *)viewControllersForModules:(NSArray *)modules;

- (NSArray *)modulesForViewControllers:(NSArray *)viewControllers;


@end
