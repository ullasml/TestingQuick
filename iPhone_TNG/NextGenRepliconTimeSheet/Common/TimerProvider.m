#import "TimerProvider.h"


@implementation TimerProvider

- (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                     target:(id)target
                                   selector:(SEL)selector
                                   userInfo:(id)userInfo
                                    repeats:(BOOL)repeats
{
    return [NSTimer scheduledTimerWithTimeInterval:interval
                                            target:target
                                          selector:selector
                                          userInfo:userInfo
                                           repeats:repeats];
}

@end
