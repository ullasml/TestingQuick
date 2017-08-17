//
//  PunchOEFStorage.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 9/29/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "PunchOEFStorage.h"
#import "OEFType.h"
#import "SQLiteTableStore.h"
#import "Punch.h"
#import "DoorKeeper.h"
#import "TimeLinePunchesStorage.h"

@interface PunchOEFStorage ()

@property (nonatomic) SQLiteTableStore *sqliteStore;

@end

@implementation PunchOEFStorage

- (instancetype)initWithSqliteStore:(SQLiteTableStore *)sqliteStore {
    self = [super init];
    if (self)
    {
        self.sqliteStore = sqliteStore;

    }

    return self;
}

- (void)storePunchOEFArray:(NSArray *)oefTypesArray forPunch:(id<Punch>)punch
{
    for (OEFType *oefType in oefTypesArray) {

        NSDictionary *oefTypeDictionary = [self dictionaryWithOEFType:oefType requestID:punch.requestID];
        NSDictionary *oefFilter = @{@"punch_client_id": punch.requestID, @"oef_uri": oefType.oefUri};
        NSDictionary *resultSet = [self.sqliteStore readLastRowWithArgs:oefFilter];
        if (resultSet) {
            [self.sqliteStore updateRow:oefTypeDictionary whereClause:oefFilter];
        } else {
            [self.sqliteStore insertRow:oefTypeDictionary];
        }
    }


}

-(NSArray *)getPunchOEFTypesForRequestID:(NSString *)requestID
{
    NSArray *oefTypes = [self.sqliteStore readAllRowsWithArgs:@{@"punch_client_id": requestID}];
    return [self serializeOEFType:oefTypes];

}

- (void)deletePunchOEFWithRequestID:(NSString *)requestID
{
    NSDictionary *whereArgs = @{@"punch_client_id": requestID};
    [self.sqliteStore deleteRowWithArgs:whereArgs];
}

- (void)deleteAllPunchOEF
{
    [self.sqliteStore deleteAllRows];
}



#pragma mark - Private

- (NSDictionary *)dictionaryWithOEFType:(OEFType *)oefType requestID:(NSString *)punch_client_id
{
    NSString *oefNumericValue = IsNotEmptyString(oefType.oefNumericValue) ? [NSString stringWithFormat:@"%@", oefType.oefNumericValue] : @"";
    
    return @{
             @"punch_client_id":punch_client_id,
             @"oef_uri":oefType.oefUri,
             @"oef_definitionTypeUri":oefType.oefDefinitionTypeUri,
             @"oef_name":oefType.oefName,
             @"numericValue":IsNotEmptyString(oefNumericValue) ? oefNumericValue : [NSNull null],
             @"textValue":[self getValueAfterCheckForNullForValue:oefType.oefTextValue],
             @"dropdownOptionUri":[self getValueAfterCheckForNullForValue:oefType.oefDropdownOptionUri],
             @"dropdownOptionValue":[self getValueAfterCheckForNullForValue:oefType.oefDropdownOptionValue],
             @"punchActionType":oefType.oefPunchActionType,
             @"collectAtTimeOfPunch":@(oefType.collectAtTimeOfPunch),
             @"disabled":@(oefType.disabled)
             };
}

-(id)getValueAfterCheckForNullForValue:(id)value
{
    if (value == nil || value == [NSNull null] ) {
        return [NSNull null];
    }
    return value;
}

-(NSArray *)serializeOEFType:(NSArray *)oefs
{
    NSMutableArray *oefTypes = [NSMutableArray arrayWithCapacity:oefs.count];
    for (NSDictionary *oefTypeDictionary in oefs)
    {
        
        OEFType *oefype = [[OEFType alloc] initWithUri:oefTypeDictionary[@"oef_uri"] definitionTypeUri:oefTypeDictionary[@"oef_definitionTypeUri"] name:oefTypeDictionary[@"oef_name"] punchActionType:oefTypeDictionary[@"punchActionType"] numericValue:oefTypeDictionary[@"numericValue"] textValue:oefTypeDictionary[@"textValue"] dropdownOptionUri:oefTypeDictionary[@"dropdownOptionUri"] dropdownOptionValue:oefTypeDictionary[@"dropdownOptionValue"] collectAtTimeOfPunch:[oefTypeDictionary[@"collectAtTimeOfPunch"] boolValue] disabled:[oefTypeDictionary[@"disabled"] boolValue]];
        [oefTypes addObject:oefype];
    }
    return [oefTypes copy];
}

-(NSString *)filterStringFromPunchesArray:(NSArray *)punchesArray
{
    NSString *query = @"";
    for (id<Punch> punch in punchesArray)
    {
        if ([query isEqualToString:@""])
        {
            query = [NSString stringWithFormat:@"request_id!='%@'",punch.requestID];
        }
        else
        {
            query = [NSString stringWithFormat:@"%@ request_id!='%@' AND",query,punch.requestID];
        }

    }

    return query;
}

@end
