#import "PunchCardStorage.h"
#import "PunchCardObject.h"
#import "SQLiteTableStore.h"
#import "DateProvider.h"
#import "Punch.h"
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "OEFType.h"
#import "Constants.h"

@interface PunchCardStorage ()

@property (nonatomic) SQLiteTableStore *sqliteStore;
@property (nonatomic) DoorKeeper *doorKeeper;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) DateProvider *dateProvider;

@end

@implementation PunchCardStorage

- (instancetype)initWithSqliteStore:(SQLiteTableStore *)sqliteStore
                       dateProvider:(DateProvider *)dateProvider
                        userSession:(id <UserSession>)userSession
                         doorKeeper:(DoorKeeper *)doorKeeper {
    self = [super init];
    if (self) {
        self.sqliteStore = sqliteStore;
        self.doorKeeper = doorKeeper;
        self.userSession = userSession;
        self.dateProvider = dateProvider;
    }
    return self;
}
#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void)storePunchCard:(PunchCardObject *)punchCardObject
{
    NSString *projectUri = punchCardObject.projectType.uri;
    if ([self isValidString:projectUri]) {
        NSDictionary *punchCardDictionary = [self dictionaryWithPunchCardObject:punchCardObject];
        if (![self shouldAddCardOrNot:punchCardObject]) {
            NSDictionary *clientProjectAndTaskDictionary = [self dictionaryWithClientProjectAndTask:punchCardObject];
            [self.sqliteStore deleteRowWithArgs:clientProjectAndTaskDictionary];
        }
        [self.sqliteStore insertRow:punchCardDictionary];
    }
}

-(void)deletePunchCard:(PunchCardObject *)punchCardObject
{
    NSString *projectURI = IsNotEmptyString(punchCardObject.projectType.uri) ? punchCardObject.projectType.uri : @"";
    NSString *clientURI = IsNotEmptyString(punchCardObject.clientType.uri) ? punchCardObject.clientType.uri : @"";
    NSString *taskURI = IsNotEmptyString(punchCardObject.taskType.uri) ? punchCardObject.taskType.uri : @"";
    NSString *punchCardURI = IsNotEmptyString(punchCardObject.uri) ? punchCardObject.uri : @"";
    
    NSDictionary *userSessionFilter = @{@"user_uri": [self.userSession currentUserURI],
                                        @"uri":punchCardURI,
                                        @"client_uri": clientURI,
                                        @"project_uri" : projectURI,
                                        @"task_uri": taskURI};
    
    [self.sqliteStore deleteRowWithArgs:userSessionFilter];
}

-(NSArray *)getPunchCardsExcludingPunch:(id <Punch>)punch
{
    NSDictionary *whereFilter = @{@"user_uri": [self.userSession currentUserURI]};
    NSArray *punchCards = [self.sqliteStore readAllRowsWithArgs:whereFilter orderedBy:@"date"];

    NSMutableArray *allPunchCards = [[NSMutableArray alloc]initWithCapacity:punchCards.count];
    for (NSDictionary *cardInfo in punchCards) {
        PunchCardObject *card = [self punchCardWithDictionary:cardInfo];
        if (![self checkIfStoredPunchCard:card matchesCardWithMostRecentPunch:punch]) {
            [allPunchCards addObject:card];
        }

    }

    return allPunchCards;
}

-(NSArray *)getPunchCards
{
    NSDictionary *whereFilter = @{@"user_uri": [self.userSession currentUserURI]};
    NSArray *punchCards = [self.sqliteStore readAllRowsWithArgs:whereFilter orderedBy:@"date"];

    NSMutableArray *allPunchCards = [[NSMutableArray alloc]initWithCapacity:punchCards.count];
    for (NSDictionary *cardInfo in punchCards) {
        PunchCardObject *card = [self punchCardWithDictionary:cardInfo];
        [allPunchCards addObject:card];
    }
    
    return allPunchCards;
}

-(NSArray *)getPunchCardsDataDictionary
{
    NSDictionary *whereFilter = @{@"user_uri": [self.userSession currentUserURI]};
    NSArray *punchCards = [self.sqliteStore readAllRowsWithArgs:whereFilter orderedBy:@"date"];
    return punchCards;
}

