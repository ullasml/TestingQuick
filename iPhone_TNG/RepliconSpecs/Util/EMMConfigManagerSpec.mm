#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(EMMConfigManagerSpec)

describe(@"EMMConfigManager", ^{
    __block EMMConfigManager *subject;
    __block NSUserDefaults *userDefaults;
    
    beforeEach(^{
        userDefaults = [[NSUserDefaults alloc]init];
        spy_on(userDefaults);
        
        subject = [[EMMConfigManager alloc] initWithUserDefaults:userDefaults];
    });
    
    describe(@"when values are stored in userdefaults", ^{
        __block NSDictionary *emmDataDict;
        beforeEach(^{
            emmDataDict = @{@"com.replicon.companyname":@"some-company",
                            @"com.replicon.username":@"some-user"};
            userDefaults stub_method(@selector(objectForKey:))
            .with(@"com.apple.configuration.managed").and_return(emmDataDict);
        });
        
        it(@"should have received correct dictionart values", ^{
            subject.userName should equal(@"some-user");
            subject.companyName should equal(@"some-company");
        });
    });
    
    describe(@"when only company name is stored in userdefaults", ^{
        __block NSDictionary *emmDataDict;
        beforeEach(^{
            emmDataDict = @{@"com.replicon.companyname":@"some-company"};
            userDefaults stub_method(@selector(objectForKey:))
            .with(@"com.apple.configuration.managed").and_return(emmDataDict);
        });
        
        it(@"should have received correct dictionart values", ^{
            subject.companyName should equal(@"some-company");
            subject.userName should be_nil;
        });
        
    });
    
    describe(@"when only username is stored in userdefaults", ^{
        __block NSDictionary *emmDataDict;
        beforeEach(^{
            emmDataDict = @{@"com.replicon.username":@"some-user"};
            userDefaults stub_method(@selector(objectForKey:))
            .with(@"com.apple.configuration.managed").and_return(emmDataDict);
        });
        
        it(@"should have received correct dictionart values", ^{
            subject.userName should equal(@"some-user");
            subject.companyName should be_nil;
        });
    });
    
    describe(@"when values are not stored in userdefaults", ^{
        beforeEach(^{
            userDefaults stub_method(@selector(objectForKey:))
            .with(@"com.apple.configuration.managed").and_return(nil);
        });
        
        it(@"should have received correct dictionart values", ^{
            subject.companyName should be_nil;
            subject.userName should be_nil;
        });
    });
    
    describe(@"check for company name and user name values", ^{
        __block NSDictionary *emmDataDict;
        __block BOOL isValuePresent;
        beforeEach(^{
            emmDataDict = @{@"com.replicon.companyname":@"some-company",
                            @"com.replicon.username":@"some-user"};
            userDefaults stub_method(@selector(objectForKey:))
            .with(@"com.apple.configuration.managed").and_return(emmDataDict);
            isValuePresent = [subject isEMMValuesStored];
        });
        
        it(@"should have received correct dictionart values", ^{
            isValuePresent should be_truthy;
        });
    });
    
    describe(@"check for company name", ^{
        __block NSDictionary *emmDataDict;
        __block BOOL isValuePresent;
        beforeEach(^{
            emmDataDict = @{@"com.replicon.companyname":@"some-company"};
            userDefaults stub_method(@selector(objectForKey:))
            .with(@"com.apple.configuration.managed").and_return(emmDataDict);
            isValuePresent = [subject isEMMValuesStored];
        });
        
        it(@"should have received correct dictionart values", ^{
            isValuePresent should be_truthy;
        });
    });
    
    describe(@"check for user name", ^{
        __block NSDictionary *emmDataDict;
        __block BOOL isValuePresent;
        beforeEach(^{
            emmDataDict = @{@"com.replicon.username":@"some-user"};
            userDefaults stub_method(@selector(objectForKey:))
            .with(@"com.apple.configuration.managed").and_return(emmDataDict);
            isValuePresent = [subject isEMMValuesStored];
        });
        
        it(@"should have received correct dictionart values", ^{
            isValuePresent should be_truthy;
        });
    });
    
    describe(@"when both the values are nil", ^{
        __block BOOL isValuePresent;
        beforeEach(^{
            userDefaults stub_method(@selector(objectForKey:))
            .with(@"com.apple.configuration.managed").and_return(nil);
            isValuePresent = [subject isEMMValuesStored];
        });
        
        it(@"should have received correct dictionart values", ^{
            isValuePresent should be_falsy;
        });
    });
});

SPEC_END

