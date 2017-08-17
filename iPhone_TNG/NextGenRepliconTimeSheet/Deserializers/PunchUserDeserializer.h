#import <Foundation/Foundation.h>

@class PunchUser;
@class BookedTimeOffDeserializer;

@interface PunchUserDeserializer : NSObject

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithBookedTimeOffDeserializer:(BookedTimeOffDeserializer *)bookedTimeOffDeserializer NS_DESIGNATED_INITIALIZER;

- (PunchUser *) deserialize:(NSDictionary *)punchUserDictionary;

@end
