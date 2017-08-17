#import <Foundation/Foundation.h>
#import "UserSession.h"
#import "DoorKeeper.h"
@class LoginModel;

@interface PersistentUserSession : NSObject <UserSession,DoorKeeperLogOutObserver>

@property (nonatomic,readonly) NSUserDefaults *userDefaults;
@property (nonatomic,readonly) DoorKeeper *doorKeeper;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
                          doorKeeper:(DoorKeeper *)doorKeeper
                          loginModel:(LoginModel *)loginModel;
@end
