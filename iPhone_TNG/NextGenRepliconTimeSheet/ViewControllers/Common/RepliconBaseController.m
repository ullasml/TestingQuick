
#import "RepliconBaseController.h"
#import "Theme.h"
#import "DefaultTheme.h"
#import <Blindside/BSInjector.h>
#import "InjectorProvider.h"

@interface RepliconBaseController ()
@property (nonatomic) id <Theme> theme;
@property (nonatomic) id <BSInjector> injector;
@end


@implementation RepliconBaseController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.injector = [InjectorProvider injector];
        self.theme = [self.injector getInstance:@protocol(Theme)];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}


@end
