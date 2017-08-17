#import <Foundation/Foundation.h>


@protocol PunchOutDelegate <NSObject>

- (void)controllerDidPunchOut:(UIViewController *)controller;

@end
