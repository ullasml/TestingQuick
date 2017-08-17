//
//  ErrorBannerViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 5/5/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "ErrorBannerViewController.h"
#import "Theme.h"
#import "Constants.h"
#import "ErrorDetailsDeserializer.h"
#import "ErrorDetailsStorage.h"
#import "ErrorDetails.h"
#import "ErrorDetailsViewController.h"
#import <Blindside/BSInjector.h>
#import "SyncNotificationScheduler.h"

@interface ErrorBannerViewController ()

@property (weak, nonatomic) IBOutlet UILabel    *errorLabel;
@property (weak, nonatomic) IBOutlet UILabel    *dateLabel;
@property (nonatomic) id<Theme> theme;
@property (nonatomic) NSNotificationCenter      *notificationCenter;
@property (nonatomic) ErrorDetailsDeserializer  *errorDetailsDeserializer;
@property (nonatomic) ErrorDetailsStorage       *errorDetailsStorage;
@property (nonatomic) NSDateFormatter           *dbDateLocalTimeZoneDateFormatter;
@property (nonatomic) NSDateFormatter           *dateFormatter;
@property (nonatomic, weak) id<BSInjector>      injector;
@property (nonatomic,assign) UINavigationController  *parentController;
@property (nonatomic) SyncNotificationScheduler      *syncNotificationScheduler;
@property (nonatomic) NSHashTable                    *observers;

@end

@implementation ErrorBannerViewController

- (instancetype)initWithTheme:(id <Theme>)theme
           notificationCenter:(NSNotificationCenter *)notificationCenter
     errorDetailsDeserializer:(ErrorDetailsDeserializer *)errorDetailsDeserializer
          errorDetailsStorage:(ErrorDetailsStorage *)errorDetailsStorage
                dateFormatter:(NSDateFormatter *)dateFormatter
    syncNotificationScheduler:(SyncNotificationScheduler *)syncNotificationScheduler
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.theme = theme;
        self.notificationCenter = notificationCenter;
        self.errorDetailsDeserializer = errorDetailsDeserializer;
        self.errorDetailsStorage = errorDetailsStorage;
        self.dbDateLocalTimeZoneDateFormatter = dateFormatter;
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.timeZone = [NSTimeZone localTimeZone];
        self.syncNotificationScheduler = syncNotificationScheduler;

        [self.notificationCenter removeObserver: self name: errorNotification object: nil];
        [self.notificationCenter addObserver: self
                                    selector: @selector(errorDataReceivedAction:)
                                        name: errorNotification
                                      object: nil];

        [self.notificationCenter removeObserver: self name: successNotification object: nil];
        [self.notificationCenter addObserver: self
                                    selector: @selector(successDataReceivedAction:)
                                        name: successNotification
                                      object: nil];
        self.observers = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.view.tag = ERROR_BANNER_TAG;

    self.view.backgroundColor = [self.theme errorBannerBackgroundColor];

    self.errorLabel.backgroundColor = [UIColor clearColor];
    self.errorLabel.textColor = [self.theme errorBannerCountTextColor];
    self.errorLabel.font = [self.theme errorBannerCountFont];

    self.dateLabel.backgroundColor = [UIColor clearColor];
    self.dateLabel.textColor = [self.theme errorBannerDateTextColor];
    self.dateLabel.font = [self.theme errorBannerDateFont];



}

-(void)setLocalDateFormatter:(NSDateFormatter *)dateFormatter
{
    self.dateFormatter = dateFormatter;
}

-(void)errorDataReceivedAction:(NSNotification *)notification
{
    NSDictionary *userinfo = [notification userInfo];
    NSArray *errorDetailsArray = [self.errorDetailsDeserializer deserialize:userinfo];
    [self.errorDetailsStorage storeErrorDetails:errorDetailsArray];
    [self updateErrorBannerData];
    [self.syncNotificationScheduler cancelNotification:@"ErrorBackgroundStatus"];
    NSArray *allErrorDetails = [self.errorDetailsStorage getAllErrorDetailsForModuleName:TIMESHEETS_TAB_MODULE_NAME];

    NSString *msg = nil;

    if (allErrorDetails.count==1)
    {
       msg = [NSString stringWithFormat:@"%@ %lu %@. %@",RPLocalizedString(@"You have", @""),(unsigned long)allErrorDetails.count,RPLocalizedString(@"error", @""), RPLocalizedString(@"Tap to view.",@"")];
    }
    else
    {
       msg = [NSString stringWithFormat:@"%@ %lu %@. %@",RPLocalizedString(@"You have", @""),(unsigned long)allErrorDetails.count,RPLocalizedString(@"errors", @""), RPLocalizedString(@"Tap to view.",@"")];
    }


    [self.syncNotificationScheduler cancelNotification:@"ErrorBackgroundStatus"];
    [self.syncNotificationScheduler scheduleNotificationWithAlertBody:msg uid:@"ErrorBackgroundStatus"];

}

