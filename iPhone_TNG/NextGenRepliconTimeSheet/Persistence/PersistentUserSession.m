#import "PersistentUserSession.h"
#import "DoorKeeper.h"
#import "LoginModel.h"
#import "NSUserDefaults+Convenience.h"

static NSString * const UserUriKey = @"UserUri";
static NSString * const ValidUserSessionKey = @"ValidUserSession";

@interface PersistentUserSession ()
@property (nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) DoorKeeper *doorKeeper;
@property (nonatomic) LoginModel *loginModel;
@end


@implementation PersistentUserSession

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
                          doorKeeper:(DoorKeeper *)doorKeeper
                          loginModel:(LoginModel *)loginModel
{
    self = [super init];
    if (self) {
        self.userDefaults = userDefaults;
        self.doorKeeper = doorKeeper;
        [self.doorKeeper addLogOutObserver:self];
        self.loginModel = loginModel;
    }
    return self;
}

- (NSString *)currentUserURI
{
    NSString *userUri=nil;
    ///to fix crash for nil userUri, first we try to read from userdefaults
    userUri = [self.userDefaults objectForKey:UserUriKey];
    if (userUri!=nil && userUri!=(id)[NSNull null])
    {
        return userUri;
    }
    else{
        ///if userDefaults returns userUri nil, reading from LoginModel userDetails table
        CLS_LOG(@"-------userUri is read from LoginModel---------:%@", self.loginModel);
        userUri = [self.loginModel getUserUriInfoFromDb];
        if (userUri!=nil && userUri!=(id)[NSNull null])
        {
            return userUri;
        }

        NSString *userUriFromCustomKeyValueStore = [AppPersistentStorage objectForKey:UserUriKey];
        if (userUriFromCustomKeyValueStore!=nil && userUriFromCustomKeyValueStore!=(id)[NSNull null]) {
            CLS_LOG(@"-------userUri is read from Custom key value store---------:%@", userUriFromCustomKeyValueStore);
            return userUriFromCustomKeyValueStore;
        }

    }
    
    CLS_LOG(@"-------print UserDefaults object:%@", self.userDefaults);
    CLS_LOG(@"-------print UserDefaults object:%@", [self.userDefaults dictionaryRepresentation]);
    CLS_LOG(@"-------print Custom Key value store object:%@", [AppPersistentStorage sharedInstance]);
    CLS_LOG(@"-------userUri is nil--------- :%@", userUri);
    return userUri;
}

-(BOOL)validUserSession
{
    BOOL validUserSession = [self.userDefaults boolForKey:ValidUserSessionKey];
    return validUserSession;
}

#pragma mark - <DoorKeeperObserver>

- (void)doorKeeperDidLogOut:(DoorKeeper *)doorKeeper
{
    [self.userDefaults setBool:NO forKey:ValidUserSessionKey];
    [self.userDefaults synchronize];
}


@end
