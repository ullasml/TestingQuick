//
//  AppPersistentStorage.m
//  NextGenRepliconTimeSheet


#import "AppPersistentStorage.h"
#import <repliconkit/repliconkit.h>
#import "NSData+AES.h"

#define PERSISTENT_PLIST_FILE_NAME  @"AppPersistentData.plist"
#define SECRET_KEY  @"replico^777"

@interface AppPersistentStorage()

@property (nonatomic) NSMutableDictionary *persistentDataDictionary;

@end

static id sharedInstance = nil;

@implementation AppPersistentStorage

+ (instancetype)sharedInstance {

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if(sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
        }

    });
    return sharedInstance;
}

+ (void)resetSharedInstance {
    sharedInstance = nil;
}

- (instancetype)init {
    if(self = [super init]) {
        [self createAndParsePersistentStorePlistInDocumentsDirectory];
    }
    return self;
}

#pragma mark - Private Helper Methods

- (void)log:(NSError *)error success:(BOOL)success {
  NSString *fileProtectionAttributeErrorString = (!success) ? [NSString stringWithFormat:@"File protection failed for persistent data plist: %@", error] : [NSString stringWithFormat:@"File protection successful for persistent data plist"];

        [LogUtil logLoggingInfo:fileProtectionAttributeErrorString forLogLevel:LoggerCocoaLumberjack];
}

- (void)createAndParsePersistentStorePlistInDocumentsDirectory {

    NSString *path = [Util pathForResource:PERSISTENT_PLIST_FILE_NAME];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (![fileManager fileExistsAtPath: path]) {

        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"AppPersistentData" ofType:@"plist"];

        NSError *error;
        [fileManager copyItemAtPath:bundlePath toPath:path error:&error];

        NSDictionary *attributes = @{NSFileProtectionKey: NSFileProtectionCompleteUntilFirstUserAuthentication};
        BOOL success = [[NSFileManager defaultManager] setAttributes:attributes
                                                        ofItemAtPath:path
                                                               error:&error];

        [self log:error success:success];

        [self encryptDataFromDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:path]];
    }

    if ([fileManager fileExistsAtPath: path]) {

        NSMutableDictionary *tempDecryptedDataDictionary = [self decryptDataFromPlist];

        self.persistentDataDictionary = tempDecryptedDataDictionary;

        [self encryptDataFromDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:path]];
    }
}


- (NSMutableDictionary *)decryptDataFromPlist
{
    NSError* error;

    NSString *file = [Util pathForResource:PERSISTENT_PLIST_FILE_NAME];
    NSData *encryptedData = [NSData dataWithContentsOfFile:file];
    NSData *decryptedData = [encryptedData decryptWithString:SECRET_KEY];

    NSPropertyListFormat format;
    NSMutableDictionary *decryptedDictionary = [NSPropertyListSerialization propertyListWithData:decryptedData
                                                            options:NSPropertyListMutableContainersAndLeaves
                                                                           format:&format
                                                                            error:&error];


    return decryptedDictionary;
}

- (void)encryptDataFromDictionary:(NSDictionary *)dictionary {
    NSError *error;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:dictionary
                                                              format:NSPropertyListXMLFormat_v1_0
                                                             options:0
                                                               error:&error];

    NSData *encryptedData = [data encryptWithString:SECRET_KEY];
    [encryptedData writeToFile:[Util pathForResource:PERSISTENT_PLIST_FILE_NAME] atomically:YES];
}

#pragma mark - Public Class Methods

+ (void)syncInMemoryMapToPlist {
    AppPersistentStorage *persistentStorage = [AppPersistentStorage sharedInstance];

    if([[persistentStorage persistentDataDictionary] count] == 0) {
        return;
    }

    [persistentStorage decryptDataFromPlist];
    
    [persistentStorage encryptDataFromDictionary:[persistentStorage persistentDataDictionary]];
}

+ (void)setObject:(id)object forKey:(NSString *)key {
    [[[AppPersistentStorage sharedInstance] persistentDataDictionary] setObject:object forKey:key];
}

+ (id)objectForKey:(NSString *)key {
    return [[[AppPersistentStorage sharedInstance] persistentDataDictionary] objectForKey:key];
}
@end
