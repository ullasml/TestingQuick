#import <Foundation/Foundation.h>


@class KSPromise;


@protocol PunchesForDateFetcher <NSObject>

- (KSPromise *)punchesForDate:(NSDate *)date userURI:(NSString *)userURI;
- (KSPromise *)punchesForDateAndMostRecentLastTwoPunch:(NSDate *)date;

@end
