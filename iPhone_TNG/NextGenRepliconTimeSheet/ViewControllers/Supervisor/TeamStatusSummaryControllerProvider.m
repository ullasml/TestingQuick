#import "TeamStatusSummaryControllerProvider.h"
#import "TeamStatusSummaryController.h"
#import <KSDeferred/KSPromise.h>
#import "TeamStatusTablePresenter.h"
#import "TeamTableStylist.h"
#import "ErrorBannerViewParentPresenterHelper.h"

@interface TeamStatusSummaryControllerProvider ()

@property (nonatomic) TeamStatusTablePresenter              *teamStatusSummaryCellPresenter;
@property (nonatomic) TeamTableStylist                      *teamTableStylist;
@property (nonatomic) ErrorBannerViewParentPresenterHelper  *errorBannerViewParentPresenterHelper;
@end

@implementation TeamStatusSummaryControllerProvider

- (instancetype)initWithErrorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper *)errorBannerViewParentPresenterHelper
                              teamStatusSummaryCellPresenter:(TeamStatusTablePresenter *)teamStatusSummaryCellPresenter
                                            teamTableStylist:(TeamTableStylist *)teamTableStylist {
    self = [super init];
    if (self) {
        self.errorBannerViewParentPresenterHelper = errorBannerViewParentPresenterHelper;
        self.teamStatusSummaryCellPresenter = teamStatusSummaryCellPresenter;
        self.teamTableStylist = teamTableStylist;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (TeamStatusSummaryController *)provideInstanceWithTeamStatusSummaryPromise:(KSPromise *)teamStatusSummaryPromise initiallyDisplayedSection:(TeamStatusTableSection)initiallyDisplayedSection {

    TeamStatusSummaryController *teamStatusSummaryController = [[TeamStatusSummaryController alloc]     initWithErrorBannerViewParentPresenterHelper:self.errorBannerViewParentPresenterHelper
                                                                              teamStatusSummaryCellPresenter:self.teamStatusSummaryCellPresenter initiallyDisplayedSection:initiallyDisplayedSection teamStatusSummaryPromise:teamStatusSummaryPromise teamTableStylist:self.teamTableStylist];
    return teamStatusSummaryController;

}

@end
