//
//  DailyWidgetDayLevelViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 1/7/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "DailyWidgetDayLevelViewController.h"
#import "Constants.h"
#import "CurrentTimeSheetsCellView.h"
#import "DayTimeEntryCustomCell.h"
#import "TimesheetEntryObject.h"
#import "Util.h"
#import "AppDelegate.h"
#import "TimeEntryViewController.h"
#import "TimesheetMainPageController.h"
#import "LoginModel.h"
#import "ApprovalsScrollViewController.h"
#import "EditEntryViewController.h"
#import "BookedTimeOffEntry.h"
#import "TimeOffObject.h"
#import "TimeOffDetailsViewController.h"
#import "ApprovalsNavigationController.h"
#import "SupervisorDashboardNavigationController.h"
#import "OEFObject.h"
#import "DailyWidgetCutomCell.h"
#import "UIView+Additions.h"

#define Total_Hours_Footer_Height 28
#define Extra_Padding_Cell 35
#define Done_Toolbar_Height 44
#define CONTENT_IMAGEVIEW_TAG 9999
#define LABEL_WIDTH 200

@interface DailyWidgetDayLevelViewController ()

@property (nonatomic) OEFObject *selectedOEFObject;
@property (nonatomic,assign) NSInteger selectedRow;


@end

@implementation DailyWidgetDayLevelViewController
@synthesize timeEntryTableView;
@synthesize timesheetDataArray;
@synthesize currentIndexpath;
@synthesize datePicker;
@synthesize toolbar;
@synthesize selectedIndexPath;
@synthesize isTextFieldClicked;
@synthesize lastUsedTextField;
@synthesize lastUsedTextView;
@synthesize timesheetEntryObjectArray;
@synthesize timesheetStatus;
@synthesize isUDFieldClicked;
@synthesize controllerDelegate;
@synthesize isProjectAccess,isClientAccess;
@synthesize isActivityAccess;
@synthesize selectedDropdownUdfIndex;
@synthesize selectedTextUdfIndex;
@synthesize isBillingAccess;
@synthesize totallabelView;
@synthesize totalLabelHoursLbl;
@synthesize currentPageDate;
@synthesize cellHeightsArray;
@synthesize isProgramAccess;
@synthesize approvalsDelegate;
#pragma mark -
#pragma mark View lifeCycle Methods

- (void)loadView
{
    [super loadView];

    self.view = [[UIView alloc] init];

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [self.view setBackgroundColor:[Util colorWithHex:@"#f8f8f8" alpha:1]];

    self.timeEntryTableView = [[UITableView alloc] init];
    [self.timeEntryTableView setAccessibilityLabel:@"daily_widget_details_tableview"];
    self.timeEntryTableView.delegate = self;
    self.timeEntryTableView.dataSource = self;
    [self.timeEntryTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.view addSubview: self.timeEntryTableView];

    UIView *bckView = [UIView new];
    [bckView setFrame:CGRectMake(0,0 ,screenRect.size.width,screenRect.size.height)];
    [bckView setBackgroundColor:RepliconStandardWhiteColor];
    [ self.timeEntryTableView setBackgroundView:bckView];


    float totalCalculatedHours=0;
    for (int i=0; i<[self.timesheetEntryObjectArray count]; i++)
    {
        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:i];
        float timeEntryHours=[[tsEntryObject timeEntryHoursInDecimalFormat] newFloatValue];
        totalCalculatedHours=totalCalculatedHours+timeEntryHours;
    }


    self.totallabelView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, Total_Hours_Footer_Height)];
    [self.totallabelView setBackgroundColor:[Util colorWithHex:@"#EEEEEE" alpha:1.0f]];


    [self.view addSubview:totallabelView];

    UIImage *separatorImage = [Util thumbnailImage:Cell_HairLine_Image];
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0, self.view.width,1)];
    [lineImageView setImage:separatorImage];
    [self.timeEntryTableView setTableFooterView:lineImageView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    for (UIGestureRecognizer *recognizer in self.timeEntryTableView.tableHeaderView.gestureRecognizers)
    {
        [self.timeEntryTableView.tableHeaderView removeGestureRecognizer:recognizer];
    }
    [self.timeEntryTableView.tableHeaderView addGestureRecognizer:tap];
    self.cellHeightsArray=[NSMutableArray array];


}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerForKeyboardNotification];
}

-(void)registerForKeyboardNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillBeOnScreen:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)deregisterKeyboardNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

-(void)keyboardWillBeOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:keyboardFrame.size.height forKey:@"KeyBoardHeight"];
    [userDefaults synchronize];
}

-(void)keyboardOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    NSArray *allWindows = [[UIApplication sharedApplication] windows];
    NSUInteger topWindow = [allWindows count] - 1;
    UIWindow *keyboardWindow = [allWindows objectAtIndex:topWindow];
    for (UIView *view in keyboardWindow.subviews){
        if([view isKindOfClass:[DoneButton class]]){
            CGRect buttonFrame = view.frame;
            buttonFrame.size.height = keyboardFrame.size.height/4;
            buttonFrame.origin.y = SCREEN_HEIGHT - buttonFrame.size.height;
            [UIView animateWithDuration:0.2f animations:^{
                view.frame = buttonFrame;
            }];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self deregisterKeyboardNotification];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.timeEntryTableView.frame = CGRectMake(0, Total_Hours_Footer_Height, CGRectGetWidth([[UIScreen mainScreen] bounds]), [self heightForTableView] - Total_Hours_Footer_Height - 50.0f);

}

