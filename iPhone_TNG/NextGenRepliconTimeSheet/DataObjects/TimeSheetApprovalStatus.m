
#import "TimeSheetApprovalStatus.h"

@interface TimeSheetApprovalStatus()

@property (nonatomic, copy) NSString *approvalStatusUri;
@property (nonatomic, copy) NSString *approvalStatus;

@end

@implementation TimeSheetApprovalStatus

- (instancetype)initWithApprovalStatusUri:(NSString *)uri
                           approvalStatus:(NSString *)approvalStatus{
    if(self  = [super init]) {
        self.approvalStatusUri = uri;
        self.approvalStatus = approvalStatus;
    }
    
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@> \r approvalStatusUri: %@ \r approvalStatus: %@", NSStringFromClass([self class]),
            self.approvalStatusUri,
            self.approvalStatus];
}

-(BOOL)isEqual:(TimeSheetApprovalStatus *)otherPunchUser
{
    if(![otherPunchUser isKindOfClass:[self class]]) {
        return NO;
    }
    
    BOOL uriEqual = (!self.approvalStatusUri && !otherPunchUser.approvalStatusUri) || [self.approvalStatusUri isEqualToString:otherPunchUser.approvalStatusUri];
     BOOL statusEqual = (!self.approvalStatus && !otherPunchUser.approvalStatus) || [self.approvalStatus isEqualToString:otherPunchUser.approvalStatus];

    return ( uriEqual && statusEqual);
}

#pragma mark - <NSCopying>

- (id)copy
{
    return [self copyWithZone:NULL];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[TimeSheetApprovalStatus alloc] initWithApprovalStatusUri:[self.approvalStatusUri copy]
                                                       approvalStatus:[self.approvalStatus copy]];
}


@end
