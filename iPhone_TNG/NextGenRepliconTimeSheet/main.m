#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "RepliconAppDelegate.h"
#import "TestAppDelegate.h"


int main(int argc, char *argv[])
{
    @autoreleasepool {
        BOOL isGen2=[[NSUserDefaults standardUserDefaults]boolForKey:@"IS_GEN2_INSTANCE"];
        if (isGen2)
        {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([RepliconAppDelegate class]));
        }
        else
        {
            BOOL inTests = (BOOL)NSClassFromString(@"XCTest");
            if (inTests) {
                return UIApplicationMain(argc, argv, nil, NSStringFromClass([TestAppDelegate class]));
            }
            else
            {
                return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
            }
        }
    }
}
