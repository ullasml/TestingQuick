#import "PunchAssemblyGuard.h"
#import <CoreLocation/CoreLocation.h>
#import "UserPermissionsStorage.h"
#import <AVFoundation/AVFoundation.h>
#import <KSDeferred/KSDeferred.h>
#import "Constants.h"


@interface PunchAssemblyGuard ()

@property (nonatomic) NSArray *childAssemblyGuards;

@end


@implementation PunchAssemblyGuard

- (instancetype)initWithChildAssemblyGuards:(NSArray *)childAssemblyGuards
{
    self = [super init];
    if (self)
    {
        self.childAssemblyGuards = childAssemblyGuards;
    }

    return self;
}

- (KSPromise *)shouldAssemble
{
    NSMutableArray *childShouldAssemblePromises = [NSMutableArray arrayWithCapacity:self.childAssemblyGuards.count];

    for(id<AssemblyGuard> childAssemblyGuard in self.childAssemblyGuards)
    {
        [childShouldAssemblePromises addObject:[childAssemblyGuard shouldAssemble]];
    }

    KSDeferred *shouldAssembleDeferred = [[KSDeferred alloc] init];

    KSPromise *joinedChildShouldAssemblePromise = [KSPromise when:childShouldAssemblePromises];

    [joinedChildShouldAssemblePromise then:^id(id value) {
        [shouldAssembleDeferred resolveWithValue:@(YES)];
        return nil;
    }  error:^id(NSError *error) {
        NSArray *childShouldAssembleErrors = error.userInfo[KSPromiseWhenErrorErrorsKey];
        NSDictionary *userInfo = @{
                                 PunchAssemblyGuardChildErrorsKey: childShouldAssembleErrors
                                 };

        NSError *shouldAssembleError = [[NSError alloc] initWithDomain:PunchAssemblyGuardErrorDomain
                                                                  code:PunchAssemblyGuardErrorCodeChildAssemblyGuardError
                                                              userInfo:userInfo];

        [shouldAssembleDeferred rejectWithError:shouldAssembleError];
        return nil;
    }];

    return shouldAssembleDeferred.promise;
}


#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
