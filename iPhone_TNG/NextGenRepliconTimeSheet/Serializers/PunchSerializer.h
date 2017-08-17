#import <Foundation/Foundation.h>


@protocol Punch;


@interface PunchSerializer : NSObject

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (NSDictionary *)timePunchDictionaryForPunch:(id<Punch>)punch;

@end
