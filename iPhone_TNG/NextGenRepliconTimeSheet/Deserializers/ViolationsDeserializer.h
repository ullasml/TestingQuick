#import <Foundation/Foundation.h>


@class SingleViolationDeserializer;


@interface ViolationsDeserializer : NSObject

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSingleViolationDeserializer:(SingleViolationDeserializer *)singleViolationDeserializer NS_DESIGNATED_INITIALIZER;

- (NSArray *)deserialize:(NSArray *)responseArray;
- (NSArray*)deserializeViolationsFromPunchValidationResult:(NSDictionary*)response;
@end
