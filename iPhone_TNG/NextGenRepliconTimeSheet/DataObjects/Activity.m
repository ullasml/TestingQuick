
#import "Activity.h"

@interface Activity ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *uri;

@end


@implementation Activity

- (instancetype)initWithName:(NSString *)name
                         uri:(NSString *)uri
{
    self = [super init];
    if (self) {
        self.name = name;
        self.uri = uri;
    }

    return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(Activity *)otherActivity
{
    BOOL typesAreEqual = [self isKindOfClass:[otherActivity class]];
    if (!typesAreEqual) {
        return NO;
    }

    BOOL namesEqualOrBothNil = (!self.name && !otherActivity.name) || ([self.name isEqual:otherActivity.name]);
    BOOL urisEqualOrBothNil = (!self.uri && !otherActivity.uri) || ([self.uri isEqual:otherActivity.uri]);
    return namesEqualOrBothNil && urisEqualOrBothNil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@>: name: %@, uri: %@, isActivityRequired: %d", NSStringFromClass([self class]),
            self.name,
            self.uri,
            self.isActivityRequired];
}

#pragma mark - <NSCoding>

- (id)initWithCoder:(NSCoder *)decoder
{
    NSString *name = [decoder decodeObjectForKey:@"name"];
    NSString *uri = [decoder decodeObjectForKey:@"uri"];

    return [self initWithName:name uri:uri];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
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
    return [[Activity alloc] initWithName:nameCopy
                                       uri:uriCopy];

}

@end
