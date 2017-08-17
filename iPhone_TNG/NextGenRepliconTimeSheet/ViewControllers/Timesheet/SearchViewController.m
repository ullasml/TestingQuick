//
//  SearchViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 10/01/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "SearchViewController.h"
#import "Util.h"
#import "Constants.h"
#import "CustomSelectedView.h"
#import "CurrentTimesheetViewController.h"
#import "TimeEntryViewController.h"
#import "SVPullToRefresh.h"
#import "AppDelegate.h"
#import "TimesheetModel.h"
#import "BillingObject.h"
#import "ActivityObject.h"
#import "PunchEntryViewController.h"
#import "LoginModel.h"
#import "CameraCaptureViewController.h"
#import "AttendanceViewController.h"
#import "UIView+Additions.h"

#define SKIP_BUTTON_TAG 444
#define CONTINUE_BUTTON_TAG 555

@implementation SearchViewController

@synthesize searchTextField;
@synthesize mainTableView;
@synthesize listOfItems;
@synthesize delegate;
@synthesize selectedTimesheetUri;
@synthesize selectedItem;
@synthesize selectedProject;
@synthesize entryDelegate;
@synthesize arrayOfCharacters;
@synthesize objectsForCharacters;
@synthesize selectedProjectUri;
@synthesize searchTimer;
@synthesize selectedTaskUri;
@synthesize screenMode;
@synthesize searchProjectString;
@synthesize isPreFilledSearchString;
@synthesize selectedProjectCode;
@synthesize selectedActivityName;
@synthesize isTextFieldFirstResponder;
@synthesize isFromLockedInOut;
@synthesize isFromAttendance;
@synthesize userId;
@synthesize isOnlyActivity;
@synthesize selectedActivityUri;
@synthesize punchMapViewController;
@synthesize isStartNewTask;

#define searchBar_Height 44
#define tabBar_Height 49
#define navBar_Height 40
#define customView_Height 26
#define Yoffset 35
#define BOTTOM_SEPARATOR_HEIGHT 2.0
#define SEARCH_POLL 0.2
#define tableSpaceHeightBilling 55
#define tableSpaceHeightActivity 0
#define ACCEPTABLE_CHARACTERS @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:TRUE];
     self.searchTextField.text=self.searchProjectString;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
        {
            [Util showOfflineAlert];
            return;
        }
        
        if (self.isPreFilledSearchString)
        {
            if (searchProjectString!=nil && ![searchProjectString isKindOfClass:[NSNull class]] && ![searchProjectString isEqualToString:@"null"] &&
                ![searchProjectString isEqualToString:RPLocalizedString(SELECT_STRING, @"") ] && ![searchProjectString isEqualToString:RPLocalizedString(NONE_STRING, @"")])
            {
                
                
            }
            else
            {
                self.searchProjectString=@"";
            }
        }
        self.isTextFieldFirstResponder=NO;
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"SearchString"];
        [defaults synchronize];
        [defaults setObject:searchProjectString forKey:@"SearchString"];
        [defaults synchronize];
        
        
        
        if (screenMode==BILLING_SCREEN)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:BILLING_RECEIVED_NOTIFICATION object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterDataRecieved:)
                                                         name:BILLING_RECEIVED_NOTIFICATION
                                                       object:nil];
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
            if (isFromAttendance)
            {
                [[RepliconServiceManager attendanceService]fetchBillingRateBasedOnProjectWithSearchText:self.searchProjectString withProjectUri:self.selectedProjectUri taskUri:self.selectedTaskUri andDelegate:self];
            }
            else
            {
                [[RepliconServiceManager timesheetService]fetchBillingRateBasedOnProjectForTimesheetUri:self.selectedTimesheetUri withSearchText:self.searchProjectString withProjectUri:self.selectedProjectUri taskUri:self.selectedTaskUri andDelegate:self];
            }
            
            
            
            
        }
        if (screenMode==ACTIVITY_SCREEN)
        {
            
            if (isFromAttendance)
            {
                [[RepliconServiceManager attendanceService]fetchActivityWithSearchText:self.searchProjectString andDelegate:self];
            }
            else if ([delegate isKindOfClass:[PunchEntryViewController class]]){
                [[RepliconServiceManager teamTimeService]fetchActivityWithSearchText:self.searchProjectString forUser:userId andDelegate:self];
            }
            else
            {
                [[RepliconServiceManager timesheetService]fetchActivityBasedOnTimesheetUri:self.selectedTimesheetUri withSearchText:self.searchProjectString andDelegate:self];
            }
            

            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:ACTIVITY_RECEIVED_NOTIFICATION object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterDataRecieved:)
                                                         name:ACTIVITY_RECEIVED_NOTIFICATION
                                                       object:nil];
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
         
        }
                
        if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
        {
            [Util setToolbarLabel:delegate withText:selectedItem];
            
        }
        else
        {
            [Util setToolbarLabel:self withText:selectedItem];
        }
        
        
        
        UIBarButtonItem *tempLeftButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(CANCEL_STRING, @"")
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self action:@selector(cancelAction:)];
        
        if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
        {
            [delegate navigationItem].rightBarButtonItem=nil;
            [[delegate navigationItem ] setLeftBarButtonItem:tempLeftButtonOuterBtn animated:NO];
            
        }
        else
        {
            [self navigationItem].rightBarButtonItem=nil;
            BOOL isActivitySelectionRequired = NO;
            if ([delegate isKindOfClass:[PunchEntryViewController class]])
            {
                TeamTimeModel *teamTimeModel=[[TeamTimeModel alloc]init];
                NSMutableDictionary *userCapabilitiesDict=[teamTimeModel getUserCapabilitiesForUserUri:userId];
                isActivitySelectionRequired =[[userCapabilitiesDict objectForKey:@"activitySelectionRequired"] boolValue];
            }
            else
            {
                LoginModel *loginModel=[[LoginModel alloc]init];
                NSMutableArray *userDetailsArray=[loginModel getAllUserDetailsInfoFromDb];
                
                
                if ([userDetailsArray count]!=0)
                {
                    NSDictionary *userDict=[userDetailsArray objectAtIndex:0];
                    isActivitySelectionRequired =[[userDict objectForKey:@"timepunchActivitySelectionRequired"] boolValue];
                }
            }
            
            if (([delegate isKindOfClass:[AttendanceViewController class]]||[delegate isKindOfClass:[PunchEntryViewController class]]) && isOnlyActivity &&!isActivitySelectionRequired)
            {
                UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(SKIP_STRING, @"")
                                                                                          style:UIBarButtonItemStylePlain
                                                                                         target:self action:@selector(skipOrContinueAction:)];
                [tempRightButtonOuterBtn setTag:SKIP_BUTTON_TAG];
                [self navigationItem].rightBarButtonItem=tempRightButtonOuterBtn;
            }
            [[self navigationItem ] setLeftBarButtonItem:tempLeftButtonOuterBtn animated:NO];
        }
        
        [self intialiseView];

    
}
- (void)refreshViewAfterDataRecieved:(NSNotification *)notificationObject
{
    if (screenMode==BILLING_SCREEN)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:BILLING_RECEIVED_NOTIFICATION object:nil];
    }
    if (screenMode==ACTIVITY_SCREEN)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ACTIVITY_RECEIVED_NOTIFICATION object:nil];
    }
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    [self.mainTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self setupListData];
    [self checkToShowMoreButton];
    
     [self.mainTableView setBottomContentInsetValue:0.0];
}

