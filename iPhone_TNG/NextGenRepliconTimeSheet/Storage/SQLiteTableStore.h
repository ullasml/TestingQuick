#import <Foundation/Foundation.h>


@class QueryStringBuilder;
@protocol DatabaseConnection;


@interface SQLiteTableStore : NSObject

@property (nonatomic, copy, readonly) NSString *tableName;
@property (nonatomic, readonly) QueryStringBuilder *queryStringBuilder;
@property (nonatomic, readonly) id <DatabaseConnection> sqliteDatabaseConnection;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSqliteDatabaseConnection:(id<DatabaseConnection>)sqliteDatabaseConnection
                              queryStringBuilder:(QueryStringBuilder *)queryStringBuilder
                                    databaseName:(NSString *)databaseName
                                       tableName:(NSString *)tableName;

- (NSArray *)readAllRowsWithArgs:(NSDictionary *)argsDictionary;
- (NSDictionary *)readLastRowWithArgs:(NSDictionary *)argsDictionary;
- (void)insertRow:(NSDictionary *)argsDictionary;
- (void)updateRow:(NSDictionary *)argsDictionary whereClause:(NSDictionary *)whereClause;
- (void)deleteRowWithArgs:(NSDictionary *)argsDictionary;
- (void)deleteRowWithStringArgs:(NSString *)argsString;
- (NSDictionary *)readRowWhere:(NSDictionary *)whereFilters
               withMaxValueFor:(NSString *)columnName;
- (void)deleteAllRows;
- (NSArray *)readAllRowsFromColumn:(NSString *)column pattern:(NSString *)pattern;
- (NSArray *)readAllRowsFromColumnInAscending:(NSString *)column pattern:(NSString *)pattern orderedBy:(NSString *)columnName;
- (NSArray *)readAllRowsFromColumn:(NSString *)column where:(NSDictionary *)where pattern:(NSString *)pattern;
- (NSArray *)readAllRowsFromColumnInAscending:(NSString *)column where:(NSDictionary *)where pattern:(NSString *)pattern orderedBy:(NSString *)columnName;
- (NSArray *)readAllDistinctRowsFromColumn:(NSString *)column;
- (NSArray *)readAllRowsWithArgs:(NSDictionary *)whereFilters orderedBy:(NSString *)columnName;
- (NSArray *)readAllRowsInAscendingWithArgs:(NSDictionary *)whereFilters orderedBy:(NSString *)columnName;
- (NSArray *)readAllRowsWithWhere:(NSDictionary *)firstArgsDictionary
                         andWhere:(NSDictionary *)secondArgsDictionary
                          orWhere:(NSDictionary *)thirdArgsDictionary;
- (NSArray *)readAllRowsWithArgsString:(NSString *)argsString;
- (NSArray *)readRowWhere:(NSDictionary *)whereFilters
                      rowLimit:(NSUInteger)rowLimit
               withMaxValueFor:(NSString *)columnName;
- (NSArray*)readAllRows;
@end
