#import <UIKit/UIKit.h>


@interface SupervisorTrendChartPlotView : UIView

@property (nonatomic) UIColor *barColor;

- (void)updateWithValues:(NSArray *)values
                  yScale:(NSInteger)yScale;

@end
