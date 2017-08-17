
#import "GrossHoursController.h"
#import "GrossHours.h"
#import "Theme.h"
#import "GrossPayHoursCell.h"
#import "Paycode.h"
#import "ChildControllerHelper.h"
#import <Blindside/Blindside.h>
#import "DonutChartViewController.h"

@interface GrossHoursController ()

@property (weak, nonatomic) IBOutlet UILabel *grossHoursHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalHoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *asterixHoursLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIView *grossPayLegendsContainerView;

@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic) NSArray *actualsByPayHoursArray;
@property (nonatomic) GrossPayCollectionViewViewController *grossPayCollectionViewViewController;
@property (nonatomic, weak) id<BSInjector> injector;
@property (nonatomic, copy) NSString *grossHoursHeaderText;
@property (nonatomic) GrossHours *grossHours;
@property (nonatomic) id<Theme> theme;
@property (weak, nonatomic) IBOutlet UIView *donutWidgetView;
@property (nonatomic) DonutChartViewController *donutChartViewController;
@property (nonatomic,weak) id <GrossHoursControllerDelegate> delegate;
@property (assign, nonatomic)ViewItemsAction actionType;
@property (nonatomic, assign) BOOL viewMoreOrLessAction;
@property (nonatomic) NSString *scriptCalculationDate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *asterixHeightConstraint;

@end

static NSString *const GrossPayCellReuseIdentifier = @"!";


@implementation GrossHoursController

- (instancetype)initWithChildControllerHelper:(ChildControllerHelper *)childControllerHelper
                                        theme:(id<Theme>)theme
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.childControllerHelper = childControllerHelper;
        self.theme = theme;
    }
    return self;
}

- (void)setupWithGrossHours:(GrossHours *)grossHours
       grossHoursHeaderText:(NSString *)grossHoursHeaderText
             actualsPayCode:(NSArray *)actualsByPayCodeArray
                   delegate:(id <GrossHoursControllerDelegate>)delegate
      scriptCalculationDate:(NSString *)scriptCalculationDate
{
    self.grossHours = grossHours;
    self.grossHoursHeaderText = grossHoursHeaderText;
    self.actualsByPayHoursArray = actualsByPayCodeArray;
    self.delegate = delegate;
    self.scriptCalculationDate = scriptCalculationDate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.separatorView.backgroundColor = [self.theme grossPaySeparatorBackgroundColor];
    
    self.grossHoursHeaderLabel.textColor = [self.theme grossPayTextColor];
    self.asterixHoursLabel.textColor = [self.theme grossPayTextColor];
    self.grossHoursHeaderLabel.font = [self.theme grossPayHeaderFont];
    self.grossHoursHeaderLabel.text = self.grossHoursHeaderText;
    
    self.totalHoursLabel.textColor = [self.theme grossPayTextColor];
    self.totalHoursLabel.font = [self.theme grossPayFont];
    
    self.totalHoursLabel.text = [NSString stringWithFormat:@"%@h:%@m",self.grossHours.hours,self.grossHours.minutes];
    if (self.scriptCalculationDate==nil) {
        self.asterixHeightConstraint.constant = 0.0f;
    }
    self.donutChartViewController = [self.injector getInstance:[DonutChartViewController class]];
    [self.donutChartViewController setupWithActualsPayCode:self.actualsByPayHoursArray currencyDisplayText:nil donutChartViewBounds:self.donutWidgetView.bounds];
    [self.childControllerHelper addChildController:self.donutChartViewController
                                toParentController:self
                                   inContainerView:self.donutWidgetView];

    if(self.actualsByPayHoursArray!=nil && self.actualsByPayHoursArray!=(id)[NSNull null])
    {
        self.grossPayCollectionViewViewController = [self.injector getInstance:[GrossPayCollectionViewViewController class]];
        [self.grossPayCollectionViewViewController setupWithActualsByPayCodeDetails:self.actualsByPayHoursArray theme:self.theme delegate:self scriptCalculationDate:self.scriptCalculationDate];
        
        [self.childControllerHelper addChildController:self.grossPayCollectionViewViewController
                                    toParentController:self
                                       inContainerView:self.grossPayLegendsContainerView];
    }
}

#pragma mark <GrossPayCollectionViewControllerDelegate>

-(void)grossPayTimeHomeViewControllerIntendsToUpdateHeight:(CGFloat)height viewItem:(ViewItemsAction)action
{
    [self.delegate grossPayControllerIntendsToUpdateHeight:0.0f viewItems:(ViewItemsAction)action];
}

#pragma mark <GrossPayHoursProtocol>

-(BOOL)checkForViewMore
{
    return [self.delegate didGrossPayHomeViewControllerShowingViewMore];
}

-(id <GrossPayHours> )grossPayCollectionControllerNeedsGrossPay
{
    return self;
}

@end
