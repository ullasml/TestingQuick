#import <Foundation/Foundation.h>


@class WaiverOption;


@interface Waiver : NSObject

@property (nonatomic, copy, readonly) NSString *URI;
@property (nonatomic, copy, readonly) NSString *displayText;
@property (nonatomic, copy, readonly) NSArray *options;
@property (nonatomic, readonly) WaiverOption *selectedOption;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithURI:(NSString *)URI
                displayText:(NSString *)displayText
                    options:(NSArray *)options
             selectedOption:(WaiverOption *)selectedOption NS_DESIGNATED_INITIALIZER;

@end
