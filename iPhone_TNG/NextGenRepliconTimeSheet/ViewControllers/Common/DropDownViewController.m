//
//  DropDownViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 15/05/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "DropDownViewController.h"
#import "Constants.h"
#import "Util.h"
#import "TimeoffModel.h"
#import "AppDelegate.h"
#import "CurrentTimesheetViewController.h"
#import "ExpenseEntryViewController.h"
#import "SVPullToRefresh.h"
#import "DropDownOption.h"
#import "LoginModel.h"

#import "ListOfTimeSheetsViewController.h"
#import "ListOfExpenseSheetsViewController.h"
#import "ListOfBookedTimeOffViewController.h"
#import "AttendanceViewController.h"
#import "TeamTimeViewController.h"
#import "ShiftsViewController.h"
#import "ApprovalsCountViewController.h"
#import "MoreViewController.h"


@interface DropDownViewController ()

@property (nonatomic) UITextField *searchTextField;
@property (nonatomic,assign)BOOL isTextFieldFirstResponder;
@property (nonatomic)NSTimer *searchTimer;
@end

@implementation DropDownViewController
@synthesize dropDownOptionList;
@synthesize dropDownOptionTableView;
@synthesize entryDelegate;
@synthesize arrayOfCharacters;
@synthesize objectsForCharacters;
@synthesize dropDownUri;
@synthesize selectedDropDownString;
#define Each_Cell_Row_Height 44
#define Yoffset 35
#define ACCEPTABLE_CHARACTERS @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define searchBar_Height 44
#define SEARCH_POLL 0.2




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        if (arrayOfCharacters==nil) {
            NSMutableArray *tempArrayOfCharacters=[[NSMutableArray alloc] init];
            self.arrayOfCharacters=tempArrayOfCharacters;
            
        }
        if (objectsForCharacters==nil) {
            NSMutableDictionary *tempObjectForCharacters=[[NSMutableDictionary alloc] init];
            self.objectsForCharacters=tempObjectForCharacters;
            
        }
        if (dropDownOptionList==nil) {
            NSMutableArray *tmpArray=[[NSMutableArray alloc]init];
            self.dropDownOptionList=tmpArray;
           
        }
       

    }
    return self;
}
- (void)loadView
{
	[super loadView];
	
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

     [self intialiseView];

    if (self.selectedDropDownString!=nil && ![self.selectedDropDownString isKindOfClass:[NSNull class]] && ![self.selectedDropDownString isEqualToString:@"null"] &&
        ![self.selectedDropDownString isEqualToString:RPLocalizedString(SELECT_STRING, @"") ] && ![self.selectedDropDownString isEqualToString:RPLocalizedString(NONE_STRING, @"")])
    {
        self.searchTextField.text=self.selectedDropDownString;
    }
    else
    {
        self.searchTextField.text=@"";
    }

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
   self.isTextFieldFirstResponder=NO;

        if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
        {
            [Util showOfflineAlert];
            return;
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:DROPDOWN_OPTION_RECEIVED_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createDropDownOptionList)
                                                     name:DROPDOWN_OPTION_RECEIVED_NOTIFICATION
                                                   object:nil];
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];


    if (self.isGen4Timesheet)
    {
        NSString *searchString = nil;

        if (self.searchTextField.text.length>0)
        {
            searchString = self.searchTextField.text;

            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
            [defaults setObject:searchString forKey:@"SearchString"];
            [defaults synchronize];
        }
        else
        {
            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
            [defaults removeObjectForKey:@"SearchString"];
            [defaults synchronize];
        }

        [[RepliconServiceManager loginService] sendrequestForObjectExtensionTagsForDropDownUri:dropDownUri searchString:searchString WithDelegate:self];
    }
    else
    {
            [[RepliconServiceManager loginService]sendrequestToDropDownOptionForDropDownUri:dropDownUri WithDelegate:self];
    }



    if (self.dropDownName)
    {
        [Util setToolbarLabel: self withText: self.dropDownName];
    }
    else
    {
        [Util setToolbarLabel: self withText: RPLocalizedString(DropDownOptionTilte, DropDownOptionTilte)];
    }

        //[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];
        
        UIBarButtonItem *tempLeftButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(CANCEL_STRING, @"")
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self action:@selector(cancelAction:)];
        [self navigationItem].rightBarButtonItem=nil;
        [[self navigationItem ] setLeftBarButtonItem:tempLeftButtonOuterBtn animated:NO];
}


