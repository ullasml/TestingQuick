

#import <Foundation/Foundation.h>
@protocol ClientRepositoryProtocol;
@protocol ProjectRepositoryProtocol;
@protocol TaskRepositoryProtocol;
@protocol ActivityRepositoryProtocol;

@protocol ClientProjectTaskRepository

-(id <ClientRepositoryProtocol>)clientRepository;

-(id <ProjectRepositoryProtocol>)projectRepository;

-(id <TaskRepositoryProtocol>)taskRepository;

-(id <ActivityRepositoryProtocol>)activityRepository;


@optional
-(NSString *)uri;

@end
