
#import "GrossPayTimeHomeViewController.h"
#import "UserPermissionsStorage.h"
#import "GrossPayController.h"
#import <Blindside/Blindside.h>
#import "CurrencyValue.h"
#import "GrossHours.h"
#import "Theme.h"
#import "ChildControllerHelper.h"
#import "GrossPayPagingController.h"
#import "GrossSummary.h"



@interface GrossPayTimeHomeViewController ()

@property (nonatomic) GrossPayPagingController *grossPayPagingController;
@property (nonatomic) UserPermissionsStorage *punchRulesStorage;
@property (nonatomic, weak) id<BSInjector> injector;
@property (nonatomic, copy) NSString *grossPayHeaderText;
@property (nonatomic, copy) NSString *grossHoursHeaderText;
@property (nonatomic) GrossHours *grossHours;
@property (nonatomic) CurrencyValue *grossPay;
@property (nonatomic) id<Theme> theme;
@property (nonatomic) BOOL disPlayPayAmountPermission;
@property (nonatomic) BOOL disPlayPayHoursPermission;
@property (nonatomic) NSArray *actualsByPayCodeArray;
@property (nonatomic) NSArray *actualsByPayDurationArray;
@property (nonatomic, weak) IBOutlet UIPageControl  *pageControl;
@property (nonatomic) NSArray *viewControllers;
@property (nonatomic,weak) id <GrossPayTimeHomeControllerDelegate> delegate;
@property (nonatomic) GrossHoursController *grossHoursController;
@property (nonatomic) GrossPayController *grossPayController;
@property (nonatomic, assign) BOOL viewMoreOrLessAction;
@property (nonatomic) NSString *scriptCalculationDate;
@property (weak, nonatomic) IBOutlet UIView *seperatorView;
@property (weak, nonatomic) IBOutlet UIView *pageControllerContainerView;
@end

@implementation GrossPayTimeHomeViewController

- (instancetype)initWithTheme:(id<Theme>)theme
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.theme = theme;
    }
    return self;
}

- (void)setupWithGrossSummary:(id <GrossSummary> )periodSummary
                     delegate:(id <GrossPayTimeHomeControllerDelegate>)delegate{
    self.grossPay = periodSummary.totalPay;
    self.grossHours = periodSummary.totalHours;
    self.grossPayHeaderText = RPLocalizedString(@"Gross Pay", @"Gross Pay");
    self.grossHoursHeaderText = RPLocalizedString(@"Total Time", @"Total Time");
    self.disPlayPayAmountPermission = periodSummary.payAmountDetailsPermission;
    self.disPlayPayHoursPermission = periodSummary.payHoursDetailsPermission;
    self.actualsByPayCodeArray = periodSummary.actualsByPayCode;
    self.actualsByPayDurationArray = periodSummary.actualsByPayDuration;
    self.delegate = delegate;
    self.scriptCalculationDate = periodSummary.scriptCalculationDate;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.grossHoursController = [self.injector getInstance:[GrossHoursController class]];
    [self.grossHoursController setupWithGrossHours:self.grossHours grossHoursHeaderText:self.grossHoursHeaderText actualsPayCode:self.actualsByPayDurationArray delegate:self scriptCalculationDate:self.scriptCalculationDate];

    self.grossPayController = [self.injector getInstance:[GrossPayController class]];
    [self.grossPayController setupWithGrossPay:self.grossPay grossPayHeaderText:self.grossPayHeaderText actualsPayCode:self.actualsByPayCodeArray delegate:self scriptCalculationDate:self.scriptCalculationDate];

    if(self.disPlayPayAmountPermission && self.disPlayPayHoursPermission)
    {
        self.viewControllers = @[self.grossPayController,self.grossHoursController];
    }
    else if(!self.disPlayPayAmountPermission && self.disPlayPayHoursPermission)
    {
        self.viewControllers = @[self.grossHoursController];
    }
    else if(self.disPlayPayAmountPermission && !self.disPlayPayHoursPermission)
    {
        self.viewControllers = @[self.grossPayController];
    }
    
    if (self.viewControllers.count > 0)
    {
        ChildControllerHelper *childControllerHelper = [self.injector getInstance:[ChildControllerHelper class]];
        self.grossPayPagingController = [self.injector getInstance:[GrossPayPagingController class]];
        self.grossPayPagingController.dataSource = self;
        self.grossPayPagingController.delegate = self;
        [self.grossPayPagingController setViewControllers:@[self.viewControllers.firstObject]
                                                direction:UIPageViewControllerNavigationDirectionForward
                                                 animated:NO
                                               completion:nil];
        
        if(self.disPlayPayAmountPermission && self.disPlayPayHoursPermission)
        {
            self.pageControl.hidden = NO;
        }
        else
        {
            self.grossPayPagingController.dataSource = nil;
            self.pageControl.hidden = YES;
        }
        
        
        [childControllerHelper addChildController:self.grossPayPagingController
                               toParentController:self
                                  inContainerView:self.pageControllerContainerView];
    }
    

}


#pragma mark - <UIPageViewControllerDataSource>
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 2;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    NSUInteger currentIndex = [self.viewControllers indexOfObject:viewController];
    if ((currentIndex == 0) || (currentIndex == NSNotFound)) {
        self.pageControl.currentPage = 0;
        return nil;
    }
    currentIndex--;
    self.pageControl.currentPage = currentIndex;
    return [self.viewControllers objectAtIndex:currentIndex];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {

    NSUInteger currentIndex = [self.viewControllers indexOfObject:viewController];

    if (currentIndex == NSNotFound) {
        return nil;
    }
    currentIndex++;

    if (currentIndex == [self.viewControllers count]) {
        self.pageControl.currentPage = currentIndex - 1;
        return nil;
    }
    self.pageControl.currentPage = currentIndex;
    return [self.viewControllers objectAtIndex:currentIndex];
}

#pragma mark <GrossPayControllerDelegate>

-(void)grossPayControllerIntendsToUpdateHeight:(CGFloat)height viewItems:(ViewItemsAction)action
{
    CGFloat heightForPayCodes=0.0f;
    CGFloat heightForViewMore=0.0f;
    if(self.disPlayPayAmountPermission && self.disPlayPayHoursPermission)
    {
        heightForViewMore = 30.0f;
    }
    if (action==More) {
        self.viewMoreOrLessAction = TRUE;
        heightForPayCodes = [self calculateHeightForPayWidgetLegends:(int)self.actualsByPayCodeArray.count];
    }
    else
    {
        heightForPayCodes = 100.0f;
        self.viewMoreOrLessAction = FALSE;
    }
    [self.delegate grossPayTimeHomeControllerIntendsToUpdateHeight:heightForPayCodes  + heightForViewMore viewItems:action];
}

- (BOOL)didGrossPayHomeViewControllerShowingViewMore
{
    return self.viewMoreOrLessAction;
}

-(CGFloat )calculateHeightForPayWidgetLegends:(NSUInteger)count
{
    return [Util calculateHeightForPayWidgetLegends:count];
}

@end
