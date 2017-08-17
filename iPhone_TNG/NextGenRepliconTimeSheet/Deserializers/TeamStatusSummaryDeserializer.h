#import <Foundation/Foundation.h>

@class TeamStatusSummary;
@class PunchUserDeserializer;


@interface TeamStatusSummaryDeserializer : NSObject

@property (nonatomic, readonly) PunchUserDeserializer *punchUserDeserializer;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithPunchUserDeserializer:(PunchUserDeserializer *)punchUserDeserializer NS_DESIGNATED_INITIALIZER;

- (TeamStatusSummary *)deserialize:(NSDictionary *)teamStatusDictionary;

@end
