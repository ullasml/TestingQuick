#import <Cedar/Cedar.h>
#import "NextGenRepliconTimeSheet-Swift.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(DeepLinkManagerSpec)

describe(@"DeepLinkManager", ^{
    __block DeepLinkManager *subject;
    
    beforeEach(^{
        subject = [DeepLinkManager shared];
    });
    describe(@"For a valid shortcut", ^{
        __block UIApplicationShortcutItem *shortcutItem;
        beforeEach(^{
            NSString *type = [NSString stringWithFormat:@"%@.Enter time",[[NSBundle mainBundle] bundleIdentifier]];
            shortcutItem = [[UIApplicationShortcutItem alloc] initWithType:type localizedTitle:@"Enter time"];
        });
        
        it(@"handleShortcut should return true", ^{
            [subject handleShortcutWithItem:shortcutItem] should be_truthy;
        });
    });
    
    describe(@"For an Invalid shortcut - handleShortcut", ^{
        __block UIApplicationShortcutItem *shortcutItem;
        beforeEach(^{
            NSString *type = [NSString stringWithFormat:@"%@.Unknown",[[NSBundle mainBundle] bundleIdentifier]];
            shortcutItem = [[UIApplicationShortcutItem alloc] initWithType:type localizedTitle:@"Enter time"];
        });
        
        it(@"handleShortcut should return false", ^{
            [subject handleShortcutWithItem:shortcutItem] should be_falsy;
        });
    });
});

SPEC_END
