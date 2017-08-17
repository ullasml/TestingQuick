//
//  AppPersistentStorage.h
//  NextGenRepliconTimeSheet


#import <Foundation/Foundation.h>

@interface AppPersistentStorage : NSObject

@property (nonatomic, readonly) NSMutableDictionary *persistentDataDictionary;

- (instancetype)init NS_UNAVAILABLE;
- (void)createAndParsePersistentStorePlistInDocumentsDirectory;
- (void)encryptDataFromDictionary:(NSDictionary *)dictionary;
- (NSMutableDictionary *)decryptDataFromPlist;

+ (instancetype)sharedInstance;
+ (void)resetSharedInstance;

+ (void)setObject:(id)object forKey:(NSString *)key;
+ (id)objectForKey:(NSString *)key;

+ (void)syncInMemoryMapToPlist;

@end
