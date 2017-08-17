#import "SQLiteTableStore.h"
#import <repliconkit/repliconkit.h>
#import "QueryStringBuilder.h"
#import "SQLiteDatabaseConnection.h"
#import "InsertQuery.h"


@interface SQLiteTableStore ()

@property (nonatomic, copy) NSString *tableName;
@property (nonatomic) QueryStringBuilder *queryStringBuilder;
@property (nonatomic) id <DatabaseConnection> sqliteDatabaseConnection;

@property (nonatomic) FMDatabase *database;

@end


@implementation SQLiteTableStore

- (instancetype)initWithSqliteDatabaseConnection:(id<DatabaseConnection>)sqliteDatabaseConnection
                              queryStringBuilder:(QueryStringBuilder *)queryStringBuilder
                                    databaseName:(NSString *)databaseName
                                       tableName:(NSString *)tableName
{
    self = [super init];
    if (self) {
        self.tableName = tableName;
        self.queryStringBuilder = queryStringBuilder;
        self.sqliteDatabaseConnection = sqliteDatabaseConnection;
        [self.sqliteDatabaseConnection openOrCreateDatabase:databaseName];
    }
    return self;
}

- (void)insertRow:(NSDictionary *)argsDictionary
{
    InsertQuery *query = [self.queryStringBuilder insertQueryForTable:self.tableName args:argsDictionary];

    [self.sqliteDatabaseConnection executeUpdate:query.query args:query.valueArguments];
}

- (void)updateRow:(NSDictionary *)argsDictionary whereClause:(NSDictionary *)whereClause
{
    NSString *queryString = [self.queryStringBuilder updateStatementForTable:self.tableName args:argsDictionary andWhereClauseDictionary:whereClause];

    [self.sqliteDatabaseConnection executeUpdate:queryString];
}

- (NSArray*)readAllRows {
    NSString *queryString = [self.queryStringBuilder selectStatementForTable:self.tableName];
    return [self.sqliteDatabaseConnection executeQuery:queryString];
}

- (NSArray *)readAllRowsWithArgs:(NSDictionary *)argsDictionary
{
    NSString *queryString = [self.queryStringBuilder selectStatementForTable:self.tableName
                                                                       where:argsDictionary];
    return [self.sqliteDatabaseConnection executeQuery:queryString];
}

- (NSArray *)readAllRowsWithWhere:(NSDictionary *)firstArgsDictionary
                         andWhere:(NSDictionary *)secondArgsDictionary
                          orWhere:(NSDictionary *)thirdArgsDictionary
{
    NSString *queryString = [self.queryStringBuilder selectStatementForTableWithANDORCondition:self.tableName
                                                                                firstCondition:firstArgsDictionary
                                                                               secondCondition:secondArgsDictionary
                                                                                thirdCondition:thirdArgsDictionary];
    return [self.sqliteDatabaseConnection executeQuery:queryString];
}

- (NSArray *)readAllRowsWithArgsString:(NSString *)argsString
{
    NSString *queryString = [self.queryStringBuilder selectStatementForTable:self.tableName
                                                                       whereString:argsString];
    return [self.sqliteDatabaseConnection executeQuery:queryString];
}


- (NSDictionary *)readLastRowWithArgs:(NSDictionary *)argsDictionary
{
    NSString *queryString = [self.queryStringBuilder selectStatementForTable:self.tableName
                                                                withRowLimit:1
                                                                       where:argsDictionary];
    return [[self.sqliteDatabaseConnection executeQuery:queryString] firstObject];
}

- (void)deleteRowWithArgs:(NSDictionary *)argsDictionary
{
    NSString *queryString = [self.queryStringBuilder deleteStatementForTable:self.tableName where:argsDictionary];

    [self.sqliteDatabaseConnection executeUpdate:queryString];
}

