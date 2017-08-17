
#import "ProjectType.h"
#import "ClientType.h"
#import "Period.h"
#import "Constants.h"
#import "ProjectBillingType.h"
#import "ProjectTimeAndExpenseEntryType.h"


typedef enum {
    BillingTypeNone = 0,
    ProjectTimeAndExpenseEntryTypeNonBillable = 1,
    ProjectBillingTypeNonBillable = 2,
    ProjectTimeAndExpenseEntryTypeBillable = 3,
    ProjectBillingTypeBillable = 4,
    ProjectTimeAndExpenseEntryTypeBillableAndNonBillable = 5,
    ProjectBillingTypeBillableAndNonBillable= 6
}BillingType;

@interface ProjectType ()

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *uri;
@property (nonatomic) Period *projectPeriod;
@property (nonatomic) ClientType *client;
@property (nonatomic,assign) BOOL hasTasksAvailableForTimeAllocation;
@property (nonatomic,assign) BOOL isTimeAllocationAllowed;

@end

@implementation ProjectType

- (instancetype)initWithTasksAvailableForTimeAllocation:(BOOL)tasksAvailableForTimeAllocation
                                isTimeAllocationAllowed:(BOOL)isTimeAllocationAllowed
                                          projectPeriod:(Period *)projectPeriod
                                             clientType:(ClientType *)client
                                                   name:(NSString *)name
                                                    uri:(NSString *)uri
{
    self = [super init];
    if (self) {
        self.hasTasksAvailableForTimeAllocation = tasksAvailableForTimeAllocation;
        self.isTimeAllocationAllowed = isTimeAllocationAllowed;
        self.projectPeriod = projectPeriod;
        self.client = client;
        self.name = name;
        self.uri = uri;
    }
    return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(ProjectType *)otherProjectType
{
    BOOL typesAreEqual = [self isKindOfClass:[otherProjectType class]];
    if (!typesAreEqual) {
        return NO;
    }

    BOOL namesEqualOrBothNil = (!self.name && !otherProjectType.name) || ([self.name isEqual:otherProjectType.name]);
    BOOL urisEqualOrBothNil = (!self.uri && !otherProjectType.uri) || ([self.uri isEqual:otherProjectType.uri]);
    BOOL clientEqualOrBothNil = (!self.client && !otherProjectType.client) || ([self.client isEqual:otherProjectType.client]);
    BOOL projectPeriodEqualOrBothNil = (!self.projectPeriod && !otherProjectType.projectPeriod) || ([self.projectPeriod isEqual:otherProjectType.projectPeriod]);
//    BOOL hasTasksAvailableForTimeAllocationEqual = (self.hasTasksAvailableForTimeAllocation == otherProjectType.hasTasksAvailableForTimeAllocation);
    BOOL isTimeAllocationAllowedEqual = (self.isTimeAllocationAllowed == otherProjectType.isTimeAllocationAllowed);
    return (namesEqualOrBothNil &&
            urisEqualOrBothNil &&
            clientEqualOrBothNil &&
            projectPeriodEqualOrBothNil &&
//            hasTasksAvailableForTimeAllocationEqual &&
            isTimeAllocationAllowedEqual);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@> \r name: %@ \r uri: %@ \r Client: %@ \r Project: %@ \r hasTasksAvailableForTimeAllocation: %d \r isTimeAllocationAllowed: %d \r isProjectTypeRequired: %d", NSStringFromClass([self class]),
            self.name,
            self.uri,
            self.client,
            self.projectPeriod,
            self.hasTasksAvailableForTimeAllocation,
            self.isTimeAllocationAllowed,
            self.isProjectTypeRequired];
}

- (void)setClientTypeAsNoClient{
    self.client = nil;
    ClientType *clientType = [[ClientType alloc] initWithName:RPLocalizedString(ClientTypeNoClient, ClientTypeNoClient) uri:ClientTypeNoClientUri];
    self.client = clientType;
}

#pragma mark - <NSCoding>

- (id)initWithCoder:(NSCoder *)decoder
{
    BOOL hasTasksAvailableForTimeAllocation = [decoder decodeBoolForKey:@"hasTasksAvailableForTimeAllocation"];
    BOOL isTimeAllocationAllowed = [decoder decodeBoolForKey:@"isTimeAllocationAllowed"];
    Period *projectPeriod = [decoder decodeObjectForKey:@"projectPeriod"];
    ClientType *client = [decoder decodeObjectForKey:@"client"];
    NSString *name = [decoder decodeObjectForKey:@"name"];
    NSString *uri = [decoder decodeObjectForKey:@"uri"];

    return [self initWithTasksAvailableForTimeAllocation:hasTasksAvailableForTimeAllocation isTimeAllocationAllowed:isTimeAllocationAllowed projectPeriod:projectPeriod clientType:client name:name uri:uri];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeBool:self.hasTasksAvailableForTimeAllocation forKey:@"hasTasksAvailableForTimeAllocation"];
    [coder encodeBool:self.isTimeAllocationAllowed forKey:@"isTimeAllocationAllowed"];
    [coder encodeObject:self.projectPeriod forKey:@"projectPeriod"];
    [coder encodeObject:self.client forKey:@"client"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.uri forKey:@"uri"];
}

#pragma mark - <NSCopying>

- (id)copy
{
    return [self copyWithZone:NULL];
}

- (id)copyWithZone:(NSZone *)zone
{
    NSString *nameCopy = [self.name copy];
    NSString *uriCopy = [self.uri copy];
    Period *periodCopy = [self.projectPeriod copy];
    ClientType *clientCopy = [self.client copy];
    BOOL hasTasksAvailableForTimeAllocation = self.hasTasksAvailableForTimeAllocation;
    BOOL isTimeAllocationAllowed = self.isTimeAllocationAllowed;
    return [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:hasTasksAvailableForTimeAllocation
                                                isTimeAllocationAllowed:isTimeAllocationAllowed
                                                          projectPeriod:periodCopy
                                                             clientType:clientCopy
                                                                   name:nameCopy
                                                                    uri:uriCopy];

}

#pragma mark -Private Methods

- (BillingType)getBillingTypeForProject {
    
    BillingType billingType = BillingTypeNone;
    NSString *projectTimeAndExpenseEntryTypeUri = self.projectTimeAndExpenseEntryType.projectTimeAndExpenseEntryTypeUri;
    NSString *projectBillingTypeUri = self.projectBillingType.projectBillingTypeUri;
    
    if(self.projectTimeAndExpenseEntryType != nil && [projectTimeAndExpenseEntryTypeUri isEqualToString:ProjectTimeAndExpenseEntryTypeNonBillableUri]) {
        billingType = ProjectTimeAndExpenseEntryTypeNonBillable;
    }
    else if(self.projectTimeAndExpenseEntryType ==  nil && self.projectBillingType != nil) {
        if([projectBillingTypeUri isEqualToString:ProjectBillingTypeNonBillableUri]) {
            billingType = ProjectBillingTypeNonBillable;
        }
        
    }
    return billingType;
}

#pragma mark - Public Helper Methods

- (BOOL)isProjectBillable {
    BOOL isProjectBillable_;
    BillingType billingType = [self getBillingTypeForProject];
    
    switch (billingType) {
            
        case ProjectTimeAndExpenseEntryTypeNonBillable:
            isProjectBillable_ = FALSE;
            break;
            
        case ProjectBillingTypeNonBillable:
            isProjectBillable_ = FALSE;
            break;
            
        default:
            isProjectBillable_ = TRUE;
            break;
    }
    
    return isProjectBillable_;
}
@end
