#import <Foundation/Foundation.h>

@class FailedPunchErrorStorage;

@interface PunchErrorPresenter : NSObject

@property (nonatomic, readonly) FailedPunchErrorStorage *failedPunchErrorStorage;
@property (nonatomic, readonly) NSDateFormatter *dateFormatter;
@property (nonatomic, readonly) NSDateFormatter *timeFormatter;
@property (nonatomic, readonly) NSDateFormatter *localTimeZoneDateFormatter;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithLocalTimeZoneDateFormatter:(NSDateFormatter *)localTimeZoneDateFormatter
                           failedPunchErrorStorage:(FailedPunchErrorStorage *)failedPunchErrorStorage
                                     dateFormatter:(NSDateFormatter *)dateFormatter
                                     timeFormatter:(NSDateFormatter *)timeFormatter;

- (void)presentFailedPunchesErrors;

@end
