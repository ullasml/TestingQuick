//
//  ShiftPickerViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 09/09/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "ShiftPickerViewController.h"
#import "Constants.h"
#import "SupportDataModel.h"
#import "ShiftMainPageViewController.h"
#import "RepliconServiceManager.h"
#import "AppDelegate.h"
#import <Blindside/BSInjector.h>


@interface ShiftPickerViewController ()
@property (nonatomic, weak) id<BSInjector> injector;

@end

@implementation ShiftPickerViewController
@synthesize datePicker;
@synthesize supportDataModel;
@synthesize dayUriString;
@synthesize shiftMainPageController;
@synthesize dateDict;


- (void)viewDidLoad
{
    [super viewDidLoad];

    [Util setToolbarLabel:self withText:SELECT_A_DATE_TEXT];
    [self.view setBackgroundColor:RepliconStandardBlackColor];

    UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(Continue_Button_Title, @"")
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(continueButtonClicked:)];

    self.navigationItem.rightBarButtonItem = tempRightButtonOuterBtn;

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                     target:self action:@selector(cancelButtonClicked:)];
    self.navigationItem.leftBarButtonItem = cancelButton;


    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 400)];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.calendar.locale = [NSLocale currentLocale];;
    [self.datePicker addTarget:self action:@selector(getSelection:) forControlEvents:UIControlEventValueChanged];
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];

    [self.view addSubview:datePicker];
    self.view.backgroundColor = [Util colorWithHex:@"#EEEEEE" alpha:1.0f];

    self.dateDict = [[NSMutableDictionary alloc] init];

}

#pragma mark -
#pragma mark Picker Delegates methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 1;
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return self.view.frame.size.width;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{


}


#pragma mark -
#pragma mark - Button Action


-(void)getSelection:(id)sender
{

    NSDate *pickerDate = [datePicker date];
    [self getDateDict:pickerDate];

}

-(void)getDateDict :(NSDate*)date
{
    NSArray *uriArray = [NSArray arrayWithObjects:
                         @"urn:replicon:day-of-week:sunday",
                         @"urn:replicon:day-of-week:monday",
                         @"urn:replicon:day-of-week:tuesday",
                         @"urn:replicon:day-of-week:wednesday",
                         @"urn:replicon:day-of-week:thursday",
                         @"urn:replicon:day-of-week:friday",
                         @"urn:replicon:day-of-week:saturday",
                         nil];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:date];
    int weekday = (int)[comps weekday];



    NSUInteger dayIndex = 0;
    NSUInteger dayDifference = 0;

    dayIndex = [uriArray indexOfObject:self.dayUriString] +1;
    dayDifference = dayIndex - weekday;

    if (dayDifference == 0)
    {
        dayDiff = dayDifference;
    }
    else
    {
        dayDiff = -(dayDifference);
    }


    if (dayDifference == 1) {
        dayDifference =-6;
        dayDiff = 6;
    }

    gregorian.locale = [NSLocale currentLocale];
    // gregorian.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];;
    NSDateComponents *selectedDateComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
    NSInteger theDay = [selectedDateComponents day];
    NSInteger theMonth = [selectedDateComponents month];
    NSInteger theYear = [selectedDateComponents year];


    // now build a NSDate object for yourDate using these components
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:theDay];
    [components setMonth:theMonth];
    [components setYear:theYear];
    NSDate *thisDate = [gregorian dateFromComponents:components];


    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
    [offsetComponents setDay:dayDifference];
    NSDate *startDate = [gregorian dateByAddingComponents:offsetComponents toDate:thisDate options:0];
    [offsetComponents setDay:dayDifference+6];
    NSDate *lastDate = [gregorian dateByAddingComponents:offsetComponents toDate:thisDate options:0];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSString *startDateString = [dateFormat stringFromDate:startDate];
    NSString *lastDateString = [dateFormat stringFromDate:lastDate];
    [tempDict setValue:startDateString forKey:@"startDate"];
    [tempDict setValue:lastDateString forKey:@"endDate"];

    self.dateDict = tempDict;

    NSLog(@"%@",tempDict);
}

- (IBAction)continueButtonClicked:(id)sender {

    ShiftMainPageViewController *tmpShiftMainPageController=[self.injector getInstance:[ShiftMainPageViewController class]];
    self.shiftMainPageController=tmpShiftMainPageController;

    NSDate *pickerDate = [datePicker date];
    [self getDateDict:pickerDate];

    NSMutableArray *array=[Util getArrayOfDatesForWeekWithStartDate:[dateDict objectForKey:@"startDate"] andEndDate:[dateDict objectForKey:@"endDate"]];


    [[NSNotificationCenter defaultCenter] removeObserver:shiftMainPageController name:SHIFT_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:shiftMainPageController selector:@selector(createShiftSummary:) name:SHIFT_SUMMARY_RECIEVED_NOTIFICATION object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:shiftMainPageController name:SHIFT_CHECK_TIMEOFF_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:shiftMainPageController selector:@selector(checkTimeOffAndRequestForTimeOffs:) name:SHIFT_CHECK_TIMEOFF_NOTIFICATION object:nil];



    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;
    }

    NSString *idString = [self generateUDIDForDatabade];

    [[NSUserDefaults standardUserDefaults] setValue:idString forKey:@"id"];


    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    [[RepliconServiceManager shiftsService] sendRequestShiftToServiceForDataDict:dateDict];

    [dateDict setValue:idString  forKey:@"id"];

    if (!array)
    {
        array=[NSMutableArray array];
    }
    self.shiftMainPageController.shiftWeekDatesArray=array;
    self.shiftMainPageController.pageControl.currentPage=dayDiff;
    self.shiftMainPageController.currentlySelectedPage=dayDiff;
    self.shiftMainPageController.dateDict=dateDict;
    self.shiftMainPageController.delegate=self;
    [self.navigationController pushViewController:self.shiftMainPageController animated:YES];

}

- (IBAction)cancelButtonClicked:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(NSString*)generateUDIDForDatabade
{
    NSString *IDString = [Util getRandomGUID];


    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"] invertedSet];
    IDString = [[IDString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    return IDString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
