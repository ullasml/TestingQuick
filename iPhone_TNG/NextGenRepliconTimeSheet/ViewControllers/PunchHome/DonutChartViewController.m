
#import "DonutChartViewController.h"
#import "Paycode.h"
#import "Util.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface DonutChartViewController ()
@property (nonatomic) PNPieChart *pieChart;
@property (nonatomic) id<Theme> theme;
@property (nonatomic) NSArray *actualsByPayCodeArray;
@property (nonatomic) NSString *currencyDisplayText;
@property (nonatomic) NSArray *items;
@property (nonatomic,assign) CGRect donutChartViewBounds;

@end

@implementation DonutChartViewController

- (instancetype)initWithTheme:(id <Theme>)theme
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.theme = theme;
    }
    return self;
}

- (void)setupWithActualsPayCode:(NSArray *)actualsByPayCodeArray currencyDisplayText:(NSString *)currencyDisplayText donutChartViewBounds:(CGRect )donutChartViewBounds
{

    self.actualsByPayCodeArray = actualsByPayCodeArray;
    self.currencyDisplayText = currencyDisplayText;
    self.donutChartViewBounds = donutChartViewBounds;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.items = [self getItemsForDonutChart:self.actualsByPayCodeArray];
    self.pieChart = [[PNPieChart alloc] initWithFrame:self.donutChartViewBounds items:self.items];
    self.pieChart.descriptionTextShadowColor = [UIColor clearColor];
    self.pieChart.showAbsoluteValues = NO;
    self.pieChart.showOnlyValues = YES;
    self.pieChart.hideValues = YES;
    self.pieChart.enableMultipleSelection = NO;
    self.pieChart.shouldHighlightSectorOnTouch = NO;
    [self.pieChart strokeChart];
    [self.view addSubview:self.pieChart];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSMutableArray *)getItemsForDonutChart:(NSArray *)actualPayCodeArray
{
    NSMutableArray *items = [NSMutableArray array];
    NSArray *colorListArr = [Util getColorList:(int)actualPayCodeArray.count];
    int count = 0;
    double total = 0.0;
    for (Paycode *paycode in actualPayCodeArray)
    {
        NSNumber *value=@0.0;
        if(paycode.titleValueWithSeconds!=nil && paycode.titleValueWithSeconds!=(id)[NSNull null])
        {
            if ([paycode.titleValueWithSeconds hasString:@":"])
            {
                float hours = 0;
                float minutes = 0;
                float seconds = 0;
                NSArray *hrminArr = [paycode.titleValueWithSeconds componentsSeparatedByString:@":"];
                if (hrminArr.count==3)
                {
                    NSArray *hrArr = [hrminArr[0] componentsSeparatedByString:@"h"];
                    NSArray *minArr = [hrminArr[1] componentsSeparatedByString:@"m"];
                    NSArray *secArr = [hrminArr[2] componentsSeparatedByString:@"s"];
                    
                    if (hrArr.count==2 && minArr.count==2 && secArr.count==2)
                    {
                        if ([hrArr[0] isEqualToString:@"-0"])
                        {
                            value = [NSNumber numberWithInteger:-1]; // a random -ve value
                        }
                        else
                        {
                            hours = [hrArr[0] intValue];
                            minutes = [minArr[0] intValue];
                            seconds = [secArr[0] intValue];
                            value = [Util convertApiTimeDictToDecimal:@{@"hours":[NSNumber numberWithInt:hours], @"minutes":[NSNumber numberWithInt:minutes],@"seconds":[NSNumber numberWithInt:seconds]}];
                        }
                        
                        
                    }
                    
                }
                
            }
        }
        else
        {
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            f.numberStyle = NSNumberFormatterDecimalStyle;
            value = [f numberFromString:[paycode.textValue substringFromIndex:self.currencyDisplayText.length]];
        }
        if ([value doubleValue]<0.0)
        {
            [items removeAllObjects];
            break;
        }
        [items addObject:[PNPieChartDataItem dataItemWithValue:[value doubleValue] color:colorListArr[count]]];
        total = total + [value doubleValue];
        count++;
    }

    if (total==0.0)
    {
        [items removeAllObjects];
    }

    if (items.count==0)
    {
        [items addObject:[PNPieChartDataItem dataItemWithValue:0.0 color:[Util colorWithHex:@"#dddfe0" alpha:1.0]]];
    }

    return items;
}

@end
