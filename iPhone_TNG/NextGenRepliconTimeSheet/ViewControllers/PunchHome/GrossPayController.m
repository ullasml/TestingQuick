#import "GrossPayController.h"
#import "CurrencyValue.h"
#import "Theme.h"
#import "GrossPayHoursCell.h"
#import "Paycode.h"
#import "ChildControllerHelper.h"
#import <Blindside/Blindside.h>
#import "DonutChartViewController.h"
#import "Theme.h"
#import <CoreText/CTStringAttributes.h>


@interface GrossPayController ()

@property (nonatomic, weak) id<BSInjector> injector;
@property (weak, nonatomic) IBOutlet UILabel *grossPayHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPayLabel;
@property (weak, nonatomic) IBOutlet UILabel *asterixPayLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (weak, nonatomic) IBOutlet UIView *grossPayLegendsContainerView;
@property (weak, nonatomic) IBOutlet UIView *donutWidgetView;
@property (nonatomic, assign) BOOL viewMoreOrLessAction;
@property (nonatomic, copy) NSString *grossPayHeaderText;
@property (nonatomic) NSNumberFormatter *numberFormatter;
@property (nonatomic) CurrencyValue *grossPay;
@property (nonatomic) id<Theme> theme;
@property (nonatomic) NSArray *actualsByPayCodeArray;
@property (nonatomic) GrossPayCollectionViewViewController *grossPayCollectionViewViewController;
@property (nonatomic) DonutChartViewController *donutChartViewController;
@property (nonatomic,weak) id <GrossPayControllerDelegate> delegate;
@property (assign, nonatomic)ViewItemsAction actionType;
@property (nonatomic) NSString *scriptCalculationDate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *asterixHeightConstraint;
@end

static NSString *const GrossPayCellReuseIdentifier = @"!";

@implementation GrossPayController

- (instancetype)initWithChildControllerHelper:(ChildControllerHelper *)childControllerHelper
                                        theme:(id<Theme>)theme
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.childControllerHelper = childControllerHelper;
        self.numberFormatter = [[NSNumberFormatter alloc] init];
        self.theme = theme;
    }
    return self;
}

- (void)setupWithGrossPay:(CurrencyValue *)grossPay
       grossPayHeaderText:(NSString *)grossPayHeaderText
           actualsPayCode:(NSArray *)actualsByPayCodeArray
                 delegate:(id <GrossPayControllerDelegate>)delegate
    scriptCalculationDate:(NSString *)scriptCalculationDate {
    self.grossPay = grossPay;
    self.grossPayHeaderText = grossPayHeaderText;
    self.actualsByPayCodeArray = actualsByPayCodeArray;
    self.delegate = delegate;
    self.scriptCalculationDate = scriptCalculationDate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.separatorView.backgroundColor = [self.theme grossPaySeparatorBackgroundColor];

    self.grossPayHeaderLabel.textColor = [self.theme grossPayTextColor];
    self.asterixPayLabel.textColor = [self.theme grossPayTextColor];
    self.grossPayHeaderLabel.font = [self.theme grossPayHeaderFont];
    self.grossPayHeaderLabel.text = self.grossPayHeaderText;

    self.totalPayLabel.textColor = [self.theme grossPayTextColor];
    self.totalPayLabel.font = [self.theme grossPayFont];
    [self.totalPayLabel sizeToFit];

    self.numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    self.numberFormatter.currencySymbol = self.grossPay.currencyDisplayText;

    self.totalPayLabel.text = [self.numberFormatter stringFromNumber:self.grossPay.amount];
    [self.totalPayLabel setAccessibilityIdentifier:@"uia_timesheet_gross_pay_value_label_identifier"];
    if (self.scriptCalculationDate==nil) {
        self.asterixHeightConstraint.constant = 0.0f;
    }
    self.donutChartViewController = [self.injector getInstance:[DonutChartViewController class]];
    [self.donutChartViewController setupWithActualsPayCode:self.actualsByPayCodeArray currencyDisplayText:self.grossPay.currencyDisplayText donutChartViewBounds:self.donutWidgetView.bounds];
    [self.childControllerHelper addChildController:self.donutChartViewController
                                toParentController:self
                                   inContainerView:self.donutWidgetView];

    if(self.actualsByPayCodeArray!=nil && self.actualsByPayCodeArray!=(id)[NSNull null])
    {        
        self.grossPayCollectionViewViewController = [self.injector getInstance:[GrossPayCollectionViewViewController class]];
        [self.grossPayCollectionViewViewController setupWithActualsByPayCodeDetails:self.actualsByPayCodeArray
                                                                              theme:self.theme
                                                                           delegate:self
                                                              scriptCalculationDate:self.scriptCalculationDate];
        
        [self.childControllerHelper addChildController:self.grossPayCollectionViewViewController
                                    toParentController:self
                                       inContainerView:self.grossPayLegendsContainerView];
        
    }
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

#pragma mark <GrossPayCollectionViewControllerDelegate>

-(void)grossPayTimeHomeViewControllerIntendsToUpdateHeight:(CGFloat)height viewItem:(ViewItemsAction)action
{
    [self.delegate grossPayControllerIntendsToUpdateHeight:0.0f viewItems:action];
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}



@end
