#import <Foundation/Foundation.h>


@protocol Theme;


@interface DurationStringPresenter : NSObject

@property (nonatomic, readonly) id<Theme> theme;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTheme:(id<Theme>)theme;

- (NSAttributedString *)durationStringWithHours:(NSUInteger)hours
                                        minutes:(NSUInteger)minutes
                                        seconds:(NSUInteger)seconds;

- (NSString *)durationStringWithHours:(NSUInteger)hours minutes:(NSUInteger)minutes;


@end
