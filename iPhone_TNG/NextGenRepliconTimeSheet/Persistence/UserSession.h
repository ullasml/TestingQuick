#import <Foundation/Foundation.h>

@class DoorKeeper;

@protocol UserSession <NSObject>

@optional
@property (nonatomic, readonly) NSUserDefaults *userDefaults;
@property (nonatomic, readonly) DoorKeeper *doorKeeper;

@optional
- (NSString *)currentUserURI;

- (BOOL)validUserSession;

@end
