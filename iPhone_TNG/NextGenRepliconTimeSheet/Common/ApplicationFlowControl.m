
#import "ApplicationFlowControl.h"
#import "AppDelegate.h"

@interface ApplicationFlowControl ()

@property (nonatomic) AppDelegate *delegate;
@property (nonatomic) NSUserDefaults *userDefaults;


@end

@implementation ApplicationFlowControl

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
                            delegate:(AppDelegate *)delegate {
    self = [super init];
    if (self) {

        self.delegate = delegate;
        self.userDefaults = userDefaults;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


-(void)performFlowControlForError:(NSError *)error
{
    if ([[error domain] isEqualToString:PasswordAuthenticationErrorDomain]||
        [[error domain] isEqualToString:UserDisabledErrorDomain]||
        [[error domain] isEqualToString:PasswordExpiredErrorDomain]||
        [[error domain] isEqualToString:NoAuthErrorDomain]||
        [[error domain] isEqualToString:UnknownErrorDomain])
    {
        NSString *authMode = [self.userDefaults objectForKey:@"AuthMode"];
        if ([authMode isEqualToString:@"SAML"])
        {
            [self.delegate launchLoginViewController:NO];
        }
        else
        {
            [self.delegate launchLoginViewController:YES];
        }

    }
    else if ([[error domain] isEqualToString:UserAuthChangeErrorDomain])
    {
        [self.delegate launchLoginViewController:NO];
    }
    else if ([[error domain] isEqualToString:CompanyDisabledErrorDomain])
    {
        [self.delegate launchLoginViewController:NO];
    }

}
@end
