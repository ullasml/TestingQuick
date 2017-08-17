#import <UIKit/UIKit.h>


@class DateProvider;
@class TodaysDateController;
@protocol Theme;


@interface TodaysDateControllerProvider : NSObject

@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic, readonly) NSDateFormatter *dateFormatter;
@property (nonatomic, readonly) id<Theme> theme;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDateProvider:(DateProvider *)dateProvider
                       dateFormatter:(NSDateFormatter *)dateFormatter
                               theme:(id <Theme>)theme NS_DESIGNATED_INITIALIZER;

- (TodaysDateController *)provideInstance;

@end
