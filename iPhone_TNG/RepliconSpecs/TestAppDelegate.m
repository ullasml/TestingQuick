#import "TestAppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "BaseService.h"
#import "BaseService+Spec.h"
#import "NSObject+MethodRedirection.h"


@interface TestAppDelegate ()

@property (nonatomic) NSMutableDictionary *thumbnailCache;

@end


@implementation TestAppDelegate

+ (void)beforeEach
{
    SEL originalExecuteRequestSelector = NSSelectorFromString(@"originalExecuteRequest");

    [BaseService redirectSelector:@selector(executeRequest)
                               to:@selector(specExecuteRequest)
                    andRenameItTo:originalExecuteRequestSelector];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];

    NSArray *files = [fileManager contentsOfDirectoryAtPath:directory
                                                  error:nil];

    for(NSString *file in files) {
        [fileManager removeItemAtPath:[directory stringByAppendingPathComponent:file]
                            error:nil];
    }
}

+ (void)afterEach
{
    SEL originalExecuteRequestSelector = NSSelectorFromString(@"originalExecuteRequest");
    [BaseService redirectSelector:@selector(executeRequest)
                               to:originalExecuteRequestSelector
                    andRenameItTo:@selector(specExecuteRequest)];


}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    CGRect frame = [UIScreen mainScreen].bounds;
    self.window = [[UIWindow alloc] initWithFrame:frame];
    UILabel *label = [[UILabel alloc ] initWithFrame:CGRectMake(0, 0, 320.0f, 100.0f)];
    [self.window addSubview:label];
    label.text = @"Testing…";

    [self.window makeKeyAndVisible];

    UIViewController *testController = [[UIViewController alloc]init];
    self.window.rootViewController = testController;

    return YES;
}

- (void)sendRequestForGettingUpdatedBadgeValue
{
    
}

-(void)showTransparentLoadingOverlay{
    
}

-(void)hideTransparentLoadingOverlay
{
 
}

- (void)launchTabBarController
{
    
}

-(void) networkActivated
{

    
}

- (void)launchLoginViewController:(BOOL)showPasswordField
{

}

-(void)updateBadgeValue:(NSNotification*)notification
{
   
}

- (void)launchErrorDetailsViewController
{

}

@end
