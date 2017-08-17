#import "OvertimeSummaryControllerProvider.h"
#import "OvertimeSummaryController.h"
#import <KSDeferred/KSPromise.h>


@interface OvertimeSummaryControllerProvider ()

@property (nonatomic) OvertimeSummaryTablePresenter *overtimeSummaryTablePresenter;
@end


@implementation OvertimeSummaryControllerProvider

- (instancetype)initWithOvertimeSummaryTablePresenter:(OvertimeSummaryTablePresenter *)overtimeSummaryTablePresenter;
{
    self = [super init];
    if (self) {
        self.overtimeSummaryTablePresenter = overtimeSummaryTablePresenter;
    }
    return self;
}
- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(OvertimeSummaryController *)provideInstanceWithOvertimeSummaryPromise:(KSPromise *)overtimeSummaryPromise
{
    return [[OvertimeSummaryController alloc] initWithOvertimeSummaryPromise:overtimeSummaryPromise overtimeSummaryTablePresenter:self.overtimeSummaryTablePresenter teamTableStylist:NULL];
}

@end
