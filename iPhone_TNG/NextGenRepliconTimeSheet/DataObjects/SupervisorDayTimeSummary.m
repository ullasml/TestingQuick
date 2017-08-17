

#import "SupervisorDayTimeSummary.h"

@interface SupervisorDayTimeSummary()

@property (nonatomic) NSDateComponents *dateComponents;
@property (nonatomic) NSDateComponents *breakTimeComponents;
@property (nonatomic) NSDateComponents *regularTimeComponents;
@property (nonatomic) NSDateComponents *regularTimeOffsetComponents;
@property (nonatomic) NSDateComponents *breakTimeOffsetComponents;
@property (nonatomic) NSDateComponents *overTimeComponents;
@end

@implementation SupervisorDayTimeSummary

- (instancetype)initWithDateComponents:(NSDateComponents *)dateComponents
                 regularTimeComponents:(NSDateComponents *)regularTimeComponents
                   breakTimeComponents:(NSDateComponents *)breakTimeComponents
                    overTimeComponents:(NSDateComponents *)overtimeComponents
                     regularTimeOffset:(NSDateComponents *)regularTimeOffset
                       breakTimeOffset:(NSDateComponents *)breakTimeOffset{
    self = [super init];
    if (self) {
        self.dateComponents = dateComponents;
        self.breakTimeComponents = breakTimeComponents;
        self.regularTimeComponents = regularTimeComponents;
        self.regularTimeOffsetComponents = regularTimeOffset;
        self.breakTimeOffsetComponents = breakTimeOffset;
        self.overTimeComponents = overtimeComponents;
    }
    return self;
}

- (BOOL)isEqual:(SupervisorDayTimeSummary *)otherSupervisorDayTimeSummary
{
    return NO;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@>: RegularTimeComponents: %@, BreakTimeComponents: %@, OverTimeComponents: %@, RegularTimeOffsetComponents: %@, BreakTimeOffsetComponents: %@ ,DateComponents: %@", NSStringFromClass([self class]),
            self.regularTimeComponents,
            self.breakTimeComponents,
            self.overtimeComponents,
            self.regularTimeOffsetComponents,
            self.breakTimeOffsetComponents,
            self.dateComponents];
}


#pragma mark - <NSCoding>

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.regularTimeComponents forKey:@"regularTimeComponents"];
    [coder encodeObject:self.breakTimeComponents forKey:@"breakTimeComponents"];
    [coder encodeObject:self.overTimeComponents forKey:@"overTimeComponents"];
    [coder encodeObject:self.regularTimeOffsetComponents forKey:@"regularTimeOffsetComponents"];
    [coder encodeObject:self.breakTimeOffsetComponents forKey:@"breakTimeOffsetComponents"];
    [coder encodeObject:self.dateComponents forKey:@"dateComponents"];

}

- (id)initWithCoder:(NSCoder *)decoder
{
    NSDateComponents *regularTimeComponents = [decoder decodeObjectForKey:@"regularTimeComponents"];
    NSDateComponents *breakTimeComponents = [decoder decodeObjectForKey:@"breakTimeComponents"];
    NSDateComponents *overTimeComponents = [decoder decodeObjectForKey:@"overTimeComponents"];
    NSDateComponents *regularTimeOffset = [decoder decodeObjectForKey:@"regularTimeOffsetComponents"];
    NSDateComponents *breakTimeOffset = [decoder decodeObjectForKey:@"breakTimeOffsetComponents"];
    NSDateComponents *dateComponents = [decoder decodeObjectForKey:@"dateComponents"];


    return [self initWithDateComponents:dateComponents
                  regularTimeComponents:regularTimeComponents
                    breakTimeComponents:breakTimeComponents
                     overTimeComponents:overTimeComponents
                      regularTimeOffset:regularTimeOffset
                        breakTimeOffset:breakTimeOffset];
}


#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    return [[SupervisorDayTimeSummary alloc] initWithDateComponents:[self.dateComponents copy]
                                              regularTimeComponents:[self.regularTimeComponents copy]
                                                breakTimeComponents:[self.breakTimeComponents copy]
                                                 overTimeComponents:[self.overTimeComponents copy]
                                                  regularTimeOffset:[self.regularTimeOffsetComponents copy]
                                                    breakTimeOffset:[self.breakTimeOffsetComponents copy]];

}


@end
