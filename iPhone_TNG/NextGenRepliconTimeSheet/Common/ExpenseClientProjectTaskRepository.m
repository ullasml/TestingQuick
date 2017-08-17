
#import "ExpenseClientProjectTaskRepository.h"
#import "ClientRepositoryProtocol.h"
#import "ProjectRepositoryProtocol.h"
#import "TaskRepositoryProtocol.h"
#import "ExpenseClientRepository.h"
#import "ExpenseProjectRepository.h"
#import "ExpenseTaskRepository.h"
#import <Blindside/Blindside.h>


@interface ExpenseClientProjectTaskRepository()

@property (weak, nonatomic) id<BSInjector> injector;
@property (nonatomic) NSString *expenseSheetUri;
@end



@implementation ExpenseClientProjectTaskRepository

-(void)setUpWithExpenseSheetUri:(NSString*)uri
{
    self.expenseSheetUri = uri;
}

-(id <ClientRepositoryProtocol>)clientRepository
{
    ExpenseClientRepository *expenseClientRepository = [self.injector getInstance:[ExpenseClientRepository class]];
    [expenseClientRepository setUpWithExpenseSheetUri:self.expenseSheetUri];
    return expenseClientRepository;
}

-(id <ProjectRepositoryProtocol>)projectRepository
{
    ExpenseProjectRepository *expenseProjectRepository = [self.injector getInstance:[ExpenseProjectRepository class]];
    [expenseProjectRepository setUpWithExpenseSheetUri:self.expenseSheetUri];
    return expenseProjectRepository;
}

-(id <TaskRepositoryProtocol>)taskRepository
{
    ExpenseTaskRepository *expenseTaskRepository = [self.injector getInstance:[ExpenseTaskRepository class]];
    [expenseTaskRepository setUpWithExpenseSheetUri:self.expenseSheetUri];
    return expenseTaskRepository;
}

-(id <ActivityRepositoryProtocol>)activityRepository
{
    return nil;
}

-(NSString*)uri
{
    return self.expenseSheetUri;
}


@end