- (CGFloat)heightForTableView
{
    static CGFloat paddingForLastCellBottomSeparatorFudgeFactor = 2.0f;
    return CGRectGetHeight([[UIScreen mainScreen] bounds]) -
    (CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) +
     CGRectGetHeight(self.navigationController.navigationBar.frame) +
     CGRectGetHeight(self.tabBarController.tabBar.frame)) +
    paddingForLastCellBottomSeparatorFudgeFactor;
}

#pragma mark
#pragma mark  UITableView Delegates

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:RepliconStandardBackgroundColor];

    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)viewDidLayoutSubviews
{
    if ([self.timeEntryTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.timeEntryTableView setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([self.timeEntryTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.timeEntryTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self calculateHeights];
    return [[[cellHeightsArray objectAtIndex:[indexPath row]]objectForKey:CELL_HEIGHT_KEY]floatValue];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [timesheetEntryObjectArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"DayWidgetTSCellIdentifier";

    DailyWidgetCutomCell *cell = (DailyWidgetCutomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[DailyWidgetCutomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }


    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }

    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:indexPath.row];

    BOOL isEditState=YES;
    if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
        [timesheetStatus isEqualToString:APPROVED_STATUS ]||
        [tsEntryObject.entryType isEqualToString:Time_Off_Key]||![tsEntryObject isRowEditable])
    {
        isEditState=NO;
    }

    NSMutableArray *oefArr = tsEntryObject.timeEntryDailyFieldOEFArray;
    OEFObject *oefObject = oefArr[0];

    NSString *cellTitle=[oefObject oefName];
    NSString *fieldValue=nil;
    NSString *fieldType=nil;
    if (oefObject.oefNumericValue!=nil && ![oefObject.oefNumericValue isKindOfClass:[NSNull class]])
    {
        fieldValue=[oefObject oefNumericValue];
    }
    else if (oefObject.oefTextValue!=nil && ![oefObject.oefTextValue isKindOfClass:[NSNull class]])
    {
        fieldValue=[oefObject oefTextValue];
    }
    else if (oefObject.oefDropdownOptionValue!=nil && ![oefObject.oefDropdownOptionValue isKindOfClass:[NSNull class]])
    {
        fieldValue=[oefObject oefDropdownOptionValue];
    }

    fieldType=[oefObject oefDefinitionTypeUri];

    NSString *cellValue=nil;

    BOOL isNumericField = NO;

    if([fieldType isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
    {


        if (fieldValue==nil)
        {
            if (!isEditState)
            {
                cellValue=RPLocalizedString(NONE_STRING, @"");
            }
            else
            {
                cellValue=RPLocalizedString(DAILY_WIDGET_PLACEHOLDER_NUMERIC_OEF, DAILY_WIDGET_PLACEHOLDER_NUMERIC_OEF);
            }

        }
        else
        {
          cellValue=[NSString stringWithFormat:@"%@",[Util getRoundedValueFromDecimalPlaces:[fieldValue newDoubleValue] withDecimalPlaces:2.0]];
        }

        isNumericField = YES;

    }
    else if ([fieldType isEqualToString:UDFType_DROPDOWN] || [fieldType isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
    {
        cellValue=[NSString stringWithFormat:@"%@",fieldValue];

        if (fieldValue==nil)
        {
            if (!isEditState)
            {
                cellValue=RPLocalizedString(NONE_STRING, @"");
            }
            else
            {
                cellValue=RPLocalizedString(DAILY_WIDGET_PLACEHOLDER_DROPDOWN_OEF, DAILY_WIDGET_PLACEHOLDER_DROPDOWN_OEF);
            }

        }


    }

    else if([fieldType isEqualToString:UDFType_TEXT] || [fieldType isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI])
    {
        cellValue=[NSString stringWithFormat:@"%@",fieldValue];

        if (fieldValue==nil)
        {
            if (!isEditState)
            {
                cellValue=RPLocalizedString(NONE_STRING, @"");
            }
            else
            {
                cellValue=RPLocalizedString(DAILY_WIDGET_PLACEHOLDER_TEXT_OEF, DAILY_WIDGET_PLACEHOLDER_TEXT_OEF);
            }

        }
    }

    if ([tsEntryObject.entryType isEqualToString:Time_Off_Key]||
        [timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
        [timesheetStatus isEqualToString:APPROVED_STATUS ]||isEditState==NO)
    {
        [cell setUserInteractionEnabled:NO];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.disclosureImageView.hidden=YES;

        isNumericField = NO;

    }
    else
    {
        [cell setUserInteractionEnabled:YES];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }

    [cell createCellLayoutWidgetTitle:cellTitle andDescription:cellValue andTitleTextHeight:[self getHeightForString:cellTitle font:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17] forWidth:278] anddescriptionTextHeight:[self getHeightForString:cellValue font:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_13] forWidth:278] isNumericFieldType:isNumericField andSelectedRow:indexPath.row];

    if([fieldType isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI] || !isEditState)
    {

        cell.disclosureImageView.hidden=YES;
    }

    [cell setDelegate:self];


    [cell setBackgroundColor:[UIColor whiteColor]];
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [self.timeEntryTableView deselectRowAtIndexPath:indexPath animated:NO];

    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:indexPath.row];

    NSMutableArray *oefArr = tsEntryObject.timeEntryDailyFieldOEFArray;
    OEFObject *oefObject = oefArr[0];

    NSString *fieldType=[oefObject oefDefinitionTypeUri];

    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];

    if([fieldType isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI])
    {
        [self textOEFAction:oefObject];
        self.selectedOEFObject = oefObject;
        self.selectedRow = indexPath.row;
    }
    else if([fieldType isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
    {
        [self dataActionForDropdownOEF:oefObject];
        self.selectedOEFObject = oefObject;
        self.selectedRow = indexPath.row;
    }
    else if([fieldType isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
    {
        [self dataActionForNumericOEF:indexPath.row andSelectedCell:[tableView cellForRowAtIndexPath:indexPath]];
        self.selectedOEFObject = oefObject;
        self.selectedRow = indexPath.row;
    }


}



#pragma mark
#pragma mark  Other methods

- (void)calculateHeights {
    [cellHeightsArray removeAllObjects];
    for (TimesheetEntryObject *tsEntryObject in timesheetEntryObjectArray)
    {

        NSMutableDictionary *heightDict=[NSMutableDictionary dictionary];
        BOOL isTimeoffSickRow=[tsEntryObject isTimeoffSickRowPresent];

        if (!isTimeoffSickRow)
        {

            BOOL isEditState=YES;
            if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
                [timesheetStatus isEqualToString:APPROVED_STATUS ]||
                [tsEntryObject.entryType isEqualToString:Time_Off_Key]||![tsEntryObject isRowEditable])
            {
                isEditState=NO;
            }

            NSMutableArray *oefArr = tsEntryObject.timeEntryDailyFieldOEFArray;
            OEFObject *oefObject = oefArr[0];

            NSString *cellTitle=[oefObject oefName];
            NSString *fieldValue=nil;
            NSString *fieldType=nil;
            if (oefObject.oefNumericValue!=nil && ![oefObject.oefNumericValue isKindOfClass:[NSNull class]])
            {
                fieldValue=[oefObject oefNumericValue];
            }
            else if (oefObject.oefTextValue!=nil && ![oefObject.oefTextValue isKindOfClass:[NSNull class]])
            {
                fieldValue=[oefObject oefTextValue];
            }
            else if (oefObject.oefDropdownOptionValue!=nil && ![oefObject.oefDropdownOptionValue isKindOfClass:[NSNull class]])
            {
                fieldValue=[oefObject oefDropdownOptionValue];
            }

            fieldType=[oefObject oefDefinitionTypeUri];

            NSString *cellValue=nil;

            if([fieldType isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
            {
                cellValue=[NSString stringWithFormat:@"%@",fieldValue];

                if (fieldValue==nil)
                {
                    if (!isEditState)
                    {
                        cellValue=RPLocalizedString(NONE_STRING, @"");
                    }
                    else
                    {
                        cellValue=RPLocalizedString(DAILY_WIDGET_PLACEHOLDER_NUMERIC_OEF, DAILY_WIDGET_PLACEHOLDER_NUMERIC_OEF);
                    }

                }

            }
            else if ([fieldType isEqualToString:UDFType_DROPDOWN] || [fieldType isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
            {
                cellValue=[NSString stringWithFormat:@"%@",fieldValue];

                if (fieldValue==nil)
                {
                    if (!isEditState)
                    {
                        cellValue=RPLocalizedString(NONE_STRING, @"");
                    }
                    else
                    {
                        cellValue=RPLocalizedString(DAILY_WIDGET_PLACEHOLDER_DROPDOWN_OEF, DAILY_WIDGET_PLACEHOLDER_DROPDOWN_OEF);
                    }

                }


            }

            else if([fieldType isEqualToString:UDFType_TEXT] || [fieldType isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI])
            {
                cellValue=[NSString stringWithFormat:@"%@",fieldValue];

                if (fieldValue==nil)
                {
                    if (!isEditState)
                    {
                        cellValue=RPLocalizedString(NONE_STRING, @"");
                    }
                    else
                    {
                        cellValue=RPLocalizedString(DAILY_WIDGET_PLACEHOLDER_TEXT_OEF, DAILY_WIDGET_PLACEHOLDER_TEXT_OEF);
                    }

                }
            }

            [heightDict setObject:[NSString stringWithFormat:@"%f",15.0+[self getHeightForString:cellTitle font:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17] forWidth:278]+10.0+[self getHeightForString:cellValue font:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_13] forWidth:278]+15.0] forKey:CELL_HEIGHT_KEY];
            
            [cellHeightsArray addObject:heightDict];
            
            

        }



    }
}


- (void)resetTableSize:(BOOL)isResetTable {
    CGFloat inset = isResetTable ? 168.0f + Done_Toolbar_Height : 0.0f;
    self.timeEntryTableView.contentInset = UIEdgeInsetsMake(0, 0, inset, 0);
}
//JUHI
-(void)handleButtonClick:(NSIndexPath*)selectedIndex
{
    if (toolbar == nil)
    {
       
    }

    [self.toolbar setHidden:NO];
}


-(void)calculateAndUpdateTotalHoursValueForFooter
{
    float totalCalculatedHours=0;
    TimesheetMainPageController *ctr=(TimesheetMainPageController *)controllerDelegate;
    NSMutableArray *timesheetEntryObjectArr=[[ctr timesheetDataArray] objectAtIndex:ctr.pageControl.currentPage];
    for (int i=0; i<[timesheetEntryObjectArr count]; i++)
    {
        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArr objectAtIndex:i];

        float timeEntryHours=[[tsEntryObject timeEntryHoursInDecimalFormat] newFloatValue];
        totalCalculatedHours=totalCalculatedHours+timeEntryHours;
    }
    [self.timeEntryTableView setTableFooterView:nil];

    NSString *totalHoursString=[NSString stringWithFormat:@"%f",totalCalculatedHours];
    [self.totalLabelHoursLbl setText:[Util getRoundedValueFromDecimalPlaces:[totalHoursString newDoubleValue]withDecimalPlaces:2]];

    UIImage *separatorImage = [Util thumbnailImage:Cell_HairLine_Image];
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0, self.view.width,1)];
    [lineImageView setImage:separatorImage];
    [self.timeEntryTableView setTableFooterView:lineImageView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    for (UIGestureRecognizer *recognizer in self.timeEntryTableView.tableHeaderView.gestureRecognizers)
    {
        [self.timeEntryTableView.tableHeaderView removeGestureRecognizer:recognizer];
    }
    [self.timeEntryTableView.tableHeaderView addGestureRecognizer:tap];



    BOOL hoursPresent=NO;
    if ([totalHoursString newFloatValue]>0.0f)
    {
        hoursPresent=YES;
    }
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        [tsMainPageCtrl checkAndupdateCurrentButtonFilledStatus:hoursPresent andPageSelected:tsMainPageCtrl.pageControl.currentPage];
    }


}




-(void)changeParentViewLeftBarbutton
{
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        UIBarButtonItem *tempLeftButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(SAVE_STRING,@"")
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:tsMainPageCtrl action:@selector(backAndSaveAction:)];

        [tempLeftButtonOuterBtn setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:RepliconFontFamilyRegular size:17.0f]}
                                              forState:UIControlStateNormal];
        [tempLeftButtonOuterBtn setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:RepliconFontFamilyRegular size:17.0f]}
                                              forState:UIControlStateHighlighted];

        [tempLeftButtonOuterBtn setAccessibilityLabel:@"dailly_widget_save_btn"];
        [tsMainPageCtrl.navigationItem setLeftBarButtonItem:tempLeftButtonOuterBtn animated:NO];


    }


}
-(void)handleTapAndResetDayScroll
{
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        [tsMainPageCtrl resetDayScrollViewPosition];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{

    [self handleTapAndResetDayScroll];
}
-(void) didTapOnTableView:(UIGestureRecognizer*) recognizer
{
    [self handleTapAndResetDayScroll];
}




-(float)getHeightForString:(NSString *)string font:(UIFont *)font forWidth:(float)width
{

    // Let's make an NSAttributedString first
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    //Add LineBreakMode
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
    // Add Font
    [attributedString setAttributes:@{NSFontAttributeName:font} range:NSMakeRange(0, attributedString.length)];

    //Now let's make the Bounding Rect
    CGSize mainSize = [attributedString boundingRectWithSize:CGSizeMake(width, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

    if (mainSize.width==0 && mainSize.height ==0)
    {
        mainSize=CGSizeMake(0,0);
    }

    CGSize maxSize = CGSizeMake(width, MAXFLOAT);
    CGRect labelRect = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return labelRect.size.height;

    return mainSize.height;
}



-(void) deleteEntryforRow:(NSInteger)row withDelegate:(id)delegate
{
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {

        TimesheetMainPageController *ctrl=(TimesheetMainPageController *)controllerDelegate;
        NSUInteger count=[ctrl.timesheetDataArray count];
        for (int i=0; i<count; i++)
        {
            NSMutableArray *tsEntryObjectsArray=[NSMutableArray arrayWithArray:[ctrl.timesheetDataArray objectAtIndex:i]];
            [tsEntryObjectsArray removeObjectAtIndex:row];
            [ctrl.timesheetDataArray replaceObjectAtIndex:i withObject:tsEntryObjectsArray];
        }
        [ctrl setHasUserChangedAnyValue:YES];
        [self calculateAndUpdateTotalHoursValueForDeleteAction];
        [ctrl reloadViewWithRefreshedDataAfterSave];
    }
}


-(void)textOEFAction:(OEFObject *)oefObject
{

    AddDescriptionViewController *addDescriptionViewCtrl=[[AddDescriptionViewController alloc]init];
    addDescriptionViewCtrl.fromTextUdf =YES;
    
    if (oefObject.oefTextValue==nil || [oefObject.oefTextValue isKindOfClass:[NSNull class]])
    {
        [addDescriptionViewCtrl setDescTextString:@""];
    }
    else
    {
         [addDescriptionViewCtrl setDescTextString:oefObject.oefTextValue];
    }


    [addDescriptionViewCtrl setViewTitle:oefObject.oefName];
    addDescriptionViewCtrl.descControlDelegate=self;

    if (([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||([timesheetStatus isEqualToString:APPROVED_STATUS ])))
    {
        [addDescriptionViewCtrl setIsNonEditable:YES];
    }
    else
        [addDescriptionViewCtrl setIsNonEditable:NO];


    [self.navigationController pushViewController:addDescriptionViewCtrl animated:YES];


}

-(void)dataActionForDropdownOEF:(OEFObject *)oefObject
{

    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;
    }

    DropDownViewController *dropDownViewCtrl=[[DropDownViewController alloc]init];
    dropDownViewCtrl.entryDelegate=self;
    dropDownViewCtrl.dropDownUri=[oefObject oefUri];
    dropDownViewCtrl.isGen4Timesheet=YES;
    dropDownViewCtrl.selectedDropDownString=[oefObject oefDropdownOptionValue];
    dropDownViewCtrl.dropDownName=[oefObject oefName];

    [self.navigationController pushViewController:dropDownViewCtrl animated:YES];

}

-(void)dataActionForNumericOEF:(NSInteger)row andSelectedCell:(UITableViewCell *)selectedCell
{

    UITextField *numericTextfield = [selectedCell viewWithTag:row];
    if ([numericTextfield isKindOfClass:[UITextField class]])
    {
        [numericTextfield becomeFirstResponder];
    }
}


#pragma mark
#pragma mark  Update methods
-(void)updateTimeEntryHoursForIndex:(NSInteger)index withValue:(NSString *)value isDoneClicked:(BOOL)isDoneClicked
{
    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:index];
    NSString *clientName=tsEntryObject.timeEntryClientName;
    NSString *clientUri=tsEntryObject.timeEntryClientUri;
    //MOBI-746
    NSString *programName=tsEntryObject.timeEntryProgramName;
    NSString *programUri=tsEntryObject.timeEntryProgramUri;
    NSString *projectName=tsEntryObject.timeEntryProjectName;
    NSString *projectUri=tsEntryObject.timeEntryProjectUri;
    NSString *taskName=tsEntryObject.timeEntryTaskName;
    NSString *taskUri=tsEntryObject.timeEntryTaskUri;
    NSString *activityName=tsEntryObject.timeEntryActivityName;
    NSString *activityUri=tsEntryObject.timeEntryActivityUri;
    NSString *timeOffName=tsEntryObject.timeEntryTimeOffName;
    NSString *timeOffUri=tsEntryObject.timeEntryTimeOffUri;
    NSString *billingName=tsEntryObject.timeEntryBillingName;
    NSString *billingUri=tsEntryObject.timeEntryBillingUri;
    NSString *hoursInHourFormat=tsEntryObject.timeEntryHoursInHourFormat;
    //NSString *hoursInDecimalFormat=tsEntryObject.timeEntryHoursInDecimalFormat;
    NSString *comments=tsEntryObject.timeEntryComments;

    NSMutableDictionary *multiInoutEntry=tsEntryObject.multiDayInOutEntry;
    NSString *punchUri=tsEntryObject.timePunchUri;
    NSString *allocationUri=tsEntryObject.timeAllocationUri;
    NSString *entryType=tsEntryObject.entryType;
    NSDate *entryDate=tsEntryObject.timeEntryDate;
    BOOL isTimeoffSickRowPresent=tsEntryObject.isTimeoffSickRowPresent;
    NSString *timesheetUri=tsEntryObject.timesheetUri;
    NSString *rowUri=tsEntryObject.rowUri;
    BOOL isRowEditable=tsEntryObject.isRowEditable;
    BOOL isNewlyAddedAdhocRow=tsEntryObject.isNewlyAddedAdhocRow;
    NSString *rowNumber=tsEntryObject.rownumber;
    if (value!=nil && ![value isKindOfClass:[NSNull class]])
    {
        value=[Util getRoundedValueFromDecimalPlaces:[value newDoubleValue] withDecimalPlaces:2];
    }

    if (isDoneClicked)
    {
        if ([value isEqualToString:@""]||[value isKindOfClass:[NSNull class]]) {
            value=[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]];
        }
        DayTimeEntryCustomCell *cell = (DayTimeEntryCustomCell *)[self.timeEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [cell.upperRight setText:value];

    }
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        if (![value isEqualToString:[tsEntryObject timeEntryHoursInDecimalFormat]])
        {
            tsMainPageCtrl.hasUserChangedAnyValue=YES;
            [self changeParentViewLeftBarbutton];
        }

    }
    TimesheetEntryObject *tsTempEntryObject=[[TimesheetEntryObject alloc] init];
    //MOBI-746
    [tsTempEntryObject setTimeEntryProgramName:programName];
    [tsTempEntryObject setTimeEntryProgramUri:programUri];
    [tsTempEntryObject setTimeEntryClientName:clientName];
    [tsTempEntryObject setTimeEntryClientUri:clientUri];
    [tsTempEntryObject setTimeEntryProjectName:projectName];
    [tsTempEntryObject setTimeEntryProjectUri:projectUri];
    [tsTempEntryObject setTimeEntryTaskName:taskName];
    [tsTempEntryObject setTimeEntryTaskUri:taskUri];
    [tsTempEntryObject setTimeEntryActivityName:activityName];
    [tsTempEntryObject setTimeEntryActivityUri:activityUri];
    [tsTempEntryObject setTimeEntryTimeOffName:timeOffName];
    [tsTempEntryObject setTimeEntryTimeOffUri:timeOffUri];
    [tsTempEntryObject setTimeEntryBillingName:billingName];
    [tsTempEntryObject setTimeEntryBillingUri:billingUri];
    [tsTempEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"%@",value]];
    [tsTempEntryObject setTimeEntryHoursInHourFormat:hoursInHourFormat];
    [tsTempEntryObject setTimeEntryComments:comments];

    [tsTempEntryObject setMultiDayInOutEntry:multiInoutEntry];
    [tsTempEntryObject setTimePunchUri:punchUri];
    [tsTempEntryObject setTimeAllocationUri:allocationUri];
    [tsTempEntryObject setEntryType:entryType];
    [tsTempEntryObject setTimeEntryDate:entryDate];
    [tsTempEntryObject setIsTimeoffSickRowPresent:isTimeoffSickRowPresent];
    [tsTempEntryObject setTimesheetUri:timesheetUri];
    [tsTempEntryObject setRowUri:rowUri];
    [tsTempEntryObject setIsRowEditable:isRowEditable];
    [tsTempEntryObject setIsNewlyAddedAdhocRow:isNewlyAddedAdhocRow];
//    if([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
//    {
//        [tsTempEntryObject setTimeEntryCellOEFArray:tsEntryObject.timeEntryCellOEFArray];
//        [tsTempEntryObject setTimeEntryRowOEFArray:tsEntryObject.timeEntryRowOEFArray];
//    }
//    else
//    {
//        [tsTempEntryObject setTimeEntryUdfArray:tsEntryObject.timeEntryUdfArray];
//        [tsTempEntryObject setTimeEntryRowUdfArray:tsEntryObject.timeEntryRowUdfArray];
//    }
    [tsTempEntryObject setRownumber:rowNumber];
    [self.timesheetEntryObjectArray replaceObjectAtIndex:index withObject:tsTempEntryObject];
    [self calculateAndUpdateTotalHoursValueForFooter];

}
-(void)updateProjectName:(NSString *)_projectName withProjectUri:(NSString *)_projectUri withTaskName:(NSString *)_taskName
             withTaskUri:(NSString *)_taskUri withActivityName:(NSString *)_activityName withActivityUri:(NSString *)_activityUri withBillingName:(NSString *)_billingName withBillingUri:(NSString *)_billingUri
{
    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:currentIndexpath.row];
    NSString *clientName=tsEntryObject.timeEntryClientName;
    NSString *clientUri=tsEntryObject.timeEntryClientUri;
    //MOBI-746
    NSString *programName=tsEntryObject.timeEntryProgramName;
    NSString *programUri=tsEntryObject.timeEntryProgramUri;
    NSString *comments=tsEntryObject.timeEntryComments;
    NSString *timeOffName=tsEntryObject.timeEntryTimeOffName;
    NSString *timeOffUri=tsEntryObject.timeEntryTimeOffUri;
    NSString *hoursInHourFormat=tsEntryObject.timeEntryHoursInHourFormat;
    NSString *hoursInDecimalFormat=tsEntryObject.timeEntryHoursInDecimalFormat;

    NSMutableDictionary *multiInoutEntry=tsEntryObject.multiDayInOutEntry;
    NSString *punchUri=tsEntryObject.timePunchUri;
    NSString *allocationUri=tsEntryObject.timeAllocationUri;
    NSDate *entryDate=tsEntryObject.timeEntryDate;
    NSString *entryType=tsEntryObject.entryType;
    BOOL isTimeoffSickRowPresent=tsEntryObject.isTimeoffSickRowPresent;
    NSString *timesheetUri=tsEntryObject.timesheetUri;
    NSString *rowUri=tsEntryObject.rowUri;
    BOOL isRowEditable=tsEntryObject.isRowEditable;
    NSString *rowNumber=tsEntryObject.rownumber;
    TimesheetEntryObject *tsTempEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:currentIndexpath.row];
    //MOBI-746
    [tsTempEntryObject setTimeEntryProgramName:programName];
    [tsTempEntryObject setTimeEntryProgramUri:programUri];
    [tsTempEntryObject setTimeEntryClientName:clientName];
    [tsTempEntryObject setTimeEntryClientUri:clientUri];
    [tsTempEntryObject setTimeEntryProjectName:_projectName];
    [tsTempEntryObject setTimeEntryProjectUri:_projectUri];
    [tsTempEntryObject setTimeEntryTaskName:_taskName];
    [tsTempEntryObject setTimeEntryTaskUri:_taskUri];
    [tsTempEntryObject setTimeEntryBillingName:_billingName];
    [tsTempEntryObject setTimeEntryBillingUri:_billingUri];
    [tsTempEntryObject setTimeEntryActivityName:_activityName];
    [tsTempEntryObject setTimeEntryActivityUri:_activityUri];
    [tsTempEntryObject setTimeEntryTimeOffName:timeOffName];
    [tsTempEntryObject setTimeEntryTimeOffUri:timeOffUri];
    [tsTempEntryObject setTimeEntryHoursInDecimalFormat:hoursInDecimalFormat];
    [tsTempEntryObject setTimeEntryHoursInHourFormat:hoursInHourFormat];
    [tsTempEntryObject setTimeEntryComments:comments];

    [tsTempEntryObject setMultiDayInOutEntry:multiInoutEntry];
    [tsTempEntryObject setTimePunchUri:punchUri];
    [tsTempEntryObject setTimeAllocationUri:allocationUri];
    [tsTempEntryObject setEntryType:entryType];
    [tsTempEntryObject setTimeEntryDate:entryDate];
    [tsTempEntryObject setIsTimeoffSickRowPresent:isTimeoffSickRowPresent];
    [tsTempEntryObject setTimesheetUri:timesheetUri];
    [tsTempEntryObject setRowUri:rowUri];
    [tsTempEntryObject setIsRowEditable:isRowEditable];
