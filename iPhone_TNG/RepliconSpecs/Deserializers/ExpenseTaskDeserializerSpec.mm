#import <Cedar/Cedar.h>
#import "ExpenseTaskDeserializer.h"
#import "RepliconSpecHelper.h"
#import "TaskType.h"
#import "ClientType.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ExpenseTaskDeserializerSpec)

describe(@"ExpenseTaskDeserializer", ^{
    __block ExpenseTaskDeserializer *subject;
    __block NSArray *tasksArray;
    
    beforeEach(^{
        subject = [[ExpenseTaskDeserializer alloc]init];
        NSDictionary *jsonDictionary= [RepliconSpecHelper jsonWithFixture:@"expense_get_tasks"];
        tasksArray = [subject deserialize:jsonDictionary forProjectWithUri:@"special-project-uri"];
    });
    
    it(@"should deserialize tasks correctly", ^{
        
        
        TaskType *taskA = [[TaskType alloc] initWithProjectUri:@"special-project-uri"
                                                    taskPeriod:nil
                                                          name:@"Design"
                                                           uri:@"urn:replicon-tenant:repliconiphone-2:task:100"];
        
        TaskType *taskB = [[TaskType alloc] initWithProjectUri:@"special-project-uri"
                                                    taskPeriod:nil
                                                          name:@"Development"
                                                           uri:@"urn:replicon-tenant:repliconiphone-2:task:101"];
        
        TaskType *taskC = [[TaskType alloc] initWithProjectUri:@"special-project-uri"
                                                    taskPeriod:nil
                                                          name:@"Product Mantaienance & Problems / QA"
                                                           uri:@"urn:replicon-tenant:repliconiphone-2:task:102"];
        
        
        tasksArray should equal(@[taskA,taskB,taskC]);
    });
    
    it(@"should deserialize tasks correctly when actual and expected task names are different", ^{

        TaskType *taskA = [[TaskType alloc] initWithProjectUri:@"special-project-uri"
                                                    taskPeriod:nil
                                                          name:@"Product Mantaienance & Problems /QA"
                                                           uri:@"urn:replicon-tenant:repliconiphone-2:task:102"];
        
        
        tasksArray.lastObject should_not equal(taskA);
    });
    
    it(@"should deserialize tasks correctly when task has only taskfullpath field", ^{
        
        TaskType *taskA = [[TaskType alloc] initWithProjectUri:@"special-project-uri"
                                                    taskPeriod:nil
                                                          name:@"Product Mantaienance & Problems /"
                                                           uri:@"urn:replicon-tenant:repliconiphone-2:task:102"];
        
        
        tasksArray.lastObject should_not equal(taskA);
    });
    
    it(@"should deserialize tasks correctly when task has only name field", ^{
        
        TaskType *taskA = [[TaskType alloc] initWithProjectUri:@"special-project-uri"
                                                    taskPeriod:nil
                                                          name:@"QA"
                                                           uri:@"urn:replicon-tenant:repliconiphone-2:task:102"];
        
        
        tasksArray.lastObject should_not equal(taskA);
    });
    
    it(@"should deserialize tasks correctly when name is empty", ^{
        
        TaskType *taskA = [[TaskType alloc] initWithProjectUri:@"special-project-uri"
                                                    taskPeriod:nil
                                                          name:@""
                                                           uri:@"urn:replicon-tenant:repliconiphone-2:task:102"];
        
        
        tasksArray.lastObject should_not equal(taskA);
    });
    
});

SPEC_END
