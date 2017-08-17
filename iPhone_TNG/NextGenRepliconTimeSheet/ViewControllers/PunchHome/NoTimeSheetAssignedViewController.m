
#import "NoTimeSheetAssignedViewController.h"
#import "UserPermissionsStorage.h"
#import "HomeSummaryRepository.h"
#import "AppDelegate.h"
#import "Theme.h"
#import <KSDeferred/KSDeferred.h>
#import "SpinnerDelegate.h"
#import "Constants.h"
#import "ButtonStylist.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "HomeSummaryDelegate.h"
#import "SupportDataModel.h"

@interface NoTimeSheetAssignedViewController ()

@property (nonatomic, weak) IBOutlet UIButton               *refreshButton;
@property (nonatomic, weak) IBOutlet UILabel                *msgLabel;
@property (nonatomic, weak) id<SpinnerDelegate>             spinnerDelegate;
@property (nonatomic) HomeSummaryRepository                 *homeSummaryRepository;
@property (nonatomic) AppDelegate                           *appDelegate;
@property (nonatomic) id<Theme>                             theme;
@property (nonatomic) ButtonStylist                         *buttonStylist;
@property (nonatomic) ReachabilityMonitor                   *reachabilityMonitor;
@property (nonatomic) id<HomeSummaryDelegate>               homeSummaryDelegate;
@property (nonatomic) SupportDataModel                      *supportDataModel;


@end

@implementation NoTimeSheetAssignedViewController

- (instancetype)initWithHomeSummaryRepository:(HomeSummaryRepository *)homeSummaryRepository
                          homeSummaryDelegate:(id <HomeSummaryDelegate>)homeSummaryDelegate
                          reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                             supportDataModel:(SupportDataModel *)supportDataModel
                              spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                buttonStylist:(ButtonStylist *)buttonStylist
                                  appDelegate:(AppDelegate *)appDelegate
                                        theme:(id<Theme>)theme
{
    self = [super init];
    if (self) {
        self.homeSummaryDelegate = homeSummaryDelegate;
        self.reachabilityMonitor = reachabilityMonitor;
        self.homeSummaryRepository = homeSummaryRepository;
        self.supportDataModel = supportDataModel;
        self.spinnerDelegate = spinnerDelegate;
        self.buttonStylist = buttonStylist;
        self.appDelegate =appDelegate;
        self.theme = theme;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [self.theme supervisorDashboardBackgroundColor];
    [self.msgLabel setText:RPLocalizedString(NoTimeSheetAssignedMsg, NoTimeSheetAssignedMsg)];
    [self.msgLabel  setFont:[self.theme teamStatusValueFont]];
    UIColor *titleColor = [self.theme viewTimesheetButtonTitleColor];
    UIColor *backgroundColor = [self.theme viewTimesheetButtonBackgroundColor];
    UIColor *borderColor = [self.theme viewTimesheetButtonBorderColor];
    [self.buttonStylist styleButton:self.refreshButton
                              title:RPLocalizedString(RefreshButtonTitle, RefreshButtonTitle)
                         titleColor:titleColor
                    backgroundColor:backgroundColor
                        borderColor:borderColor];
}




#pragma  - Button Action 

-(IBAction)refreshButtonAction:(id)sender
{
    if ([self.reachabilityMonitor isNetworkReachable] == NO)
    {
        [Util showOfflineAlert];
        return;
    }
    [self.spinnerDelegate showTransparentLoadingOverlay];
    KSPromise *homeSumaaryPromise= [self.homeSummaryRepository getHomeSummary];
    [homeSumaaryPromise then:^id(NSDictionary *response) {
        NSDictionary *responseDataDictionary = response[@"d"];
        NSDictionary *userSummary = responseDataDictionary[@"userSummary"];
        int hasTimesheetAccess = 0;
        NSDictionary *timesheetCapabilities=[userSummary objectForKey:@"timesheetCapabilities"];
        if (timesheetCapabilities!=nil && ![timesheetCapabilities isKindOfClass:[NSNull class]]) {
            if ([[timesheetCapabilities objectForKey:@"hasTimesheetAccess"] boolValue] == YES )
                hasTimesheetAccess = 1;
        }

        [self.supportDataModel updateTimesheetPermission:hasTimesheetAccess];
        [self.homeSummaryDelegate homeSummaryFetcher:self didReceiveHomeSummaryResponse:responseDataDictionary];
        [self.appDelegate launchTabBarController];
        [self.spinnerDelegate hideTransparentLoadingOverlay];
        return nil;
    } error:^id(NSError *error) {
        [self.spinnerDelegate hideTransparentLoadingOverlay];
        return error;
    }];
}
@end
