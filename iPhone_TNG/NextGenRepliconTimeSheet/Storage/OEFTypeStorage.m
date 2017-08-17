
#import "OEFTypeStorage.h"
#import "DoorKeeper.h"
#import "BreakType.h"
#import "SQLiteTableStore.h"
#import "UserSession.h"
#import "OEFType.h"
#import "UserPermissionsStorage.h"
#import "PunchActionTypeDeserializer.h"


@interface OEFTypeStorage ()

@property (nonatomic) SQLiteTableStore *sqliteStore;
@property (nonatomic) DoorKeeper *doorKeeper;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic) NSString *userUri;
@property (nonatomic) FlowType flowType;
@property (nonatomic) PunchActionTypeDeserializer *punchActionTypeDeserializer;
@end


@implementation OEFTypeStorage

- (instancetype)initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                   sqliteStore:(SQLiteTableStore *)sqliteStore
                                   userSession:(id <UserSession>)userSession
                                    doorKeeper:(DoorKeeper *)doorKeeper
                   punchActionTypeDeserializer:(PunchActionTypeDeserializer *)punchActionTypeDeserializer
{
    self = [super init];
    if (self)
    {
        self.userPermissionsStorage = userPermissionsStorage;
        self.sqliteStore = sqliteStore;
        self.doorKeeper = doorKeeper;
        self.userSession = userSession;
        [self.doorKeeper addLogOutObserver:self];
        self.punchActionTypeDeserializer = [[PunchActionTypeDeserializer alloc] init];
        self.userUri = self.userSession.currentUserURI;
    }

    return self;
}

-(void)setUpWithUserUri:(NSString *)userUri
{
    self.userUri = userUri;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}



-(void)storeOEFTypes:(NSArray *)oefTypesArray
{
    [self.sqliteStore deleteRowWithArgs:@{@"user_uri": self.userUri}];

    for (OEFType *oefType in oefTypesArray) {

        NSDictionary *oefTypeDictionary = [self dictionaryWithOEFType:oefType];
        NSDictionary *oefFilter = @{@"uri": oefType.oefUri, @"user_uri": self.userUri};
        NSDictionary *resultSet = [self.sqliteStore readLastRowWithArgs:oefFilter];
        if (resultSet) {
            [self.sqliteStore updateRow:oefTypeDictionary whereClause:oefFilter];
        } else {
            [self.sqliteStore insertRow:oefTypeDictionary];
        }
    }

}

-(OEFType *)getOEFTypeForUri:(NSString *)oefUri
{
    NSArray *oefTypes = [self.sqliteStore readAllRowsWithArgs:@{@"user_uri": self.userUri,
                                                               @"uri":oefUri}];
    return [self serializeOEFType:oefTypes].firstObject;

}

-(NSArray *)getAllOEFS
{
    NSArray *oefs;
    oefs = [self.sqliteStore readAllRowsWithArgs:@{@"user_uri": self.userUri
                                                       }];

    return [self serializeOEFType:oefs];
    
}


-(NSArray *)getAllOEFSForCollectAtTimeOfPunch:(PunchActionType)punchActionType
{
    NSArray *oefs;
    NSString *punchActionTypeStr = [self.punchActionTypeDeserializer getPunchActionTypeString:punchActionType];
    oefs = [self.sqliteStore readAllRowsWithArgs:@{@"user_uri": self.userUri, @"collectAtTimeOfPunch" : [NSNumber numberWithBool:YES], @"punchActionType" : punchActionTypeStr}];

    return [self serializeOEFType:oefs];
}


-(NSArray *)getUnionOEFArrayFromPunchCardOEF:(NSArray *)punchCardOEFArray andPunchActionType:(PunchActionType)punchActionType
{
    NSArray *oefTypesArray = [self getAllOEFSForPunchActionType:punchActionType];
    NSMutableArray *unionOEFArray = [NSMutableArray arrayWithArray:oefTypesArray];
    int index = 0;
    for (OEFType *oefType in oefTypesArray)
    {
        NSString *oefName = oefType.oefName;
        for (OEFType *oefTypePunchCard in punchCardOEFArray)
        {
            if ([oefTypePunchCard.oefName isEqualToString:oefName])
            {
                [unionOEFArray replaceObjectAtIndex:index withObject:oefTypePunchCard];
            }
        }
        index++;
    }

    return unionOEFArray;

}



#pragma mark - <DoorKeeperObserver>

- (void)doorKeeperDidLogOut:(DoorKeeper *)doorKeeper
{
    NSArray *allUserUris = [self.sqliteStore readAllDistinctRowsFromColumn:@"user_uri"];
    for (NSDictionary *user in allUserUris) {
        NSString *userUri = user[@"user_uri"];
        if (![userUri isEqualToString:self.userUri]) {
            [self.sqliteStore deleteAllRows];
        }
    }
}


#pragma mark - Private

- (NSDictionary *)dictionaryWithOEFType:(OEFType *)oefType
{
    return @{
             @"uri":oefType.oefUri,
             @"user_uri":self.userUri,
             @"definitionTypeUri":oefType.oefDefinitionTypeUri,
             @"name":oefType.oefName,
             @"punchActionType":oefType.oefPunchActionType,
             @"collectAtTimeOfPunch":@(oefType.collectAtTimeOfPunch),
             @"numericValue":[self getValueAfterCheckForNullForValue:oefType.oefNumericValue],
             @"textValue":[self getValueAfterCheckForNullForValue:oefType.oefTextValue],
             @"dropdownOptionUri":[self getValueAfterCheckForNullForValue:oefType.oefDropdownOptionUri],
             @"dropdownOptionValue":[self getValueAfterCheckForNullForValue:oefType.oefDropdownOptionValue]
             };
}

-(NSArray *)serializeOEFType:(NSArray *)oefs
{
    NSMutableArray *oefTypes = [NSMutableArray arrayWithCapacity:oefs.count];
    for (NSDictionary *oefTypeDictionary in oefs) {
        OEFType *oefype = [[OEFType alloc] initWithUri:oefTypeDictionary[@"uri"] definitionTypeUri:oefTypeDictionary[@"definitionTypeUri"] name:oefTypeDictionary[@"name"] punchActionType:oefTypeDictionary[@"punchActionType"] numericValue:oefTypeDictionary[@"numericValue"] textValue:oefTypeDictionary[@"textValue"] dropdownOptionUri:oefTypeDictionary[@"dropdownOptionUri"] dropdownOptionValue:oefTypeDictionary[@"dropdownOptionValue"] collectAtTimeOfPunch:[oefTypeDictionary[@"collectAtTimeOfPunch"] boolValue] disabled:NO];
        [oefTypes addObject:oefype];
    }
    return [oefTypes copy];
}


-(id)getValueAfterCheckForNullForValue:(id)value
{
    if (value == nil || value == [NSNull null] ) {
        return [NSNull null];
    }
    return value;
}


-(FlowType)flowType
{
    BOOL isSameUser = [self.userSession.currentUserURI isEqualToString:self.userUri];
    return isSameUser ? UserFlowContext : SupervisorFlowContext;
}

-(NSArray *)getAllOEFSForPunchActionType:(PunchActionType)punchActionType
{
    NSArray *oefs;
    NSString *punchActionTypeStr = [self.punchActionTypeDeserializer getPunchActionTypeString:punchActionType];
    oefs = [self.sqliteStore readAllRowsWithArgs:@{@"user_uri": self.userUri, @"punchActionType" : punchActionTypeStr}];

    return [self serializeOEFType:oefs];

}

@end

