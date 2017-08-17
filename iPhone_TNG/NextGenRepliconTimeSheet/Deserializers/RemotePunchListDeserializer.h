#import <Foundation/Foundation.h>

@class DateProvider;
@interface RemotePunchListDeserializer : NSObject

@property (nonatomic,readonly) DateProvider *dateProvider;
@property (nonatomic,readonly) NSDateFormatter *dateFormatter;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDateProvider:(DateProvider *)dateProvider
                       dateFormatter:(NSDateFormatter *)dateFormatter NS_DESIGNATED_INITIALIZER;

- (NSArray *)deserializeWithArray:(NSArray *)jsonArray;
- (NSArray *)deserialize:(NSDictionary *)jsonDictionary;
@end
