#import <Cedar/Cedar.h>
#import "SQLiteTableStore.h"
#import "UserSession.h"
#import "QueryStringBuilder.h"
#import "SQLiteDatabaseConnection.h"
#import "InsertQuery.h"
#import "Enum.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SQLiteTableStoreSpec)

describe(@"SQLiteTableStore", ^{
    __block SQLiteTableStore *subject;
    __block QueryStringBuilder *queryStringBuilder;
    __block SQLiteDatabaseConnection *databaseConnection;

    beforeEach(^{
        queryStringBuilder = nice_fake_for([QueryStringBuilder class]);
        databaseConnection = nice_fake_for([SQLiteDatabaseConnection class]);

        subject = [[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:databaseConnection
                                                          queryStringBuilder:queryStringBuilder
                                                                databaseName:@"some_database"
                                                                   tableName:@"some_table"];
    });

    it(@"should ask its database connection to open the database", ^{
        databaseConnection should have_received(@selector(openOrCreateDatabase:))
        .with(@"some_database");
    });

    describe(@"-insertRow:", ^{
        InsertQuery *query = [[InsertQuery alloc] initWithValueArguments:@[@"value1", @"value2"] query:@"an expected query"];
        NSDictionary *expectedArgs = @{@"column": @"value"};

        beforeEach(^{
            queryStringBuilder stub_method(@selector(insertQueryForTable:args:))
            .with(@"some_table", expectedArgs)
            .and_return(query);

            [subject insertRow:@{@"column": @"value"}];
        });

        it(@"should get its query string from the query string builder", ^{
            queryStringBuilder should have_received(@selector(insertQueryForTable:args:))
            .with(@"some_table", expectedArgs);
        });

        it(@"should ask the database connection to execute the update query", ^{
            databaseConnection should have_received(@selector(executeUpdate:args:))
            .with(@"an expected query", @[@"value1", @"value2"]);
        });
    });

    describe(@"-updateRow:whereClause:", ^{
        NSString *queryString = @"sql-statement-goes-here";
        NSDictionary *expectedArgs = @{@"column": @"value"};
        NSDictionary *whereClause = @{@"user_uri": @"my-special-user-uri"};

        beforeEach(^{
            queryStringBuilder stub_method(@selector(updateStatementForTable:args:andWhereClauseDictionary:))
            .with(@"some_table", expectedArgs, whereClause)
            .and_return(queryString);

            [subject updateRow:@{@"column":@"value"} whereClause:@{@"user_uri": @"my-special-user-uri"}];
        });

        it(@"should get its query string from the query string builder", ^{
            queryStringBuilder should have_received(@selector(updateStatementForTable:args:andWhereClauseDictionary:))
            .with(@"some_table", expectedArgs, whereClause);
        });

        it(@"should ask the database connection to execute the update query", ^{
            databaseConnection should have_received(@selector(executeUpdate:))
            .with(queryString);
        });
    });

    describe(@"-readAllRows", ^{
        __block NSArray *returnedDictionaryArray;
        __block NSArray *expectedDictionaryArray;
        NSString *selectQuery = @"select-all-the-things";
        beforeEach(^{
            queryStringBuilder stub_method(@selector(selectStatementForTable:))
            .with(@"some_table")
            .and_return(selectQuery);

            expectedDictionaryArray = @[@{@"column-name": @"value"}];
            databaseConnection stub_method(@selector(executeQuery:))
            .with(selectQuery)
            .and_return(expectedDictionaryArray);

            returnedDictionaryArray = [subject readAllRows];
        });

        it(@"should get its query string from the query string builder", ^{
            queryStringBuilder should have_received(@selector(selectStatementForTable:))
            .with(@"some_table");
        });

        it(@"should ask the database connection to execute the select query", ^{
            databaseConnection should have_received(@selector(executeQuery:))
            .with(selectQuery);
        });

        it(@"should return the row from the database", ^{
            returnedDictionaryArray should be_same_instance_as(expectedDictionaryArray);
        });
    });

    describe(@"-readAllRowsWithArgs:", ^{
        __block NSArray *returnedDictionaryArray;
        __block NSArray *expectedDictionaryArray;
        NSString *selectQuery = @"select-all-the-things";

        beforeEach(^{
            queryStringBuilder stub_method(@selector(selectStatementForTable:where:))
            .with(@"some_table", @{@"user_uri": @"my-special-user-uri"})
            .and_return(selectQuery);

            expectedDictionaryArray = @[@{@"column-name": @"value"}];
            databaseConnection stub_method(@selector(executeQuery:))
            .with(selectQuery)
            .and_return(expectedDictionaryArray);

            returnedDictionaryArray = [subject readAllRowsWithArgs:@{@"user_uri": @"my-special-user-uri"}];
        });

        it(@"should get its query string from the query string builder", ^{
            queryStringBuilder should have_received(@selector(selectStatementForTable:where:))
            .with(@"some_table", @{@"user_uri": @"my-special-user-uri"});
        });

        it(@"should ask the database connection to execute the select query", ^{
            databaseConnection should have_received(@selector(executeQuery:))
            .with(selectQuery);
        });

        it(@"should return the row from the database", ^{
            returnedDictionaryArray should be_same_instance_as(expectedDictionaryArray);
        });
    });

    describe(@"-readLastRowWithArgs:", ^{
        __block NSDictionary *returnedDictionary;
        __block NSDictionary *expectedDictionary;
        NSString *selectQuery = @"select-all-the-things";

        beforeEach(^{
            queryStringBuilder stub_method(@selector(selectStatementForTable:withRowLimit:where:))
            .with(@"some_table", (NSUInteger)1, @{@"user_uri": @"my-special-user-uri"})
            .and_return(selectQuery);

            expectedDictionary = @{@"column-name": @"value"};
            databaseConnection stub_method(@selector(executeQuery:))
            .with(selectQuery)
            .and_return(@[expectedDictionary]);

            returnedDictionary = [subject readLastRowWithArgs:@{@"user_uri": @"my-special-user-uri"}];
        });

        it(@"should get its query string from the query string builder", ^{
            queryStringBuilder should have_received(@selector(selectStatementForTable:withRowLimit:where:))
            .with(@"some_table", (NSUInteger)1, @{@"user_uri": @"my-special-user-uri"});
        });

        it(@"should ask the database connection to execute the select query", ^{
            databaseConnection should have_received(@selector(executeQuery:))
            .with(selectQuery);
        });

        it(@"should return the row from the database", ^{
            returnedDictionary should be_same_instance_as(expectedDictionary);
        });
    });

    describe(@"-deleteRowWithArgs:", ^{
        NSString *queryString = @"sql-statement-goes-here";
        NSDictionary *expectedArgs = @{@"column": @"value"};

        beforeEach(^{
            queryStringBuilder stub_method(@selector(deleteStatementForTable:where:))
            .with(@"some_table", expectedArgs)
            .and_return(queryString);

            [subject deleteRowWithArgs:@{@"column": @"value"}];
        });

        it(@"should get its query string from the query string builder", ^{
            queryStringBuilder should have_received(@selector(deleteStatementForTable:where:))
            .with(@"some_table", expectedArgs);
        });

        it(@"should ask the database connection to execute the update query", ^{
            databaseConnection should have_received(@selector(executeUpdate:))
            .with(queryString);
        });
    });

    describe(@"-deleteRowWithArgs:", ^{
        NSString *queryString = @"sql-statement-goes-here";
        NSString *expectedArgs = @"user_uri != 'user:uri'";

        beforeEach(^{
            queryStringBuilder stub_method(@selector(deleteStatementForTable:whereString:))
            .with(@"some_table", expectedArgs)
            .and_return(queryString);

            [subject deleteRowWithStringArgs:@"user_uri != 'user:uri'"];
        });

        it(@"should get its query string from the query string builder", ^{
            queryStringBuilder should have_received(@selector(deleteStatementForTable:whereString:))
            .with(@"some_table", expectedArgs);
        });

        it(@"should ask the database connection to execute the update query", ^{
            databaseConnection should have_received(@selector(executeUpdate:))
            .with(queryString);
        });
    });

    describe(@"-deleteAllRows:", ^{
        NSString *queryString = @"sql-statement-goes-here";

        beforeEach(^{
            queryStringBuilder stub_method(@selector(deleteStatementForTable:))
            .with(@"some_table")
            .and_return(queryString);

            [subject deleteAllRows];
        });

        it(@"should get its query string from the query string builder", ^{
            queryStringBuilder should have_received(@selector(deleteStatementForTable:))
            .with(@"some_table");
        });

        it(@"should ask the database connection to execute the update query", ^{
            databaseConnection should have_received(@selector(executeUpdate:))
            .with(queryString);
        });
    });

    describe(@"-readRowWithMaxValueFor:", ^{
        __block NSDictionary *returnedDictionary;
        __block NSDictionary *expectedDictionary;
        NSString *selectQuery = @"select-all-the-things";

        beforeEach(^{
            queryStringBuilder stub_method(@selector(selectStatementForTable:withRowLimit:where:orderedBy:))
            .with(@"some_table", (NSUInteger)1, @{@"user_uri": @"my-special-user-uri"}, @"the_column_we_want_to_order_by")
            .and_return(selectQuery);

            expectedDictionary = @{@"column-name": @"value"};
            databaseConnection stub_method(@selector(executeQuery:))
            .with(selectQuery)
            .and_return(@[expectedDictionary]);

            returnedDictionary = [subject readRowWhere:@{@"user_uri": @"my-special-user-uri"}
                                       withMaxValueFor:@"the_column_we_want_to_order_by"];
        });

        it(@"should get its query string from the query string builder", ^{
            queryStringBuilder should have_received(@selector(selectStatementForTable:withRowLimit:where:orderedBy:))
            .with(@"some_table", (NSUInteger)1, @{@"user_uri": @"my-special-user-uri"}, @"the_column_we_want_to_order_by");
        });

        it(@"should ask the database connection to execute the select query", ^{
            databaseConnection should have_received(@selector(executeQuery:))
            .with(selectQuery);
        });

        it(@"should return the row from the database", ^{
            returnedDictionary should be_same_instance_as(expectedDictionary);
        });
    });
    
    describe(@"-readRowWithMaxValueFor:", ^{
        __block NSArray *returnedArray;
        __block NSArray *expectedArray;
        NSString *selectQuery = @"select-all-the-things";
        
        beforeEach(^{
            queryStringBuilder stub_method(@selector(selectStatementForTable:withRowLimit:where:orderedBy:))
            .with(@"some_table", (NSUInteger)2, @{@"user_uri": @"my-special-user-uri"}, @"the_column_we_want_to_order_by")
            .and_return(selectQuery);
            
            expectedArray = @[@{@"column-name": @"value"}, @{@"column-name": @"value"}];
            databaseConnection stub_method(@selector(executeQuery:))
            .with(selectQuery)
            .and_return(@[expectedArray]);
            
            returnedArray = [subject readRowWhere:@{@"user_uri": @"my-special-user-uri"}
                                       rowLimit:2
                                       withMaxValueFor:@"the_column_we_want_to_order_by"];
        });
        
        it(@"should get its query string from the query string builder", ^{
            queryStringBuilder should have_received(@selector(selectStatementForTable:withRowLimit:where:orderedBy:))
            .with(@"some_table", (NSUInteger)2, @{@"user_uri": @"my-special-user-uri"}, @"the_column_we_want_to_order_by");
        });
        
        it(@"should ask the database connection to execute the select query", ^{
            databaseConnection should have_received(@selector(executeQuery:))
            .with(selectQuery);
        });
        
        it(@"should return the row from the database", ^{
            returnedArray[0] should equal(expectedArray);
        });
    });

    describe(@"-readAllRowsFromColumn:pattern:", ^{
        __block NSArray *returnedDictionaryArray;
        __block NSArray *expectedDictionaryArray;
        NSString *selectQuery = @"select-all-the-things";

        beforeEach(^{
            queryStringBuilder stub_method(@selector(selectStatementForTable:columnName:pattern:)).with(@"some_table",@"column_name",@"pattern").and_return(selectQuery);

            expectedDictionaryArray = @[@{@"column-name": @"value"}];
            databaseConnection stub_method(@selector(executeQuery:))
            .with(selectQuery)
            .and_return(expectedDictionaryArray);

            returnedDictionaryArray =  [subject readAllRowsFromColumn:@"column_name" pattern:@"pattern"];
        });

        it(@"should get its query string from the query string builder", ^{
            queryStringBuilder should have_received(@selector(selectStatementForTable:columnName:pattern:))
            .with(@"some_table",@"column_name",@"pattern");
        });

        it(@"should ask the database connection to execute the select query", ^{
            databaseConnection should have_received(@selector(executeQuery:))
            .with(selectQuery);
        });
        
        it(@"should return the row from the database", ^{
            returnedDictionaryArray should be_same_instance_as(expectedDictionaryArray);
        });
    });

    describe(@"readAllRowsFromColumnInAscending:pattern:orderedBy", ^{
        __block NSArray *returnedDictionaryArray;
        __block NSArray *expectedDictionaryArray;
        NSString *selectQuery = @"select-all-the-things";

        beforeEach(^{
            queryStringBuilder stub_method(@selector(selectStatementForTableInAscending:columnName:pattern:orderedBy:)).with(@"some_table",@"column_name",@"pattern",@"column_name").and_return(selectQuery);

            expectedDictionaryArray = @[@{@"column-name": @"value"}];
            databaseConnection stub_method(@selector(executeQuery:))
            .with(selectQuery)
            .and_return(expectedDictionaryArray);

            returnedDictionaryArray =  [subject readAllRowsFromColumnInAscending:@"column_name" pattern:@"pattern" orderedBy:@"column_name"];
        });

        it(@"should get its query string from the query string builder", ^{
            queryStringBuilder should have_received(@selector(selectStatementForTableInAscending:columnName:pattern:orderedBy:))
            .with(@"some_table",@"column_name",@"pattern",@"column_name");
        });

        it(@"should ask the database connection to execute the select query", ^{
            databaseConnection should have_received(@selector(executeQuery:))
            .with(selectQuery);
        });

        it(@"should return the row from the database", ^{
            returnedDictionaryArray should be_same_instance_as(expectedDictionaryArray);
        });
    });

    describe(@"readAllRowsFromColumn:where:pattern", ^{
        __block NSArray *returnedDictionaryArray;
        __block NSArray *expectedDictionaryArray;
        NSString *selectQuery = @"select-all-the-things";

        beforeEach(^{
            queryStringBuilder stub_method(@selector(selectStatementForTable:columnName:pattern:where:)).with(@"some_table",@"column_name",@"pattern",@{@"user_uri": @"my-special-user-uri"}).and_return(selectQuery);

            expectedDictionaryArray = @[@{@"column-name": @"value"}];
            databaseConnection stub_method(@selector(executeQuery:))
            .with(selectQuery)
            .and_return(expectedDictionaryArray);

            returnedDictionaryArray =  [subject readAllRowsFromColumn:@"column_name"
                                                                where:@{@"user_uri": @"my-special-user-uri"}
                                                              pattern:@"pattern"];
        });

        it(@"should get its query string from the query string builder", ^{
            queryStringBuilder should have_received(@selector(selectStatementForTable:columnName:pattern:where:))
            .with(@"some_table",@"column_name",@"pattern",@{@"user_uri": @"my-special-user-uri"});
        });

        it(@"should ask the database connection to execute the select query", ^{
            databaseConnection should have_received(@selector(executeQuery:))
            .with(selectQuery);
        });

        it(@"should return the row from the database", ^{
            returnedDictionaryArray should be_same_instance_as(expectedDictionaryArray);
        });

    });

    describe(@"readAllRowsFromColumnInAscending:where:pattern:orderedBy", ^{
        __block NSArray *returnedDictionaryArray;
        __block NSArray *expectedDictionaryArray;
        NSString *selectQuery = @"select-all-the-things";

        beforeEach(^{
            queryStringBuilder stub_method(@selector(selectStatementForTableInAscending:columnName:pattern:where:orderedBy:)).with(@"some_table",@"column_name",@"pattern",@{@"user_uri": @"my-special-user-uri"},@"column_name").and_return(selectQuery);

            expectedDictionaryArray = @[@{@"column-name": @"value"}];
            databaseConnection stub_method(@selector(executeQuery:))
            .with(selectQuery)
            .and_return(expectedDictionaryArray);

            returnedDictionaryArray =  [subject readAllRowsFromColumnInAscending:@"column_name"
                                                                where:@{@"user_uri": @"my-special-user-uri"}
                                                              pattern:@"pattern"
                                                                       orderedBy:@"column_name"];
        });

        it(@"should get its query string from the query string builder", ^{
            queryStringBuilder should have_received(@selector(selectStatementForTableInAscending:columnName:pattern:where:orderedBy:))
            .with(@"some_table",@"column_name",@"pattern",@{@"user_uri": @"my-special-user-uri"},@"column_name");
        });

        it(@"should ask the database connection to execute the select query", ^{
            databaseConnection should have_received(@selector(executeQuery:))
            .with(selectQuery);
        });

        it(@"should return the row from the database", ^{
            returnedDictionaryArray should be_same_instance_as(expectedDictionaryArray);
        });
        
    });

    describe(@"readAllDistinctRowsFromColumn", ^{
        __block NSArray *returnedDictionaryArray;
        __block NSArray *expectedDictionaryArray;
        NSString *selectQuery = @"select-all-the-things";

        beforeEach(^{
            queryStringBuilder stub_method(@selector(distinctStatementForTable:columnName:)).with(@"some_table",@"column_name").and_return(selectQuery);

            expectedDictionaryArray = @[@{@"column-name": @"value"}];
            databaseConnection stub_method(@selector(executeQuery:))
            .with(selectQuery)
            .and_return(expectedDictionaryArray);

            returnedDictionaryArray =  [subject readAllDistinctRowsFromColumn:@"column_name"];
        });

        it(@"should get its query string from the query string builder", ^{
            queryStringBuilder should have_received(@selector(distinctStatementForTable:columnName:))
            .with(@"some_table",@"column_name");
        });

        it(@"should ask the database connection to execute the select query", ^{
            databaseConnection should have_received(@selector(executeQuery:))
            .with(selectQuery);
        });

        it(@"should return the row from the database", ^{
            returnedDictionaryArray should be_same_instance_as(expectedDictionaryArray);
        });
        
    });

    describe(@"-readAllRowsWithArgs:orderedBy:", ^{
        __block NSArray *returnedDictionaryArray;
        __block NSArray *expectedDictionaryArray;
        NSString *selectQuery = @"select-all-the-things";

        beforeEach(^{
            queryStringBuilder stub_method(@selector(selectStatementForTable:where:orderedBy:))
            .with(@"some_table", @{@"user_uri": @"my-special-user-uri"},@"date")
            .and_return(selectQuery);

            expectedDictionaryArray = @[@{@"column-name": @"value"}];
            databaseConnection stub_method(@selector(executeQuery:))
            .with(selectQuery)
            .and_return(expectedDictionaryArray);

            returnedDictionaryArray = [subject readAllRowsWithArgs:@{@"user_uri": @"my-special-user-uri"} orderedBy:@"date"];
        });

        it(@"should get its query string from the query string builder", ^{
            queryStringBuilder should have_received(@selector(selectStatementForTable:where:orderedBy:))
            .with(@"some_table", @{@"user_uri": @"my-special-user-uri"},@"date");
        });

        it(@"should ask the database connection to execute the select query", ^{
            databaseConnection should have_received(@selector(executeQuery:))
            .with(selectQuery);
        });

        it(@"should return the row from the database", ^{
            returnedDictionaryArray should be_same_instance_as(expectedDictionaryArray);
        });
    });

    describe(@"-readAllRowsWithArgsInAscending:orderedBy:", ^{
        __block NSArray *returnedDictionaryArray;
        __block NSArray *expectedDictionaryArray;
        NSString *selectQuery = @"select-all-the-things";

        beforeEach(^{
            queryStringBuilder stub_method(@selector(selectStatementForTableInAscending:where:orderedBy:))
            .with(@"some_table", @{@"user_uri": @"my-special-user-uri"},@"date")
            .and_return(selectQuery);

            expectedDictionaryArray = @[@{@"column-name": @"value"}];
            databaseConnection stub_method(@selector(executeQuery:))
            .with(selectQuery)
            .and_return(expectedDictionaryArray);

            returnedDictionaryArray = [subject readAllRowsInAscendingWithArgs:@{@"user_uri": @"my-special-user-uri"} orderedBy:@"date"];
        });

        it(@"should get its query string from the query string builder", ^{
            queryStringBuilder should have_received(@selector(selectStatementForTableInAscending:where:orderedBy:))
            .with(@"some_table", @{@"user_uri": @"my-special-user-uri"},@"date");
        });

        it(@"should ask the database connection to execute the select query", ^{
            databaseConnection should have_received(@selector(executeQuery:))
            .with(selectQuery);
        });

        it(@"should return the row from the database", ^{
            returnedDictionaryArray should be_same_instance_as(expectedDictionaryArray);
        });
    });
    
    describe(@"-readAllRowsWithWhere:orWhere:", ^{
        __block NSArray *returnedDictionaryArray;
        __block NSArray *expectedDictionaryArray;
        __block NSDictionary *firstWhereClause;
        __block NSDictionary *secondWhereClause;
        __block NSDictionary *thirdWhereClause;
        NSString *selectQuery = @"select-all-the-things";
        
        beforeEach(^{
            firstWhereClause = @{@"user_uri":@"user_uri"};
            secondWhereClause = @{@"punchSyncStatus":@(PendingSyncStatus)};
            thirdWhereClause = @{@"punchSyncStatus":@(UnsubmittedSyncStatus)};
            queryStringBuilder stub_method(@selector(selectStatementForTableWithANDORCondition:firstCondition:secondCondition:thirdCondition:))
            .with(@"some_table", firstWhereClause, secondWhereClause, thirdWhereClause)
            .and_return(selectQuery);
            
            expectedDictionaryArray = @[@{@"column-name": @"value"}];
            databaseConnection stub_method(@selector(executeQuery:))
            .with(selectQuery)
            .and_return(expectedDictionaryArray);
            
            returnedDictionaryArray = [subject readAllRowsWithWhere:firstWhereClause andWhere:secondWhereClause orWhere:thirdWhereClause];
        });
        
        it(@"should get its query string from the query string builder", ^{
            queryStringBuilder should have_received(@selector(selectStatementForTableWithANDORCondition:firstCondition:secondCondition:thirdCondition:))
            .with(@"some_table", firstWhereClause, secondWhereClause, thirdWhereClause);
        });
        
        it(@"should ask the database connection to execute the select query", ^{
            databaseConnection should have_received(@selector(executeQuery:))
            .with(selectQuery);
        });
        
        it(@"should return the row from the database", ^{
            returnedDictionaryArray should be_same_instance_as(expectedDictionaryArray);
        });
    });
    
    describe(@"-selectStatementForTable:whereString:", ^{
        __block NSArray *returnedDictionaryArray;
        __block NSArray *expectedDictionaryArray;
        __block NSString *whereString;
        NSString *selectQuery = @"select-all-the-things";
        
        beforeEach(^{
            whereString = @"lastSyncTime < 5 AND syncStatus = Remote";
            queryStringBuilder stub_method(@selector(selectStatementForTable:whereString:))
            .with(@"some_table", whereString)
            .and_return(selectQuery);
            
            expectedDictionaryArray = @[@{@"column-name": @"value"}];
            databaseConnection stub_method(@selector(executeQuery:))
            .with(selectQuery)
            .and_return(expectedDictionaryArray);
            
            returnedDictionaryArray = [subject readAllRowsWithArgsString:whereString];
        });
        
        it(@"should get its query string from the query string builder", ^{
            queryStringBuilder should have_received(@selector(selectStatementForTable:whereString:))
            .with(@"some_table", whereString);
        });
        
        it(@"should ask the database connection to execute the select query", ^{
            databaseConnection should have_received(@selector(executeQuery:))
            .with(selectQuery);
        });
        
        it(@"should return the row from the database", ^{
            returnedDictionaryArray should be_same_instance_as(expectedDictionaryArray);
        });
    });

});

SPEC_END
