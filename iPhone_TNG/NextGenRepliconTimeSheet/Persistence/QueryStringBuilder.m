#import "QueryStringBuilder.h"
#import "InsertQuery.h"


@interface QueryStringBuilder ()

@property (nonatomic) NSDateFormatter *dateFormatter;

@end


@implementation QueryStringBuilder

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";

    }
    return self;
}

- (NSString *)insertStatementForTable:(NSString *) tableName args:(NSDictionary *)argsDictionary
{
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    NSMutableArray *values = [[NSMutableArray alloc] init];

    for (NSString *key in argsDictionary)
    {
        [keys addObject:key];

        id object = argsDictionary[key];
        if ([object isKindOfClass:[NSString class]])
        {
            [values addObject:[NSString stringWithFormat:@"'%@'", object]];
        }
        else if ([object isKindOfClass:[NSDate class]])
        {
            NSString *dateString = [NSString stringWithFormat:@"'%@'", [self.dateFormatter stringFromDate:object]];
            [values addObject:dateString];
        }
        else if ([object isKindOfClass:[NSData class]])
        {
            [values addObject:object];
        }
        else
        {
            [values addObject:[object description]];
        }
    }

    NSString *columnsList = [NSString stringWithFormat:@"(%@)", [keys componentsJoinedByString:@", "]];
    NSString *valuesList = [NSString stringWithFormat:@"(%@)", [values componentsJoinedByString:@", "]];

    return [NSString stringWithFormat:@"INSERT INTO %@ %@ VALUES %@", tableName, columnsList, valuesList];
}

- (InsertQuery *) insertQueryForTable:(NSString *) tableName args:(NSDictionary *)argsDictionary
{
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSMutableArray *positions = [[NSMutableArray alloc] init];

    for (NSString *key in argsDictionary)
    {
        [keys addObject:key];
        [positions addObject:@"?"];

        id object = argsDictionary[key];
        if ([object isKindOfClass:[NSString class]])
        {
            [values addObject:object];
        }
        else if ([object isKindOfClass:[NSDate class]])
        {
            NSString *dateString = [NSString stringWithFormat:@"%@", [self.dateFormatter stringFromDate:object]];
            [values addObject:dateString];
        }
        else if ([object isKindOfClass:[NSData class]])
        {
            [values addObject:object];
        }
        else
        {
            [values addObject:[object description]];
        }
    }

    NSString *columnsList = [NSString stringWithFormat:@"(%@)", [keys componentsJoinedByString:@", "]];
    NSString *positionsList = [NSString stringWithFormat:@"(%@)", [positions componentsJoinedByString:@", "]];
    NSString *query = [NSString stringWithFormat:@"insert into %@ %@ values %@", tableName, columnsList, positionsList];
    InsertQuery *insertQuery = [[InsertQuery alloc] initWithValueArguments:values query:query];

    return insertQuery;
}

