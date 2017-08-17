

#import "PunchCardObject.h"
#import "Util.h"
#import "Activity.h"
#import "BreakType.h"

@interface PunchCardObject ()

@property (nonatomic) ClientType *clientType;
@property (nonatomic) ProjectType *projectType;
@property (nonatomic) BreakType *breakType;
@property (nonatomic) TaskType *taskType;
@property (nonatomic) Activity *activity;
@property (nonatomic) NSArray *oefTypesArray;
@property (nonatomic,copy) NSString *uri;


@end

@implementation PunchCardObject

- (instancetype)initWithClientType:(ClientType *)clientType
                       projectType:(ProjectType *)projectType
                     oefTypesArray:(NSArray *)oefTypesArray
                         breakType:(BreakType *)breakType
                          taskType:(TaskType *)taskType
                          activity:(Activity *)activity
                               uri:(NSString *)uri {
    self = [super init];
    if (self) {
        self.oefTypesArray = oefTypesArray;
        self.projectType = projectType;
        self.clientType = clientType;
        self.breakType = breakType;
        self.taskType = taskType;
        self.activity = activity;
        self.uri = uri;
        self.isValidPunchCard = YES;
    }
    return self;
}


#pragma mark - NSObject

- (BOOL)isEqual:(PunchCardObject *)otherPunchCard
{
    BOOL typesAreEqual = [self isKindOfClass:[otherPunchCard class]];
    if (!typesAreEqual) {
        return NO;
    }

    BOOL clientsEqualOrBothNil = (!self.clientType && !otherPunchCard.clientType) || ([self.clientType isEqual:otherPunchCard.clientType]);
    BOOL projectsEqualOrBothNil = (!self.projectType && !otherPunchCard.projectType) || ([self.projectType isEqual:otherPunchCard.projectType]);
    BOOL tasksEqualOrBothNil = (!self.taskType && !otherPunchCard.taskType) || ([self.taskType isEqual:otherPunchCard.taskType]);
    BOOL activitiesEqualOrBothNil = (!self.activity && !otherPunchCard.activity) || ([self.activity isEqual:otherPunchCard.activity]);
    BOOL uriEqualOrBothNil = (!self.uri && !otherPunchCard.uri) || ([self.uri isEqual:otherPunchCard.uri]) || (self.uri.length == 0 && otherPunchCard.uri.length ==0);
    BOOL oefTypesEqualOrBothNil = (!self.oefTypesArray && !otherPunchCard.oefTypesArray) || ([self.oefTypesArray isEqual:otherPunchCard.oefTypesArray]);
    BOOL breakEqualOrBothNil = (!self.breakType && !otherPunchCard.breakType) || ([self.breakType isEqual:otherPunchCard.breakType]);

    return clientsEqualOrBothNil && projectsEqualOrBothNil && tasksEqualOrBothNil && uriEqualOrBothNil && activitiesEqualOrBothNil && oefTypesEqualOrBothNil && breakEqualOrBothNil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@> \n client: %@ \n project: %@ \n task: %@ \n activity: %@ \n break: %@ \n uri: %@ \n oef: %@ \n userUri: %@", NSStringFromClass([self class]),
            self.clientType,
            self.projectType,
            self.taskType,
            self.activity,
            self.breakType,
            self.uri,
            self.oefTypesArray,
            self.userUri];
}

#pragma mark - <NSCopying>

- (id)copy
{
    return [self copyWithZone:NULL];
}

- (id)copyWithZone:(NSZone *)zone
{
    ClientType *clientCopy = [self.clientType copy];
    ProjectType *projectCopy = [self.projectType copy];
    TaskType *taskCopy = [self.taskType copy];
    Activity *activityCopy = [self.activity copy];
    BreakType *breakCopy = [self.breakType copy];
    NSMutableArray *oefTypesArrayCopy = [self.oefTypesArray copy];

    NSString *uriCopy = [self.uri copy];

    return [[PunchCardObject alloc]
                             initWithClientType:clientCopy
                                    projectType:projectCopy
                                  oefTypesArray:oefTypesArrayCopy
                                      breakType:breakCopy
                                       taskType:taskCopy
                                       activity:activityCopy
                                            uri:uriCopy];
    
}

@end
