#import <Cedar/Cedar.h>
#import "ExpenseProjectStorage.h"
#import "SQLiteTableStore.h"
#import "SQLiteDatabaseConnection.h"
#import "QueryStringBuilder.h"
#import "ProjectType.h"
#import "Period.h"
#import "ClientType.h"
#import "UserPermissionsStorage.h"
#import "ProjectBillingType.h"
#import "ProjectTimeAndExpenseEntryType.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ExpenseProjectStorageSpec)

describe(@"ExpenseProjectStorage", ^{
    __block ExpenseProjectStorage *subject;
    __block NSUserDefaults *userDefaults;
    __block DoorKeeper *doorKeeper;
    __block SQLiteTableStore<CedarDouble> *sqlLiteStore;
    __block id<UserSession> userSession;
    __block UserPermissionsStorage *userPermissionsStorage;
    
    beforeEach(^{
        
        sqlLiteStore = (id)[[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                   queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                         databaseName:@"Test"
                                                                            tableName:@"expense_project_types"];
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
        doorKeeper = nice_fake_for([DoorKeeper class]);
        userDefaults = nice_fake_for([NSUserDefaults class]);
        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        
        subject = [[ExpenseProjectStorage alloc]initWithSqliteStore:sqlLiteStore
                                                       userDefaults:userDefaults
                                                        userSession:userSession
                                                         doorKeeper:doorKeeper userPermissionsStorage:userPermissionsStorage];
        
        spy_on(sqlLiteStore);
        
    });
    
    
    describe(@"-lastDownloadedPageNumber", ^{
        
        it(@"should return 1 if there was no last Downloaded PageNumber", ^{
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
            lastDownloadedPageNumber should equal(@1);
        });
        
        it(@"should return correctly stored last Downloaded PageNumber", ^{
            userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedExpenseProjectPageNumber").and_return(@4);
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
            lastDownloadedPageNumber should equal(@4);
        });
    });
    
    describe(@"-updatePageNumber", ^{
        
        it(@"should update last Downloaded PageNumber value with 1", ^{
            [subject updatePageNumber];
            userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"LastDownloadedExpenseProjectPageNumber");
            userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedExpenseProjectPageNumber").and_return(@1);
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
            lastDownloadedPageNumber should equal(@1);
        });
        
        it(@"should update last Downloaded PageNumber value correctly ", ^{
            userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedExpenseProjectPageNumber").and_return(@4);
            userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"LastDownloadedExpenseProjectPageNumber");
            [subject updatePageNumber];
            userDefaults stub_method(@selector(objectForKey:)).again().with(@"LastDownloadedExpenseProjectPageNumber").and_return(@5);
            
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
            lastDownloadedPageNumber should equal(@5);
        });
    });
    
    describe(@"-resetPageNumber", ^{
        
        it(@"should reset the last Downloaded PageNumber", ^{
            [subject resetPageNumber];
            userDefaults should have_received(@selector(removeObjectForKey:)).with(@"LastDownloadedExpenseProjectPageNumber");
        });
    });
    
    describe(@"-getLastPageNumberForFilteredSearch", ^{
        
        it(@"should return 1 if there was no last Downloaded PageNumber", ^{
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
            lastDownloadedPageNumber should equal(@1);
        });
        
        it(@"should return correctly stored last Downloaded PageNumber", ^{
            userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredExpenseProjectPageNumber").and_return(@4);
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
            lastDownloadedPageNumber should equal(@4);
        });
    });
    
    describe(@"-updatePageNumberForFilteredSearch", ^{
        
        it(@"should update last Downloaded PageNumber value with 1", ^{
            [subject updatePageNumberForFilteredSearch];
            userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"LastDownloadedFilteredExpenseProjectPageNumber");
            userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredExpenseProjectPageNumber").and_return(@1);
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
            lastDownloadedPageNumber should equal(@1);
        });
        
        it(@"should update last Downloaded PageNumber value correctly ", ^{
            userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredExpenseProjectPageNumber").and_return(@4);
            userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"LastDownloadedFilteredExpenseProjectPageNumber");
            [subject updatePageNumber];
            userDefaults stub_method(@selector(objectForKey:)).again().with(@"LastDownloadedFilteredExpenseProjectPageNumber").and_return(@5);
            
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
            lastDownloadedPageNumber should equal(@5);
        });
    });
    
    describe(@"-resetPageNumberForFilteredSearch", ^{
        
        it(@"should reset the last Downloaded PageNumber", ^{
            [subject resetPageNumberForFilteredSearch];
            userDefaults should have_received(@selector(removeObjectForKey:)).with(@"LastDownloadedFilteredExpenseProjectPageNumber");
        });
    });
    
    describe(@"-storeClients", ^{
        
        __block ProjectType *project;
        context(@"When inserting a fresh client in DB", ^{
            context(@"when client is selected", ^{
                beforeEach(^{
                    ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                    project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                  isTimeAllocationAllowed:NO
                                                                            projectPeriod:nil
                                                                               clientType:client
                                                                                     name:@"project-name"
                                                                                      uri:@"project-uri"];

                    sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"uri": @"stored-project-uri"}).and_return(nil);
                    [subject storeProjects:@[project]];
                });

                it(@"should insert the row into database", ^{
                    sqlLiteStore should have_received(@selector(insertRow:)).with(@{
                                                                                    @"uri":@"project-uri",
                                                                                    @"name":@"project-name",
                                                                                    @"client_uri":@"client-uri",
                                                                                    @"client_name":@"client-name",
                                                                                    @"hasTasksAvailableForExpenseEntry":@(NO),
                                                                                    @"user_uri":@"user:uri",
                                                                                    @"billing_type_display_text":[NSNull null],
                                                                                    @"billing_type_uri":[NSNull null],
                                                                                    @"time_expense_entry_display_text":[NSNull null],
                                                                                    @"time_expense_entry_uri":[NSNull null]
                                                                                    });
                });

                context(@"when the project is mandatory", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(YES);
                    });
                    it(@"should return the newly inserted record", ^{
                        [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[project]);
                    });
                });

                context(@"when the project is optional", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(NO);
                    });
                    it(@"should return the newly inserted record", ^{
                        [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[project]);
                    });
                });
            });
            context(@"when client is selected with Project Time and Expense entry type is null and project billing type has value", ^{
                beforeEach(^{
                    ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                    project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                  isTimeAllocationAllowed:NO
                                                                            projectPeriod:nil
                                                                               clientType:client
                                                                                     name:@"project-name"
                                                                                      uri:@"project-uri"];
                    ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeA = nil;
                    ProjectBillingType *projectBillingTypeA = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:non-billable" displayText:@"Non-Billable"];
                    project.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeA;
                    project.projectBillingType = projectBillingTypeA;
                    
                    sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"uri": @"stored-project-uri"}).and_return(nil);
                    [subject storeProjects:@[project]];
                });
                
                it(@"should insert the row into database", ^{
                    sqlLiteStore should have_received(@selector(insertRow:)).with(@{
                                                                                    @"uri":@"project-uri",
                                                                                    @"name":@"project-name",
                                                                                    @"client_uri":@"client-uri",
                                                                                    @"client_name":@"client-name",
                                                                                    @"hasTasksAvailableForExpenseEntry":@(NO),
                                                                                    @"user_uri":@"user:uri",
                                                                                    @"billing_type_display_text":@"Non-Billable",
                                                                                    @"billing_type_uri":@"urn:replicon:billing-type:non-billable",
                                                                                    @"time_expense_entry_display_text":[NSNull null],
                                                                                    @"time_expense_entry_uri":[NSNull null]
                                                                                    });
                });
                
                context(@"when the project is mandatory", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(YES);
                    });
                    it(@"should return the newly inserted record", ^{
                        [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[project]);
                    });
                });
                
                context(@"when the project is optional", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(NO);
                    });
                    it(@"should return the newly inserted record", ^{
                        [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[project]);
                    });
                });
            });
            context(@"when client is selected with Project Time and Expense entry type has value", ^{
                beforeEach(^{
                    ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                    project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                  isTimeAllocationAllowed:NO
                                                                            projectPeriod:nil
                                                                               clientType:client
                                                                                     name:@"project-name"
                                                                                      uri:@"project-uri"];
                    
                    ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeB = [[ProjectTimeAndExpenseEntryType alloc] initWithUri:@"urn:replicon:time-and-expense-entry-type:non-billable" displayText:@"Non-Billable"];
                    ProjectBillingType *projectBillingTypeB = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:time-and-material" displayText:@"Time & Materials"];
                    project.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeB;
                    project.projectBillingType = projectBillingTypeB;
                    
                    sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"uri": @"stored-project-uri"}).and_return(nil);
                    [subject storeProjects:@[project]];
                });
                
                it(@"should insert the row into database", ^{
                    sqlLiteStore should have_received(@selector(insertRow:)).with(@{
                                                                                    @"uri":@"project-uri",
                                                                                    @"name":@"project-name",
                                                                                    @"client_uri":@"client-uri",
                                                                                    @"client_name":@"client-name",
                                                                                    @"hasTasksAvailableForExpenseEntry":@(NO),
                                                                                    @"user_uri":@"user:uri",
                                                                                    @"billing_type_display_text":@"Time & Materials",
                                                                                    @"billing_type_uri":@"urn:replicon:billing-type:time-and-material",
                                                                                    @"time_expense_entry_display_text":@"Non-Billable",
                                                                                    @"time_expense_entry_uri":@"urn:replicon:time-and-expense-entry-type:non-billable"
                                                                                    });
                });
                
                context(@"when the project is mandatory", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(YES);
                    });
                    it(@"should return the newly inserted record", ^{
                        [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[project]);
                    });
                });
                
                context(@"when the project is optional", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(NO);
                    });
                    it(@"should return the newly inserted record", ^{
                        [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[project]);
                    });
                });
            });
            
            context(@"when client is not selected", ^{
                beforeEach(^{
                    project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                  isTimeAllocationAllowed:NO
                                                                            projectPeriod:nil
                                                                               clientType:nil
                                                                                     name:@"project-name"
                                                                                      uri:@"project-uri"];

                    sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"uri": @"stored-project-uri"}).and_return(nil);
                    [subject storeProjects:@[project]];
                });

                it(@"should insert the row into database", ^{
                    sqlLiteStore should have_received(@selector(insertRow:)).with(@{
                                                                                    @"uri":@"project-uri",
                                                                                    @"name":@"project-name",
                                                                                    @"client_uri":[NSNull null],
                                                                                    @"client_name":[NSNull null],
                                                                                    @"hasTasksAvailableForExpenseEntry":@(NO),
                                                                                    @"user_uri":@"user:uri",
                                                                                    @"billing_type_display_text":[NSNull null],
                                                                                    @"billing_type_uri":[NSNull null],
                                                                                    @"time_expense_entry_display_text":[NSNull null],
                                                                                    @"time_expense_entry_uri":[NSNull null]
                                                                                    });
                });

                context(@"when the project is mandatory", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(YES);
                    });
                    it(@"should return the newly inserted record", ^{
                        [subject getAllProjectsForClientUri:nil] should equal(@[project]);
                    });
                });

                context(@"when the project is optional", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(NO);
                    });
                    it(@"should return the newly inserted record", ^{
                        ProjectType *noneProject = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:RPLocalizedString(@"None", @"") uri:nil];
                        [subject getAllProjectsForClientUri:nil] should equal(@[noneProject,project]);
                    });
                });
            });
            
            context(@"when client is not selected with Project Time and Expense entry type is null and project billing type has value", ^{
                beforeEach(^{
                    project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                  isTimeAllocationAllowed:NO
                                                                            projectPeriod:nil
                                                                               clientType:nil
                                                                                     name:@"project-name"
                                                                                      uri:@"project-uri"];
                    
                    ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeA = nil;
                    ProjectBillingType *projectBillingTypeA = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:non-billable" displayText:@"Non-Billable"];
                    project.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeA;
                    project.projectBillingType = projectBillingTypeA;
                    
                    sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"uri": @"stored-project-uri"}).and_return(nil);
                    [subject storeProjects:@[project]];
                });
                
                it(@"should insert the row into database", ^{
                    sqlLiteStore should have_received(@selector(insertRow:)).with(@{
                                                                                    @"uri":@"project-uri",
                                                                                    @"name":@"project-name",
                                                                                    @"client_uri":[NSNull null],
                                                                                    @"client_name":[NSNull null],
                                                                                    @"hasTasksAvailableForExpenseEntry":@(NO),
                                                                                    @"user_uri":@"user:uri",
                                                                                    @"billing_type_display_text":@"Non-Billable",
                                                                                    @"billing_type_uri":@"urn:replicon:billing-type:non-billable",
                                                                                    @"time_expense_entry_display_text":[NSNull null],
                                                                                    @"time_expense_entry_uri":[NSNull null]
                                                                                    });
                });
                
                context(@"when the project is mandatory", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(YES);
                    });
                    it(@"should return the newly inserted record", ^{
                        [subject getAllProjectsForClientUri:nil] should equal(@[project]);
                    });
                });
                
                context(@"when the project is optional", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(NO);
                    });
                    it(@"should return the newly inserted record", ^{
                        ProjectType *noneProject = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:RPLocalizedString(@"None", @"") uri:nil];
                        [subject getAllProjectsForClientUri:nil] should equal(@[noneProject,project]);
                    });
                });
            });
            
            context(@"when client is not selected with Project Time and Expense entry type has value", ^{
                beforeEach(^{
                    project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                  isTimeAllocationAllowed:NO
                                                                            projectPeriod:nil
                                                                               clientType:nil
                                                                                     name:@"project-name"
                                                                                      uri:@"project-uri"];
                    
                    ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeB = [[ProjectTimeAndExpenseEntryType alloc] initWithUri:@"urn:replicon:time-and-expense-entry-type:non-billable" displayText:@"Non-Billable"];
                    ProjectBillingType *projectBillingTypeB = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:time-and-material" displayText:@"Time & Materials"];
                    project.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeB;
                    project.projectBillingType = projectBillingTypeB;
                    
                    sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"uri": @"stored-project-uri"}).and_return(nil);
                    [subject storeProjects:@[project]];
                });
                
                it(@"should insert the row into database", ^{
                    sqlLiteStore should have_received(@selector(insertRow:)).with(@{
                                                                                    @"uri":@"project-uri",
                                                                                    @"name":@"project-name",
                                                                                    @"client_uri":[NSNull null],
                                                                                    @"client_name":[NSNull null],
                                                                                    @"hasTasksAvailableForExpenseEntry":@(NO),
                                                                                    @"user_uri":@"user:uri",
                                                                                    @"billing_type_display_text":@"Time & Materials",
                                                                                    @"billing_type_uri":@"urn:replicon:billing-type:time-and-material",
                                                                                    @"time_expense_entry_display_text":@"Non-Billable",
                                                                                    @"time_expense_entry_uri":@"urn:replicon:time-and-expense-entry-type:non-billable"
                                                                                    });
                });
                
                context(@"when the project is mandatory", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(YES);
                    });
                    it(@"should return the newly inserted record", ^{
                        [subject getAllProjectsForClientUri:nil] should equal(@[project]);
                    });
                });
                
                context(@"when the project is optional", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(NO);
                    });
                    it(@"should return the newly inserted record", ^{
                        ProjectType *noneProject = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:RPLocalizedString(@"None", @"") uri:nil];
                        [subject getAllProjectsForClientUri:nil] should equal(@[noneProject,project]);
                    });
                });
            });

        });
        
        context(@"When updating a already stored client in DB", ^{
            context(@"when client is selected", ^{
                beforeEach(^{
                    Period *storedPeriod = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                                    endDate:[NSDate dateWithTimeIntervalSince1970:2]];
                    ClientType *storedClient = [[ClientType alloc]initWithName:@"clientA" uri:@"clientUriA"];
                    ProjectType *storedProject = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                     isTimeAllocationAllowed:NO
                                                                                               projectPeriod:storedPeriod
                                                                                                  clientType:storedClient
                                                                                                        name:@"stored-project-name"
                                                                                                         uri:@"project-uri"];

                    [subject storeProjects:@[storedProject]];

                    sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"uri": @"project-uri"}).and_return(@{
                                                                                                                           @"name": @"StoredClient",
                                                                                                                           @"uri": @"ClientUriA",
                                                                                                                           @"user_uri":@"user:uri"
                                                                                                                           });

                    ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                    project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                  isTimeAllocationAllowed:NO
                                                                            projectPeriod:nil
                                                                               clientType:client
                                                                                     name:@"new-project-name"
                                                                                      uri:@"project-uri"];


                    [subject storeProjects:@[project]];
                });

                it(@"should update the row in database", ^{
                    sqlLiteStore should have_received(@selector(updateRow:whereClause:)).with(@{
                                                                                    @"uri":@"project-uri",
                                                                                    @"name":@"new-project-name",
                                                                                    @"client_uri":@"client-uri",
                                                                                    @"client_name":@"client-name",
                                                                                    @"hasTasksAvailableForExpenseEntry":@(NO),
                                                                                    @"user_uri":@"user:uri",
                                                                                    @"billing_type_display_text":[NSNull null],
                                                                                    @"billing_type_uri":[NSNull null],
                                                                                    @"time_expense_entry_display_text":[NSNull null],
                                                                                    @"time_expense_entry_uri":[NSNull null]
                                                                                    },nil);
                });

                context(@"when the project is mandatory", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(YES);
                    });
                    it(@"should return the newly updated record", ^{
                        [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[project]);
                    });
                });

                context(@"when the project is optional", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(NO);
                    });
                    it(@"should return the newly updated record", ^{

                        [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[project]);
                    });
                    
                });
            });
            context(@"when client is not selected", ^{
                beforeEach(^{
                    Period *storedPeriod = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                                    endDate:[NSDate dateWithTimeIntervalSince1970:2]];

                    ProjectType *storedProject = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                     isTimeAllocationAllowed:NO
                                                                                               projectPeriod:storedPeriod
                                                                                                  clientType:nil
                                                                                                        name:@"stored-project-name"
                                                                                                         uri:@"project-uri"];

                    [subject storeProjects:@[storedProject]];

                    sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"uri": @"project-uri"}).and_return(@{
                                                                                                                           @"name": @"StoredClient",
                                                                                                                           @"uri": @"ClientUriA",
                                                                                                                           @"user_uri":@"user:uri"
                                                                                                                           });


                    project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                  isTimeAllocationAllowed:NO
                                                                            projectPeriod:nil
                                                                               clientType:nil
                                                                                     name:@"new-project-name"
                                                                                      uri:@"project-uri"];


                    [subject storeProjects:@[project]];
                });

                it(@"should update the row in database", ^{
                    sqlLiteStore should have_received(@selector(updateRow:whereClause:)).with(@{
                                                                                @"uri":@"project-uri",
                                                                                    @"name":@"new-project-name",
                                                                                    @"client_uri":[NSNull null],
                                                                                    @"client_name":[NSNull null],
                                                                                    @"hasTasksAvailableForExpenseEntry":@(NO),
                                                                                    @"user_uri":@"user:uri",
                                                                                    @"billing_type_display_text":[NSNull null],
                                                                                    @"billing_type_uri":[NSNull null],
                                                                                    @"time_expense_entry_display_text":[NSNull null],
                                                                                    @"time_expense_entry_uri":[NSNull null]
                                                                                    },nil);
                });

                context(@"when the project is mandatory", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(YES);
                    });
                    it(@"should return the newly updated record", ^{
                        [subject getAllProjectsForClientUri:nil] should equal(@[project]);
                    });
                });

                context(@"when the project is optional", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(NO);
                    });
                    it(@"should return the newly updated record", ^{
                        ProjectType *noneProject = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:RPLocalizedString(@"None", @"") uri:nil];
                        [subject getAllProjectsForClientUri:nil] should equal(@[noneProject,project]);
                    });
                    
                });
            });

            
        });
        
    });
    
    describe(@"-getAllProjectsForClientUri", ^{

        context(@"when client is selected", ^{
            context(@"when the project is mandatory", ^{
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(YES);
                });
                it(@"should return all Project Types", ^{

                    ClientType *clientA = [[ClientType alloc]initWithName:@"clientA" uri:@"client-uri"];
                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientA
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];
                    ClientType *clientB = [[ClientType alloc]initWithName:@"clientB" uri:@"client-uri"];
                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientB
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];
                    ClientType *clientC = [[ClientType alloc]initWithName:@"clientC" uri:@"client-uri"];
                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientC
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];
                    [subject storeProjects:@[projectA,projectB,projectC]];

                    [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[projectA,projectB,projectC]);
                });

                it(@"should return older Project Types along with recent Project Types", ^{
                    ClientType *clientA = [[ClientType alloc]initWithName:@"clientA" uri:@"client-uri"];
                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientA
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];

                    ClientType *clientB = [[ClientType alloc]initWithName:@"clientB" uri:@"client-uri"];
                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientB
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];


                    ClientType *clientC = [[ClientType alloc]initWithName:@"clientC" uri:@"client-uri"];
                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientC
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];


                    [subject storeProjects:@[projectA,projectB,projectC]];


                    ClientType *clientD = [[ClientType alloc]initWithName:@"clientD" uri:@"client-uri"];
                    ProjectType *recentProjectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:clientD
                                                                                                         name:@"ProjectD"
                                                                                                          uri:@"uriD"];

                    ClientType *clientE = [[ClientType alloc]initWithName:@"clientE" uri:@"some-client-uri"];
                    ProjectType *recentProjectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:clientE
                                                                                                         name:@"ProjectE"
                                                                                                          uri:@"uriE"];

                    [subject storeProjects:@[recentProjectA,recentProjectB]];

                    [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[projectA,projectB,projectC,recentProjectA]);
                });
            });
            
            context(@"when the project is mandatory with Project Time and Expense entry type is null and project billing type has value", ^{
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(YES);
                });
                it(@"should return all Project Types", ^{
                    
                    ClientType *clientA = [[ClientType alloc]initWithName:@"clientA" uri:@"client-uri"];
                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientA
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];
                    ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeA = nil;
                    ProjectBillingType *projectBillingTypeA = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:non-billable" displayText:@"Non-Billable"];
                    projectA.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeA;
                    projectA.projectBillingType = projectBillingTypeA;
                    
                    ClientType *clientB = [[ClientType alloc]initWithName:@"clientB" uri:@"client-uri"];
                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientB
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];
                    ClientType *clientC = [[ClientType alloc]initWithName:@"clientC" uri:@"client-uri"];
                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientC
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];
                    [subject storeProjects:@[projectA,projectB,projectC]];
                    
                    [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[projectA,projectB,projectC]);
                });
                
                it(@"should return older Project Types along with recent Project Types", ^{
                    ClientType *clientA = [[ClientType alloc]initWithName:@"clientA" uri:@"client-uri"];
                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientA
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];
                    
                    ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeA = nil;
                    ProjectBillingType *projectBillingTypeA = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:non-billable" displayText:@"Non-Billable"];
                    projectA.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeA;
                    projectA.projectBillingType = projectBillingTypeA;
                    
                    ClientType *clientB = [[ClientType alloc]initWithName:@"clientB" uri:@"client-uri"];
                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientB
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];
                    
                    
                    ClientType *clientC = [[ClientType alloc]initWithName:@"clientC" uri:@"client-uri"];
                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientC
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];
                    
                    
                    [subject storeProjects:@[projectA,projectB,projectC]];
                    
                    
                    ClientType *clientD = [[ClientType alloc]initWithName:@"clientD" uri:@"client-uri"];
                    ProjectType *recentProjectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:clientD
                                                                                                         name:@"ProjectD"
                                                                                                          uri:@"uriD"];
                    
                    ClientType *clientE = [[ClientType alloc]initWithName:@"clientE" uri:@"some-client-uri"];
                    ProjectType *recentProjectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:clientE
                                                                                                         name:@"ProjectE"
                                                                                                          uri:@"uriE"];
                    
                    [subject storeProjects:@[recentProjectA,recentProjectB]];
                    
                    [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[projectA,projectB,projectC,recentProjectA]);
                });
            });
            
            context(@"when the project is mandatory with Project Time and Expense entry type has value", ^{
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(YES);
                });
                it(@"should return all Project Types", ^{
                    
                    ClientType *clientA = [[ClientType alloc]initWithName:@"clientA" uri:@"client-uri"];
                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientA
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];
                    ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeB = [[ProjectTimeAndExpenseEntryType alloc] initWithUri:@"urn:replicon:time-and-expense-entry-type:non-billable" displayText:@"Non-Billable"];
                    ProjectBillingType *projectBillingTypeB = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:time-and-material" displayText:@"Time & Materials"];
                    projectA.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeB;
                    projectA.projectBillingType = projectBillingTypeB;
                    
                    ClientType *clientB = [[ClientType alloc]initWithName:@"clientB" uri:@"client-uri"];
                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientB
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];
                    ClientType *clientC = [[ClientType alloc]initWithName:@"clientC" uri:@"client-uri"];
                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientC
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];
                    [subject storeProjects:@[projectA,projectB,projectC]];
                    
                    [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[projectA,projectB,projectC]);
                });
                
                it(@"should return older Project Types along with recent Project Types", ^{
                    ClientType *clientA = [[ClientType alloc]initWithName:@"clientA" uri:@"client-uri"];
                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientA
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];
                    
                    ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeB = [[ProjectTimeAndExpenseEntryType alloc] initWithUri:@"urn:replicon:time-and-expense-entry-type:non-billable" displayText:@"Non-Billable"];
                    ProjectBillingType *projectBillingTypeB = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:time-and-material" displayText:@"Time & Materials"];
                    projectA.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeB;
                    projectA.projectBillingType = projectBillingTypeB;
                    
                    ClientType *clientB = [[ClientType alloc]initWithName:@"clientB" uri:@"client-uri"];
                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientB
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];
                    
                    
                    ClientType *clientC = [[ClientType alloc]initWithName:@"clientC" uri:@"client-uri"];
                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientC
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];
                    
                    
                    [subject storeProjects:@[projectA,projectB,projectC]];
                    
                    
                    ClientType *clientD = [[ClientType alloc]initWithName:@"clientD" uri:@"client-uri"];
                    ProjectType *recentProjectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:clientD
                                                                                                         name:@"ProjectD"
                                                                                                          uri:@"uriD"];
                    
                    ClientType *clientE = [[ClientType alloc]initWithName:@"clientE" uri:@"some-client-uri"];
                    ProjectType *recentProjectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:clientE
                                                                                                         name:@"ProjectE"
                                                                                                          uri:@"uriE"];
                    
                    [subject storeProjects:@[recentProjectA,recentProjectB]];
                    
                    [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[projectA,projectB,projectC,recentProjectA]);
                });
            });

            context(@"when the project is optional", ^{

                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(NO);

                });
                it(@"should return all Project Types", ^{

                    ClientType *clientA = [[ClientType alloc]initWithName:@"clientA" uri:@"client-uri"];
                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientA
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];
                    ClientType *clientB = [[ClientType alloc]initWithName:@"clientB" uri:@"client-uri"];
                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientB
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];
                    ClientType *clientC = [[ClientType alloc]initWithName:@"clientC" uri:@"client-uri"];
                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientC
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];
                    [subject storeProjects:@[projectA,projectB,projectC]];

                    [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[projectA,projectB,projectC]);
                });

                it(@"should return older Project Types along with recent Project Types", ^{
                    ClientType *clientA = [[ClientType alloc]initWithName:@"clientA" uri:@"client-uri"];
                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientA
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];

                    ClientType *clientB = [[ClientType alloc]initWithName:@"clientB" uri:@"client-uri"];
                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientB
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];


                    ClientType *clientC = [[ClientType alloc]initWithName:@"clientC" uri:@"client-uri"];
                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientC
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];


                    [subject storeProjects:@[projectA,projectB,projectC]];


                    ClientType *clientD = [[ClientType alloc]initWithName:@"clientD" uri:@"client-uri"];
                    ProjectType *recentProjectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:clientD
                                                                                                         name:@"ProjectD"
                                                                                                          uri:@"uriD"];

                    ClientType *clientE = [[ClientType alloc]initWithName:@"clientE" uri:@"some-client-uri"];
                    ProjectType *recentProjectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:clientE
                                                                                                         name:@"ProjectE"
                                                                                                          uri:@"uriE"];
                    
                    [subject storeProjects:@[recentProjectA,recentProjectB]];
                    
                    [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[projectA,projectB,projectC,recentProjectA]);
                });
            });
            
            context(@"when the project is optional with Project Time and Expense entry type is null and project billing type has value", ^{
                
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(NO);
                    
                });
                it(@"should return all Project Types", ^{
                    
                    ClientType *clientA = [[ClientType alloc]initWithName:@"clientA" uri:@"client-uri"];
                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientA
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];
                    ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeA = nil;
                    ProjectBillingType *projectBillingTypeA = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:non-billable" displayText:@"Non-Billable"];
                    projectA.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeA;
                    projectA.projectBillingType = projectBillingTypeA;
                    
                    ClientType *clientB = [[ClientType alloc]initWithName:@"clientB" uri:@"client-uri"];
                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientB
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];
                    ClientType *clientC = [[ClientType alloc]initWithName:@"clientC" uri:@"client-uri"];
                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientC
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];
                    [subject storeProjects:@[projectA,projectB,projectC]];
                    
                    [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[projectA,projectB,projectC]);
                });
                
                it(@"should return older Project Types along with recent Project Types", ^{
                    ClientType *clientA = [[ClientType alloc]initWithName:@"clientA" uri:@"client-uri"];
                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientA
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];
                    ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeA = nil;
                    ProjectBillingType *projectBillingTypeA = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:non-billable" displayText:@"Non-Billable"];
                    projectA.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeA;
                    projectA.projectBillingType = projectBillingTypeA;
                    
                    ClientType *clientB = [[ClientType alloc]initWithName:@"clientB" uri:@"client-uri"];
                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientB
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];
                    
                    
                    ClientType *clientC = [[ClientType alloc]initWithName:@"clientC" uri:@"client-uri"];
                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientC
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];
                    
                    
                    [subject storeProjects:@[projectA,projectB,projectC]];
                    
                    
                    ClientType *clientD = [[ClientType alloc]initWithName:@"clientD" uri:@"client-uri"];
                    ProjectType *recentProjectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:clientD
                                                                                                         name:@"ProjectD"
                                                                                                          uri:@"uriD"];
                    
                    ClientType *clientE = [[ClientType alloc]initWithName:@"clientE" uri:@"some-client-uri"];
                    ProjectType *recentProjectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:clientE
                                                                                                         name:@"ProjectE"
                                                                                                          uri:@"uriE"];
                    
                    [subject storeProjects:@[recentProjectA,recentProjectB]];
                    
                    [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[projectA,projectB,projectC,recentProjectA]);
                });
            });
            
            context(@"when the project is optional with Project Time and Expense entry type has value", ^{
                
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(NO);
                    
                });
                it(@"should return all Project Types", ^{
                    
                    ClientType *clientA = [[ClientType alloc]initWithName:@"clientA" uri:@"client-uri"];
                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientA
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];
                    ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeB = [[ProjectTimeAndExpenseEntryType alloc] initWithUri:@"urn:replicon:time-and-expense-entry-type:non-billable" displayText:@"Non-Billable"];
                    ProjectBillingType *projectBillingTypeB = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:time-and-material" displayText:@"Time & Materials"];
                    projectA.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeB;
                    projectA.projectBillingType = projectBillingTypeB;
                    
                    ClientType *clientB = [[ClientType alloc]initWithName:@"clientB" uri:@"client-uri"];
                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientB
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];
                    ClientType *clientC = [[ClientType alloc]initWithName:@"clientC" uri:@"client-uri"];
                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientC
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];
                    [subject storeProjects:@[projectA,projectB,projectC]];
                    
                    [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[projectA,projectB,projectC]);
                });
                
                it(@"should return older Project Types along with recent Project Types", ^{
                    ClientType *clientA = [[ClientType alloc]initWithName:@"clientA" uri:@"client-uri"];
                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientA
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];
                    ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeB = [[ProjectTimeAndExpenseEntryType alloc] initWithUri:@"urn:replicon:time-and-expense-entry-type:non-billable" displayText:@"Non-Billable"];
                    ProjectBillingType *projectBillingTypeB = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:time-and-material" displayText:@"Time & Materials"];
                    projectA.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeB;
                    projectA.projectBillingType = projectBillingTypeB;
                    
                    ClientType *clientB = [[ClientType alloc]initWithName:@"clientB" uri:@"client-uri"];
                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientB
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];
                    
                    
                    ClientType *clientC = [[ClientType alloc]initWithName:@"clientC" uri:@"client-uri"];
                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:clientC
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];
                    
                    
                    [subject storeProjects:@[projectA,projectB,projectC]];
                    
                    
                    ClientType *clientD = [[ClientType alloc]initWithName:@"clientD" uri:@"client-uri"];
                    ProjectType *recentProjectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:clientD
                                                                                                         name:@"ProjectD"
                                                                                                          uri:@"uriD"];
                    
                    ClientType *clientE = [[ClientType alloc]initWithName:@"clientE" uri:@"some-client-uri"];
                    ProjectType *recentProjectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:clientE
                                                                                                         name:@"ProjectE"
                                                                                                          uri:@"uriE"];
                    
                    [subject storeProjects:@[recentProjectA,recentProjectB]];
                    
                    [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[projectA,projectB,projectC,recentProjectA]);
                });
            });
            
            

        });

        context(@"when client is not selected", ^{
            context(@"when the project is mandatory", ^{
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(YES);
                });
                it(@"should return all Project Types", ^{


                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];

                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];

                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];
                    [subject storeProjects:@[projectA,projectB,projectC]];

                    [subject getAllProjectsForClientUri:nil] should equal(@[projectA,projectB,projectC]);
                });

                it(@"should return older Project Types along with recent Project Types", ^{

                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];


                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];



                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];


                    [subject storeProjects:@[projectA,projectB,projectC]];



                    ProjectType *recentProjectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:nil
                                                                                                         name:@"ProjectD"
                                                                                                          uri:@"uriD"];


                    ProjectType *recentProjectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:nil
                                                                                                         name:@"ProjectE"
                                                                                                          uri:@"uriE"];

                    [subject storeProjects:@[recentProjectA,recentProjectB]];

                    [subject getAllProjectsForClientUri:nil] should equal(@[projectA,projectB,projectC,recentProjectA,recentProjectB]);
                });
            });
            context(@"when the project is mandatory with Project Time and Expense entry type is null and project billing type has value", ^{
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(YES);
                });
                it(@"should return all Project Types", ^{
                    
                    
                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];
                    
                    ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeA = nil;
                    ProjectBillingType *projectBillingTypeA = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:non-billable" displayText:@"Non-Billable"];
                    projectA.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeA;
                    projectA.projectBillingType = projectBillingTypeA;
                    
                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];
                    
                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];
                    [subject storeProjects:@[projectA,projectB,projectC]];
                    
                    [subject getAllProjectsForClientUri:nil] should equal(@[projectA,projectB,projectC]);
                });
                
                it(@"should return older Project Types along with recent Project Types", ^{
                    
                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];
                    
                    ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeA = nil;
                    ProjectBillingType *projectBillingTypeA = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:non-billable" displayText:@"Non-Billable"];
                    projectA.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeA;
                    projectA.projectBillingType = projectBillingTypeA;
                    
                    
                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];
                    
                    
                    
                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];
                    
                    
                    [subject storeProjects:@[projectA,projectB,projectC]];
                    
                    
                    
                    ProjectType *recentProjectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:nil
                                                                                                         name:@"ProjectD"
                                                                                                          uri:@"uriD"];
                    
                    
                    ProjectType *recentProjectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:nil
                                                                                                         name:@"ProjectE"
                                                                                                          uri:@"uriE"];
                    
                    [subject storeProjects:@[recentProjectA,recentProjectB]];
                    
                    [subject getAllProjectsForClientUri:nil] should equal(@[projectA,projectB,projectC,recentProjectA,recentProjectB]);
                });
            });
            
            context(@"when the project is mandatory with Project Time and Expense entry type has value", ^{
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(YES);
                });
                it(@"should return all Project Types", ^{
                    
                    
                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];
                    
                    ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeB = [[ProjectTimeAndExpenseEntryType alloc] initWithUri:@"urn:replicon:time-and-expense-entry-type:non-billable" displayText:@"Non-Billable"];
                    ProjectBillingType *projectBillingTypeB = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:time-and-material" displayText:@"Time & Materials"];
                    projectA.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeB;
                    projectA.projectBillingType = projectBillingTypeB;
                    
                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];
                    
                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];
                    [subject storeProjects:@[projectA,projectB,projectC]];
                    
                    [subject getAllProjectsForClientUri:nil] should equal(@[projectA,projectB,projectC]);
                });
                
                it(@"should return older Project Types along with recent Project Types", ^{
                    
                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];
                    
                    ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeB = [[ProjectTimeAndExpenseEntryType alloc] initWithUri:@"urn:replicon:time-and-expense-entry-type:non-billable" displayText:@"Non-Billable"];
                    ProjectBillingType *projectBillingTypeB = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:time-and-material" displayText:@"Time & Materials"];
                    projectA.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeB;
                    projectA.projectBillingType = projectBillingTypeB;
                    
                    
                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];
                    
                    
                    
                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];
                    
                    
                    [subject storeProjects:@[projectA,projectB,projectC]];
                    
                    
                    
                    ProjectType *recentProjectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:nil
                                                                                                         name:@"ProjectD"
                                                                                                          uri:@"uriD"];
                    
                    
                    ProjectType *recentProjectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:nil
                                                                                                         name:@"ProjectE"
                                                                                                          uri:@"uriE"];
                    
                    [subject storeProjects:@[recentProjectA,recentProjectB]];
                    
                    [subject getAllProjectsForClientUri:nil] should equal(@[projectA,projectB,projectC,recentProjectA,recentProjectB]);
                });
            });

            context(@"when the project is optional", ^{
                __block ProjectType *noneProject;
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(NO);
                    noneProject = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:RPLocalizedString(@"None", @"") uri:nil];
                });
                it(@"should return all Project Types", ^{


                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];

                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];

                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];
                    [subject storeProjects:@[projectA,projectB,projectC]];

                    [subject getAllProjectsForClientUri:nil] should equal(@[noneProject,projectA,projectB,projectC]);
                });

                it(@"should return older Project Types along with recent Project Types", ^{

                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];


                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];



                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];


                    [subject storeProjects:@[projectA,projectB,projectC]];



                    ProjectType *recentProjectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:nil
                                                                                                         name:@"ProjectD"
                                                                                                          uri:@"uriD"];


                    ProjectType *recentProjectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:nil
                                                                                                         name:@"ProjectE"
                                                                                                          uri:@"uriE"];
                    
                    [subject storeProjects:@[recentProjectA,recentProjectB]];
                    
                    [subject getAllProjectsForClientUri:nil] should equal(@[noneProject,projectA,projectB,projectC,recentProjectA,recentProjectB]);
                });
            });
            
            context(@"when the project is optional with Project Time and Expense entry type is null and project billing type has value", ^{
                __block ProjectType *noneProject;
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(NO);
                    noneProject = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:RPLocalizedString(@"None", @"") uri:nil];
                });
                it(@"should return all Project Types", ^{
                    
                    
                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];
                    
                    ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeA = nil;
                    ProjectBillingType *projectBillingTypeA = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:non-billable" displayText:@"Non-Billable"];
                    projectA.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeA;
                    projectA.projectBillingType = projectBillingTypeA;
                    
                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];
                    
                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];
                    [subject storeProjects:@[projectA,projectB,projectC]];
                    
                    [subject getAllProjectsForClientUri:nil] should equal(@[noneProject,projectA,projectB,projectC]);
                });
                
                it(@"should return older Project Types along with recent Project Types", ^{
                    
                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];
                    
                    ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeA = nil;
                    ProjectBillingType *projectBillingTypeA = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:non-billable" displayText:@"Non-Billable"];
                    projectA.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeA;
                    projectA.projectBillingType = projectBillingTypeA;
                    
                    
                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];
                    
                    
                    
                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];
                    
                    
                    [subject storeProjects:@[projectA,projectB,projectC]];
                    
                    
                    
                    ProjectType *recentProjectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:nil
                                                                                                         name:@"ProjectD"
                                                                                                          uri:@"uriD"];
                    
                    
                    ProjectType *recentProjectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:nil
                                                                                                         name:@"ProjectE"
                                                                                                          uri:@"uriE"];
                    
                    [subject storeProjects:@[recentProjectA,recentProjectB]];
                    
                    [subject getAllProjectsForClientUri:nil] should equal(@[noneProject,projectA,projectB,projectC,recentProjectA,recentProjectB]);
                });
            });
            
            context(@"when the project is optional with Project Time and Expense entry type has value", ^{
                __block ProjectType *noneProject;
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(NO);
                    noneProject = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:RPLocalizedString(@"None", @"") uri:nil];
                });
                it(@"should return all Project Types", ^{
                    
                    
                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];
                    
                    
                    ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeB = [[ProjectTimeAndExpenseEntryType alloc] initWithUri:@"urn:replicon:time-and-expense-entry-type:non-billable" displayText:@"Non-Billable"];
                    ProjectBillingType *projectBillingTypeB = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:time-and-material" displayText:@"Time & Materials"];
                    projectA.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeB;
                    projectA.projectBillingType = projectBillingTypeB;
                    
                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];
                    
                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];
                    [subject storeProjects:@[projectA,projectB,projectC]];
                    
                    [subject getAllProjectsForClientUri:nil] should equal(@[noneProject,projectA,projectB,projectC]);
                });
                
                it(@"should return older Project Types along with recent Project Types", ^{
                    
                    ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectA"
                                                                                                    uri:@"uriA"];
                    
                    ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeB = [[ProjectTimeAndExpenseEntryType alloc] initWithUri:@"urn:replicon:time-and-expense-entry-type:non-billable" displayText:@"Non-Billable"];
                    ProjectBillingType *projectBillingTypeB = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:time-and-material" displayText:@"Time & Materials"];
                    projectA.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeB;
                    projectA.projectBillingType = projectBillingTypeB;
                    
                    
                    ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectB"
                                                                                                    uri:@"uriB"];
                    
                    
                    
                    ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"ProjectC"
                                                                                                    uri:@"uriC"];
                    
                    
                    [subject storeProjects:@[projectA,projectB,projectC]];
                    
                    
                    
                    ProjectType *recentProjectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:nil
                                                                                                         name:@"ProjectD"
                                                                                                          uri:@"uriD"];
                    
                    
                    ProjectType *recentProjectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:nil
                                                                                                         name:@"ProjectE"
                                                                                                          uri:@"uriE"];
                    
                    [subject storeProjects:@[recentProjectA,recentProjectB]];
                    
                    [subject getAllProjectsForClientUri:nil] should equal(@[noneProject,projectA,projectB,projectC,recentProjectA,recentProjectB]);
                });
            });

        });



    });
    
    describe(@"-getProjectsWithMatchingText:clientUri:", ^{
        
        __block ProjectType *projectA;
        __block ProjectType *projectB;
        __block ProjectType *projectC;
        __block ProjectType *projectD;
        __block ProjectType *projectE;
        __block ProjectType *projectF;


        context(@"when client is selected", ^{
            beforeEach(^{
                ClientType *clientA = [[ClientType alloc]initWithName:@"clientA" uri:@"clientUriA"];
                projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                               isTimeAllocationAllowed:NO
                                                                         projectPeriod:nil
                                                                            clientType:clientA
                                                                                  name:@"Apple"
                                                                                   uri:@"uriA"];

                ClientType *clientB = [[ClientType alloc]initWithName:@"clientB" uri:@"clientUriB"];
                projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                               isTimeAllocationAllowed:NO
                                                                         projectPeriod:nil
                                                                            clientType:clientB
                                                                                  name:@"Orange"
                                                                                   uri:@"uriB"];


                ClientType *clientC = [[ClientType alloc]initWithName:@"clientC" uri:@"clientUriC"];
                projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                               isTimeAllocationAllowed:NO
                                                                         projectPeriod:nil
                                                                            clientType:clientC
                                                                                  name:@"Pineapple"
                                                                                   uri:@"uriC"];

                ClientType *clientD = [[ClientType alloc]initWithName:@"clientD" uri:@"clientUriD"];
                projectD = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                               isTimeAllocationAllowed:NO
                                                                         projectPeriod:nil
                                                                            clientType:clientD
                                                                                  name:@"Grape"
                                                                                   uri:@"uriD"];

                ClientType *clientE = [[ClientType alloc]initWithName:@"clientE" uri:@"clientUriE"];
                projectE = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                               isTimeAllocationAllowed:NO
                                                                         projectPeriod:nil
                                                                            clientType:clientE
                                                                                  name:@"Kiwi"
                                                                                   uri:@"uriE"];


                ClientType *clientF = [[ClientType alloc]initWithName:@"clientF" uri:@"clientUriF"];
                projectF = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                               isTimeAllocationAllowed:NO
                                                                         projectPeriod:nil
                                                                            clientType:clientF
                                                                                  name:@"Strawberry"
                                                                                   uri:@"uriF"];
            });

            context(@"when the project is mandatory", ^{
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(YES);
                });
                it(@"should return all Project Types matching the text", ^{

                    [subject storeProjects:@[projectA,projectB,projectC,projectD,projectE,projectF]];
                    [subject getProjectsWithMatchingText:@"apple" clientUri:nil] should equal(@[projectA,projectC]);
                });

                it(@"should return all Project Types matching the text and client uri", ^{

                    [subject storeProjects:@[projectA,projectB,projectC,projectD,projectE,projectF]];

                    [subject getProjectsWithMatchingText:@"apple" clientUri:@"clientUriF"] should be_nil;
                    [subject getProjectsWithMatchingText:@"berry" clientUri:@"clientUriF"] should equal(@[projectF]);
                });
            });

            context(@"when the project is optional", ^{

                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(NO);

                });
                it(@"should return all Project Types matching the text", ^{

                    [subject storeProjects:@[projectA,projectB,projectC,projectD,projectE,projectF]];
                    [subject getProjectsWithMatchingText:@"apple" clientUri:nil] should equal(@[projectA,projectC]);
                });

                it(@"should return all Project Types matching the text and client uri", ^{
                    
                    [subject storeProjects:@[projectA,projectB,projectC,projectD,projectE,projectF]];
                    
                    [subject getProjectsWithMatchingText:@"apple" clientUri:@"clientUriF"] should be_nil;
                    [subject getProjectsWithMatchingText:@"berry" clientUri:@"clientUriF"] should equal(@[projectF]);
                });
            });

        });

        context(@"when client is not selected", ^{
            beforeEach(^{

                projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                               isTimeAllocationAllowed:NO
                                                                         projectPeriod:nil
                                                                            clientType:nil
                                                                                  name:@"Apple"
                                                                                   uri:@"uriA"];


                projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                               isTimeAllocationAllowed:NO
                                                                         projectPeriod:nil
                                                                            clientType:nil
                                                                                  name:@"Orange"
                                                                                   uri:@"uriB"];



                projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                               isTimeAllocationAllowed:NO
                                                                         projectPeriod:nil
                                                                            clientType:nil
                                                                                  name:@"Pineapple"
                                                                                   uri:@"uriC"];


                projectD = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                               isTimeAllocationAllowed:NO
                                                                         projectPeriod:nil
                                                                            clientType:nil
                                                                                  name:@"Grape"
                                                                                   uri:@"uriD"];


                projectE = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                               isTimeAllocationAllowed:NO
                                                                         projectPeriod:nil
                                                                            clientType:nil
                                                                                  name:@"Kiwi"
                                                                                   uri:@"uriE"];



                projectF = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                               isTimeAllocationAllowed:NO
                                                                         projectPeriod:nil
                                                                            clientType:nil
                                                                                  name:@"Strawberry"
                                                                                   uri:@"uriF"];
            });

            context(@"when the project is mandatory", ^{
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(YES);
                });
                it(@"should return all Project Types matching the text", ^{

                    [subject storeProjects:@[projectA,projectB,projectC,projectD,projectE,projectF]];
                    [subject getProjectsWithMatchingText:@"apple" clientUri:nil] should equal(@[projectA,projectC]);
                });

                it(@"should return all Project Types matching the text and client uri", ^{

                    [subject storeProjects:@[projectA,projectB,projectC,projectD,projectE,projectF]];

                    [subject getProjectsWithMatchingText:@"banana" clientUri:nil] should be_nil;
                    [subject getProjectsWithMatchingText:@"berry" clientUri:nil] should equal(@[projectF]);
                });
            });

            context(@"when the project is optional", ^{
                __block ProjectType *noneProject;
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(NO);
                    noneProject = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:RPLocalizedString(@"None", @"") uri:nil];
                });
                it(@"should return all Project Types matching the text", ^{

                    [subject storeProjects:@[projectA,projectB,projectC,projectD,projectE,projectF]];
                    [subject getProjectsWithMatchingText:@"apple" clientUri:nil] should equal(@[noneProject,projectA,projectC]);
                });

                it(@"should return all Project Types matching the text and client uri", ^{
                    
                    [subject storeProjects:@[projectA,projectB,projectC,projectD,projectE,projectF]];
                    
                    [subject getProjectsWithMatchingText:@"banana" clientUri:nil] should be_nil;
                    [subject getProjectsWithMatchingText:@"berry" clientUri:nil] should equal(@[noneProject,projectF]);
                });
            });

        });



    });
    
    describe(@"-deleteAllProjectsForClientUri", ^{
        
        context(@"deleting projects with empty client uri ", ^{
            beforeEach(^{
                ClientType *client = [[ClientType alloc]initWithName:nil uri:nil];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"projectname"
                                                                                               uri:@"projecturi"];;
                [subject storeProjects:@[project]];
                [subject deleteAllProjectsForClientUri:nil];
            });
            
            it(@"should remove all Project types", ^{
                [subject getAllProjectsForClientUri:nil] should be_nil;
                sqlLiteStore should have_received(@selector(deleteAllRows));
            });
            
        });
        
        context(@"deleting projects with client uri ", ^{
            
            __block ProjectType *projectA;
            __block ProjectType *projectB;


            context(@"when client is selected", ^{

                beforeEach(^{
                    ClientType *clientA = [[ClientType alloc]initWithName:@"client-name"
                                                                      uri:@"client-uri"];
                    projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                   isTimeAllocationAllowed:NO
                                                                             projectPeriod:nil
                                                                                clientType:clientA
                                                                                      name:@"projectname"
                                                                                       uri:@"projecturi"];

                    ClientType *clientB = [[ClientType alloc]initWithName:@"new-client-name"
                                                                      uri:@"new-client-uri"];
                    projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                   isTimeAllocationAllowed:NO
                                                                             projectPeriod:nil
                                                                                clientType:clientB
                                                                                      name:@"projectname"
                                                                                       uri:@"projecturi"];;
                    [subject storeProjects:@[projectA,projectB]];

                });

                context(@"Deleting projects with client uri", ^{
                    beforeEach(^{
                        [subject deleteAllProjectsForClientUri:@"client-uri"];
                    });


                    it(@"should delete only projects relating to client passed", ^{
                        sqlLiteStore should have_received(@selector(deleteRowWithArgs:)).with(@{@"client_uri": @"client-uri"});
                    });
                    
                });


                context(@"when the project is mandatory", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(YES);
                    });
                    it(@"should not delete projects with different clients", ^{
                        [subject getAllProjectsForClientUri:@"new-client-uri"] should equal(@[projectB]);
                    });

                    it(@"should return only project for client uri passed", ^{
                        [subject getAllProjectsForClientUri:nil] should equal(@[projectB]);

                    });
                });

                context(@"when the project is optional", ^{

                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(NO);

                    });
                    it(@"should not delete projects with different clients", ^{
                        [subject getAllProjectsForClientUri:@"new-client-uri"] should equal(@[projectB]);
                    });

                    it(@"should return only project for client uri passed", ^{
                        [subject getAllProjectsForClientUri:nil] should equal(@[projectB]);

                    });
                });
            });

            context(@"when client is not selected", ^{

                beforeEach(^{
                    projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                   isTimeAllocationAllowed:NO
                                                                             projectPeriod:nil
                                                                                clientType:nil
                                                                                      name:@"projectname"
                                                                                       uri:@"projecturi"];


                    projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                   isTimeAllocationAllowed:NO
                                                                             projectPeriod:nil
                                                                                clientType:nil
                                                                                      name:@"projectname"
                                                                                       uri:@"projecturi"];;
                    [subject storeProjects:@[projectA,projectB]];

                });


                context(@"when the project is mandatory", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(YES);
                    });
                    it(@"should not delete projects with different clients", ^{
                        [subject getAllProjectsForClientUri:nil] should equal(@[projectB]);
                    });

                    it(@"should return only project for client uri passed", ^{
                        [subject getAllProjectsForClientUri:nil] should equal(@[projectB]);

                    });
                });

                context(@"when the project is optional", ^{
                    __block ProjectType *noneProject;
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(NO);
                        noneProject = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:RPLocalizedString(@"None", @"") uri:nil];
                    });
                    it(@"should not delete projects with different clients", ^{
                        [subject getAllProjectsForClientUri:nil] should equal(@[noneProject,projectB]);
                    });

                    it(@"should return only project for client uri passed", ^{
                        [subject getAllProjectsForClientUri:nil] should equal(@[noneProject,projectB]);

                    });
                });
            });


        });
    });
    
    describe(@"As a <DoorKeeperObserver>", ^{
        beforeEach(^{
            ClientType *clientF = [[ClientType alloc]initWithName:@"clientF" uri:@"clientUriF"];
            ProjectType *projectF = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:nil
                                                                                     clientType:clientF
                                                                                           name:@"Strawberry"
                                                                                            uri:@"uriF"];
            [subject storeProjects:@[projectF]];
            
            userSession stub_method(@selector(currentUserURI)).again().and_return(@"user:uri:new");
            
            [subject doorKeeperDidLogOut:nil];
        });
        
        it(@"should remove all Client types", ^{
            [subject getAllProjectsForClientUri:nil] should be_nil;
        });
    });
    
    describe(@"-getProjectInfoForUri:", ^{
        __block ProjectType *expectedProject;
        __block ProjectType *project;
        
        beforeEach(^{
            ClientType *clientF = [[ClientType alloc]initWithName:@"clientF" uri:@"clientUriF"];
            project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                          isTimeAllocationAllowed:NO
                                                                    projectPeriod:nil
                                                                       clientType:clientF
                                                                             name:@"Strawberry"
                                                                              uri:@"project-uri"];
            [subject storeProjects:@[project]];
            
            [sqlLiteStore reset_sent_messages];
            expectedProject = [subject getProjectInfoForUri:@"project-uri"];
        });
        
        it(@"should ask sqlite store for the client info", ^{
            sqlLiteStore should have_received(@selector(readAllRowsWithArgs:)).with(@{@"user_uri": @"user:uri",
                                                                                      @"uri":@"project-uri"});
        });
        
        it(@"should return the stored client correctly ", ^{
            expectedProject should equal(project);
        });
    });
});

SPEC_END
