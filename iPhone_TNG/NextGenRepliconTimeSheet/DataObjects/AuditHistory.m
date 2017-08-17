
#import "AuditHistory.h"

@interface AuditHistory ()

@property (nonatomic, copy) NSString *uri;
@property (nonatomic, copy) NSArray *history;

@end


@implementation AuditHistory

- (instancetype)initWithHistory:(NSArray*)history uri:(NSString *)uri
{
    self = [super init];
    if (self) {
        self.uri = uri;
        self.history = history;
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
    return [NSString stringWithFormat:@"<%@ \r: uri: %@ \r  history: %@ \r>", NSStringFromClass([self class]), self.uri, self.history];
}

#pragma mark - NSObject

- (BOOL)isEqual:(AuditHistory *)otherActivity
{
    BOOL typesAreEqual = [self isKindOfClass:[otherActivity class]];
    if (!typesAreEqual) {
        return NO;
    }
    
    BOOL namesEqualOrBothNil = (!self.history && !otherActivity.history) || ([self.history isEqual:otherActivity.history]);
    BOOL urisEqualOrBothNil = (!self.uri && !otherActivity.uri) || ([self.uri isEqual:otherActivity.uri]);
    return namesEqualOrBothNil && urisEqualOrBothNil;
}

@end
