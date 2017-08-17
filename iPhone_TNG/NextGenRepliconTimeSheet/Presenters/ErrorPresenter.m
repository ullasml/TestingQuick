
#import "ErrorPresenter.h"
#import "Constants.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "MobileLoggerWrapperUtil.h"

@interface ErrorPresenter ()

@property (nonatomic) AppDelegate *delegate;
@property (nonatomic) LoginService *loginService;
@property (nonatomic) ReachabilityMonitor *reachabilityMonitor;

@end

@implementation ErrorPresenter

- (instancetype)initWithReachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                               loginService:(LoginService *)loginService
                                   delegate:(AppDelegate *)delegate {
    self = [super init];
    if (self) {

        self.reachabilityMonitor = reachabilityMonitor;
        self.loginService = loginService;
        self.delegate = delegate;

    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void)presentAlertViewForError:(NSError *)error
{

    if ([[error domain] isEqualToString:RepliconNoAlertErrorDomain]||
        [[error domain] isEqualToString:RepliconHTTPNonJsonResponseErrorDomain])
    {
        return;
    }
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        [LogUtil logLoggingInfo:@"Application is in background" forLogLevel:LoggerCocoaLumberjack];
        return;
    }
    else
    {
        [LogUtil logLoggingInfo:@"Application is in foreground" forLogLevel:LoggerCocoaLumberjack];
        
    }

    NSString *message = error.userInfo[NSLocalizedDescriptionKey];
    if ([[error domain] isEqualToString:RepliconFailureStatusCodeDomain])
    {
        [UIAlertView showAlertViewWithCancelButtonTitle:nil
                                       otherButtonTitle:RPLocalizedString(APP_REFRESH_DATA_TITLE, @"")
                                               delegate:self.delegate
                                                message:message
                                                  title:nil
                                                    tag:555];

    }
    else if ([[error domain] isEqualToString:PasswordExpiredErrorDomain])
    {
        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                       otherButtonTitle:nil
                                               delegate:self.loginService
                                                message:message
                                                  title:nil
                                                    tag:9123];

    }
    else if ([[error domain] isEqualToString:UriErrorDomain])
    {
        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                       otherButtonTitle:nil
                                               delegate:self.delegate
                                                message:message
                                                  title:nil
                                                    tag:1001];
    }
    else if ([[error domain] isEqualToString:AuthorizationErrorDomain])
    {
        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(APP_REFRESH_DATA_TITLE, @"")
                                       otherButtonTitle:nil
                                               delegate:self.delegate
                                                message:message
                                                  title:nil
                                                    tag:555];

        
    }
    else if ([[error domain] isEqualToString:RepliconHTTPRequestErrorDomain])
    {
        if ([self.reachabilityMonitor isNetworkReachable])
        {
            [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                           otherButtonTitle:nil
                                                   delegate:nil
                                                    message:message
                                                      title:nil
                                                        tag:100002];
        }

    }
    else
    {
        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                       otherButtonTitle:nil
                                               delegate:nil
                                                message:message
                                                  title:nil
                                                    tag:LONG_MIN];
    }
    
}


@end