//    if([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
//    {
//        [tsTempEntryObject setTimeEntryCellOEFArray:tsEntryObject.timeEntryCellOEFArray];
//        [tsTempEntryObject setTimeEntryRowOEFArray:tsEntryObject.timeEntryRowOEFArray];
//    }
//    else
//    {
//        [tsTempEntryObject setTimeEntryUdfArray:tsEntryObject.timeEntryUdfArray];
//        [tsTempEntryObject setTimeEntryRowUdfArray:tsEntryObject.timeEntryRowUdfArray];
//    }
    [tsTempEntryObject setRownumber:rowNumber];
    [self.timesheetEntryObjectArray replaceObjectAtIndex:currentIndexpath.row withObject:tsTempEntryObject];
    DayTimeEntryCustomCell *cell = (DayTimeEntryCustomCell *)[self.timeEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndexpath.row inSection:0]];
    [cell.upperLeft setText:_projectName];
    [cell.lowerLeft setText:_taskName];
}
-(void)updateComments:(NSString *)commentsStr andUdfArray:(NSMutableArray *)entryUdfArray forRow:(NSInteger)row
{
    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:row];
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;

        tsMainPageCtrl.hasUserChangedAnyValue=YES;
        [self changeParentViewLeftBarbutton];


        NSString *clientName=tsEntryObject.timeEntryClientName;
        NSString *clientUri=tsEntryObject.timeEntryClientUri;
        //MOBI-746
        NSString *programName=tsEntryObject.timeEntryProgramName;
        NSString *programUri=tsEntryObject.timeEntryProgramUri;
        NSString *projectName=tsEntryObject.timeEntryProjectName;
        NSString *projectUri=tsEntryObject.timeEntryProjectUri;
        NSString *taskName=tsEntryObject.timeEntryTaskName;
        NSString *taskUri=tsEntryObject.timeEntryTaskUri;
        NSString *activityName=tsEntryObject.timeEntryActivityName;
        NSString *activityUri=tsEntryObject.timeEntryActivityUri;
        NSString *timeOffName=tsEntryObject.timeEntryTimeOffName;
        NSString *timeOffUri=tsEntryObject.timeEntryTimeOffUri;
        NSString *billingName=tsEntryObject.timeEntryBillingName;
        NSString *billingUri=tsEntryObject.timeEntryBillingUri;
        NSString *hoursInHourFormat=tsEntryObject.timeEntryHoursInHourFormat;
        NSString *hoursInDecimalFormat=tsEntryObject.timeEntryHoursInDecimalFormat;
        //NSMutableArray *udfArray=tsEntryObject.timeEntryUdfArray;
        NSMutableDictionary *multiInoutEntry=tsEntryObject.multiDayInOutEntry;
        NSString *punchUri=tsEntryObject.timePunchUri;
        NSString *allocationUri=tsEntryObject.timeAllocationUri;
        NSDate *entryDate=tsEntryObject.timeEntryDate;
        NSString *entryType=tsEntryObject.entryType;
        BOOL isTimeoffSickRowPresent=tsEntryObject.isTimeoffSickRowPresent;
        NSString *timesheetUri=tsEntryObject.timesheetUri;
        NSString *rowUri=tsEntryObject.rowUri;
        BOOL isRowEditable=tsEntryObject.isRowEditable;
        NSString *rowNumber=tsEntryObject.rownumber;

        TimesheetEntryObject *tsTempEntryObject=[[TimesheetEntryObject alloc]init];
        //MOBI-746
        [tsTempEntryObject setTimeEntryProgramName:programName];
        [tsTempEntryObject setTimeEntryProgramUri:programUri];
        [tsTempEntryObject setTimeEntryClientName:clientName];
        [tsTempEntryObject setTimeEntryClientUri:clientUri];
        [tsTempEntryObject setTimeEntryProjectName:projectName];
        [tsTempEntryObject setTimeEntryProjectUri:projectUri];
        [tsTempEntryObject setTimeEntryTaskName:taskName];
        [tsTempEntryObject setTimeEntryTaskUri:taskUri];
        [tsTempEntryObject setTimeEntryActivityName:activityName];
        [tsTempEntryObject setTimeEntryActivityUri:activityUri];
        [tsTempEntryObject setTimeEntryTimeOffName:timeOffName];
        [tsTempEntryObject setTimeEntryTimeOffUri:timeOffUri];
        [tsTempEntryObject setTimeEntryBillingName:billingName];
        [tsTempEntryObject setTimeEntryBillingUri:billingUri];
        [tsTempEntryObject setTimeEntryHoursInDecimalFormat:hoursInDecimalFormat];
        [tsTempEntryObject setTimeEntryHoursInHourFormat:hoursInHourFormat];
        [tsTempEntryObject setTimeEntryComments:[NSString stringWithFormat:@"%@",commentsStr]];

        [tsTempEntryObject setMultiDayInOutEntry:multiInoutEntry];
        [tsTempEntryObject setTimePunchUri:punchUri];
        [tsTempEntryObject setTimeAllocationUri:allocationUri];
        [tsTempEntryObject setEntryType:entryType];
        [tsTempEntryObject setTimeEntryDate:entryDate];
        [tsTempEntryObject setIsTimeoffSickRowPresent:isTimeoffSickRowPresent];
        [tsTempEntryObject setTimesheetUri:timesheetUri];
        [tsTempEntryObject setRowUri:rowUri];
        [tsTempEntryObject setIsRowEditable:isRowEditable];
