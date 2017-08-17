
#import <Foundation/Foundation.h>

@interface Period : NSObject

@property (nonatomic, readonly) NSDate *startDate;
@property (nonatomic, readonly) NSDate *endDate;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary NS_UNAVAILABLE;

- (instancetype)initWithStartDate:(NSDate *)startDate
                          endDate:(NSDate *)endDate;

@end
