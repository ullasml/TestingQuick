#import <Foundation/Foundation.h>


@protocol HomeSummaryDelegate <NSObject>

- (void)homeSummaryFetcher:(id)homeSummaryFetcher didReceiveHomeSummaryResponse:(NSDictionary *)homeSummaryResponse;

@end
