
#import <Foundation/Foundation.h>
#import "UserSession.h"
#import "DoorKeeper.h"
#import "Enum.h"
#import "OEFType.h"
#import "PunchActionTypeDeserializer.h"

@class SQLiteTableStore;
@class ProjectType;
@class UserPermissionsStorage;


@interface OEFTypeStorage : NSObject <DoorKeeperLogOutObserver>
@property (nonatomic,readonly) SQLiteTableStore *sqliteStore;
@property (nonatomic,readonly) DoorKeeper *doorKeeper;
@property (nonatomic,readonly) id<UserSession> userSession;
@property (nonatomic,readonly) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic,readonly) NSString *userUri;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                   sqliteStore:(SQLiteTableStore *)sqliteStore
                                   userSession:(id <UserSession>)userSession
                                    doorKeeper:(DoorKeeper *)doorKeeper
                   punchActionTypeDeserializer:(PunchActionTypeDeserializer *)punchActionTypeDeserializer NS_DESIGNATED_INITIALIZER;


-(void)storeOEFTypes:(NSArray *)oefTypesArray;

-(void)setUpWithUserUri:(NSString *)userUri;

-(OEFType *)getOEFTypeForUri:(NSString *)oefUri;

-(NSArray *)getAllOEFS;

-(NSArray *)getAllOEFSForCollectAtTimeOfPunch:(PunchActionType)punchActionType;

-(NSArray *)getUnionOEFArrayFromPunchCardOEF:(NSArray *)punchCardOEFArray andPunchActionType:(PunchActionType)punchActionType;

-(NSArray *)getAllOEFSForPunchActionType:(PunchActionType)punchActionType;

@end

