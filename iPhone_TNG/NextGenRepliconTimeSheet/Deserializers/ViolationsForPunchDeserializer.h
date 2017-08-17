#import <Foundation/Foundation.h>


@class AllViolationSections;
@class SingleViolationDeserializer;


@interface ViolationsForPunchDeserializer : NSObject

@property (nonatomic, readonly) SingleViolationDeserializer *singleViolationDeserializer;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSingleViolationDeserializer:(SingleViolationDeserializer *)singleViolationDeserializer NS_DESIGNATED_INITIALIZER;

- (AllViolationSections *)deserialize:(NSDictionary *)jsonDictionary;

@end
