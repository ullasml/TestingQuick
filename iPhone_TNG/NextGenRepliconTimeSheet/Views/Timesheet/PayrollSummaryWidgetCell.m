

#import "PayrollSummaryWidgetCell.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "InjectorKeys.h"


@implementation PayrollSummaryWidgetCell

-(void)createPayrollSummaryWidgetCellWithTitle:(NSString *)title paycodes:(NSArray *)paycodes yOffset:(float)yOffset labelHeight:(float)labelHeight hPadding:(float)hPadding

{
    float yWidgetSepartorView = 0;
    float separatorOffset = yOffset;
    float xOffset=10.0;
    float xRegularLabel=20;
    float rightPadding = 20.0;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset*2, SCREEN_WIDTH-(2*rightPadding), labelHeight)];
    [titleLabel setTextColor:[Util colorWithHex:@"#333333" alpha:1]];
    [titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setText:title];
    [titleLabel setNumberOfLines:1];
    [self.contentView addSubview:titleLabel];
    [titleLabel setAccessibilityIdentifier:@"uia_payroll_summary_widget_title_label"];

    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, CGRectGetMinY(titleLabel.frame)+CGRectGetHeight(titleLabel.frame) +5.0, SCREEN_WIDTH-(2*rightPadding), 15.0)];
    [dateLabel setTextColor:[Util colorWithHex:@"#A3A3A3" alpha:1]];
    [dateLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
    [dateLabel setTextAlignment:NSTextAlignmentLeft];
    if (paycodes.count>0)
    {
        NSString *savedOnDateUTCStr = paycodes.firstObject[@"savedOnDate"];
        if (savedOnDateUTCStr!=nil && ![savedOnDateUTCStr isKindOfClass:[NSNull class]])
        {
            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            
            NSDateFormatter *longDateInLocalTimeZoneFormatter = [appDelegate.injector getInstance:InjectorKeyLongDateInLocalTimeZoneFormatter];
            NSDate *dateInLocalTimeZone = [longDateInLocalTimeZoneFormatter dateFromString:savedOnDateUTCStr];
            
            NSDateFormatter *dateFormatter = [appDelegate.injector getInstance:InjectorKeyShortDateWithWeekdayInLocalTimeZoneFormatter];
            NSString *dateWithWeekday = [dateFormatter stringFromDate:dateInLocalTimeZone];
            
            NSDateFormatter *shortTimeWithAMPMInLocalTimeZoneFormatter = [appDelegate.injector getInstance:InjectorKeyShortTimeWithAMPMInLocalTimeZoneFormatter];
            NSString *timeInAMPM = [shortTimeWithAMPMInLocalTimeZoneFormatter stringFromDate:dateInLocalTimeZone];
            
            NSString *dateLabelText = [NSString stringWithFormat:@"%@ %@ %@ %@",RPLocalizedString(@"Data as of", @""),dateWithWeekday,RPLocalizedString(AT_STRING, @""),timeInAMPM];
            [dateLabel setText:dateLabelText];
        }

    }

    [dateLabel setNumberOfLines:1];
    [self.contentView addSubview:dateLabel];

    UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(xRegularLabel, CGRectGetMinY(titleLabel.frame)+CGRectGetHeight(titleLabel.frame)+2*yOffset, SCREEN_WIDTH/2, labelHeight)];
    [totalLabel setTextColor:[Util colorWithHex:@"#838383" alpha:1]];
    [totalLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
    [totalLabel setTextAlignment:NSTextAlignmentLeft];
    [totalLabel setText:RPLocalizedString(TOTAL_STRING, TOTAL_STRING)];
    [totalLabel setNumberOfLines:1];
    [self.contentView addSubview:totalLabel];



    BOOL zeroHoursScenario = NO;
    if (paycodes.count ==1) {
        NSString *paycode = paycodes.firstObject[@"paycodename"];
        if ([paycode isKindOfClass:[NSNull class]] || paycode.length ==0) {
            zeroHoursScenario = YES;
        }
    }

    if (paycodes.count>0 && !zeroHoursScenario) {
        BOOL showAmount = NO;
        if (paycodes.count>0) {
            showAmount = [paycodes.firstObject[@"displayPayAmount"] boolValue];
        }
        NSMutableArray *amountWidths = [[NSMutableArray alloc]init];
        NSMutableArray *hoursWidths = [[NSMutableArray alloc]init];

        for (NSDictionary *paycodeDict in paycodes) {
            NSString *paycodeamount = paycodeDict[@"paycodeamount"];
            NSString *paycodehours = [NSString stringWithFormat:@"%@ hrs",paycodeDict[@"paycodehours"]];

            NSNumber *paycodeAmountWidth = [self getWidthOfString:paycodeamount];
            [amountWidths addObject:paycodeAmountWidth];

            NSNumber *paycodeHoursWidth = [self getWidthOfString:paycodehours];
            [hoursWidths addObject:paycodeHoursWidth];

        }

        NSString *totalpayhours = [NSString stringWithFormat:@"%@ hrs",paycodes.firstObject[@"totalpayhours"]];
        NSString *totalpayamount = paycodes.firstObject[@"totalpayamount"];
        NSNumber *totalamountLabelWidth = [self getWidthOfString:totalpayamount];
        [amountWidths addObject:totalamountLabelWidth];
        NSNumber *totalhoursLabelWidth = [self getWidthOfString:totalpayhours] ;
        [hoursWidths addObject:totalhoursLabelWidth];

        NSArray *amountWidthNumbers = [NSArray arrayWithArray:amountWidths];
        amountWidthNumbers = [amountWidthNumbers sortedArrayUsingSelector:@selector(compare:)];
        float amountLabelMax = [[amountWidthNumbers lastObject] floatValue];

        NSArray *hoursWidthNumbers = [NSArray arrayWithArray:hoursWidths];
        hoursWidthNumbers = [hoursWidthNumbers sortedArrayUsingSelector:@selector(compare:)];
        float hoursLabelMax = [[hoursWidthNumbers lastObject] floatValue];




        float yPaycodeLabel = yOffset + 15.0;
        float hView = paycodes.count * (labelHeight +( 2 * separatorOffset));
        float yView=titleLabel.frame.origin.y+titleLabel.frame.size.height+yOffset;

        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xRegularLabel, yView, SCREEN_WIDTH, hView)];

        for (int i = 0 ; i < paycodes.count ; i++) {

            NSDictionary *paycodeDict = paycodes[i];
            NSString *paycodeamount = paycodeDict[@"paycodeamount"];
            NSString *paycodehours = [NSString stringWithFormat:@"%@ hrs",paycodeDict[@"paycodehours"]];
            NSString *paycodename = paycodeDict[@"paycodename"];

            UILabel *paycodeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, yPaycodeLabel, SCREEN_WIDTH/2, labelHeight)];
            [paycodeNameLabel setTextColor:[Util colorWithHex:@"#838383" alpha:1]];
            [paycodeNameLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
            [paycodeNameLabel setTextAlignment:NSTextAlignmentLeft];
            [paycodeNameLabel setText:paycodename];
            [paycodeNameLabel setNumberOfLines:1];
            [view addSubview:paycodeNameLabel];
            [self.contentView addSubview:view];
            [paycodeNameLabel setAccessibilityIdentifier:@"uia_pay_code_name_label_identifier"];




            float xPaycodeHourLabel = SCREEN_WIDTH - 40 - hoursLabelMax;
            if (showAmount) {

                float xPaycodeAmountLabel = SCREEN_WIDTH - 40 - amountLabelMax;
                xPaycodeHourLabel = xPaycodeAmountLabel -hoursLabelMax -10;
                UILabel *paycodeAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPaycodeAmountLabel, yPaycodeLabel, amountLabelMax, labelHeight)];
                [paycodeAmountLabel setTextColor:[Util colorWithHex:@"#838383" alpha:1]];
                [paycodeAmountLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
                [paycodeAmountLabel setTextAlignment:NSTextAlignmentRight];
                if ([[Util detectDecimalMark] isEqualToString:@","])
                {
                    paycodeamount=[paycodeamount stringByReplacingOccurrencesOfString:@"." withString:@","];
                }
                [paycodeAmountLabel setText:paycodeamount];
                [paycodeAmountLabel setNumberOfLines:1];
                [view addSubview:paycodeAmountLabel];
                [paycodeAmountLabel setAccessibilityIdentifier:@"uia_pay_code_amount_label_identifier"];

            }


            UILabel *paycodeHoursLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPaycodeHourLabel, yPaycodeLabel, hoursLabelMax, labelHeight)];
            [paycodeHoursLabel setTextColor:[Util colorWithHex:@"#838383" alpha:1]];
            [paycodeHoursLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
            [paycodeHoursLabel setTextAlignment:NSTextAlignmentRight];
            if ([[Util detectDecimalMark] isEqualToString:@","])
            {
                paycodehours=[paycodehours stringByReplacingOccurrencesOfString:@"." withString:@","];
            }
            [paycodeHoursLabel setText:paycodehours];
            [paycodeHoursLabel setNumberOfLines:1];
            [view addSubview:paycodeHoursLabel];
            [self.contentView addSubview:view];
            [paycodeHoursLabel setAccessibilityIdentifier:@"uia_pay_code_hours_label_identifier"];




            float ySeparator=paycodeNameLabel.frame.origin.y+paycodeNameLabel.frame.size.height+separatorOffset;
            UIView *viewSeparator=[[UIView alloc]initWithFrame:CGRectMake(0, ySeparator, SCREEN_WIDTH, 1)];
            [viewSeparator setBackgroundColor:[UIColor lightGrayColor]];
            [view addSubview:viewSeparator];

            yPaycodeLabel = ySeparator + separatorOffset ;



        }

        float yTotalLabel = view.frame.origin.y+hView+yOffset+15.0;
        CGRect frame = totalLabel.frame;
        frame.origin.y=yTotalLabel;
        totalLabel.frame = frame;
        float xPaycodeHourLabel = SCREEN_WIDTH - 20 - hoursLabelMax;
        if (showAmount) {

            float xPaycodeAmountLabel = SCREEN_WIDTH - 20 - amountLabelMax;
            xPaycodeHourLabel = xPaycodeAmountLabel -hoursLabelMax -10;
            UILabel *totalPaycodeAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPaycodeAmountLabel, yTotalLabel, amountLabelMax, labelHeight)];
            [totalPaycodeAmountLabel setTextColor:[Util colorWithHex:@"#838383" alpha:1]];
            [totalPaycodeAmountLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
            [totalPaycodeAmountLabel setTextAlignment:NSTextAlignmentRight];
            if ([[Util detectDecimalMark] isEqualToString:@","])
            {
                totalpayamount=[totalpayamount stringByReplacingOccurrencesOfString:@"." withString:@","];
            }
            [totalPaycodeAmountLabel setText:totalpayamount];
            [totalPaycodeAmountLabel setNumberOfLines:1];
            [self.contentView addSubview:totalPaycodeAmountLabel];
             [totalPaycodeAmountLabel setAccessibilityIdentifier:@"uia_payroll_summary_widget_amount_label_identifier"];
        }
        
        
        UILabel *paycodeHoursLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPaycodeHourLabel, yTotalLabel, hoursLabelMax, labelHeight)];
        [paycodeHoursLabel setTextColor:[Util colorWithHex:@"#838383" alpha:1]];
        [paycodeHoursLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
        [paycodeHoursLabel setTextAlignment:NSTextAlignmentRight];
        if ([[Util detectDecimalMark] isEqualToString:@","])
        {
            totalpayhours=[totalpayhours stringByReplacingOccurrencesOfString:@"." withString:@","];
        }
        [paycodeHoursLabel setText:totalpayhours];
        [paycodeHoursLabel setNumberOfLines:1];
        [self.contentView addSubview:paycodeHoursLabel];
        [paycodeHoursLabel setAccessibilityIdentifier:@"uia_payroll_summary_widget_total_hours_label_identifier"];


        yWidgetSepartorView = CGRectGetHeight(paycodeHoursLabel.frame)+CGRectGetMinY(paycodeHoursLabel.frame);
    }

    else{


        NSString *str = [Util getRoundedValueFromDecimalPlaces:[@"0.00" newDoubleValue] withDecimalPlaces:2];
        NSString *paycodehours = [NSString stringWithFormat:@"%@ hrs",str];
        float xPaycodeHourLabel = SCREEN_WIDTH - 20 - 100;
        UILabel *paycodeHoursLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPaycodeHourLabel, CGRectGetMinY(titleLabel.frame)+CGRectGetHeight(titleLabel.frame)+2*yOffset, 100, labelHeight)];
        [paycodeHoursLabel setTextColor:[Util colorWithHex:@"#838383" alpha:1]];
        [paycodeHoursLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
        [paycodeHoursLabel setTextAlignment:NSTextAlignmentRight];
        if ([[Util detectDecimalMark] isEqualToString:@","])
        {
            paycodehours=[paycodehours stringByReplacingOccurrencesOfString:@"." withString:@","];
        }
        [paycodeHoursLabel setText:paycodehours];
        [paycodeHoursLabel setNumberOfLines:1];
        [self.contentView addSubview:paycodeHoursLabel];
        [paycodeHoursLabel setAccessibilityIdentifier:@"uia_payroll_summary_widget_total_hours_label_identifier"];


        yWidgetSepartorView = CGRectGetHeight(paycodeHoursLabel.frame)+CGRectGetMinY(paycodeHoursLabel.frame);
    }

    UIView *statusView= [[UIView alloc]initWithFrame:CGRectMake(0, yWidgetSepartorView+8, SCREEN_WIDTH, hPadding)];
    [statusView setBackgroundColor:[Util colorWithHex:@"#DADADA" alpha:1]];
    [self.contentView addSubview:statusView];

}


-(NSNumber *)getWidthOfString:(NSString *)string
{
    UIFont *font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    float width = [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
    NSNumber *widthOfLabel = [NSNumber  numberWithFloat:width];
    return widthOfLabel;
}

@end