-(void)intialiseView
{
    [self.view setBackgroundColor:RepliconStandardBackgroundColor];

    float height=0.0;
    if (self.isGen4Timesheet)
    {
        self.searchTextField=[[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, searchBar_Height)];
        self.searchTextField.clearButtonMode=YES;

        height=searchBar_Height;
        [self.view addSubview:self.searchTextField];

        float xPadding=10.0;
        float paddingFromSearchIconToPlaceholder=10.0;

        UIImage *searchIconImage=[UIImage imageNamed:@"icon_search_magnifying_glass"];

        UIImageView *searchIconImageView=[[UIImageView alloc]initWithFrame:CGRectMake(xPadding,15, searchIconImage.size.width, searchIconImage.size.height)];
        [searchIconImageView setImage:searchIconImage];
        [searchIconImageView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:searchIconImageView];
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, xPadding+searchIconImage.size.width+paddingFromSearchIconToPlaceholder, 20)];
        self.searchTextField.leftView = paddingView;
        self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
        self.searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.searchTextField.contentHorizontalAlignment = UIControlContentVerticalAlignmentCenter;
        [self.searchTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [self.searchTextField setDelegate:self];
        [self.searchTextField setReturnKeyType:UIReturnKeyDone];
        [self.searchTextField setEnablesReturnKeyAutomatically:NO];
        self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.searchTextField.delegate = self;
        self.searchTextField.font = [UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16];
        self.searchTextField.placeholder=RPLocalizedString(SEARCHBAR_DROPDOWN_OEF_PLACEHOLDER,@"");
        [self.searchTextField setAccessibilityLabel:@"drop_down_search_field"];

    }

     if (dropDownOptionTableView==nil) {
         UITableView *temptimeSheetsTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, height, self.view.frame.size.width, [self heightForTableView] - height) style:UITableViewStylePlain];
         self.dropDownOptionTableView=temptimeSheetsTableView;
         
     }
     self.dropDownOptionTableView.delegate=self;
     self.dropDownOptionTableView.dataSource=self;
     [self.dropDownOptionTableView setAccessibilityIdentifier:@"drop_down_oef_table"];
     [self.view addSubview:dropDownOptionTableView];
     
     UIView *bckView = [UIView new];
     [bckView setBackgroundColor:RepliconStandardBackgroundColor];
     [self.dropDownOptionTableView setBackgroundView:bckView];
    [self.dropDownOptionTableView setAccessibilityIdentifier:@"uia_dropdown_table_identifier"];
    
     [self configureTableForPullToRefresh];
     [self.dropDownOptionTableView setBottomContentInsetValue:0.0];
    //Fix for ios7//JUHI
    float version= [[UIDevice currentDevice].systemVersion newFloatValue];
    if (version>=7.0)
    {
        [[UITableViewHeaderFooterView appearance]setTintColor:[Util colorWithHex:@"#e8e8e8" alpha:1]];
    }
}
-(void)createDropDownOptionList{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DROPDOWN_OPTION_RECEIVED_NOTIFICATION object:nil];
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    
    [self.dropDownOptionTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self setupListData];
    [self checkToShowMoreButton];
    
    [self.dropDownOptionTableView setBottomContentInsetValue:0.0];
    
}
-(void)configureTableForPullToRefresh
{
    DropDownViewController *weakSelf = self;
    //setup pull to refresh widget
    [self.dropDownOptionTableView addPullToRefreshWithActionHandler:^{
        int64_t delayInSeconds = 0.0;
        [weakSelf.dropDownOptionTableView.pullToRefreshView startAnimating];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
           {
               [weakSelf refreshAction];
           });
    }];
    
    // setup infinite scrolling
    [self.dropDownOptionTableView addInfiniteScrollingWithActionHandler:^{
        if ([weakSelf.arrayOfCharacters count]>0) {
            [weakSelf.dropDownOptionTableView setBottomContentInsetValue: 60.0];
            NSUInteger sectionCount=[weakSelf.arrayOfCharacters count];
            NSUInteger rowCount=[(NSMutableArray *)[weakSelf.objectsForCharacters objectForKey:[weakSelf.arrayOfCharacters objectAtIndex:sectionCount-1]] count];
            NSIndexPath* ipath = [NSIndexPath indexPathForRow: rowCount-1 inSection: sectionCount-1];
            [weakSelf.dropDownOptionTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionBottom animated: YES];
            
            int64_t delayInSeconds = 0.0;
            [weakSelf.dropDownOptionTableView.infiniteScrollingView startAnimating];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
               {
                   [weakSelf moreAction];
               });
        }
        else
            [weakSelf.dropDownOptionTableView.infiniteScrollingView stopAnimating];
    }];
    
}
-(void)refreshAction
{
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [self.view setUserInteractionEnabled:YES];
        DropDownViewController *weakSelf = self;
        [weakSelf.dropDownOptionTableView.pullToRefreshView stopAnimating];
        [Util showOfflineAlert];
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DROPDOWN_OPTION_RECEIVED_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterPullToRefreshAction:)
                                                 name:DROPDOWN_OPTION_RECEIVED_NOTIFICATION
                                               object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    if (self.isGen4Timesheet)
    {
        NSString *searchString = nil;

        if (self.searchTextField.text.length>0)
        {
            searchString = self.searchTextField.text;
        }

        [[RepliconServiceManager loginService] sendrequestForObjectExtensionTagsForDropDownUri:dropDownUri searchString:searchString WithDelegate:self];
    }
    else
    {
        [[RepliconServiceManager loginService]sendrequestToDropDownOptionForDropDownUri:dropDownUri WithDelegate:self];
    }
}
-(void)refreshViewAfterPullToRefreshAction:(NSNotification *)notificationObject
{
    [self.view setUserInteractionEnabled:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DROPDOWN_OPTION_RECEIVED_NOTIFICATION object:nil];
    DropDownViewController *weakSelf = self;
    [weakSelf.dropDownOptionTableView.pullToRefreshView stopAnimating];
    self.dropDownOptionTableView.showsInfiniteScrolling=TRUE;
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
    
    [self.dropDownOptionTableView setBottomContentInsetValue:0.0];
    
}
-(void)moreAction
{
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        [self performSelector:@selector(refreshTableViewOnConnectionError) withObject:nil afterDelay:0.2];
    }
    //Fix for defect DE15459
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DROPDOWN_NEXT_OPTION_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterMoreAction:) name:DROPDOWN_NEXT_OPTION_RECEIVED_NOTIFICATION object:nil];//Fix for defect DE15459
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;

    if (self.isGen4Timesheet)
    {
        NSString *searchString = nil;

        if (self.searchTextField.text.length>0)
        {
            searchString = self.searchTextField.text;
        }

        [[RepliconServiceManager loginService] sendrequestForNextObjectExtensionTagsForDropDownUri:dropDownUri searchString:searchString WithDelegate:self];
    }
    else
    {
        [[RepliconServiceManager loginService]sendrequestForNextDropDownOptionForDropDownUri:dropDownUri WithDelegate:self];
    }

        
}
-(void)refreshTableViewOnConnectionError
{
    DropDownViewController *weakSelf = self;
    [weakSelf.dropDownOptionTableView.infiniteScrollingView stopAnimating];
    
    self.dropDownOptionTableView.showsInfiniteScrolling=FALSE;
    self.dropDownOptionTableView.showsInfiniteScrolling=TRUE;
    
}
-(void)refreshViewAfterMoreAction:(NSNotification *)notificationObject
{
    //Fix for defect DE15459
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DROPDOWN_NEXT_OPTION_RECEIVED_NOTIFICATION object:nil];
    [self.view setUserInteractionEnabled:YES];
    DropDownViewController *weakSelf = self;
    [weakSelf.dropDownOptionTableView.infiniteScrollingView stopAnimating];
    
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    
    NSDictionary *theData = [notificationObject userInfo];
    NSNumber *n = [theData objectForKey:@"isErrorOccured"];
    
    
    BOOL isErrorOccured = [n boolValue];
    
    if (isErrorOccured)
    {
        self.dropDownOptionTableView.showsInfiniteScrolling=FALSE;
    }
    else
    {
        
        [self setupListData];
        [self checkToShowMoreButton];
    }
    
    [self.dropDownOptionTableView setBottomContentInsetValue:0.0];
}
-(void)checkToShowMoreButton
{
    NSNumber *count=nil ;
    NSNumber *fetchCount=nil;

    if (self.isGen4Timesheet)
    {
        count =	[[NSUserDefaults standardUserDefaults]objectForKey:@"oefDropDownTagOptionDownloadCount"];
        fetchCount  =    [[AppProperties getInstance] getAppPropertyFor:@"oefDropDownTagOptionDownloadCount"];
    }
    else
    {
        count =	[[NSUserDefaults standardUserDefaults]objectForKey:@"dropDownOptionDataDownloadCount"];
        fetchCount  =    [[AppProperties getInstance] getAppPropertyFor:@"dropDownOptionDownloadCount"];
    }



    if (([count intValue]<[fetchCount intValue]))
    {
		self.dropDownOptionTableView.showsInfiniteScrolling=FALSE;
	}
    else
    {
        self.dropDownOptionTableView.showsInfiniteScrolling=TRUE;
    }
    
    if ([self.dropDownOptionList count]==0)
    {
        self.dropDownOptionTableView.showsPullToRefresh=TRUE;
        self.dropDownOptionTableView.showsInfiniteScrolling=FALSE;
    }
    else
    {
        self.dropDownOptionTableView.showsPullToRefresh=TRUE;
    }
    
}
- (void)setupListData
{
    [dropDownOptionList removeAllObjects];
    [arrayOfCharacters removeAllObjects];
    [objectsForCharacters removeAllObjects];
    
    LoginModel *loginModel=[[LoginModel alloc]init];
    if (self.isGen4Timesheet)
    {
       self.dropDownOptionList=[loginModel getOEFDropDownTagOptionsFromDatabase];
    }
    else
    {
       self.dropDownOptionList=[loginModel getDropDownOptionsFromDatabase];
    }

   
    
    NSString *key=nil;
    if (self.isGen4Timesheet)
    {
        key=@"oefDropDownTagDisplayText";
    }
    else
    {
        key=@"name";
    }
    if ([dropDownOptionList count]>0)
    {
        NSSortDescriptor * brandDescriptor =[[NSSortDescriptor alloc] initWithKey:key ascending:YES comparator:^(id firstDocumentName, id secondDocumentName) {
            
            
            
            static NSStringCompareOptions comparisonOptions =
            
            NSCaseInsensitiveSearch | NSNumericSearch |
            
            NSWidthInsensitiveSearch | NSForcedOrderingSearch;
            
            
            
            return [firstDocumentName compare:secondDocumentName options:comparisonOptions];
            
        }];
        NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:brandDescriptor];
       
        NSArray *array = [dropDownOptionList sortedArrayUsingDescriptors:sortDescriptors];
        self.dropDownOptionList=[NSMutableArray arrayWithArray:array];
        
    }
    else if([self.dropDownOptionList count]==0)
    {


    }
    [self setupIndexDataBasedOnSectionAlphabets];
    
    
}
- (void)setupIndexDataBasedOnSectionAlphabets
{
    
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSMutableArray *arrayOfNames = [[NSMutableArray alloc] init];
    NSMutableArray *arrayOfNamesForNumeric=[[NSMutableArray alloc] init];//Fix for DE15484
    NSString *numbericSection    = @"#";
    NSString *firstLetter;
    NSString *name;
    
    for (NSDictionary *item in self.dropDownOptionList) {
        NSDictionary *listOfitemDict=item;
        NSArray *allKeys=[listOfitemDict allKeys];
        DropDownOption *dropDownOptionObject=[[DropDownOption alloc]init];
        
        for (NSString *tmpKey in allKeys)
        {
            
            if ([tmpKey isEqualToString:@"name"] || [tmpKey isEqualToString:@"oefDropDownTagDisplayText"])
            {
                dropDownOptionObject.dropDownOptionName=[listOfitemDict objectForKey:tmpKey];
            }
            else if ([tmpKey isEqualToString:@"uri"] || [tmpKey isEqualToString:@"oefDropDownTagUri"])
            {
                dropDownOptionObject.dropDownOptionUri=[listOfitemDict objectForKey:tmpKey];
            }
           
        }
        NSString *key=nil;

        if (self.isGen4Timesheet)
        {
            key=@"oefDropDownTagDisplayText";
        }
        else
        {
            key=@"name";
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
                
                [self.arrayOfCharacters addObject:newStrfirstLetter];
            }
            [arrayOfNames addObject:dropDownOptionObject];
            
            /**
             * Need to autorelease the copy to preven potential leak.  Even though the
             * arrayOfNames is released below it still has a retain count of +1
             */
            [self.objectsForCharacters setObject:[arrayOfNames copy] forKey:newStrfirstLetter];
            
        }
        else {
            if (![self.objectsForCharacters objectForKey:numbericSection]) {
                
                [arrayOfNamesForNumeric removeAllObjects];//Fix for DE15484
                
                [self.arrayOfCharacters addObject:numbericSection];
            }
            
            [arrayOfNamesForNumeric addObject:dropDownOptionObject];//Fix for DE15484
            
            [self.objectsForCharacters setObject:[arrayOfNamesForNumeric copy] forKey:numbericSection];//Fix for DE15484
        }
        
        
    }
    
    
    [self.dropDownOptionTableView reloadData];
}
-(void)cancelAction:(id)sender
{
    self.isTextFieldFirstResponder=NO;
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)tableViewcell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableViewcell setBackgroundColor:RepliconStandardBackgroundColor];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
	NSUInteger count= [self.arrayOfCharacters count];
    if (count<1)
    {
        return 1;
    }
    return [self.arrayOfCharacters count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
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
       
        name=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] dropDownOptionName];
   
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
        CGSize mainSize = [attributedString boundingRectWithSize:CGSizeMake(250.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        if (mainSize.width==0 && mainSize.height ==0)
        {
            mainSize=CGSizeMake(11.0, 18.0);
        }
        
        return mainSize.height+20;
        
    }
    return 40;
    

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
	static NSString *CellIdentifier = @"Cell";
	cell  = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
    {
		cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
		//Fix for ios7//JUHI
        float version= [[UIDevice currentDevice].systemVersion newFloatValue];
        if (version>=7.0)
        {
            UIView *selectedView = [[UIView alloc]init];
            selectedView.backgroundColor = RepliconStandardNavBarTintColor;
            cell.selectedBackgroundView =  selectedView;
        }
        else{
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	}
    NSString *name=@"";
    // NSMutableDictionary *dataDict=[listOfItems objectAtIndex:indexPath.row];
   
    NSUInteger count= [self.arrayOfCharacters count];
    
    if (count>0)
    {
        name=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] dropDownOptionName];
    
    }
    else
    {
        name=RPLocalizedString(NO_RESULTS_FOUND, NO_RESULTS_FOUND);
    }
    
    CGSize size =CGSizeMake(0, 0);
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
        //MOBi-802
        size = [attributedString boundingRectWithSize:CGSizeMake(250.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        if (size.width==0 && size.height ==0)
        {
            size=CGSizeMake(11.0, 18.0);
        }
    }
    
    UILabel *fieldName=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-Yoffset, size.height)];
    if (count<1)
    {
        fieldName.textAlignment=NSTextAlignmentCenter;
    }
    [fieldName setBackgroundColor:[UIColor clearColor]];
    fieldName.font = [UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_14];
    fieldName.numberOfLines=100;
    fieldName.text=name;
    fieldName.highlightedTextColor=[UIColor whiteColor];
    [cell.contentView addSubview:fieldName];
    
    [cell setAccessibilityIdentifier:@"drop_down_oef_cell"];
    
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if ([arrayOfCharacters count] == 0) {
        return @"";
    }
    
    return [NSString stringWithFormat:@"%@", [arrayOfCharacters objectAtIndex:section]];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    NSArray *toBeReturned = [NSArray arrayWithArray:
                             [@"#|A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z"
                              componentsSeparatedByString:@"|"]];
    
    return toBeReturned;
}


