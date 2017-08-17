

#import "ClientType.h"

@interface ClientType ()

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *uri;

@end

@implementation ClientType

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

- (BOOL)isEqual:(ClientType *)otherClientType
{
    BOOL typesAreEqual = [self isKindOfClass:[otherClientType class]];
    if (!typesAreEqual) {
        return NO;
    }

    BOOL namesEqualOrBothNil = (!self.name && !otherClientType.name) || ([self.name isEqual:otherClientType.name]);
    BOOL urisEqualOrBothNil = (!self.uri && !otherClientType.uri) || ([self.uri isEqual:otherClientType.uri]);
    return namesEqualOrBothNil && urisEqualOrBothNil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@> \r name: %@ \r uri: %@", NSStringFromClass([self class]),
            self.name,
            self.uri];
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
    return [[ClientType alloc] initWithName:nameCopy
                                       uri:uriCopy];

}



@end
