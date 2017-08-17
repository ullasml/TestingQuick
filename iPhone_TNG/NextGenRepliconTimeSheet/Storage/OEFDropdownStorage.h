
#import <Foundation/Foundation.h>
#import "UserSession.h"
#import "DoorKeeper.h"
#import "Enum.h"

@class SQLiteTableStore;
@class OEFDropDownType;
@class UserPermissionsStorage;

@interface OEFDropdownStorage : NSObject <DoorKeeperLogOutObserver>

@property (nonatomic,readonly) SQLiteTableStore *sqliteStore;
@property (nonatomic,readonly) DoorKeeper *doorKeeper;
@property (nonatomic,readonly) id<UserSession> userSession;
@property (nonatomic,readonly) NSUserDefaults *userDefaults;
@property (nonatomic,readonly) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic,readonly) NSString *dropDownOEFUri;
@property (nonatomic,readonly) NSString *userUri;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                   sqliteStore:(SQLiteTableStore *)sqliteStore
                                  userDefaults:(NSUserDefaults *)userDefaults
                                   userSession:(id <UserSession>)userSession
                                    doorKeeper:(DoorKeeper *)doorKeeper;


-(void)storeOEFDropDownOptions:(NSArray *)array;

-(void)deleteAllOEFDropDownOptions;

-(void)deleteAllOEFDropDownOptionsForOEFUri:(NSString *)oefUri;

-(NSArray *)getAllOEFDropDownOptions;

-(NSArray *)getOEFDropDownOptionsWithMatchingText:(NSString *)text;

-(NSNumber *)getLastPageNumber;

-(void)updatePageNumber;

-(void)resetPageNumber;

-(NSNumber *)getLastPageNumberForFilteredSearch;

-(void)updatePageNumberForFilteredSearch;

-(void)resetPageNumberForFilteredSearch;

-(OEFDropDownType *)getOEFDropDownOptionsInfoForUri:(NSString *)oefDropDownOptionsUri;

-(void)setUpWithDropDownOEFUri:(NSString *)dropDownOEFUri userUri:(NSString *)userUri;


@end
