
#import "TaskType.h"
#import "Period.h"

@interface TaskType ()

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *uri;
@property (nonatomic,copy) NSString *projectUri;
@property (nonatomic) Period *taskPeriod;




@end

@implementation TaskType

- (instancetype)initWithProjectUri:(NSString *)projectUri
                        taskPeriod:(Period *)taskPeriod
                              name:(NSString *)name
                               uri:(NSString *)uri {
    self = [super init];
    if (self) {
        self.taskPeriod = taskPeriod;
        self.name = name;
        self.uri = uri;
        self.projectUri = projectUri;
    }
    return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(TaskType *)otherTaskType
{
    BOOL typesAreEqual = [self isKindOfClass:[otherTaskType class]];
    if (!typesAreEqual) {
        return NO;
    }

    BOOL namesEqualOrBothNil = (!self.name && !otherTaskType.name) || ([self.name isEqual:otherTaskType.name]);
    BOOL urisEqualOrBothNil = (!self.uri && !otherTaskType.uri) || ([self.uri isEqual:otherTaskType.uri]);
    BOOL periodsEqualOrBothNil = (!self.taskPeriod && !otherTaskType.taskPeriod) || ([self.taskPeriod isEqual:otherTaskType.taskPeriod]);
    BOOL projectUriEqualOrBothNil = (!self.projectUri && !otherTaskType.projectUri) || ([self.projectUri isEqual:otherTaskType.projectUri]);
    return namesEqualOrBothNil && urisEqualOrBothNil && periodsEqualOrBothNil && projectUriEqualOrBothNil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@> /r period: %@ /r name: %@ /r uri: %@ /r project uri: %@ ", NSStringFromClass([self class]),
            self.taskPeriod,
            self.name,
            self.uri,
            self.projectUri];
}

#pragma mark - <NSCoding>

- (id)initWithCoder:(NSCoder *)decoder
{
    NSString *projectUri = [decoder decodeObjectForKey:@"projectUri"];
    Period *taskPeriod = [decoder decodeObjectForKey:@"taskPeriod"];
    NSString *name = [decoder decodeObjectForKey:@"name"];
    NSString *uri = [decoder decodeObjectForKey:@"uri"];

    return [self initWithProjectUri:projectUri taskPeriod:taskPeriod name:name uri:uri];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.projectUri forKey:@"projectUri"];
    [coder encodeObject:self.taskPeriod forKey:@"taskPeriod"];
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
    Period *periodCopy = [self.taskPeriod copy];
    NSString *projectUriCopy = [self.projectUri copy];
    return [[TaskType alloc] initWithProjectUri:projectUriCopy taskPeriod:periodCopy name:nameCopy uri:uriCopy];

}

@end