-(void)intialiseView
{
    [self.view setBackgroundColor:RepliconStandardBackgroundColor];
    float yOffset=0;
    if (screenMode==ACTIVITY_SCREEN)
    {
        yOffset=0;
    }
    else
    {
        yOffset=customView_Height;
    }
    UITextField *tempsearchBar=[[UITextField alloc]initWithFrame:CGRectMake(0, yOffset, self.view.frame.size.width, searchBar_Height)];
    self.searchTextField=tempsearchBar;
    self.searchTextField.clearButtonMode=YES;
    [self.searchTextField setBackgroundColor:[UIColor whiteColor]];
   
    [self.view addSubview:self.searchTextField];
    
	float xPadding=10.0;
    float paddingFromSearchIconToPlaceholder=10.0;
    UIImage *searchIconImage=[Util thumbnailImage:SEARCH_ICON_IMAGE];
    UIImageView *searchIconImageView=[[UIImageView alloc]initWithFrame:CGRectMake(xPadding, yOffset+14, searchIconImage.size.width, searchIconImage.size.height)];
    [searchIconImageView setImage:searchIconImage];
    [searchIconImageView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:searchIconImageView];
   
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, xPadding+searchIconImage.size.width+paddingFromSearchIconToPlaceholder, 20)];
    searchTextField.leftView = paddingView;
    searchTextField.leftViewMode = UITextFieldViewModeAlways;
    searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    searchTextField.contentHorizontalAlignment = UIControlContentVerticalAlignmentCenter;
    [searchTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[searchTextField setDelegate:self];
    [searchTextField setReturnKeyType:UIReturnKeyDone];
    [searchTextField setEnablesReturnKeyAutomatically:NO];
    [searchTextField setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16]];
    
    if (screenMode==BILLING_SCREEN){
        searchTextField.placeholder=RPLocalizedString(SEARCHBAR_BILLING_PLACEHOLDER,@"");
        [self addCustomViewWithTag:0];
    }
    if (screenMode==ACTIVITY_SCREEN)
    {
        searchTextField.placeholder=RPLocalizedString(SEARCHBAR_ACTIVITY_PLACEHOLDER,@"");
    }
    
    UITableView *tempmainTableView=[[UITableView alloc]initWithFrame:CGRectMake(0,tempsearchBar.bottom, self.view.frame.size.width ,self.view.frame.size.height-tempsearchBar.bottom) style:UITableViewStylePlain];
    
    self.mainTableView=tempmainTableView;
    self.mainTableView.separatorColor=[Util colorWithHex:@"#cccccc" alpha:1];
    self.mainTableView.delegate=self;
    self.mainTableView.dataSource=self;
    mainTableView.separatorInset = UIEdgeInsetsZero;

    if ([mainTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        mainTableView.layoutMargins = UIEdgeInsetsZero;
    }

    [self.view addSubview:mainTableView];
    [self configureTableForPullToRefresh];
    
    [self.mainTableView setBottomContentInsetValue:0.0];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect rect = self.mainTableView.frame;
    rect.size.height = self.view.height-self.searchTextField.bottom;
    self.mainTableView.frame = rect;
}

