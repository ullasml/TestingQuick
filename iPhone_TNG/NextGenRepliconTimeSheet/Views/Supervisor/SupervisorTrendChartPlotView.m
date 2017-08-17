#import "SupervisorTrendChartPlotView.h"


@interface SupervisorTrendChartPlotView ()

@property (nonatomic, copy) NSArray *values;
@property (nonatomic) NSInteger yScale;

@end


@implementation SupervisorTrendChartPlotView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.opaque = NO;
    }
    return self;
}

- (void)updateWithValues:(NSArray *)values
                  yScale:(NSInteger)yScale
{
    self.values = values;
    self.yScale = yScale;

    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGFloat height = CGRectGetHeight(self.bounds);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, self.bounds);

    CGContextSaveGState(context);

    CGContextTranslateCTM(context, 0.0f, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);

    [self drawBarsInContext:context];

    CGContextRestoreGState(context);
}

#pragma mark - Private

- (void)drawBarsInContext:(CGContextRef)context
{
    CGFloat plotWidth = CGRectGetWidth(self.bounds);
    CGFloat plotHeight = CGRectGetHeight(self.bounds);
    __block CGFloat barBorderHeight = 0;

    CGFloat barWidth = floorf(plotWidth / self.values.count);

    [self.values enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger i, BOOL *stop) {
        CGFloat barHeight = plotHeight * [value integerValue] / self.yScale;
        barHeight -= 0.5; // This is to make sure the bar doesnt touch the middle horizontal line.

        CGFloat x = barWidth * i;

        CGContextSetFillColorWithColor(context, [self.barColor CGColor]);
        CGContextFillRect(context, CGRectMake(x, 0, barWidth, barHeight));

        CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
        if (barHeight > 0) {
            //Draw Horizontal border line
            CGContextFillRect(context, CGRectMake(x, barHeight, barWidth, 0.5));
        }
        if (barHeight > barBorderHeight) {
            barBorderHeight = barHeight;
        }
        //Draw vertical Border line
        CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
        CGContextFillRect(context, CGRectMake(x, 0, 0.5, barBorderHeight));
        x += barWidth;
        barBorderHeight = barHeight;
    }];
}

@end
