//
//  ErrorDetails.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 5/11/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "ErrorDetails.h"

@interface ErrorDetails ()

@property (nonatomic) NSString * uri;
@property (nonatomic) NSString * errorMessage;
@property (nonatomic) NSString *errorDate;
@property (nonatomic) NSString *moduleName;

@end

@implementation ErrorDetails

- (instancetype)initWithUri:(NSString *)uri
               errorMessage:(NSString *)errorMessage
                  errorDate:(NSString *)errorDate
                 moduleName:(NSString *)moduleName {
    self = [super init];
    if (self)
    {
        self.uri = uri;
        self.errorMessage = errorMessage;
        self.errorDate = errorDate;
        self.moduleName = moduleName;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)isEqual:(ErrorDetails *)otherType
{
    BOOL typesAreEqual = [self isKindOfClass:[otherType class]];
    if (!typesAreEqual) {
        return NO;
    }

    BOOL urisEqualOrBothNil = (!self.uri && !otherType.uri) || ([self.uri compare:otherType.uri] == NSOrderedSame);
    BOOL errorMsgEqualOrBothNil = (!self.errorMessage && !otherType.errorMessage) || ([self.errorMessage compare:otherType.errorMessage] == NSOrderedSame);
    BOOL errorDateEqualOrBothNil = (!self.errorDate && !otherType.errorDate) || ([self.errorDate compare:otherType.errorDate] == NSOrderedSame);
    BOOL errorModuleEqualOrBothNil = (!self.moduleName && !otherType.moduleName) || ([self.moduleName compare:otherType.moduleName] == NSOrderedSame);

    return urisEqualOrBothNil && errorMsgEqualOrBothNil && errorDateEqualOrBothNil && errorModuleEqualOrBothNil;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@> \r uri: %@ \r error_msg: %@ \r date: %@ \r module: %@", NSStringFromClass([self class]),
            self.uri,
            self.errorMessage,
            self.errorDate,
            self.moduleName];
}


#pragma mark - <NSCoding>

- (id)initWithCoder:(NSCoder *)decoder
{
    NSString *uri = [decoder decodeObjectForKey:@"uri"];
    NSString *errorMessage = [decoder decodeObjectForKey:@"error_msg"];
    NSString *errorDate = [decoder decodeObjectForKey:@"date"];
    NSString *moduleName = [decoder decodeObjectForKey:@"module"];

    return [self initWithUri:uri errorMessage:errorMessage errorDate:errorDate moduleName:moduleName];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.uri forKey:@"uri"];
    [coder encodeObject:self.errorMessage forKey:@"error_msg"];
    [coder encodeObject:self.errorDate forKey:@"date"];
    [coder encodeObject:self.moduleName forKey:@"module"];
}

#pragma mark - <NSCopying>

- (id)copy
{
    return [self copyWithZone:NULL];
}

- (id)copyWithZone:(NSZone *)zone
{
    NSString *uri = [self.uri copy];
    NSString *errorMessage = [self.errorMessage copy];
    NSString *errorDate = [self.errorDate copy];
    NSString *moduleName = [self.moduleName copy];
    return [[ErrorDetails alloc] initWithUri:uri errorMessage:errorMessage errorDate:errorDate moduleName:moduleName];

}


@end
