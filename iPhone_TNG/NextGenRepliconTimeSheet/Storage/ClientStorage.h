
#import <Foundation/Foundation.h>
#import "UserSession.h"
#import "DoorKeeper.h"
#import "Enum.h"

@class SQLiteTableStore;
@class ClientType;

@interface ClientStorage : NSObject <DoorKeeperLogOutObserver>

@property (nonatomic,readonly) SQLiteTableStore *sqliteStore;
@property (nonatomic,readonly) DoorKeeper *doorKeeper;
@property (nonatomic,readonly) id<UserSession> userSession;
@property (nonatomic,readonly) NSUserDefaults *userDefaults;
@property (nonatomic,readonly) NSString *userUri;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSqliteStore:(SQLiteTableStore *)sqliteStore
                       userDefaults:(NSUserDefaults *)userDefaults
                        userSession:(id<UserSession>)userSession
                         doorKeeper:(DoorKeeper *)doorKeeper NS_DESIGNATED_INITIALIZER;


-(void)storeClients:(NSArray *)array;

-(void)deleteAllClients;

-(NSArray *)getAllClients;

-(NSArray *)getClientsWithMatchingText:(NSString *)text;

-(NSNumber *)getLastPageNumber;

-(void)updatePageNumber;

-(void)resetPageNumber;

-(NSNumber *)getLastPageNumberForFilteredSearch;

-(void)updatePageNumberForFilteredSearch;

-(void)resetPageNumberForFilteredSearch;

-(ClientType *)getClientInfoForUri:(NSString *)clientUri;

-(void)setUpWithUserUri:(NSString *)userUri;

@end
