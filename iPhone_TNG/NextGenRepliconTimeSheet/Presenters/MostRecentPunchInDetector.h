
#import <Foundation/Foundation.h>

@protocol Punch;
@class TimeLinePunchesStorage;

@interface MostRecentPunchInDetector : NSObject

@property (nonatomic,readonly) TimeLinePunchesStorage *timeLinePunchesStorage;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTimeLinePunchesStorage:(TimeLinePunchesStorage *)timeLinePunchesStorage NS_DESIGNATED_INITIALIZER;

-(id <Punch>)mostRecentPunchIn;

@end