-(void)successDataReceivedAction:(NSNotification *)notification
{
    NSDictionary *userinfo = [notification userInfo];
    NSArray *errorDetailsArray = [self.errorDetailsDeserializer deserialize:userinfo];
    ErrorDetails *errorDetails = errorDetailsArray.lastObject;
    if (errorDetails)
    {
        [self.errorDetailsStorage deleteErrorDetails:errorDetails.uri];
    }


    [self updateErrorBannerData];
    
}

- (void)presentErrorDetailsControllerOnParentController:(UINavigationController *)parentController withTabBarcontroller:(UITabBarController *)tabBarController
{
    [self.view removeFromSuperview];
    self.view.frame = CGRectMake(0.0f, CGRectGetHeight(parentController.view.bounds)-CGRectGetHeight([tabBarController.tabBar bounds])-45.0, CGRectGetWidth(parentController.view.bounds), errorBannerHeight);
    [parentController.view addSubview:self.view];
    [parentController.view bringSubviewToFront:self.view];
     [self updateErrorBannerData];

    self.parentController = parentController;
}


-(void)updateErrorBannerData
{
    NSArray *allErrorDetails = [self.errorDetailsStorage getAllErrorDetailsForModuleName:TIMESHEETS_TAB_MODULE_NAME];

    if ([allErrorDetails count]==0)
    {
        [self hideErrorBanner];
    }
    else
    {
        if (allErrorDetails.count==1)
        {
            self.errorLabel.text = [NSString stringWithFormat:@"%ld %@",(unsigned long)allErrorDetails.count,RPLocalizedString(notificationText, @"")];
        }
        else
        {
            self.errorLabel.text = [NSString stringWithFormat:@"%ld %@",(unsigned long)allErrorDetails.count,RPLocalizedString(notificationsText, @"")];

        }


        ErrorDetails *errorDetails = (ErrorDetails *)allErrorDetails.firstObject;
        NSDate *localDate = [self.dbDateLocalTimeZoneDateFormatter dateFromString:errorDetails.errorDate];
        NSLocale *locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        self.dateFormatter.locale = locale;
        self.dateFormatter.dateFormat = @"MMM dd";
        NSString *dateString = [self.dateFormatter stringFromDate:localDate];
        self.dateFormatter.dateFormat = @"hh:mm a";
        NSString *timeString = [self.dateFormatter stringFromDate:localDate];

        self.dateLabel.text = [NSString stringWithFormat:@"As of %@ at %@",dateString,timeString];

        [self showErrorBanner];
    }
    [self notifyObservers];
}

-(void)hideErrorBanner
{
    [self.view setHidden:YES];
}

-(void)showErrorBanner
{
    if (![self.parentController.topViewController isKindOfClass:[ErrorDetailsViewController class]])
    {
        [self.view setHidden:NO];
    }
    else
    {
       [self.view setHidden:YES];
    }
}

-(void)presentErrorDetailsViewController
{
    ErrorDetailsViewController *errorDetailsViewController = [self.injector getInstance:[ErrorDetailsViewController class]];
    [self.parentController pushViewController:errorDetailsViewController animated:YES];
}

#pragma mark - <ErrorBannerMonitorObserver>

-(void)addObserver:(id<ErrorBannerMonitorObserver>)observer
{
    [self.observers addObject:observer];
}

-(void)removeObserver
{
    [self.observers removeAllObjects];
}

-(void)notifyObservers
{
    for (id<ErrorBannerMonitorObserver> observer in self.observers)
    {
        [observer errorBannerViewChanged];
    }
}

#pragma mark - <UIView Delegates>

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self presentErrorDetailsViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
