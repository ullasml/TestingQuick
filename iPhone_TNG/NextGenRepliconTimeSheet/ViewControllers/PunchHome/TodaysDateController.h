#import <UIKit/UIKit.h>


@class DateProvider;
@protocol Theme;


@interface TodaysDateController : UIViewController

@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic, readonly) NSDateFormatter *dateFormatter;
@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, weak, readonly) UILabel *dateLabel;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDateProvider:(DateProvider *)dateProvider
                       dateFormatter:(NSDateFormatter *)dateFormatter
                               theme:(id <Theme>)theme NS_DESIGNATED_INITIALIZER;

-(void)setUpWithScheduledDay:(BOOL)isScheduledDay;

@end