//        if([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
//        {
//            [tsTempEntryObject setTimeEntryCellOEFArray:entryUdfArray];
//            [tsTempEntryObject setTimeEntryRowOEFArray:tsEntryObject.timeEntryRowOEFArray];
//        }
//        else
//        {
//            [tsTempEntryObject setTimeEntryUdfArray:entryUdfArray];
//            [tsTempEntryObject setTimeEntryRowUdfArray:tsEntryObject.timeEntryRowUdfArray];
//        }

        [tsTempEntryObject setRownumber:rowNumber];
        if ([entryType isEqualToString:Adhoc_Time_OffKey])
        {
            [self.timesheetEntryObjectArray replaceObjectAtIndex:row withObject:tsTempEntryObject];
            if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
            {
                [controllerDelegate updateAdhocTimeoffUdfValuesAcrossEntireTimesheet:currentIndexpath.row withUdfArray:entryUdfArray];
            }

        }
        else
        {
            [self.timesheetEntryObjectArray replaceObjectAtIndex:row withObject:tsTempEntryObject];
        }

        [cellHeightsArray removeAllObjects];
        [self.timeEntryTableView reloadData];

    }



}

-(void)calculateAndUpdateTotalHoursValueForDeleteAction
{

    TimesheetMainPageController *ctr=(TimesheetMainPageController *)controllerDelegate;

    for (int k=0; k<ctr.pageControl.numberOfPages; k++)
    {
        float totalCalculatedHours=0;
        NSMutableArray *timesheetEntryObjectArr=[[ctr timesheetDataArray] objectAtIndex:k];
        for (int i=0; i<[timesheetEntryObjectArr count]; i++)
        {
            TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArr objectAtIndex:i];
            
            float timeEntryHours=[[tsEntryObject timeEntryHoursInDecimalFormat] newFloatValue];
            totalCalculatedHours=totalCalculatedHours+timeEntryHours;
        }
        NSString *totalHoursString=[NSString stringWithFormat:@"%f",totalCalculatedHours];
        BOOL hoursPresent=NO;
        if ([totalHoursString newFloatValue]>0.0f)
        {
            hoursPresent=YES;
        }
        if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
        {
            TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
            [tsMainPageCtrl checkAndupdateCurrentButtonFilledStatus:hoursPresent andPageSelected:(NSInteger) k];
        }
        
    }
    
    
    
}

