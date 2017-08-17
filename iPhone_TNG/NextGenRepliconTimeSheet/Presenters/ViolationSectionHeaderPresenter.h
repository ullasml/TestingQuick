#import <Foundation/Foundation.h>

@class DateProvider;
@class ViolationSection;

@interface ViolationSectionHeaderPresenter : NSObject

@property (nonatomic, readonly) NSDateFormatter *dateFormatter;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDateFormatter:(NSDateFormatter *)dateFormatter NS_DESIGNATED_INITIALIZER;

- (NSString *)sectionHeaderTextWithViolationSection:(ViolationSection *)violationSection;

@end
