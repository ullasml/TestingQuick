#import <Foundation/Foundation.h>


@class TimeLineCell;
@protocol Theme;
@class DayTimeLineCell;


@interface TimeLineCellStylist : NSObject


@property (nonatomic, readonly) id <Theme> theme;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary NS_UNAVAILABLE;

-(instancetype)initWithTheme:(id <Theme>)theme NS_DESIGNATED_INITIALIZER;

- (void)applyStyleToCell:(TimeLineCell *)timeLineCell hidesDescendingLine:(BOOL)hidesDescendingLine;

- (void)applyStyleToDayTimeLineCell:(DayTimeLineCell *)timeLineCell hidesDescendingLine:(BOOL)hidesDescendingLine;



@end