-(void)updateTextUdf:(NSString*)oefTextValue
{

    if (oefTextValue!=nil && ![oefTextValue isKindOfClass:[NSNull class]])
    {
        if (![oefTextValue isEqualToString:@""])
        {
            self.selectedOEFObject.oefTextValue = oefTextValue;

        }
        else
        {
            self.selectedOEFObject.oefTextValue = nil;
        }

    }

    else
    {

        self.selectedOEFObject.oefTextValue = nil;
    }

    [self.timeEntryTableView beginUpdates];
    [self.timeEntryTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.selectedRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.timeEntryTableView endUpdates];

    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        tsMainPageCtrl.hasUserChangedAnyValue=YES;
        [self changeParentViewLeftBarbutton];

    }


}

-(void)updateOEFNumber:(UITextField *)oefNumericTextField
{
    NSString *oefTextValue = oefNumericTextField.text;
    if (oefTextValue!=nil && ![oefTextValue isKindOfClass:[NSNull class]])
    {
        if (![oefTextValue isEqualToString:@""])
        {
            self.selectedOEFObject.oefNumericValue = oefTextValue;

        }
        else
        {
            self.selectedOEFObject.oefNumericValue = nil;
        }

    }

    else
    {

        self.selectedOEFObject.oefNumericValue = nil;
    }

    [self.timeEntryTableView beginUpdates];
    [self.timeEntryTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.selectedRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.timeEntryTableView endUpdates];

    [self resetTableSize:NO];


    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        tsMainPageCtrl.hasUserChangedAnyValue=YES;
        [self changeParentViewLeftBarbutton];

    }
}