-(void)configureTableForPullToRefresh
{
    SearchViewController *weakSelf = self;
    
    
    //setup pull to refresh widget
    [self.mainTableView addPullToRefreshWithActionHandler:^{
            int64_t delayInSeconds = 0.0;
            [weakSelf.mainTableView.pullToRefreshView startAnimating];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
               {
                   [weakSelf refreshAction];
               });
    }];
    // setup infinite scrolling
    [self.mainTableView addInfiniteScrollingWithActionHandler:^{
        if ([weakSelf.arrayOfCharacters count]>0) {
            [weakSelf.mainTableView setBottomContentInsetValue: 60.0];
            NSUInteger sectionCount=[weakSelf.arrayOfCharacters count];
            NSUInteger rowCount=[(NSMutableArray *)[weakSelf.objectsForCharacters objectForKey:[weakSelf.arrayOfCharacters objectAtIndex:sectionCount-1]] count];
            NSIndexPath* ipath = [NSIndexPath indexPathForRow: rowCount-1 inSection: sectionCount-1];
            [weakSelf.mainTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionBottom animated: YES];
            
            int64_t delayInSeconds = 0.0;
            [weakSelf.mainTableView.infiniteScrollingView startAnimating];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
               {
                   [weakSelf moreAction];
               });
        }
        else
            [weakSelf.mainTableView.infiniteScrollingView stopAnimating];
    }];
    
}
-(void)refreshAction
{
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [self.view setUserInteractionEnabled:YES];
        SearchViewController *weakSelf = self;
        [weakSelf.mainTableView.pullToRefreshView stopAnimating];
        [Util showOfflineAlert];
        return;
    }
    if (screenMode==BILLING_SCREEN)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:BILLING_RECEIVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterPullToRefreshAction:) name:BILLING_RECEIVED_NOTIFICATION object:nil];
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        if (isFromAttendance)
        {
            [[RepliconServiceManager attendanceService]fetchBillingRateBasedOnProjectWithSearchText:searchTextField.text withProjectUri:self.selectedProjectUri taskUri:self.selectedTaskUri andDelegate:self];
        }
        else
        {
           [[RepliconServiceManager timesheetService]fetchBillingRateBasedOnProjectForTimesheetUri:self.selectedTimesheetUri withSearchText:searchTextField.text withProjectUri:self.selectedProjectUri taskUri:self.selectedTaskUri andDelegate:self];
        }
        
    }
    if (screenMode==ACTIVITY_SCREEN)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ACTIVITY_RECEIVED_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterPullToRefreshAction:)
                                                     name:ACTIVITY_RECEIVED_NOTIFICATION
                                                   object:nil];
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        if (isFromAttendance)
        {
            [[RepliconServiceManager attendanceService]fetchActivityWithSearchText:searchTextField.text andDelegate:self];
        }
        else if ([delegate isKindOfClass:[PunchEntryViewController class]]){
            [[RepliconServiceManager teamTimeService]fetchActivityWithSearchText:searchTextField.text forUser:userId andDelegate:self];
        }
        else
        {
            [[RepliconServiceManager timesheetService]fetchActivityBasedOnTimesheetUri:self.selectedTimesheetUri withSearchText:searchTextField.text andDelegate:self];
        }
        
    }
}
-(void)refreshViewAfterPullToRefreshAction:(NSNotification *)notificationObject
{
    [self.view setUserInteractionEnabled:YES];
    if (screenMode==BILLING_SCREEN)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:BILLING_RECEIVED_NOTIFICATION object:nil];
        
    }
    if (screenMode==ACTIVITY_SCREEN)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ACTIVITY_RECEIVED_NOTIFICATION object:nil];
    }
    SearchViewController *weakSelf = self;
    [weakSelf.mainTableView.pullToRefreshView stopAnimating];
    self.mainTableView.showsInfiniteScrolling=TRUE;
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    NSDictionary *theData = [notificationObject userInfo];
    NSNumber *n = [theData objectForKey:@"isErrorOccured"];
    BOOL isErrorOccured = [n boolValue];
    if (isErrorOccured)
    {
        
    }
    else
    {
        [self setupListData];
        [self checkToShowMoreButton];
        
    }
    
     [self.mainTableView setBottomContentInsetValue:0.0];
    
}
-(void)moreAction
{
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        [self performSelector:@selector(refreshTableViewOnConnectionError) withObject:nil afterDelay:0.2];
    }
    if (screenMode==ACTIVITY_SCREEN)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ACTIVITY_RECEIVED_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterMoreAction:)
                                                     name:ACTIVITY_RECEIVED_NOTIFICATION
                                                   object:nil];
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        if (isFromAttendance)
        {
            [[RepliconServiceManager attendanceService]fetchNextActivityWithSearchText:searchTextField.text andDelegate:self];
        }
        else if([delegate isKindOfClass:[PunchEntryViewController class]])
        {
            [[RepliconServiceManager teamTimeService]fetchNextActivityWithSearchText:searchTextField.text forUser:self.userId andDelegate:self];
        }
            
        else
        {
            [[RepliconServiceManager timesheetService]fetchNextActivityBasedOnTimesheetUri:self.selectedTimesheetUri withSearchText:searchTextField.text andDelegate:self];
        }
        
    }
    
    if (screenMode==BILLING_SCREEN)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:BILLING_RECEIVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterMoreAction:) name:BILLING_RECEIVED_NOTIFICATION object:nil];
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        
        if (isFromAttendance)
        {
            [[RepliconServiceManager attendanceService]fetchNextBillingRateBasedOnProjectWithSearchText:searchTextField.text withProjectUri:self.selectedProjectUri taskUri:self.selectedTaskUri andDelegate:self];
        }

        else
        {
            [[RepliconServiceManager timesheetService]fetchNextBillingRateBasedOnProjectForTimesheetUri:self.selectedTimesheetUri withSearchText:searchTextField.text withProjectUri:self.selectedProjectUri taskUri:self.selectedTaskUri andDelegate:self];
        }
        
    }
    
}
-(void)refreshTableViewOnConnectionError
{
    SearchViewController *weakSelf = self;
    [weakSelf.mainTableView.infiniteScrollingView stopAnimating];
    
    self.mainTableView.showsInfiniteScrolling=FALSE;
    self.mainTableView.showsInfiniteScrolling=TRUE;
    
}
-(void)refreshViewAfterMoreAction:(NSNotification *)notificationObject
{
    if (screenMode==BILLING_SCREEN)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:BILLING_RECEIVED_NOTIFICATION object:nil];
        
    }
    if (screenMode==ACTIVITY_SCREEN)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ACTIVITY_RECEIVED_NOTIFICATION object:nil];
        
    }
    [self.view setUserInteractionEnabled:YES];
    SearchViewController *weakSelf = self;
    [weakSelf.mainTableView.infiniteScrollingView stopAnimating];
    
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    
    NSDictionary *theData = [notificationObject userInfo];
    NSNumber *n = [theData objectForKey:@"isErrorOccured"];
    
    
    BOOL isErrorOccured = [n boolValue];
    
    if (isErrorOccured)
    {
        self.mainTableView.showsInfiniteScrolling=FALSE;
    }
    else
    {
        
        [self setupListData];
        [self checkToShowMoreButton];
    }
    
     [self.mainTableView setBottomContentInsetValue:0.0];
}
-(void)checkToShowMoreButton
{
    NSNumber *count=nil ;
    NSNumber *fetchCount=nil;
    
    if (screenMode==BILLING_SCREEN)
    {
        count =	[[NSUserDefaults standardUserDefaults]objectForKey:@"billingDownloadCount"];
        fetchCount  =    [[AppProperties getInstance] getAppPropertyFor:@"billingRateDownloadCount"];
    }
    if (screenMode==ACTIVITY_SCREEN)
    {
        count =	[[NSUserDefaults standardUserDefaults]objectForKey:@"activityDataDownloadCount"];
        fetchCount  =    [[AppProperties getInstance] getAppPropertyFor:@"activityDownlaodCount"];
    }
    if (([count intValue]<[fetchCount intValue]))
    {
		self.mainTableView.showsInfiniteScrolling=FALSE;
	}
    else
    {
        self.mainTableView.showsInfiniteScrolling=TRUE;
    }
    
    if ([self.listOfItems count]==0)
    {
        self.mainTableView.showsPullToRefresh=TRUE;
        self.mainTableView.showsInfiniteScrolling=FALSE;
    }
    else
    {
        self.mainTableView.showsPullToRefresh=TRUE;
    }
    
}
-(void)addCustomViewWithTag:(int)tag
{
    
    CustomSelectedView *customView=[[CustomSelectedView alloc]initWithFrame:CGRectMake(0, searchBar_Height-1+(customView_Height*tag), self.view.frame.size.width, customView_Height+BOTTOM_SEPARATOR_HEIGHT) andTag:tag];
    customView.deleteBtn.hidden=TRUE;
    customView.fieldName.text=[NSString stringWithFormat:@"%@ : %@ ",RPLocalizedString(Project, @""),selectedProject];
    customView.delegate=self;
    
    [self.view addSubview:customView];
    
    //    CGRect frame=self.mainTableView.frame;
    //    frame.origin.y=self.mainTableView.frame.origin.y+customView_Height*tag;
    //    frame.size.height=frame.size.height-tabBar_Height-navBar_Height;
    //    self.mainTableView.frame=frame;
    
    
    
}
- (void)removeCustomView:(id)sender
{
}
- (void)setupListData
{
    [listOfItems removeAllObjects];
    [arrayOfCharacters removeAllObjects];
    [objectsForCharacters removeAllObjects];
    
    
    listOfItems=[[NSMutableArray alloc]init];
    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    NSString *key=nil;
    if (screenMode==BILLING_SCREEN)
    {
        self.listOfItems=[timesheetModel getAllBillingDetailsFromDBForModule:@"Timesheet"];
        key=@"billingName";
    }
    if (screenMode==ACTIVITY_SCREEN)
    {
        self.listOfItems=[timesheetModel getAllActivityDetailsFromDBForModule:@"Timesheet"];
        key=@"activityName";
    }
    
    if ([self.listOfItems count]>0)
    {
        isResult=TRUE;
        if (!isTextFieldFirstResponder)
        {
            NSSortDescriptor * brandDescriptor =[[NSSortDescriptor alloc] initWithKey:key ascending:YES comparator:^(id firstDocumentName, id secondDocumentName) {
                
                
                
                static NSStringCompareOptions comparisonOptions =
                
                NSCaseInsensitiveSearch | NSNumericSearch |
                
                NSWidthInsensitiveSearch | NSForcedOrderingSearch;
                
                
                
                return [firstDocumentName compare:secondDocumentName options:comparisonOptions];
                
            }];
            NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:brandDescriptor];
            
            NSArray *array = [listOfItems sortedArrayUsingDescriptors:sortDescriptors];
            self.listOfItems=[NSMutableArray arrayWithArray:array];
        }
        
       
    }
    else if([self.listOfItems count]==0 && !isResult)
    {
        NSString *message=nil;
        if (screenMode==BILLING_SCREEN)
        {
            message=[NSString stringWithFormat:@"%@ %@",RPLocalizedString(NO_BILLING_AVAILABLE, @""),selectedProject];
        }
        if (screenMode==ACTIVITY_SCREEN)
        {
            message=[NSString stringWithFormat:@"%@",RPLocalizedString(NO_ACTIVITY_AVAILABLE, @"")];
            
        }

        [UIAlertView showAlertViewWithCancelButtonTitle:nil
                                       otherButtonTitle:RPLocalizedString(@"OK", @"OK")
                                               delegate:self
                                                message:message
                                                  title:nil
                                                    tag:LONG_MIN];

        
    }
     [self setupIndexDataBasedOnSectionAlphabets];
   
}
- (void)setupIndexDataBasedOnSectionAlphabets
{
   
    arrayOfCharacters    = [[NSMutableArray alloc] init];
    
    
    objectsForCharacters = [[NSMutableDictionary alloc] init];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSMutableArray *arrayOfNames = [[NSMutableArray alloc] init];
    NSString *numbericSection    = @"#";
    NSString *firstLetter;
    NSString *name;
    
    for (NSDictionary *item in self.listOfItems) {
        NSDictionary *listOfitemDict=item;
        NSArray *allKeys=[listOfitemDict allKeys];
        BillingObject *billingObject=[[BillingObject alloc]init];
        ActivityObject *activityObject=[[ActivityObject alloc]init];
        for (NSString *tmpKey in allKeys)
        {
            if (screenMode==BILLING_SCREEN)
            {
                if ([tmpKey isEqualToString:@"billingName"])
                {
                    billingObject.billingName=[listOfitemDict objectForKey:tmpKey];
                }
                else if ([tmpKey isEqualToString:@"billingUri"])
                {
                    billingObject.billingUri=[listOfitemDict objectForKey:tmpKey];
                }
            }
            if (screenMode==ACTIVITY_SCREEN)
            {
                //Implementation for US8849//JUHI
                if ([tmpKey isEqualToString:@"activityName"])
                {
                    activityObject.activityName=[listOfitemDict objectForKey:tmpKey];
                }
                else if ([tmpKey isEqualToString:@"activityUri"])
                {
                    activityObject.activityUri=[listOfitemDict objectForKey:tmpKey];
                }
            }
        }
        NSString *key=nil;
        if (screenMode==BILLING_SCREEN)
            key=@"billingName";
        if (screenMode==ACTIVITY_SCREEN)
        {
            key=@"activityName";
            
        }
        name=[[listOfitemDict objectForKey:key] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        firstLetter = [[name substringToIndex:1] uppercaseString];
        
        NSData *data = [firstLetter dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *newStrfirstLetter = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        
        // Check if it's NOT a number
        NSString *accepatable=[NSString stringWithFormat:@"%@",ACCEPTABLE_CHARACTERS];
        
        
        if ([formatter numberFromString:newStrfirstLetter] == nil && [accepatable rangeOfString:newStrfirstLetter].location != NSNotFound ) {
            
            /**
             * If the letter doesn't exist in the dictionary go ahead and add it the
             * dictionary.
             *
             * ::IMPORTANT::
             * You HAVE to removeAllObjects from the arrayOfNames or you will have an N + 1
             * problem.  Let's say that start with the A's, well once you hit the
             * B's then in your table you will the A's and B's for the B's section.  Once
             * you hit the C's you will all the A's, B's, and C's, etc.
             */
            if (![self.objectsForCharacters objectForKey:newStrfirstLetter]) {
                
                [arrayOfNames removeAllObjects];
                
                [arrayOfCharacters addObject:newStrfirstLetter];
            }
            if (screenMode==BILLING_SCREEN)
            {
                [arrayOfNames addObject:billingObject];
            }
            if (screenMode==ACTIVITY_SCREEN)
            {
                [arrayOfNames addObject:activityObject];
            }
            
            /**
             * Need to autorelease the copy to preven potential leak.  Even though the
             * arrayOfNames is released below it still has a retain count of +1
             */
            [self.objectsForCharacters setObject:[arrayOfNames copy] forKey:newStrfirstLetter];
            
        }
        else {
            
            if (![self.objectsForCharacters objectForKey:numbericSection]) {
                
                [arrayOfNames removeAllObjects];
                
                [arrayOfCharacters addObject:numbericSection];
            }
            
            if (screenMode==BILLING_SCREEN)
            {
                [arrayOfNames addObject:billingObject];
            }
            if (screenMode==ACTIVITY_SCREEN)
            {
                [arrayOfNames addObject:activityObject];
            }
            
            
            [self.objectsForCharacters setObject:[arrayOfNames copy] forKey:numbericSection];
        }
        
       
    }
    
    
    [self.mainTableView reloadData];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{//MOBI-849
    if (alertView.tag==001)
    {
        // DO NOTHING
    }
    else if (buttonIndex==0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)cancelAction:(id)sender
{

    [self.navigationController popViewControllerAnimated:YES];
    if([delegate isKindOfClass:[AttendanceViewController class]])
    {
        [delegate showLastPunchDataView];
    }
}
-(void)skipOrContinueAction:(id)sender
{
    if ([delegate isKindOfClass:[PunchEntryViewController class]])
    {
        if (entryDelegate != nil && ![entryDelegate isKindOfClass:[NSNull class]] &&
            [entryDelegate conformsToProtocol:@protocol(UpdateEntryFieldProtocol)])
        {
            [entryDelegate updateFieldWithFieldName:self.selectedActivityName andFieldURI:self.selectedActivityUri];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        LoginModel *loginModel=[[LoginModel alloc]init];
        BOOL isUsingAuditImages=[loginModel getStatusForGivenPermissions:@"timepunchAuditImageRequired"];
        
        NSString *activityName=@"";
        NSString *activityUri=@"";
        if ([sender tag]==SKIP_BUTTON_TAG)
        {
            CLS_LOG(@"-----skip Action on search view controller -----");
        }
        else
        {
            CLS_LOG(@"----- Continue Action after selecting a Entry----");
            activityName=self.selectedActivityName;
            activityUri=self.selectedActivityUri;
            if (activityUri==nil || [activityUri isEqualToString:@"null"]||[activityUri isKindOfClass:[NSNull class]]||[activityUri isEqualToString:NULL_STRING])
            {
                activityUri=@"";
                activityName=@"";
            }
            
        }
        NSMutableDictionary *dict=[NSMutableDictionary dictionary];
        [dict setObject:@"" forKey:@"clientName"];
        [dict setObject:@"" forKey:@"clientUri"];
        [dict setObject:@"" forKey:@"projectName"];
        [dict setObject:@"" forKey:@"projectUri"];
        [dict setObject:@"" forKey:@"taskName"];
        [dict setObject:@"" forKey:@"taskUri"];
        [dict setObject:@"" forKey:@"billingName"];
        [dict setObject:@"" forKey:@"billingUri"];
        [dict setObject:activityName forKey:@"activityName"];
        [dict setObject:activityUri forKey:@"activityUri"];
        [dict setObject:@"" forKey:@"breakName"];
        [dict setObject:@"" forKey:@"breakUri"];
        //Fix for MOBI-849//JUHI
        
        BOOL isCameraPermission=TRUE;
        
        DeviceType deviceType = [self getDeviceType];
        if (deviceType == OnDevice)
        {
            NSArray *devices = [AVCaptureDevice devices];
            AVCaptureDevice *frontCamera;
            AVCaptureDevice *backCamera;
            
            for (AVCaptureDevice *device in devices) {
                
//                NSLog(@"Device name: %@", [device localizedName]);
                
                if ([device hasMediaType:AVMediaTypeVideo]) {
                    
                    if ([device position] == AVCaptureDevicePositionBack) {
                        NSLog(@"Device position : back");
                        backCamera = device;
                    }
                    else {
                        NSLog(@"Device position : front");
                        frontCamera = device;
                    }
                }
            }
            NSError *error = nil;
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
            if (!input)
            {
                isCameraPermission=FALSE;
            }
            
        }
        else
        
        {
            isCameraPermission=TRUE;
        }
        
        
        
        if (!isCameraPermission && isUsingAuditImages) {

            [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                           otherButtonTitle:nil
                                                   delegate:self
                                                    message:RPLocalizedString(CameraDisableMsg, @"")
                                                      title:nil
                                                        tag:001];

        }
        else{
            if (isUsingAuditImages && isCameraPermission)
            {
                CameraCaptureViewController *cameraViewCtrl=[[CameraCaptureViewController alloc]init];
                cameraViewCtrl._parentdelegate=self;
                cameraViewCtrl.projectInfoDict=dict;
                cameraViewCtrl.isUsingBreak=NO;
                cameraViewCtrl.isPunchIn=YES;
                AttendanceViewController *ctrl=(AttendanceViewController *)delegate;
                cameraViewCtrl._delegate=ctrl;
                cameraViewCtrl.hidesBottomBarWhenPushed = YES ;
                [ctrl.navigationController pushViewController:cameraViewCtrl animated:FALSE];
            }
            
            else
            {
                
                if (![NetworkMonitor isNetworkAvailableForListener:self])
                {
                    [Util showOfflineAlert];
                    
                }
                else
                {
                    
                    self.punchMapViewController=[[PunchMapViewController alloc]init];
                    self.punchMapViewController.isClockIn=YES;
                    self.punchMapViewController.delegate=self;
                    self.punchMapViewController.punchTime=[Util getCurrentTime:YES];
                    self.punchMapViewController.punchTimeAmPm=[Util getCurrentTime:NO];
                    self.punchMapViewController._parentDelegate=delegate;
                    
                    if ([delegate isKindOfClass:[AttendanceViewController class]])
                    {
                        AttendanceViewController *attCtrl=(AttendanceViewController *)delegate;
                        punchMapViewController.locationDict=attCtrl.locationDict;
                        attCtrl.punchMapViewController= self.punchMapViewController;
                    }
                    
                    
                    
                    punchMapViewController.projectInfoDict=dict;
                    //AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                    //[appDelegate.window addSubview:punchMapViewController.view];
                    [punchMapViewController checkForLocation];
                    
                }
                
                
            }
        }
        

    }
    
    
}
-(void)dismissCameraView
{
    // [locationManager stopUpdatingLocation];
    self.view.backgroundColor=[UIColor clearColor];
    //[self.punchMapViewController.view removeFromSuperview];
    [self.navigationController popToRootViewControllerAnimated:YES];
    if([delegate isKindOfClass:[AttendanceViewController class]])
    {
        [delegate  addActiVityIndicator];
    }
}


#pragma mark -
#pragma mark Search Delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.mainTableView.scrollEnabled = YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *textStr=[textField text];
    if (textStr==nil || [textStr isEqualToString:@""]||[textStr isKindOfClass:[NSNull class]])
    {
        self.isTextFieldFirstResponder=FALSE;
    }
    else
    {
        self.isTextFieldFirstResponder=TRUE;
    }
    self.mainTableView.scrollEnabled = YES;
    if ([self.searchTimer isValid])
    {
        [self.searchTimer invalidate];
        
    }
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:textField.text forKey:@"SearchString"];
    [defaults synchronize];
    
    self.searchTimer=  [NSTimer scheduledTimerWithTimeInterval:SEARCH_POLL
                                                        target:self
                                                      selector:@selector(fetchDataWithSearchText)
                                                      userInfo:nil
                                                       repeats:NO];
    return NO;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [searchTextField resignFirstResponder];
    self.mainTableView.scrollEnabled = YES;
    /*
     [ovController.view removeFromSuperview];
     
     ovController = nil;*/
    if ([self.searchTimer isValid])
    {
        [self.searchTimer invalidate];
        
    }
   
//    [self fetchDataWithSearchText];

}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.text=@"";
    self.isTextFieldFirstResponder=FALSE;
    self.mainTableView.scrollEnabled = YES;
    if ([self.searchTimer isValid])
    {
        [self.searchTimer invalidate];
        
    }
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:textField.text forKey:@"SearchString"];
    [defaults synchronize];
    
    self.searchTimer=  [NSTimer scheduledTimerWithTimeInterval:SEARCH_POLL
                                                        target:self
                                                      selector:@selector(fetchDataWithSearchText)
                                                      userInfo:nil
                                                       repeats:NO];
    return YES;
}
#pragma mark -
#pragma mark TableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSUInteger count= [self.arrayOfCharacters count];
    if (count<1)
    {
        return 1;
    }
    return [arrayOfCharacters count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count= [self.arrayOfCharacters count];
    if (count<1)
    {
        return 1;
    }
    return  [(NSMutableArray *)[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:section]] count];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name=@"";
    
    NSUInteger count= [self.arrayOfCharacters count];
    
    if (count>0)
    {
        if (screenMode==BILLING_SCREEN)
        {
            name=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] billingName];
        }
        if (screenMode==ACTIVITY_SCREEN)
        {
            
            ActivityObject *tmpActivityObject=[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
            
            NSString *activityName=[tmpActivityObject activityName];
            //Implementation for US8849//JUHI
            name=[NSString stringWithFormat:@"%@",activityName];
            
        }
    }
    else
    {
        name=RPLocalizedString(NO_RESULTS_FOUND, NO_RESULTS_FOUND);
    }
    
    
    if (name)
    {
        // Let's make an NSAttributedString first
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:name];
        //Add LineBreakMode
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_14]} range:NSMakeRange(0, attributedString.length)];
        
        //Now let's make the Bounding Rect
        CGSize mainSize  = [attributedString boundingRectWithSize:CGSizeMake(250.0, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        if (mainSize.width==0 && mainSize.height ==0)
        {
            mainSize=CGSizeMake(11.0, 18.0);
        }
        
        return mainSize.height+20;
        
    }
    return 40;

	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
	static NSString *CellIdentifier = @"Cell";
	cell  = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
    {
		cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	}
    NSString *name=@"";
    NSString *lowerName=@"";
    // NSMutableDictionary *dataDict=[listOfItems objectAtIndex:indexPath.row];
    
    NSUInteger count= [self.arrayOfCharacters count];
    
    if (count>0)
    {
        if (screenMode==BILLING_SCREEN)
        {
            name=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] billingName];
        }
        if (screenMode==ACTIVITY_SCREEN)
        {
            name=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] activityName];
            ActivityObject *tmpActivityObject=[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
            name=[tmpActivityObject activityName];
            
        }
    }
    else
    {
        name=RPLocalizedString(NO_RESULTS_FOUND, NO_RESULTS_FOUND);
    }


    CGFloat maxWidth = CGRectGetWidth(self.view.bounds) - Yoffset;
    UILabel *fieldName=[[UILabel alloc] initWithFrame:CGRectMake(10, 7, self.view.frame.size.width-Yoffset, 0)];
    if (count<1)
    {
        fieldName.textAlignment=NSTextAlignmentCenter;
    }
    [fieldName setBackgroundColor:[UIColor clearColor]];
    fieldName.font = [UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16];
    fieldName.numberOfLines=100;
    fieldName.text=name;
    [Util resizeLabel:fieldName withWidth:maxWidth];
    [cell.contentView addSubview:fieldName];
    
    
    UILabel *lowerlabel=[[UILabel alloc] initWithFrame:CGRectMake(10, fieldName.frame.size.height+10, self.view.frame.size.width-Yoffset, 0)];
    if (count<1)
    {
        lowerlabel.textAlignment=NSTextAlignmentCenter;
    }
    lowerlabel.font = [UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14];
    [lowerlabel setBackgroundColor:[UIColor clearColor]];
    lowerlabel.numberOfLines=100;
    lowerlabel.text=lowerName;
    [Util resizeLabel:lowerlabel withWidth:maxWidth];
    [cell.contentView addSubview:lowerlabel];

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }

    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if ([arrayOfCharacters count] == 0) {
        return @"";
    }
    if (self.isTextFieldFirstResponder)
    {
        return @"";
    }
    else
    {
        return [NSString stringWithFormat:@"%@", [arrayOfCharacters objectAtIndex:section]];
    }
    
    return [NSString stringWithFormat:@"%@", [arrayOfCharacters objectAtIndex:section]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.isTextFieldFirstResponder) {
        return 0.0f;
    }
    return CGRectGetHeight([[self tableView:tableView viewForHeaderInSection:section] bounds]);
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 24)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.frame.size.width, 18)];
    [label setFont:[UIFont fontWithName:RepliconFontFamilyLight size:16.0f]];
    [label setText:[self tableView:tableView titleForHeaderInSection:section]];
    [view addSubview:label];
    [view setBackgroundColor:TimesheetTotalHoursBackgroundColor];
    [view sizeToFit];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger count= [self.arrayOfCharacters count];
    self.isTextFieldFirstResponder=NO;
    if (count>0)
    {
        NSString *selectedName=nil;
        NSString *selectedUri=nil;
        if (screenMode==BILLING_SCREEN)
        {
            selectedName=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] billingName];
            selectedUri=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] billingUri];
        }
        if (screenMode==ACTIVITY_SCREEN)
        {
            selectedName=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] activityName];
            selectedUri=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] activityUri];
        }
        if (([delegate isKindOfClass:[AttendanceViewController class]]||[delegate isKindOfClass:[PunchEntryViewController class]]) && isOnlyActivity)
        {
            UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(Continue_Button_Title, @"")
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:self action:@selector(skipOrContinueAction:)];
            [tempRightButtonOuterBtn setTag:CONTINUE_BUTTON_TAG];
            [self navigationItem].rightBarButtonItem=tempRightButtonOuterBtn;
            self.selectedActivityName=selectedName;
            self.selectedActivityUri=selectedUri;
        }
        else
        {
            if (entryDelegate != nil && ![entryDelegate isKindOfClass:[NSNull class]] &&
                [entryDelegate conformsToProtocol:@protocol(UpdateEntryFieldProtocol)])
            {
                [entryDelegate updateFieldWithFieldName:selectedName andFieldURI:selectedUri];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        
    }
    

    
    
}
- (void)fetchDataWithSearchText
{
    
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
	}
    else
    {
        if (screenMode==BILLING_SCREEN)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:BILLING_RECEIVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterDataRecieved:) name:BILLING_RECEIVED_NOTIFICATION object:nil];
            UIApplication* app = [UIApplication sharedApplication];
            app.networkActivityIndicatorVisible = YES;
            if (isFromAttendance)
            {
                [[RepliconServiceManager attendanceService]fetchBillingRateBasedOnProjectWithSearchText:searchTextField.text withProjectUri:self.selectedProjectUri taskUri:self.selectedTaskUri andDelegate:self];
            }
            else
            {
               [[RepliconServiceManager timesheetService]fetchBillingRateBasedOnProjectForTimesheetUri:self.selectedTimesheetUri withSearchText:searchTextField.text withProjectUri:self.selectedProjectUri taskUri:self.selectedTaskUri andDelegate:self];
            }
            
        }
        if (screenMode==ACTIVITY_SCREEN)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:ACTIVITY_RECEIVED_NOTIFICATION object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterDataRecieved:)
                                                         name:ACTIVITY_RECEIVED_NOTIFICATION
                                                       object:nil];
            UIApplication* app = [UIApplication sharedApplication];
            app.networkActivityIndicatorVisible = YES;
            if (isFromAttendance)
            {
                [[RepliconServiceManager attendanceService]fetchActivityWithSearchText:searchTextField.text andDelegate:self];
            }
            else if ([delegate isKindOfClass:[PunchEntryViewController class]]){
                [[RepliconServiceManager teamTimeService]fetchActivityWithSearchText:searchTextField.text forUser:userId andDelegate:self];
            }
            else
            {
                [[RepliconServiceManager timesheetService]fetchActivityBasedOnTimesheetUri:self.selectedTimesheetUri withSearchText:searchTextField.text andDelegate:self];
            }
            
        }
        
    }
    
    [self.searchTimer invalidate];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    [searchTextField resignFirstResponder];
    self.mainTableView.scrollEnabled = YES;
    /*
     [ovController.view removeFromSuperview];
     
     ovController = nil;*/
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc
{
    self.mainTableView.delegate = nil;
    self.mainTableView.dataSource = nil;
}

-(DeviceType)getDeviceType
{
    if (TARGET_IPHONE_SIMULATOR)
        return OnSimulator;
    else
        return OnDevice;
}


@end
