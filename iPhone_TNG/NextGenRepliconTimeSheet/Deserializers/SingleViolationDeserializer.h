#import <Foundation/Foundation.h>


@class Violation;
@class WaiverDeserializer;


@interface SingleViolationDeserializer : NSObject

@property (nonatomic, readonly) WaiverDeserializer *waiverDeserializer;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithWaiverDeserializer:(WaiverDeserializer *)waiverDeserializer NS_DESIGNATED_INITIALIZER;

- (Violation *)deserialize:(NSDictionary *)violationDictionary;

@end
