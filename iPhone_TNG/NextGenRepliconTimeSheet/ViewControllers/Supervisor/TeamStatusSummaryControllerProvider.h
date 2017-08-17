#import <Foundation/Foundation.h>
#import "TeamStatusSummaryController.h"


@class TeamStatusSummaryController;
@class TeamStatusTablePresenter;
@class TeamTableStylist;
@class KSPromise;
@class ErrorBannerViewParentPresenterHelper;



@interface TeamStatusSummaryControllerProvider : NSObject

@property (nonatomic, readonly) TeamStatusTablePresenter              *teamStatusSummaryCellPresenter;
@property (nonatomic, readonly) TeamTableStylist                      *teamTableStylist;
@property (nonatomic, readonly) ErrorBannerViewParentPresenterHelper  *errorBannerViewParentPresenterHelper;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;


- (instancetype)initWithErrorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper *)errorBannerViewParentPresenterHelper
                              teamStatusSummaryCellPresenter:(TeamStatusTablePresenter *)teamStatusSummaryCellPresenter
                                            teamTableStylist:(TeamTableStylist *)teamTableStylist;

- (TeamStatusSummaryController *)provideInstanceWithTeamStatusSummaryPromise:(KSPromise *)teamStatusSummaryPromise initiallyDisplayedSection:(TeamStatusTableSection)initiallyDisplayedSection;

@end
