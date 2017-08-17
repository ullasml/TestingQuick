#import "DoorKeeper.h"

@interface DoorKeeper ()

@property (nonatomic) NSHashTable *observers;

@end

@implementation DoorKeeper

- (instancetype)init {
    if(self = [super init]) {
        self.observers = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)addLogOutObserver:(id<DoorKeeperLogOutObserver>)doorKeeperObserver {
    [self.observers addObject:doorKeeperObserver];
}

- (void)logOut {
    for(id<DoorKeeperLogOutObserver> observer in [self.observers allObjects]) {
        [observer doorKeeperDidLogOut:self];
    }
}

@end