- (NSArray *)getCPTMap {
    NSArray *punchCards = [self getPunchCardsDataDictionary];
    NSMutableArray *allPunchCards = [[NSMutableArray alloc]initWithCapacity:punchCards.count];
    for(NSDictionary *cardInfo in punchCards) {
        NSDictionary *cptMap = @{
                                     @"client": @{
                                                    @"uri" :[self getValidString:cardInfo[@"client_uri"]],
                                                    @"name":[self getValidString:cardInfo[@"client_name"]]
                                                },
                                     @"project":@{
                                                    @"uri" :[self getValidString:cardInfo[@"project_uri"]],
                                                    @"name":[self getValidString:cardInfo[@"project_name"]]
                                                },
                                     @"task" : @{
                                                    @"uri" :[self getValidString:cardInfo[@"task_uri"]],
                                                    @"name":[self getValidString:cardInfo[@"task_name"]]
                                                }
                                 };

        [allPunchCards addObject:cptMap];
    }
    return allPunchCards;
}

- (PunchCardObject *)getPunchCardObjectWithClientUri:(NSString *)clientUri
                                          projectUri:(NSString *)projectUri
                                             taskUri:(NSString *)taskUri {
    PunchCardObject *card = nil;

    NSDictionary *whereFilter = @{ @"client_uri":[self getValueAfterCheckForNullForValue:clientUri],
                                   @"project_uri":[self getValueAfterCheckForNullForValue:projectUri],
                                   @"task_uri":[self getValueAfterCheckForNullForValue:taskUri] };

    NSArray *punchCards = [self.sqliteStore readAllRowsWithArgs:whereFilter];

    for (NSDictionary *cardInfo in punchCards) {
        card = [self punchCardWithDictionary:cardInfo];
    }

    return card;
}

#pragma mark - Private

- (id)getValidString:(NSString *)string {
    if(!IsValidString(string)) {
        return [NSNull null];
    }
    return string;
}

- (NSDictionary *)dictionaryWithPunchCardObject:(PunchCardObject *)punchCard
{
    id clientUri = [self getValueAfterCheckForNullForValue:punchCard.clientType.uri];
    id projectUri = [self getValueAfterCheckForNullForValue:punchCard.projectType.uri];
    id taskUri = [self getValueAfterCheckForNullForValue:punchCard.taskType.uri];
    id clientName = [self getValueAfterCheckForNullForValue:punchCard.clientType.name];
    id projectName = [self getValueAfterCheckForNullForValue:punchCard.projectType.name];
    id taskName = [self getValueAfterCheckForNullForValue:punchCard.taskType.name];
    id uri = [self getValueAfterCheckForNullForValue:punchCard.uri];
    id userUri = [self getUserUri:punchCard];

    NSNumber *hasTasksAvailableForTimeAllocation = [NSNumber numberWithBool:punchCard.projectType.hasTasksAvailableForTimeAllocation];

    NSNumber *isValidPunchChard = [NSNumber numberWithBool:punchCard.isValidPunchCard];

    return @{@"client_uri": clientUri,
             @"project_uri": projectUri,
             @"task_uri": taskUri,
             @"client_name": clientName,
             @"project_name": projectName,
             @"task_name": taskName,
             @"uri":uri,
             @"user_uri":userUri,
             @"date":[self.dateProvider date],
             @"hasTasksAvailableForTimeAllocation":hasTasksAvailableForTimeAllocation,
             @"is_valid_punch_card":isValidPunchChard
             };

}

-(BOOL)isValidString:(NSString *)value
{
    if (value != nil && value != (id) [NSNull null] && value.length > 0 && ![value isEqualToString:NULL_STRING]) {
        return YES;
    }
    return NO;
}


- (NSDictionary *)dictionaryWithClientProjectAndTask:(PunchCardObject *)punchCard
{
    id clientUri = [self getValueAfterCheckForNullForValue:punchCard.clientType.uri];
    id projectUri = [self getValueAfterCheckForNullForValue:punchCard.projectType.uri];
    id taskUri = [self getValueAfterCheckForNullForValue:punchCard.taskType.uri];
    
    
    return @{@"client_uri": clientUri,
             @"project_uri": projectUri,
             @"task_uri": taskUri,
             };
}


-(id)getValueAfterCheckForNullForValue:(id)value
{
    if (value == nil || value == [NSNull null] ) {
        return @"";
    }
    return value;
}

- (NSString *)getUserUri:(PunchCardObject *)punchCard {
    NSString *userUri = punchCard.userUri;
    userUri = (IsNotEmptyString(userUri)) ? userUri : [self.userSession currentUserURI];
    return userUri;
}


