
#import "WrongConfigurationMessageViewController.h"
#import "Theme.h"
#import "Constants.h"

@interface WrongConfigurationMessageViewController ()

@property (nonatomic, weak) IBOutlet UILabel                *msgLabel;
@property (nonatomic) id<Theme>                             theme;
@end

@implementation WrongConfigurationMessageViewController


- (instancetype)initWithTheme:(id<Theme>)theme
{
    self = [super init];
    if (self) {
        self.theme = theme;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [self.theme supervisorDashboardBackgroundColor];
    [self.msgLabel setText:RPLocalizedString(wrongConfigurationMsg, wrongConfigurationMsg)];
    [self.msgLabel  setFont:[self.theme teamStatusValueFont]];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


@end
