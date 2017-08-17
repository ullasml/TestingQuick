
#import "TimesheetClientProjectTaskRepository.h"
#import "ClientRepositoryProtocol.h"
#import "ProjectRepositoryProtocol.h"
#import "TaskRepositoryProtocol.h"
#import <Blindside/Blindside.h>
#import "ClientRepository.h"
#import "ProjectRepository.h"
#import "TaskRepository.h"
#import "ActivityRepository.h"


@interface TimesheetClientProjectTaskRepository ()

@property (weak, nonatomic) id<BSInjector> injector;
@property (nonatomic) NSString *userUri;

@end

@implementation TimesheetClientProjectTaskRepository


-(void)setUpWithUserUri:(NSString *)userUri
{
    self.userUri = userUri;
}


-(id <ClientRepositoryProtocol>)clientRepository
{
    ClientRepository *clientRepository = [self.injector getInstance:[ClientRepository class]];
    [clientRepository setUpWithUserUri:self.userUri];
    return clientRepository;
}

-(id <ProjectRepositoryProtocol>)projectRepository
{
    ProjectRepository *projectRepository = [self.injector getInstance:[ProjectRepository class]];
    [projectRepository setUpWithUserUri:self.userUri];
    return projectRepository;
}

-(id <TaskRepositoryProtocol>)taskRepository
{
    TaskRepository *taskRepository = [self.injector getInstance:[TaskRepository class]];
    [taskRepository setUpWithUserUri:self.userUri];
    return taskRepository;
}

-(id <ActivityRepositoryProtocol>)activityRepository
{
    ActivityRepository *activityRepository = [self.injector getInstance:[ActivityRepository class]];
    [activityRepository setUpWithUserUri:self.userUri];
    return activityRepository;
}

@end
