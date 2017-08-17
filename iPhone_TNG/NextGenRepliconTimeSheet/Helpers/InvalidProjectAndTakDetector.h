#import <Foundation/Foundation.h>

@class PunchCardStorage;
@class TimeLinePunchesStorage;
@protocol Punch;

@interface InvalidProjectAndTakDetector : NSObject

@property (nonatomic, readonly) PunchCardStorage *punchCardStorage;
@property (nonatomic, readonly) TimeLinePunchesStorage *timeLinePunchesStorage;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTimeLinePunchesStorage:(TimeLinePunchesStorage*)timeLinePunchesStorage  punchCardStorage:(PunchCardStorage *)punchCardStorage NS_DESIGNATED_INITIALIZER;

-(void)validatePunchAndUpdate:(id<Punch>)punch withError:(NSDictionary*)error;
@end
