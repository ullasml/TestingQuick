
#import "TimesheetActionRequestBodyProvider.h"
#import "Timesheet.h"
#import "GUIDProvider.h"

@interface TimesheetActionRequestBodyProvider ()
@property (nonatomic) GUIDProvider *guidProvider;
@end

@implementation TimesheetActionRequestBodyProvider

- (instancetype)initWithGuidProvider:(GUIDProvider *)guidProvider
{
    self = [super init];
    if (self)
    {
        self.guidProvider = guidProvider;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSDictionary *)requestBodyDictionaryWithComment:(NSString *)comment timesheet:(id <Timesheet>)timesheet{
    
    id comment_ = (comment ==  nil) ? [NSNull null] : comment;
    
    NSDictionary * postMap = @{@"timesheetUri":timesheet.uri,
                               @"unitOfWorkId":self.guidProvider.guid,
                               @"comments" :comment_,
                               @"changeReason":[NSNull null],
                               @"attestationStatus":[NSNull null]};
    return postMap;
}
@end
