
#import "GrossHours.h"

@interface GrossHours()
@property (nonatomic) NSString *hours;
@property (nonatomic) NSString *minutes;

@end

@implementation GrossHours

- (instancetype)initWithHours:(NSString *)hours
                      minutes:(NSString *)minutes
{
    self = [super init];
    if (self)
    {
        self.hours = hours;
        self.minutes = minutes;
    }
    return self;
    
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@> \r hours: %@ \r minutes: %@", NSStringFromClass([self class]),
            self.hours,
            self.minutes];
}

-(BOOL)isEqual:(GrossHours *)otherPunchUser
{
    if(![otherPunchUser isKindOfClass:[self class]]) {
        return NO;
    }
    
    BOOL hoursEqual = (!self.hours && !otherPunchUser.hours) || [self.hours isEqualToString:otherPunchUser.hours];
    BOOL minutesEqual = (!self.minutes && !otherPunchUser.minutes) || [self.minutes isEqual:otherPunchUser.minutes];
    return ( hoursEqual && minutesEqual);
}

#pragma mark - <NSCopying>

- (id)copy
{
    return [self copyWithZone:NULL];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[GrossHours alloc] initWithHours:[self.hours copy]
                                     minutes:[self.minutes copy]];
    
}


@end
