#import <Foundation/Foundation.h>


@class InsertQuery;


@interface QueryStringBuilder : NSObject

- (NSString *)insertStatementForTable:(NSString *)tableName args:(NSDictionary *)args;
- (InsertQuery *) insertQueryForTable:(NSString *) tableName args:(NSDictionary *)argsDictionary;

- (NSString *)selectStatementForTable:(NSString *)tableName withRowLimit:(NSUInteger)limit;
- (NSString *)selectStatementForTable:(NSString *)tableName withRowLimit:(NSUInteger)limit where:(NSDictionary *)whereClause;
- (NSString *)selectStatementForTable:(NSString *)tableName withRowLimit:(NSUInteger)limit where:(NSDictionary *)whereClause orderedBy:(NSString *)orderedBy;
- (NSString *) updateStatementForTable:(NSString *) tableName args:(NSDictionary *)argsDictionary andWhereClauseDictionary:(NSDictionary *)whereClauseDict;
- (NSString *)selectStatementForTable:(NSString *)tableName where:(NSDictionary *)whereClause;
- (NSString *)deleteStatementForTable:(NSString *)tableName where:(NSDictionary *)whereClause;
- (NSString *) deleteStatementForTable:(NSString *)tableName whereString:(NSString *)whereClauseinString;
- (NSString *) deleteStatementForTable:(NSString *)tableName;
- (NSString *) selectStatementForTable:(NSString *)tableName
                            columnName:(NSString *)columnName
                               pattern:(NSString *)pattern;
- (NSString *) selectStatementForTableInAscending:(NSString *)tableName
                            columnName:(NSString *)columnName
                               pattern:(NSString *)pattern
                             orderedBy:(NSString *)orderedBy;
- (NSString *) selectStatementForTable:(NSString *)tableName
                            columnName:(NSString *)columnName
                               pattern:(NSString *)pattern
                                 where:(NSDictionary *)whereClause;
- (NSString *) selectStatementForTableInAscending:(NSString *)tableName
                                       columnName:(NSString *)columnName
                                          pattern:(NSString *)pattern
                                            where:(NSDictionary *)whereClause
                                        orderedBy:(NSString *)orderedBy;
- (NSString *) selectStatementForTableWithANDORCondition:(NSString *)tableName
                                     firstCondition:(NSDictionary *)firstCondition
                                    secondCondition:(NSDictionary *)secondCondition
                                    thirdCondition:(NSDictionary *)thirdCondition;

- (NSString *)selectStatementForTable:(NSString *)tableName whereString:(NSString*)whereString;

- (NSString *)distinctStatementForTable:(NSString *)tableName columnName:(NSString *)columnName;
- (NSString *)selectStatementForTable:(NSString *)tableName where:(NSDictionary *)whereClause orderedBy:(NSString *)orderedBy;
- (NSString *)selectStatementForTableInAscending:(NSString *)tableName where:(NSDictionary *)whereClause orderedBy:(NSString *)orderedBy;
- (NSString *) selectStatementForTable:(NSString *)tableName;
@end
