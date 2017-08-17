#import <Cedar/Cedar.h>
#import "QueryStringBuilder.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(QueryStringBuilderSpec)

describe(@"QueryStringBuilder", ^{
    __block QueryStringBuilder *subject;

    beforeEach(^{
        subject = [[QueryStringBuilder alloc] init];
    });

    describe(@"creating an insert statement", ^{
        __block NSString *queryString;
        beforeEach(^{
            NSDictionary *args = @{@"name" : @"value", @"name2" : @"value2"};

            queryString = [subject insertStatementForTable:@"my_special_table" args:args];
        });

        it(@"should be the correct name", ^{
            queryString should equal(@"INSERT INTO my_special_table (name, name2) VALUES ('value', 'value2')");
        });
    });

    describe(@"Creating an SELECT statement", ^{
        __block NSString *queryString;

        beforeEach(^{
            queryString = [subject selectStatementForTable:@"my_special_table" withRowLimit:1];
        });

        it(@"should return the correct query string", ^{
            queryString should equal(@"SELECT * FROM my_special_table LIMIT 1");
        });
    });

    describe(@"Creating an DELETE statement", ^{
        __block NSString *queryString;

        beforeEach(^{
            queryString = [subject deleteStatementForTable:@"my-special-table"];
        });

        it(@"should return the correct query string", ^{
            queryString should equal(@"DELETE FROM my-special-table");
        });
    });

    describe(@"Creating an SELECT statement to select all rows", ^{
        __block NSString *queryString;

        beforeEach(^{
            queryString = [subject selectStatementForTable:@"my-special-table"];
        });

        it(@"should return the correct query string", ^{
            queryString should equal(@"SELECT * FROM my-special-table");
        });
    });

    describe(@"Creating an SELECT statement with a WHERE clause", ^{
        __block NSString *queryString;

        beforeEach(^{
            queryString = [subject selectStatementForTable:@"my_special_table" withRowLimit:1 where:@{@"bananas":@"tasty", @"age":@25}];
        });

        it(@"should return the correct query string", ^{
            queryString should equal(@"SELECT * FROM my_special_table WHERE age = 25 AND bananas = 'tasty' LIMIT 1");
        });
    });

    describe(@"Creating an SELECT statement with a WHERE clause and LIKE operator", ^{
        __block NSString *queryString;

        beforeEach(^{

            queryString = [subject selectStatementForTable:@"my_special_table"
                                                columnName:@"bananas"
                                                   pattern:@"match"];
        });

        it(@"should return the correct query string", ^{
            queryString should equal(@"SELECT * FROM my_special_table WHERE LOWER(bananas) LIKE LOWER('%match%')");
                                       
        });

    });

    describe(@"Creating an SELECT statement with a WHERE clause and LIKE operator and Ascending Order", ^{
        __block NSString *queryString;

        beforeEach(^{

            queryString = [subject selectStatementForTableInAscending:@"my_special_table"
                                                columnName:@"bananas"
                                                   pattern:@"match"
                                                 orderedBy:@"bananas"];
        });

        it(@"should return the correct query string", ^{
            queryString should equal(@"SELECT * FROM my_special_table WHERE LOWER(bananas) LIKE LOWER('%match%') ORDER BY bananas ASC");

        });

    });

    describe(@"-selectStatementForTable:where:", ^{
        __block NSString *queryString;

        beforeEach(^{
            queryString = [subject selectStatementForTable:@"my_special_table" where:@{@"bananas":@"tasty", @"age":@25}];
        });

        it(@"should return the correct query string", ^{
            queryString should equal(@"SELECT * FROM my_special_table WHERE age = 25 AND bananas = 'tasty'");
        });
    });

    describe(@"-selectStatementForTable:where:", ^{
        __block NSString *queryString;
        
        beforeEach(^{
            queryString = [subject selectStatementForTable:@"my_special_table" whereString:@"lastSyncTime < 5 AND syncStatus = Remote"];
        });
        
        it(@"should return the correct query string", ^{
            queryString should equal(@"SELECT * FROM my_special_table WHERE lastSyncTime < 5 AND syncStatus = Remote");
        });
    });

    describe(@"-deleteStatementForTable:args:", ^{
        __block NSString *queryString;

        context(@"with dictionary as args", ^{
            beforeEach(^{
                queryString = [subject deleteStatementForTable:@"my_special_table" where:@{@"bananas":@"tasty", @"date": [NSDate dateWithTimeIntervalSince1970:10]}];
            });

            it(@"should return the correct query string", ^{
                queryString should equal(@"DELETE FROM my_special_table WHERE bananas = 'tasty' AND date = '1970-01-01 00:00:10'");
            });
        });

        context(@"with string as args", ^{
            beforeEach(^{
                queryString = [subject deleteStatementForTable:@"my_special_table" whereString:@"user_uri != 'user:uri'"];
            });

            it(@"should return the correct query string", ^{
                queryString should equal(@"DELETE FROM my_special_table WHERE user_uri != 'user:uri'");
            });
        });

    });

    

    describe(@"-selectStatementForTable:withRowLimit:where:orderBy:", ^{
        __block NSString *queryString;

        beforeEach(^{
            queryString = [subject selectStatementForTable:@"my_special_table"
                                              withRowLimit:1
                                                     where:@{@"bananas":@"tasty", @"age":@25}
                                                 orderedBy:@"date"];
        });

        it(@"should return the correct query string", ^{
            queryString should equal(@"SELECT * FROM my_special_table WHERE age = 25 AND bananas = 'tasty' ORDER BY date DESC LIMIT 1");
        });
    });
    

    describe(@"Creating an SELECT statement with a WHERE clause and LIKE operator with WHERE clause", ^{
        __block NSString *queryString;

        beforeEach(^{

            queryString = [subject selectStatementForTable:@"my_special_table"
                                                columnName:@"bananas"
                                                   pattern:@"match"
                                                     where:@{@"age":@25}];

        });

        it(@"should return the correct query string", ^{
            queryString should equal(@"SELECT * FROM my_special_table WHERE LOWER(bananas) LIKE LOWER('%match%') AND age = 25");

        });

    });

    describe(@"Creating an SELECT statement with a WHERE clause and LIKE operator with WHERE clause and Ascending order", ^{
        __block NSString *queryString;

        beforeEach(^{

            queryString = [subject selectStatementForTableInAscending:@"my_special_table"
                                                columnName:@"bananas"
                                                   pattern:@"match"
                                                     where:@{@"age":@25}
                                                 orderedBy:@"bananas"];

        });

        it(@"should return the correct query string", ^{
            queryString should equal(@"SELECT * FROM my_special_table WHERE LOWER(bananas) LIKE LOWER('%match%') AND age = 25 ORDER BY bananas ASC");
            
        });
        
    });

    describe(@"Creating an SELECT statement with a DISTINCT statement for a column", ^{
        __block NSString *queryString;

        beforeEach(^{

            queryString = [subject distinctStatementForTable:@"my_special_table"
                                                columnName:@"bananas"];

        });

        it(@"should return the correct query string", ^{
            queryString should equal(@"SELECT DISTINCT bananas FROM my_special_table");
            
        });
        
    });

    describe(@"Creating an SELECT statement with a WHERE statement for a column with ORDERED BY statement", ^{
        __block NSString *queryString;

        beforeEach(^{


            queryString = [subject selectStatementForTable:@"my_special_table" where:@{@"bananas":@"tasty", @"age":@25} orderedBy:@"date"];

        });

        it(@"should return the correct query string", ^{
            queryString should equal(@"SELECT * FROM my_special_table WHERE age = 25 AND bananas = 'tasty' ORDER BY date DESC");
            
        });
        
    });

    describe(@"Creating an SELECT statement with a WHERE statement for a column with ORDERED BY statement in ascending", ^{
        __block NSString *queryString;

        beforeEach(^{


            queryString = [subject selectStatementForTableInAscending:@"my_special_table" where:@{@"bananas":@"tasty", @"age":@25} orderedBy:@"date"];

        });

        it(@"should return the correct query string", ^{
            queryString should equal(@"SELECT * FROM my_special_table WHERE age = 25 AND bananas = 'tasty' ORDER BY date ASC");
            
        });
        
    });


    describe(@"updateStatementForTable:args:andWhereClauseDictionary:", ^{
        __block NSString *queryString;

        context(@"with dictionary as args and where clause available", ^{
            beforeEach(^{
                queryString = [subject updateStatementForTable:@"my_special_table" args:@{@"name":@"name", @"user_uri":@"uri"} andWhereClauseDictionary:@{@"bananas":@"tasty", @"date": [NSDate dateWithTimeIntervalSince1970:10]}];
            });

            it(@"should return the correct query string", ^{
                queryString should equal(@"UPDATE my_special_table SET name = 'name',user_uri = 'uri' WHERE bananas = 'tasty' AND date = '1970-01-01 00:00:10'");
            });
        });

        context(@"with dictionary as args and where clause not available", ^{
            beforeEach(^{
                queryString = [subject updateStatementForTable:@"my_special_table" args:@{@"name":@"name", @"user_uri":@"uri"} andWhereClauseDictionary:nil];
            });

            it(@"should return the correct query string", ^{
                queryString should equal(@"UPDATE my_special_table SET name = 'name',user_uri = 'uri' WHERE user_uri = 'uri'");
            });
        });
    });
    
    describe(@"-selectStatementForTableWithANDORCondition:firstCondition:secondCondition:thirdCondition:", ^{
        __block NSString *queryString;
        
        beforeEach(^{
            queryString = [subject selectStatementForTableWithANDORCondition:@"my_special_table" firstCondition:@{@"bananas":@"tasty"} secondCondition:@{@"age":@25} thirdCondition:@{@"age":@24}];
        });
        
        it(@"should return the correct query string", ^{
            queryString should equal(@"SELECT * FROM my_special_table WHERE bananas = 'tasty' AND (age = 25 OR age = 24)");
        });
    });


});

SPEC_END
