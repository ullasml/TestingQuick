

#import <Foundation/Foundation.h>

@interface DateUtil : NSObject 

+ (NSDate *)getUtcDateByAddingDays:(NSUInteger)days toUtcDate:(NSDate *)toUtcDate;

@end