-(BOOL)shouldAddCardOrNot:(PunchCardObject *)punchCardObject
{
    id clientUri = [self getValueAfterCheckForNullForValue:punchCardObject.clientType.uri];
    id projectUri = [self getValueAfterCheckForNullForValue:punchCardObject.projectType.uri];
    id taskUri = [self getValueAfterCheckForNullForValue:punchCardObject.taskType.uri];
    
    NSArray *punchCards = [self getPunchCardsDataDictionary];
    for (NSUInteger index = 0; index < [punchCards count]; index++) {
        NSDictionary *dataDict = punchCards[index];
        NSString *client = dataDict[@"client_uri"];
        NSString *project = dataDict[@"project_uri"];
        NSString *task = dataDict[@"task_uri"];
        
        if ([clientUri isEqualToString:client] && [projectUri isEqualToString:project] && [taskUri isEqualToString:task]) {
            return NO;
        }
    }
    return YES;
}


#pragma mark - <DoorKeeperLogOutObserver>

- (void)doorKeeperDidLogOut:(DoorKeeper *)doorKeeper
{

}

#pragma mark - Private

-(BOOL)checkIfStoredPunchCard:(PunchCardObject *)punchCardObject matchesCardWithMostRecentPunch:(id <Punch>)punch
{
    BOOL clientsBothNotNil = (!punchCardObject.clientType && !punch.client);
    BOOL clientsUriEqual = [punchCardObject.clientType.uri isEqual:punch.client.uri];
    BOOL isClientTypesEqual = clientsBothNotNil || clientsUriEqual;

    BOOL projectsBothNotNil = (!punchCardObject.projectType && !punch.project);
    BOOL projectsUriEqual = [punchCardObject.projectType.uri isEqual:punch.project.uri];
    BOOL isProjectTypesEqual = projectsBothNotNil || projectsUriEqual;

    BOOL tasksBothNotNil = (!punchCardObject.taskType && !punch.task);
    BOOL tasksUriEqual = [punchCardObject.taskType.uri isEqual:punch.task.uri];
    BOOL isTaskTypesEqual = tasksBothNotNil || tasksUriEqual;

    return isClientTypesEqual && isProjectTypesEqual && isTaskTypesEqual;
}

-(PunchCardObject *)punchCardWithDictionary:(NSDictionary *)cardInfo
{
    NSString *clientUri = cardInfo[@"client_uri"];
    NSString *projectUri = cardInfo[@"project_uri"];
    NSString *taskUri = cardInfo[@"task_uri"];
    NSString *clientName = cardInfo[@"client_name"];
    NSString *projectName = cardInfo[@"project_name"];
    NSString *taskName = cardInfo[@"task_name"];
    NSString *uri = cardInfo[@"uri"];
    NSString *userUri = cardInfo[@"user_uri"];
    BOOL hasTasks = [cardInfo[@"hasTasksAvailableForTimeAllocation"] boolValue];
    BOOL isValidPunchCard = [cardInfo[@"is_valid_punch_card"] boolValue];

    ClientType *client;
    if (clientUri != nil && clientUri != (id)[NSNull null] && clientUri.length > 0) {
        client = [[ClientType alloc]initWithName:clientName uri:clientUri];;
    }
    ProjectType *project;
    if (projectUri != nil && projectUri != (id)[NSNull null] && projectUri.length > 0) {
        project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:hasTasks
                                                      isTimeAllocationAllowed:NO
                                                                projectPeriod:nil
                                                                   clientType:client
                                                                         name:projectName
                                                                          uri:projectUri];
    }
    TaskType *task;
    if (taskUri != nil && taskUri != (id)[NSNull null] && taskUri.length > 0) {
        task = [[TaskType alloc]initWithProjectUri:projectUri taskPeriod:nil name:taskName uri:taskUri];
    }

    if (uri == nil || uri == (id)[NSNull null]) {
        uri = @"";
    }

    PunchCardObject *card = [[PunchCardObject alloc]
                                              initWithClientType:client
                                                     projectType:project
                                                   oefTypesArray:nil
                                                       breakType:NULL
                                                        taskType:task
                                                        activity:NULL
                                                             uri:uri];
    card.userUri = userUri;
    card.isValidPunchCard = isValidPunchCard;

    return card;
}

@end
