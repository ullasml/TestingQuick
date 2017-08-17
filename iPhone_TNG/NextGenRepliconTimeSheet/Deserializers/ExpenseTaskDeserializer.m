#import "ExpenseTaskDeserializer.h"

#import "TaskType.h"


@implementation ExpenseTaskDeserializer

-(NSArray *)deserialize:(NSDictionary *)jsonDictionary forProjectWithUri:(NSString *)projectUri
{
    NSArray *tasks = jsonDictionary[@"d"];
    NSMutableArray *allTasks = [[NSMutableArray alloc]initWithCapacity:tasks.count];
    for (NSDictionary *taskInfo in tasks) {
        
        NSDictionary *task = taskInfo[@"task"];
        NSString *taskFullPath = taskInfo[@"taskFullPath"];
        NSString *uri = task[@"uri"];
        NSString *dispalyText = task[@"displayText"];
        NSString *name = [NSString stringWithFormat:@"%@%@",taskFullPath ? taskFullPath : @"", dispalyText];
        
        TaskType *taskType = [[TaskType alloc] initWithProjectUri:projectUri taskPeriod:nil name:name uri:uri];
        
        [allTasks addObject:taskType];
        
    }
    
    return allTasks;
}

@end
