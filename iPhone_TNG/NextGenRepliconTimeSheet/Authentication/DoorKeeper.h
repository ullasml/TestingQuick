#import <Foundation/Foundation.h>

@class DoorKeeper;

@protocol DoorKeeperLogOutObserver

- (void)doorKeeperDidLogOut:(DoorKeeper *)doorKeeper;

@end

@interface DoorKeeper : NSObject

- (void)logOut;
- (void)addLogOutObserver:(id<DoorKeeperLogOutObserver>)doorKeeperObserver;

@end

