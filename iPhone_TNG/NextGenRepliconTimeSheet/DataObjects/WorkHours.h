#import <Foundation/Foundation.h>


@protocol WorkHours <NSObject>

@property (nonatomic, readonly) NSDateComponents *regularTimeComponents;
@property (nonatomic, readonly) NSDateComponents *breakTimeComponents;

@optional

@property (nonatomic, readonly) NSDateComponents *overtimeComponents;
@property (nonatomic, readonly) NSDateComponents *regularTimeOffsetComponents;
@property (nonatomic, readonly) NSDateComponents *breakTimeOffsetComponents;
@property (nonatomic, readonly) NSDateComponents *timeOffComponents;
@property (nonatomic, readonly) NSDateComponents *dateComponents;
@property (nonatomic, readonly) BOOL isScheduledDay;

@end
