

#import <Foundation/Foundation.h>
#import "ClientProjectTaskRepository.h"

@interface TimesheetClientProjectTaskRepository : NSObject<ClientProjectTaskRepository>

-(void)setUpWithUserUri:(NSString *)userUri;

@end

