#import <Foundation/Foundation.h>
#import "Enum.h"

@class KSPromise;



@interface TimeLineAndRecentPunchRepository : NSObject


-(KSPromise *)punchesPromiseWithServerDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
                                          timeLinePunchFlow:(TimeLinePunchFlow)timeLinePunchFlow
                                                    userUri:(NSString *)userUri
                                                       date:(NSDate *)date;


@end
