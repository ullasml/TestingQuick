#import <Foundation/Foundation.h>

@protocol Theme;

@interface SegmentedControlStylist : NSObject

@property (nonatomic, readonly) id <Theme> theme;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTheme:(id<Theme>)theme NS_DESIGNATED_INITIALIZER;

- (void)styleSegmentedControl:(UISegmentedControl *)segmentControl;
@end