- (void)deleteRowWithStringArgs:(NSString *)argsString
{
    NSString *queryString = [self.queryStringBuilder deleteStatementForTable:self.tableName whereString:argsString];

    [self.sqliteDatabaseConnection executeUpdate:queryString];
}

- (void)deleteAllRows
{
    NSString *queryString = [self.queryStringBuilder deleteStatementForTable:self.tableName];
    [self.sqliteDatabaseConnection executeUpdate:queryString];
}

- (NSDictionary *)readRowWhere:(NSDictionary *)whereFilters
               withMaxValueFor:(NSString *)columnName
{
    NSString *queryString = [self.queryStringBuilder selectStatementForTable:self.tableName
                                                                withRowLimit:1
                                                                       where:whereFilters
                                                                   orderedBy:columnName];

    return [[self.sqliteDatabaseConnection executeQuery:queryString] firstObject];
}

- (NSArray *)readRowWhere:(NSDictionary *)whereFilters
               rowLimit:(NSUInteger)rowLimit
               withMaxValueFor:(NSString *)columnName
{
    NSString *queryString = [self.queryStringBuilder selectStatementForTable:self.tableName
                                                                withRowLimit:rowLimit
                                                                       where:whereFilters
                                                                   orderedBy:columnName];
    
    return [self.sqliteDatabaseConnection executeQuery:queryString];
}


- (NSArray *)readAllRowsWithArgs:(NSDictionary *)whereFilters orderedBy:(NSString *)columnName
{
    NSString *queryString = [self.queryStringBuilder selectStatementForTable:self.tableName
                                                                       where:whereFilters
                                                                   orderedBy:columnName];

    return [self.sqliteDatabaseConnection executeQuery:queryString];
}

- (NSArray *)readAllRowsInAscendingWithArgs:(NSDictionary *)whereFilters orderedBy:(NSString *)columnName
{
    NSString *queryString = [self.queryStringBuilder selectStatementForTableInAscending:self.tableName
                                                                       where:whereFilters
                                                                   orderedBy:columnName];

    return [self.sqliteDatabaseConnection executeQuery:queryString];
}

- (NSArray *)readAllRowsFromColumn:(NSString *)column pattern:(NSString *)pattern
{
    NSString *queryString = [self.queryStringBuilder selectStatementForTable:self.tableName
                                                                  columnName:column
                                                                     pattern:pattern];
    return [self.sqliteDatabaseConnection executeQuery:queryString];
}

- (NSArray *)readAllRowsFromColumnInAscending:(NSString *)column pattern:(NSString *)pattern orderedBy:(NSString *)columnName
{
    NSString *queryString = [self.queryStringBuilder selectStatementForTableInAscending:self.tableName
                                                                  columnName:column
                                                                     pattern:pattern
                                                                   orderedBy:columnName];
    return [self.sqliteDatabaseConnection executeQuery:queryString];
}


- (NSArray *)readAllRowsFromColumn:(NSString *)column where:(NSDictionary *)where pattern:(NSString *)pattern
{
    NSString *queryString = [self.queryStringBuilder selectStatementForTable:self.tableName
                                                                  columnName:column
                                                                     pattern:pattern
                                                                       where:where];
    return [self.sqliteDatabaseConnection executeQuery:queryString];
}

- (NSArray *)readAllRowsFromColumnInAscending:(NSString *)column where:(NSDictionary *)where pattern:(NSString *)pattern orderedBy:(NSString *)columnName
{
    NSString *queryString = [self.queryStringBuilder selectStatementForTableInAscending:self.tableName
                                                                  columnName:column
                                                                     pattern:pattern
                                                                       where:where
                                                                   orderedBy:columnName];
    return [self.sqliteDatabaseConnection executeQuery:queryString];
}


- (NSArray *)readAllDistinctRowsFromColumn:(NSString *)column
{
    NSString *queryString = [self.queryStringBuilder distinctStatementForTable:self.tableName
                                                                    columnName:column];
    return [self.sqliteDatabaseConnection executeQuery:queryString];
}


@end
