//
//  AppPersistentStorageSpec.m
//  NextGenRepliconTimeSheet
//

#import <Cedar/Cedar.h>
#import "AppPersistentStorage.h"
#import "Util.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(AppPersistentStorageSpec)

describe(@"AppPersistentStorage", ^{

    __block AppPersistentStorage *subject;
    beforeEach(^{
        subject = [AppPersistentStorage sharedInstance];
        [subject.persistentDataDictionary removeAllObjects];
        spy_on(subject);
    });
    afterEach(^{
        stop_spying_on(subject);
      });

    describe(@"-syncDataToPlist:when persistent map is not empty", ^{
        beforeEach(^{
            [subject createAndParsePersistentStorePlistInDocumentsDirectory];
            [AppPersistentStorage setObject:@"xxxx" forKey:@"key"];
            [AppPersistentStorage syncInMemoryMapToPlist];
        });

        it(@"should call decrypt data from plist and update the latest map", ^{
            subject should have_received(@selector(decryptDataFromPlist));
            subject should have_received(@selector(encryptDataFromDictionary:));
        });

        afterEach(^{
            [subject.persistentDataDictionary removeAllObjects];
        });

    });

    describe(@"App persistent storage init", ^{

        it(@"Should have created a empty instance of dictionary", ^{
            subject.persistentDataDictionary.count should equal(0);
        });

        it(@"Should have created a .plist file which is not redable", ^{

            NSString *path = [Util pathForResource:@"AppPersistentData.plist"];
            NSFileManager *fileManager = fake_for([NSFileManager class]);
            fileManager stub_method(@selector(fileExistsAtPath:)).and_return(YES);

            NSDictionary *persistentDict = [NSDictionary dictionaryWithContentsOfFile:path];

            persistentDict should equal(nil);

        });

    });

    describe(@"-setObject:forKey", ^{
        beforeEach(^{
            [AppPersistentStorage setObject:@"xxxx" forKey:@"key"];
        });

        it(@"Should have set value in persistent Dictionary", ^{
            subject.persistentDataDictionary.count should equal(1);
            [subject.persistentDataDictionary objectForKey:@"key"] should equal(@"xxxx");
        });

        afterEach(^{
            [subject.persistentDataDictionary removeAllObjects];
        });
    });

    describe(@"-objectForKey:", ^{
        beforeEach(^{
            [AppPersistentStorage setObject:@"xxxx" forKey:@"key"];
        });

        it(@"Should have set value in persistent Dictionary", ^{
            NSString *value = [AppPersistentStorage objectForKey:@"key"];
            subject.persistentDataDictionary.count should equal(1);
            [subject.persistentDataDictionary objectForKey:@"key"] should equal(value);
        });

        afterEach(^{
            [subject.persistentDataDictionary removeAllObjects];
        });
    });

    describe(@"-syncDataToPlist: when persistent map is empty", ^{
        beforeEach(^{
            NSMutableDictionary *fakePersistentMap = fake_for([NSMutableDictionary class]);
            unsigned long countValue = 0;
            fakePersistentMap stub_method(@selector(count)).and_return(countValue);

            subject stub_method(@selector(persistentDataDictionary)).and_return(fakePersistentMap);

            [AppPersistentStorage syncInMemoryMapToPlist];

        });

        it(@"should not decrypt and encrypt plist file unnecessarily", ^{
            subject should_not have_received(@selector(decryptDataFromPlist));
            subject should_not have_received(@selector(encryptDataFromDictionary:));
        });

    });

});

SPEC_END
