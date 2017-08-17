
#import <Foundation/Foundation.h>

@class AppDelegate;
@class LoginService;
@class ReachabilityMonitor;

@interface ErrorPresenter : NSObject

@property (nonatomic,readonly) AppDelegate *delegate;
@property (nonatomic,readonly) LoginService *loginService;
@property (nonatomic,readonly) ReachabilityMonitor *reachabilityMonitor;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithReachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                               loginService:(LoginService *)loginService
                                   delegate:(AppDelegate *)delegate NS_DESIGNATED_INITIALIZER;

-(void)presentAlertViewForError:(NSError *)error;

@end
