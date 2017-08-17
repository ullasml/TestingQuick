
#import <Foundation/Foundation.h>
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "Activity.h"
#import "BreakType.h"


@interface PunchCardObject : NSObject

@property (nonatomic,readonly) ClientType *clientType;
@property (nonatomic,readonly) ProjectType *projectType;
@property (nonatomic,readonly) BreakType *breakType;
@property (nonatomic,readonly) TaskType *taskType;
@property (nonatomic,readonly) Activity *activity;
@property (nonatomic,readonly) NSArray *oefTypesArray;
@property (nonatomic, strong) NSString *userUri;
@property (nonatomic, assign) BOOL isValidPunchCard;


@property (nonatomic,copy,readonly) NSString *uri;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithClientType:(ClientType *)clientType
                       projectType:(ProjectType *)projectType
                     oefTypesArray:(NSArray *)oefTypesArray
                         breakType:(BreakType *)breakType
                          taskType:(TaskType *)taskType
                          activity:(Activity *)activity
                               uri:(NSString *)uri;



@end
