#import <Cedar/Cedar.h>
#import "PersistentUserSession.h"
#import "DoorKeeper.h"
#import "LoginModel.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PersistentUserSessionSpec)

describe(@"PersistentUserSession", ^{
    __block PersistentUserSession *subject;
    __block NSUserDefaults *userDefaults;
    __block DoorKeeper *doorKeeper;
    __block LoginModel *loginModel;
    __block id <BSBinder,BSInjector> injector;

    beforeEach(^{
        injector = [InjectorProvider injector];
        userDefaults = nice_fake_for([NSUserDefaults class]);
        doorKeeper = nice_fake_for([DoorKeeper class]);
        
        loginModel = nice_fake_for([LoginModel class]);
        [injector bind:[LoginModel class] toInstance:loginModel];
        
        subject = [[PersistentUserSession alloc] initWithUserDefaults:userDefaults doorKeeper:doorKeeper loginModel:loginModel];
    });

    describe(@"-currentUserURI", ^{
        __block NSString *userURI;
        __block AppPersistentStorage *appPersistentStorage;

        beforeEach(^{
            appPersistentStorage = [AppPersistentStorage sharedInstance];
            spy_on(appPersistentStorage);
            spy_on([appPersistentStorage persistentDataDictionary]);
            userDefaults stub_method(@selector(objectForKey:)).with(@"UserUri").and_return(@"my-users-uri");
            userDefaults stub_method(@selector(boolForKey:)).with(@"ValidUserSession").and_return(YES);
            userURI = [subject currentUserURI];
        });

        it(@"should clear the stored ValidUserSessionKey", ^{
            [userDefaults boolForKey:@"ValidUserSession"] should be_truthy;
        });

        it(@"should read the current user's URI from the user defaults", ^{
            userURI should equal(@"my-users-uri");
        });
        
        it(@"AppPersistentStorage persistentDataDictionary should not have received setObjectForKey", ^{
            [appPersistentStorage persistentDataDictionary] should_not have_received(@selector(objectForKey:));
        });
    });
    
    describe(@"userUri is nil", ^{
        __block NSString *userUri;
        beforeEach(^{
            userDefaults stub_method(@selector(objectForKey:)).with(@"UserUri").and_return(nil);
            userUri = [subject currentUserURI];
        });
        
        it(@"LoginModel should have received method getUserUriInfoFromDb", ^{
            loginModel should have_received(@selector(getUserUriInfoFromDb));
        });
        
        
    });
    
    describe(@"userUri is nil and login model returns nil", ^{
        __block NSString *userUri;
        beforeEach(^{
            userDefaults stub_method(@selector(objectForKey:)).with(@"UserUri").and_return(nil);
            loginModel stub_method(@selector(getUserUriInfoFromDb)).and_return(nil);
            userUri = [subject currentUserURI];
        });
        it(@"user Uri should be empty", ^{
            userUri should be_nil;
        });
    });
    
    describe(@"when useruri from login model is nil", ^{
        __block NSString *value;
        __block AppPersistentStorage *appPersistentStorage;
        
        beforeEach(^{
            appPersistentStorage = [AppPersistentStorage sharedInstance];
            spy_on(appPersistentStorage);
            userDefaults stub_method(@selector(objectForKey:)).with(@"UserUri").and_return(nil);
            [AppPersistentStorage setObject:@"xxxx" forKey:@"UserUri"];
            loginModel stub_method(@selector(getUserUriInfoFromDb)).and_return(nil);
            value = [AppPersistentStorage objectForKey:@"UserUri"];
            [subject currentUserURI];
        });
        
        it(@"currentUserUri should equal the persistent plist userUri value", ^{
            value should equal([subject currentUserURI]);
        });
        
        afterEach(^{
            [[appPersistentStorage persistentDataDictionary] removeAllObjects];
        });
    });
    
    describe(@"As a <DoorKeeperLogOutObserver>", ^{
        beforeEach(^{
            userDefaults stub_method(@selector(boolForKey:)).with(@"ValidUserSession").and_return(YES);
            [subject doorKeeperDidLogOut:doorKeeper];
        });

        it(@"should clear the stored ValidUserSessionKey", ^{
            userDefaults should have_received(@selector(setBool:forKey:)).with(NO,@"ValidUserSession");
        });
    });
});

SPEC_END