-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    
    return [arrayOfCharacters indexOfObject:title] ;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger count= [self.arrayOfCharacters count];
    self.isTextFieldFirstResponder=NO;
    CLS_LOG(@"-----Dropdown udf row selected on DropDownViewController -----");
    if (count>0)
    {
        NSString *selectedName=nil;
        NSString *selectedUri=nil;
        
        selectedName=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] dropDownOptionName];
        selectedUri=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] dropDownOptionUri];
               
        if (entryDelegate != nil && ![entryDelegate isKindOfClass:[NSNull class]] &&
            [entryDelegate conformsToProtocol:@protocol(UpdateDropDownFieldProtocol)])
        {
            if ([entryDelegate isKindOfClass:[TimeEntryViewController class]])
            {
                TimeEntryViewController *timeEntryViewController=(TimeEntryViewController *)entryDelegate;
                if (timeEntryViewController.selectedIndexPath!=nil)
                {
                    [timeEntryViewController.timeEntryTableView scrollToRowAtIndexPath:timeEntryViewController.selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:FALSE];
                    [entryDelegate updateDropDownFieldWithFieldName:selectedName andFieldURI:selectedUri];
                    //[timeEntryViewController doneClicked];
                    
                }
            }
            else
            {
                [entryDelegate updateDropDownFieldWithFieldName:selectedName andFieldURI:selectedUri];
            }
           
            
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    
    
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];

        [[NSNotificationCenter defaultCenter] removeObserver:self name:DROPDOWN_OPTION_RECEIVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:DROPDOWN_NEXT_OPTION_RECEIVED_NOTIFICATION object:nil];//Fix for defect DE15459
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc
{
    self.dropDownOptionTableView.delegate = nil;
    self.dropDownOptionTableView.dataSource = nil;
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

#pragma mark -
#pragma mark Search Delegates

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.dropDownOptionTableView.scrollEnabled = YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    /*[self.listTableView insertSubview:ovController.view aboveSubview:self.parentViewController.view];*/
    NSString *textStr=[textField text];
    if (textStr==nil || [textStr isEqualToString:@""]||[textStr isKindOfClass:[NSNull class]])
    {
        self.isTextFieldFirstResponder=FALSE;
    }
    else
    {
        self.isTextFieldFirstResponder=TRUE;
    }

    if ([self.searchTimer isValid])
    {
        [self.searchTimer invalidate];

    }


    if (textField.text.length>0)
    {
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setObject:textField.text forKey:@"SearchString"];
        [defaults synchronize];
    }
    else
    {
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"SearchString"];
        [defaults synchronize];
    }



    self.searchTimer=  [NSTimer scheduledTimerWithTimeInterval:SEARCH_POLL
                                                        target:self
                                                      selector:@selector(refreshAction)
                                                      userInfo:nil
                                                       repeats:NO];
    //self.listTableView.scrollEnabled = NO;

    self.dropDownOptionTableView.scrollEnabled = YES;
    return NO;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.text=@"";
    self.isTextFieldFirstResponder=FALSE;

    if ([self.searchTimer isValid])
    {
        [self.searchTimer invalidate];

    }
    if (textField.text.length>0)
    {
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setObject:textField.text forKey:@"SearchString"];
        [defaults synchronize];
    }
    else
    {
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"SearchString"];
        [defaults synchronize];
    }

    self.searchTimer=  [NSTimer scheduledTimerWithTimeInterval:SEARCH_POLL
                                                        target:self
                                                      selector:@selector(refreshAction)
                                                      userInfo:nil
                                                       repeats:NO];


    self.dropDownOptionTableView.scrollEnabled = YES;
    return YES;
}


- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{

    [self.searchTextField resignFirstResponder];
    if ([self.searchTimer isValid])
    {
        [self.searchTimer invalidate];

    }
    self.dropDownOptionTableView.scrollEnabled = YES;

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

    [self.searchTextField resignFirstResponder];
}


@end
