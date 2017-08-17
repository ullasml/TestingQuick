
#import "ExpenseProjectDeserializer.h"
#import "ProjectType.h"
#import "ClientType.h"
#import "ProjectBillingType.h"
#import "ProjectTimeAndExpenseEntryType.h"


@implementation ExpenseProjectDeserializer

-(NSArray *)deserialize:(NSDictionary *)jsonDictionary
{
    NSArray *projects = jsonDictionary[@"d"];
    NSMutableArray *allProjects = [[NSMutableArray alloc]initWithCapacity:projects.count];
    for (NSDictionary *projectDictionary in projects) {
        
        NSDictionary *projectInfo = projectDictionary[@"project"];
        NSDictionary *clientInfo = projectDictionary[@"client"];
        NSString *projectName = projectInfo[@"name"];
        NSString *projectUri = projectInfo[@"uri"];
        
        NSString *clientName;
        NSString *clientUri;
        
        if (clientInfo != nil && clientInfo != (id) [NSNull null]) {
            clientName = clientInfo[@"name"];
            clientUri = clientInfo[@"uri"];
        }
        
        BOOL hasTasksAvailableForExpenseEntry = [projectDictionary[@"hasTasksAvailableForExpenseEntry"] boolValue];
        
        ClientType *client = [[ClientType alloc]initWithName:clientName
                                                         uri:clientUri];
        
        ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:hasTasksAvailableForExpenseEntry
                                                                   isTimeAllocationAllowed:NO
                                                                             projectPeriod:nil
                                                                                clientType:client
                                                                                      name:projectName
                                                                                       uri:projectUri];
        
        ProjectTimeAndExpenseEntryType *projectTimeAndExpenseEntryType = [self projectTimeAndExpenseEntryTypeFromJson:projectDictionary];
        ProjectBillingType *projectBillingType = [self projectBillingTypeFromJson:projectDictionary];
        
        project.projectBillingType = projectBillingType;
        project.projectTimeAndExpenseEntryType = projectTimeAndExpenseEntryType;
        
        
        [allProjects addObject:project];
    }
    return allProjects;
}

- (ProjectBillingType *)projectBillingTypeFromJson:(NSDictionary *)projectDictionary {
    
    NSDictionary *projectBillingType = projectDictionary[@"projectBillingType"];
    
    if(!projectBillingType || projectBillingType == (id)[NSNull null]){
        return nil;
    }
    
    NSString *displayText = projectBillingType[@"displayText"];
    NSString *uri = projectBillingType[@"uri"];
    
    ProjectBillingType *projectBillingTypeObj = [[ProjectBillingType alloc] initWithUri:uri displayText:displayText];
    
    return projectBillingTypeObj;
    
}

- (ProjectTimeAndExpenseEntryType *)projectTimeAndExpenseEntryTypeFromJson:(NSDictionary *)projectDictionary {
    
    NSDictionary *projectTimeAndExpenseEntryType = projectDictionary[@"projectTimeAndExpenseEntryType"];
    
    if(!projectTimeAndExpenseEntryType || projectTimeAndExpenseEntryType == (id)[NSNull null] ) {
        return nil;
    }
    
    NSString *displayText = projectTimeAndExpenseEntryType[@"displayText"];
    NSString *uri = projectTimeAndExpenseEntryType[@"uri"];
    
    ProjectTimeAndExpenseEntryType *projectTimeAndExpenseEntryTypeObj = [[ProjectTimeAndExpenseEntryType alloc] initWithUri:uri
                                                                                                                displayText:displayText];
    
    return projectTimeAndExpenseEntryTypeObj;
    
}

@end