-(void)updateSelectedOEFObject:(int)row
{
    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:row];

    NSMutableArray *oefArr = tsEntryObject.timeEntryDailyFieldOEFArray;
    OEFObject *oefObject = oefArr[0];

    self.selectedOEFObject = oefObject;
    self.selectedRow = row;

    [self resetTableSize:YES];

}

-(void)updateDropDownFieldWithFieldName:(NSString*)fieldName andFieldURI:(NSString*)fieldUri
{
    if (fieldName!=nil && ![fieldName isKindOfClass:[NSNull class]])
    {
        if (![fieldName isEqualToString:@""])
        {
            self.selectedOEFObject.oefDropdownOptionValue = fieldName;

        }
        else
        {
            self.selectedOEFObject.oefDropdownOptionValue = nil;
        }

    }

    else
    {

        self.selectedOEFObject.oefDropdownOptionValue = nil;
    }

    if (fieldUri!=nil && ![fieldUri isKindOfClass:[NSNull class]])
    {
        if (![fieldUri isEqualToString:@""])
        {
            self.selectedOEFObject.oefDropdownOptionUri = fieldUri;

        }
        else
        {
            self.selectedOEFObject.oefDropdownOptionUri = nil;
            self.selectedOEFObject.oefDropdownOptionValue = nil;
        }

    }

    else
    {

        self.selectedOEFObject.oefDropdownOptionUri = nil;
        self.selectedOEFObject.oefDropdownOptionValue = nil;
    }


    [self.timeEntryTableView beginUpdates];
    [self.timeEntryTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.selectedRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.timeEntryTableView endUpdates];

    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        tsMainPageCtrl.hasUserChangedAnyValue=YES;
        [self changeParentViewLeftBarbutton];
        
    }
}


#pragma mark
#pragma mark  Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

-(void)dealloc
{
    self.timeEntryTableView.delegate = nil;
    self.timeEntryTableView.dataSource = nil;
}
@end

