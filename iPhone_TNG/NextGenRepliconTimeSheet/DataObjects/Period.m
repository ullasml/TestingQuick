
#import "Period.h"

@interface Period ()

@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;

@end


@implementation Period

- (instancetype)initWithStartDate:(NSDate *)startDate
                          endDate:(NSDate *)endDate
{
    self = [super init];
    if (self)
    {
        self.startDate = startDate;
        self.endDate = endDate;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)isEqual:(Period *)otherType
{
    BOOL typesAreEqual = [self isKindOfClass:[otherType class]];
    if (!typesAreEqual) {
        return NO;
    }

    BOOL namesEqualOrBothNil = (!self.startDate && !otherType.startDate) || ([self.startDate compare:otherType.startDate] == NSOrderedSame);
    BOOL urisEqualOrBothNil = (!self.endDate && !otherType.endDate) || ([self.endDate compare:otherType.endDate] == NSOrderedSame);
    return namesEqualOrBothNil && urisEqualOrBothNil;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@> \r startDate: %@ \r endDate: %@", NSStringFromClass([self class]),
            self.startDate,
            self.endDate];
}

#pragma mark - <NSCopying>

- (id)copy
{
    return [self copyWithZone:NULL];
}

- (id)copyWithZone:(NSZone *)zone
{
    NSDate *startDateCopy = [self.startDate copy];
    NSDate *endDateCopy = [self.endDate copy];
    return [[Period alloc] initWithStartDate:startDateCopy
                                            endDate:endDateCopy];

}



@end
