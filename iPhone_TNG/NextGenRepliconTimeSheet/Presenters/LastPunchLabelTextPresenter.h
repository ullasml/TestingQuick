#import <Foundation/Foundation.h>


@interface LastPunchLabelTextPresenter : NSObject

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDateFormatter:(NSDateFormatter *)dateFormatter NS_DESIGNATED_INITIALIZER;

- (NSString *)lastPunchLabelTextWithDate:(NSDate *)date
                            formatString:(NSString *)formatString;

@property (nonatomic, readonly) NSDateFormatter *dateFormatter;

@end