- (NSString *) updateStatementForTable:(NSString *) tableName args:(NSDictionary *)argsDictionary andWhereClauseDictionary:(NSDictionary *)whereClauseDict
{
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    NSMutableArray *values = [[NSMutableArray alloc] init];

    
    for (NSString *key in argsDictionary)
    {
        [keys addObject:key];

        id object = argsDictionary[key];
        if ([object isKindOfClass:[NSString class]]) {
            [values addObject:[NSString stringWithFormat:@"%@", object]];
        } else {
            [values addObject:[object description]];
        }
    }
    __block NSMutableArray *columnsAndValues = [[NSMutableArray alloc] init];

    [keys enumerateObjectsUsingBlock:^(NSString *column, NSUInteger idx, BOOL *stop) {
        NSString *columnAndValue = [NSString stringWithFormat:@"%@ = '%@'", column, values[idx]];
        [columnsAndValues addObject:columnAndValue];
    }];

    NSString *columnAndValuesString = [columnsAndValues componentsJoinedByString:@","];

    NSString *userURI = [argsDictionary valueForKey:@"user_uri"];

    NSString *whereString = [NSString stringWithFormat:@"%@ = '%@'",@"user_uri", userURI];
    if (whereClauseDict)
    {
        whereString = [self whereClauseWithDictionary:whereClauseDict];
    }


    return [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@", tableName, columnAndValuesString, whereString];
}


- (NSString *)selectStatementForTable:(NSString *)tableName withRowLimit:(NSUInteger)limit
{
    return [NSString stringWithFormat:@"SELECT * FROM %@ LIMIT %lu", tableName, (unsigned long)limit];
}

- (NSString *)selectStatementForTable:(NSString *)tableName withRowLimit:(NSUInteger)limit where:(NSDictionary *)whereClause
{
    NSString *whereString = [self whereClauseWithDictionary:whereClause];
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ LIMIT %lu", tableName, whereString, (unsigned long)limit];
}

- (NSString *)selectStatementForTable:(NSString *)tableName
                         withRowLimit:(NSUInteger)limit
                                where:(NSDictionary *)whereClause
                            orderedBy:(NSString *)orderedBy
{
    NSString *whereString = [self whereClauseWithDictionary:whereClause];
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ ORDER BY %@ DESC LIMIT %lu", tableName, whereString, orderedBy, (unsigned long)limit];
}

- (NSString *) selectStatementForTable:(NSString *)tableName
{
    return [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
}

- (NSString *) selectStatementForTable:(NSString *)tableName where:(NSDictionary *)whereClause
{
    NSString *whereString = [self whereClauseWithDictionary:whereClause];
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@", tableName, whereString];
}

- (NSString *) selectStatementForTable:(NSString *)tableName where:(NSDictionary *)whereClause orderedBy:(NSString *)orderedBy
{
    NSString *whereString = [self whereClauseWithDictionary:whereClause];
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ ORDER BY %@ DESC", tableName, whereString,orderedBy];
}

- (NSString *)selectStatementForTableInAscending:(NSString *)tableName where:(NSDictionary *)whereClause orderedBy:(NSString *)orderedBy
{
    NSString *whereString = [self whereClauseWithDictionary:whereClause];
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ ORDER BY %@ ASC", tableName, whereString,orderedBy];
}

- (NSString *) selectStatementForTable:(NSString *)tableName
                            columnName:(NSString *)columnName
                               pattern:(NSString *)pattern
{
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE LOWER(%@) LIKE LOWER('%%%@%%')", tableName,columnName,pattern];
}

- (NSString *) selectStatementForTableInAscending:(NSString *)tableName
                            columnName:(NSString *)columnName
                               pattern:(NSString *)pattern
                             orderedBy:(NSString *)orderedBy
{
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE LOWER(%@) LIKE LOWER('%%%@%%') ORDER BY %@ ASC", tableName,columnName,pattern,orderedBy];
}

- (NSString *) selectStatementForTable:(NSString *)tableName
                            columnName:(NSString *)columnName
                               pattern:(NSString *)pattern
                                 where:(NSDictionary *)whereClause
{
    NSString *whereString = [self whereClauseWithDictionary:whereClause];
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE LOWER(%@) LIKE LOWER('%%%@%%') AND %@", tableName,columnName,pattern,whereString];
}

- (NSString *) selectStatementForTableInAscending:(NSString *)tableName
                            columnName:(NSString *)columnName
                               pattern:(NSString *)pattern
                                 where:(NSDictionary *)whereClause
                             orderedBy:(NSString *)orderedBy
{
    NSString *whereString = [self whereClauseWithDictionary:whereClause];
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE LOWER(%@) LIKE LOWER('%%%@%%') AND %@ ORDER BY %@ ASC", tableName,columnName,pattern,whereString,orderedBy];
}


- (NSString *) selectStatementForTableWithANDORCondition:(NSString *)tableName
                                          firstCondition:(NSDictionary *)firstCondition
                                         secondCondition:(NSDictionary *)secondCondition
                                          thirdCondition:(NSDictionary *)thirdCondition
{
    NSString *firstConditionWhereString = [self whereClauseWithDictionary:firstCondition];
    NSString *secondConditionWhereString = [self whereClauseWithDictionary:secondCondition];
    NSString *thirdConditionWhereString = [self whereClauseWithDictionary:thirdCondition];
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ AND (%@ OR %@)", tableName, firstConditionWhereString, secondConditionWhereString, thirdConditionWhereString];
}

- (NSString *)selectStatementForTable:(NSString *)tableName whereString:(NSString*)whereString
{
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@", tableName, whereString];
}


- (NSString *) deleteStatementForTable:(NSString *)tableName where:(NSDictionary *)whereClause
{
    NSString *whereString = [self whereClauseWithDictionary:whereClause];
    return [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", tableName, whereString];
}

- (NSString *) deleteStatementForTable:(NSString *)tableName
{
    return [NSString stringWithFormat:@"DELETE FROM %@", tableName];
}

- (NSString *) deleteStatementForTable:(NSString *)tableName whereString:(NSString *)whereClauseinString
{
    return [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", tableName, whereClauseinString];
}

- (NSString *)distinctStatementForTable:(NSString *)tableName columnName:(NSString *)columnName
{
    return [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM %@",columnName,tableName];
}

#pragma mark - Private

- (NSString *)whereClauseWithDictionary:(NSDictionary *)whereClause
{
    NSMutableArray *whereClauseComponents = [[NSMutableArray alloc] init];
    for (NSString *key in whereClause) {
        NSString *valueString;
        id value = whereClause[key];
        if ([whereClause[key] isKindOfClass:[NSString class]]) {
            valueString = [NSString stringWithFormat:@"'%@'", value];
        }
        else if ([whereClause[key] isKindOfClass:[NSDate class]])
        {
            NSString *dateString = [NSString stringWithFormat:@"'%@'", [self.dateFormatter stringFromDate:value]];
            valueString = dateString;
        }
        else {
            valueString = whereClause[key];
        }

        [whereClauseComponents addObject:[NSString stringWithFormat:@"%@ = %@", key, valueString]];
    }
    [whereClauseComponents sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    return [whereClauseComponents componentsJoinedByString:@" AND "];
}

@end
