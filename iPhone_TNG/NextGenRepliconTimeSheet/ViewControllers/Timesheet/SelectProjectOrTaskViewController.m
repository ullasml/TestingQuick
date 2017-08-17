//
//  SelectProjectOrTaskViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 11/01/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "SelectProjectOrTaskViewController.h"
#import "Util.h"
#import "Constants.h"
#import "CurrentTimesheetViewController.h"
#import "SelectClientOrProjectViewController.h"
#import "TimeEntryViewController.h"
#import "TimesheetModel.h"
#import "TaskObject.h"
#import "ProjectObject.h"
#import "RepliconServiceManager.h"
#import "SVPullToRefresh.h"
#import "AppDelegate.h"
#import "ExpenseEntryViewController.h"
#import "ExpenseModel.h"
#import "CurrentTimeSheetsCellView.h"


#define searchBar_Height 44
#define tabBar_Height 55
#define navBar_Height 40
#define customView_Height 26
#define Yoffset 35
#define BOTTOM_SEPARATOR_HEIGHT 2.0
#define SEARCH_POLL 0.2

@implementation SelectProjectOrTaskViewController
@synthesize searchTextField;
@synthesize listTableView;
@synthesize delegate;
@synthesize selectedItem;
@synthesize selectedValue,selectedPath;
@synthesize listOfItems;
@synthesize arrayOfCharacters;
@synthesize objectsForCharacters;
@synthesize currentSelectedItem;
@synthesize entryDelegate;
@synthesize isTaskPermission;
@synthesize isTimeAllowedPermission;
@synthesize selectedClientUri;
@synthesize selectedProjectUri;
@synthesize selectedTimesheetUri;
@synthesize searchTimer;
@synthesize client;
@synthesize project;
@synthesize task;
@synthesize isFromTaskRowSelection;
@synthesize isMoreActionCalled;
@synthesize selectedExpenseUri;
@synthesize isForNoTaskDismiss;
@synthesize isLoadedOnce;
@synthesize searchProjectString;
@synthesize isPreFilledSearchString;
@synthesize isTextFieldFirstResponder;
//Implementation for US8849//JUHI
@synthesize directlyFromProjectTab;
@synthesize selectedMode;//DE20024//JUHI
@synthesize isFromLockedInOut,isFromAttendance;

#pragma mark -
#pragma mark View Intialisation
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
        if (selectedItem==nil) {
            NSString *string=[[NSString alloc]init];
            self.selectedItem=string;
           
        }
        if (selectedValue==nil) {
            NSString *string=[[NSString alloc]init];
            self.selectedValue=string;
           
        }
        if (selectedPath==nil) {
            NSString *string=[[NSString alloc]init];
            self.selectedPath=string;
           
        }
        //Implementation for US8849//JUHI

        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self intialiseView];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:TRUE];
    
        if (self.isForNoTaskDismiss)
        {
            
            if(selectedProjectUri!=nil && ![selectedProjectUri isKindOfClass:[NSNull class]] && ![selectedProjectUri isEqualToString:NULL_STRING])
            {
                [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self name:DEFAULT_BILLING_RECEIVED_NOTIFICATION object:nil];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDataForDefaultBilling:)
                                                             name:DEFAULT_BILLING_RECEIVED_NOTIFICATION
                                                           object:nil];
                
                [[RepliconServiceManager timesheetService]fetchDefaultBillingRateBasedOnProjectForTimesheetUri:self.selectedTimesheetUri withSearchText:@"" withProjectUri:selectedProjectUri taskUri:selectedTaskUri andDelegate:self];
            }
            
            else
            {
                 [self.navigationController popToViewController:(TimeEntryViewController *)entryDelegate animated:FALSE];
            }
            
            
            self.isForNoTaskDismiss=FALSE;
        }
        self.isLoadedOnce=TRUE;
    }



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
        if (self.isPreFilledSearchString)
        {
            if (searchProjectString!=nil && ![searchProjectString isKindOfClass:[NSNull class]] && ![searchProjectString isEqualToString:@"null"] &&
                ![searchProjectString isEqualToString:RPLocalizedString(SELECT_STRING, @"") ] && ![searchProjectString isEqualToString:RPLocalizedString(NONE_STRING, @"")])
            {
                self.searchTextField.text=searchProjectString;
            }
            else
            {
                self.searchTextField.text=@"";
            }
        }
        
        else
        {
            self.searchTextField.text=@"";
        }
        self.isTextFieldFirstResponder=NO;
        if (selectedMode==CLIENT_MODE ||selectedMode==PROGRAM_MODE)//DE20024//JUHI //MOBI-746
        {
            if ([entryDelegate isKindOfClass:[TimeEntryViewController class]])
            {
                if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
                {
                    [Util setToolbarLabel:delegate withText:RPLocalizedString(ADD_PROJECT, @"") ];
                }
                else
                {
                    [Util setToolbarLabel:self withText:RPLocalizedString(ADD_PROJECT, @"") ];
                }
                
                
            }
            else if ([entryDelegate isKindOfClass:[ExpenseEntryViewController class]])
            {
                [Util setToolbarLabel:self withText:RPLocalizedString(ADD_PROJECT, @"") ];
            }
            
        }
        else
        {
            if ([entryDelegate isKindOfClass:[TimeEntryViewController class]])
            {
                if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
                {
                    [Util setToolbarLabel:delegate withText:RPLocalizedString(ADD_TASK, @"") ];
                }
                else
                {
                    [Util setToolbarLabel:self withText:RPLocalizedString(ADD_TASK, @"") ];
                }
                
            }
            else if ([entryDelegate isKindOfClass:[ExpenseEntryViewController class]])
            {
                [Util setToolbarLabel:self withText:RPLocalizedString(ADD_TASK, @"") ];
            }
            
        }
        if ([entryDelegate isKindOfClass:[ExpenseEntryViewController class]])
        {
            UIBarButtonItem *tempLeftButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(CANCEL_STRING, @"")
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:self action:@selector(cancelAction:)];
            if (selectedMode==CLIENT_MODE)//DE20024//JUHI
                [self.navigationItem setRightBarButtonItem:nil];
            [self.navigationItem setLeftBarButtonItem:tempLeftButtonOuterBtn animated:NO];
        }
}

-(void)intialiseView
{
    [self.view setBackgroundColor:RepliconStandardBackgroundColor];
    UITextField *tempsearchBar=[[UITextField alloc]initWithFrame:CGRectMake(0, customView_Height, self.view.frame.size.width, searchBar_Height)];
    self.searchTextField=tempsearchBar;
  
    self.searchTextField.clearButtonMode=YES;
    [self.view addSubview:self.searchTextField];
    
    float xPadding=10.0;
    float paddingFromSearchIconToPlaceholder=10.0;
    
    UIImage *searchIconImage=[UIImage imageNamed:@"icon_search_magnifying_glass"];

    UIImageView *searchIconImageView=[[UIImageView alloc]initWithFrame:CGRectMake(xPadding, customView_Height+15, searchIconImage.size.width, searchIconImage.size.height)];
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
	searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	searchTextField.delegate = self;
    searchTextField.font = [UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16];
    [searchTextField setAccessibilityLabel:@"search_textfield_projects_tasks"];


    //DE20024//JUHI

    if (selectedMode==CLIENT_MODE||selectedMode==PROGRAM_MODE)//MOBI-746
    {
        searchTextField.placeholder=RPLocalizedString(SEARCHBAR_PROJECT_PLACEHOLDER,@"");
    }
    else
    {
        searchTextField.placeholder=RPLocalizedString(SEARCHBAR_TASK_PLACEHOLDER,@"");
    }

    NSMutableArray *tmpArray=[[NSMutableArray alloc]init];
    self.listOfItems=tmpArray;
   
     if (selectedMode==CLIENT_MODE||selectedMode==PROGRAM_MODE)//MOBI-746
    {
        self.currentSelectedItem=RPLocalizedString(Client, @"");//Implementation for US8902//JUHI
        self.directlyFromProjectTab=NO;
        [self addCustomViewWithTag:0];
    }
    else if (selectedMode==PROJECT_MODE){
        self.currentSelectedItem=RPLocalizedString(Project, @"");//Implementation for US8902//JUHI
        self.directlyFromProjectTab=YES;
        [self addCustomViewWithTag:0];
    }
    
    //Fix for ios7//JUHI
    float version= [[UIDevice currentDevice].systemVersion newFloatValue];
    int height=44;
    if (version>=7.0)
    {
        height=24;
    }
    UITableView *tempmainTableView=[[UITableView alloc]initWithFrame:CGRectMake(0,searchBar_Height+customView_Height, self.view.frame.size.width ,self.view.frame.size.height-searchBar_Height-customView_Height-navBar_Height-tabBar_Height+height) style:UITableViewStylePlain];
    
    self.listTableView=tempmainTableView;
    [self.listTableView setAccessibilityLabel:@"select_task_tbl_view"];
    self.listTableView.separatorColor=[Util colorWithHex:@"#cccccc" alpha:1];
    self.listTableView.delegate=self;
    self.listTableView.dataSource=self;
    if ([self.listTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.listTableView.layoutMargins = UIEdgeInsetsZero;
    }
    if ([self.listTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.listTableView.separatorInset = UIEdgeInsetsZero;
    }

    [self.view addSubview:listTableView];
    [self configureTableForPullToRefresh];
    
     [self.listTableView setBottomContentInsetValue:0.0];
    //Fix for ios7//JUHI
    
    if (version>=7.0)
    {
        [[UITableViewHeaderFooterView appearance]setTintColor:[Util colorWithHex:@"#e8e8e8" alpha:1]];
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
    self.listTableView.scrollEnabled = YES;
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
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:textField.text forKey:@"SearchString"];
    [defaults synchronize];
    
    self.searchTimer=  [NSTimer scheduledTimerWithTimeInterval:SEARCH_POLL
                                                        target:self
                                                      selector:@selector(fetchProjectsOrTasksWithSearchText)
                                                      userInfo:nil
                                                       repeats:NO];
    //self.listTableView.scrollEnabled = NO;
    
    self.listTableView.scrollEnabled = YES;
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
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:textField.text forKey:@"SearchString"];
    [defaults synchronize];
    
    self.searchTimer=  [NSTimer scheduledTimerWithTimeInterval:SEARCH_POLL
                                                        target:self
                                                      selector:@selector(fetchProjectsOrTasksWithSearchText)
                                                      userInfo:nil
                                                       repeats:NO];
    //self.listTableView.scrollEnabled = NO;
    
    self.listTableView.scrollEnabled = YES;
    return YES;
}


- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    
    [searchTextField resignFirstResponder];
    if ([self.searchTimer isValid])
    {
        [self.searchTimer invalidate];
        
    }
    self.listTableView.scrollEnabled = YES;
    //[self fetchProjectsOrTasksWithSearchText];
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
    return [(NSMutableArray *)[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:section]] count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name=@"";
    NSString *taskDirectoryName=@"";
    
    NSUInteger count= [self.arrayOfCharacters count];
    
    if (count>0)
    {
        
        if ([[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] isKindOfClass:[ProjectObject class]])
        {
            
            ProjectObject *tmpProjectObject=[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
            
            NSString *projectName=[tmpProjectObject projectName];
            //Implementation for US8849//JUHI
            name=[NSString stringWithFormat:@"%@",projectName];
        }
        else
        {
            TaskObject *tmpTaskObject=[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
            NSString *taskName=[tmpTaskObject taskName];
            //Implementation for US8849//JUHI
            name=[NSString stringWithFormat:@"%@",taskName];
            
            taskDirectoryName=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] taskFullPath];
        }
    }

    else
    {
        name=RPLocalizedString(NO_RESULTS_FOUND, NO_RESULTS_FOUND);
    }

    
    if ([taskDirectoryName isKindOfClass:[NSNull class]]||[taskDirectoryName isEqualToString:@""]||taskDirectoryName==nil)
    {
        CGSize size=CGSizeMake(0, 0);
        if (name)
        {


            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:name];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];

            //Now let's make the Bounding Rect
            CGFloat widthWithPadding = CGRectGetWidth(self.view.bounds) - Yoffset;
            size  = [attributedString boundingRectWithSize:CGSizeMake(widthWithPadding, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

            if (size.width==0 && size.height ==0)
            {
                size=CGSizeMake(11.0, 18.0);
            }
        }


        return size.height+20.0;

    }
    else
    {
        CGSize size ;
        if (taskDirectoryName)
        {

            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:taskDirectoryName];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];

            //Now let's make the Bounding Rect
            size  = [attributedString boundingRectWithSize:CGSizeMake(250.0, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

            if (size.width==0 && size.height ==0)
            {
                size=CGSizeMake(11.0, 18.0);
            }
        }


        CGSize nameSize =CGSizeZero;
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
            nameSize  = [attributedString boundingRectWithSize:CGSizeMake(250.0, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;


            if (nameSize.width==0 && nameSize.height ==0)
            {
                nameSize=CGSizeMake(11.0, 18.0);
            }
        }

        return size.height+nameSize.height+30.0;
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
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	}
    NSString *name=@"";
    //Implementation for US8849//JUHI
    NSString *directoryName=@"";
    
    NSUInteger count= [self.arrayOfCharacters count];
    
    if (count>0)
    {
        id object=[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        if ([object isKindOfClass:[ProjectObject class]])
        {
            name=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] projectName];
            //Implementation for US8849//JUHI
        }
        else
        {
            name=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] taskName];
            //Implementation for US8849//JUHI
            directoryName=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] taskFullPath];
        }

    }
    else
    {
        name=RPLocalizedString(NO_RESULTS_FOUND, NO_RESULTS_FOUND);
    }


    if ([directoryName isKindOfClass:[NSNull class]]||[directoryName isEqualToString:@""]||directoryName==nil)
    {
        CGSize size=CGSizeMake(0, 0);
        if (name)
        {
          
            
            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:name];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];
            
            //Now let's make the Bounding Rect
            CGFloat widthWithPadding = CGRectGetWidth(self.view.bounds) - Yoffset;
           size  = [attributedString boundingRectWithSize:CGSizeMake(widthWithPadding, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            if (size.width==0 && size.height ==0)
            {
                size=CGSizeMake(11.0, 18.0);
            }
        }
        //Implementation for US8849//JUHI
        UILabel *taskNamelabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 7, self.view.frame.size.width-Yoffset, size.height)];
        if (count<1)
        {
            taskNamelabel.textAlignment=NSTextAlignmentCenter;
        }
        taskNamelabel.font = [UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16];
        taskNamelabel.numberOfLines=100;
        taskNamelabel.text=name;
        [cell.contentView addSubview:taskNamelabel];
       
        
        //Implementation for US8849//JUHI

    }
    else
    {
        CGSize size ;
        if (directoryName)
        {
           
            
            
            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:directoryName];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];
            
            //Now let's make the Bounding Rect
            size  = [attributedString boundingRectWithSize:CGSizeMake(250.0, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            if (size.width==0 && size.height ==0)
            {
                size=CGSizeMake(11.0, 18.0);
            }
        }
        //Implementation for US8849//JUHI
        UILabel *fullTaskPathNamelabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-Yoffset, size.height)];
        fullTaskPathNamelabel.font = [UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16];
        fullTaskPathNamelabel.numberOfLines=100;
        fullTaskPathNamelabel.text=directoryName;
        [cell.contentView addSubview:fullTaskPathNamelabel];
        
        
        
        CGSize nameSize =CGSizeZero;
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
            nameSize  = [attributedString boundingRectWithSize:CGSizeMake(250.0, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            
            if (nameSize.width==0 && nameSize.height ==0)
            {
                nameSize=CGSizeMake(11.0, 18.0);
            }
        }
        
        UILabel *nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, fullTaskPathNamelabel.frame.size.height+fullTaskPathNamelabel.frame.origin.y, self.view.frame.size.width-Yoffset, nameSize.height+10.0)];
        nameLabel.numberOfLines=100;
        nameLabel.font = [UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16];
        nameLabel.text=name;
        [cell.contentView addSubview:nameLabel];
    }

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger count= [self.arrayOfCharacters count];
    self.isTextFieldFirstResponder=NO;
    if (count>0)
    {
        if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
        {
            [Util showOfflineAlert];
            
        }
        else
        {
            self.isPreFilledSearchString=NO;
            self.searchProjectString=nil;
            self.searchTextField.text=@"";
            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
            [defaults setObject:self.searchTextField.text forKey:@"SearchString"];
            [defaults synchronize];
            
            if ([entryDelegate isKindOfClass:[TimeEntryViewController class]])
            {
                id object=[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
                NSString *name=@"";
                NSString *selectedItemUri=@"";
                
                if ([object isKindOfClass:[ProjectObject class]])
                {
                    name=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] projectName];
                    selectedItemUri=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] projectUri];
                    self.selectedProjectUri=selectedItemUri;
                    //Implementation for US8849//JUHI
                    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION object:nil];
                    
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterDataRecieved:)
                                                                 name:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION
                                                               object:nil];
                    NSString *timesheetUri=self.selectedTimesheetUri;
                    NSString *searchString=searchTextField.text;
                    self.isTaskPermission=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] hasTasksAvailableForTimeAllocation];
                    self.isTimeAllowedPermission=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] isTimeAllocationAllowed];
                    if (searchString==nil) {
                        searchString=@"";
                    }
                    if (isFromAttendance)
                    {
                        [[RepliconServiceManager attendanceService]fetchTasksBasedOnProjectsWithSearchText:searchString withProjectUri:selectedItemUri andDelegate:self];
                    }
                    else
                    {
                        [[RepliconServiceManager timesheetService]fetchTasksBasedOnProjectsForTimesheetUri:timesheetUri withSearchText:searchString withProjectUri:selectedItemUri andDelegate:self];
                    }
                    
                }
                else
                {
                    name=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] taskName];
                    selectedItemUri=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] taskUri];
                    selectedTaskUri=selectedItemUri;
                    selectedPath=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] taskFullPath];
                    //Implementation for US8849//JUHI
                }
                
                selectedValue=name;
                if (selectedMode==CLIENT_MODE||selectedMode==PROGRAM_MODE)//DE20024//JUHI //MOBI-746
                {
                    self.selectedMode=PROJECT_MODE;
                    self.selectedItem=RPLocalizedString(Project, @"");
                    self.currentSelectedItem=RPLocalizedString(Project, @"");
                    [self addCustomViewWithTag:1];
                }
                else if (selectedMode==PROJECT_MODE)//DE20024//JUHI
                {
                    self.selectedMode=TASK_MODE;
                    self.selectedItem=RPLocalizedString(Task, @"");
                    self.currentSelectedItem=RPLocalizedString(Task, @"");
                    [self addCustomViewWithTag:2];
                }
                else if (selectedMode==TASK_MODE && isTaskPermission)
                {
                    self.selectedMode=TASK_MODE;
                    self.selectedItem=RPLocalizedString(Task, @"");
                    self.currentSelectedItem=RPLocalizedString(Task, @"");
                    [self addCustomViewWithTag:2];
                }
            }
            else if ([entryDelegate isKindOfClass:[ExpenseEntryViewController class]])
            {
                id object=[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
                NSString *name=@"";
                NSString *selectedItemUri=@"";
                if ([object isKindOfClass:[ProjectObject class]])
                {
                    name=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] projectName];
                    selectedItemUri=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] projectUri];
                    project=name;
                    self.selectedProjectUri=selectedItemUri;
                }
                ExpenseEntryViewController *entryVC=(ExpenseEntryViewController *)entryDelegate;
                if (entryDelegate != nil && ![entryDelegate isKindOfClass:[NSNull class]] &&
                    [entryDelegate conformsToProtocol:@protocol(UpdateEntryProjectAndTaskFieldProtocol)])
                {
                    [entryDelegate updateFieldWithClient:client clientUri:selectedClientUri project:project projectUri:selectedProjectUri task:task andTaskUri:selectedTaskUri taskPermission: self.isTaskPermission timeAllowedPermission:self.isTimeAllowedPermission];
                }

                [self.navigationController popToViewController:entryVC animated:YES];
                return;
            }
  
            
            
        }
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.isTextFieldFirstResponder || self.arrayOfCharacters.count == 0) {
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([arrayOfCharacters count] == 0)
    {
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

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [arrayOfCharacters indexOfObject:title] ;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    [searchTextField resignFirstResponder];
}

#pragma mark -
#pragma mark Other Methods
#pragma mark -
#pragma mark Other Methods
/************************************************************************************************************
 @Function Name   : configureTableForPullToRefresh
 @Purpose         : To extend tableview to add pull to refresh and infinite scrolling view
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)configureTableForPullToRefresh
{
    SelectProjectOrTaskViewController *weakSelf = self;
    
    
    //setup pull to refresh widget
    [self.listTableView addPullToRefreshWithActionHandler:^{
        [weakSelf.view setUserInteractionEnabled:NO];
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           [weakSelf.listTableView.pullToRefreshView startAnimating];
                           [weakSelf refreshAction];
                       });
    }];
    
    // setup infinite scrolling
    [self.listTableView addInfiniteScrollingWithActionHandler:^{
        
        [weakSelf.view setUserInteractionEnabled:YES];
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           if ([weakSelf.arrayOfCharacters count]>0) {
                           [weakSelf.listTableView setBottomContentInsetValue: 60.0];
                           NSUInteger sectionCount=[weakSelf.arrayOfCharacters count];
                           NSUInteger rowCount=[(NSMutableArray *)[weakSelf.objectsForCharacters objectForKey:[weakSelf.arrayOfCharacters objectAtIndex:sectionCount-1]] count];
                           NSIndexPath* ipath = [NSIndexPath indexPathForRow: rowCount-1 inSection: sectionCount-1];
                           [weakSelf.listTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionBottom animated: YES];
                           [weakSelf.listTableView.infiniteScrollingView startAnimating];
                           weakSelf.isMoreActionCalled=TRUE;
                           [weakSelf moreAction];
                        }
                           else
                               [weakSelf.listTableView.infiniteScrollingView stopAnimating];
                    });
    }];
    
}

/************************************************************************************************************
 @Function Name   : moreAction
 @Purpose         : To fetch more records of projects or tasks when tableview is scrolled to bottom
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)moreAction
{
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        
	}
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterDataRecieved:)
                                                     name:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION
                                                   object:nil];
        NSString *timesheetUri=self.selectedTimesheetUri;
        NSString *expenseSheetUri=self.selectedExpenseUri;
        if (selectedMode==CLIENT_MODE||selectedMode==PROGRAM_MODE)//DE20024//JUHI //MOBI-746
        {
            if ([entryDelegate isKindOfClass:[TimeEntryViewController class]])
            {
                if (isFromAttendance)
                {
                    [[RepliconServiceManager attendanceService]fetchNextProjectsBasedOnclientsWithSearchText:searchTextField.text withClientUri:self.selectedClientUri andDelegate:self];
                }
                else
                {
                    //MOBI_746
                    if (selectedMode==PROGRAM_MODE)
                    {
                        [[RepliconServiceManager timesheetService]fetchNextProjectsBasedOnProgramsForTimesheetUri:timesheetUri withSearchText:searchTextField.text withProgramUri:self.selectedClientUri andDelegate:self];
                    }
                    else
                    {
                        [[RepliconServiceManager timesheetService]fetchNextProjectsBasedOnclientsForTimesheetUri:timesheetUri withSearchText:searchTextField.text withClientUri:self.selectedClientUri andDelegate:self];
                    }
                    
                }
                
            }
            else if ([entryDelegate isKindOfClass:[ExpenseEntryViewController class]])
            {
                [[RepliconServiceManager expenseService]fetchNextProjectsBasedOnclientsForExpenseSheetUri:expenseSheetUri withSearchText:searchTextField.text withClientUri:self.selectedClientUri andDelegate:self];
            }
            
        }
        else
        {
            if ([entryDelegate isKindOfClass:[TimeEntryViewController class]])
            {
                if (isFromAttendance)
                {
                    [[RepliconServiceManager attendanceService]fetchNextTasksBasedOnProjectsWithSearchText:searchTextField.text withProjectUri:self.selectedProjectUri andDelegate:self];
                }
                else
                {
                    [[RepliconServiceManager timesheetService]fetchNextTasksBasedOnProjectsForTimesheetUri:timesheetUri withSearchText:searchTextField.text withProjectUri:self.selectedProjectUri andDelegate:self];
                }
                
            }
            else if ([entryDelegate isKindOfClass:[ExpenseEntryViewController class]])
            {
                
            }
            
            

        }

        
    }
    
    
    
}

/************************************************************************************************************
 @Function Name   : refreshAction
 @Purpose         : To fetch modified projects or tasks
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)refreshAction
{
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [self.view setUserInteractionEnabled:YES];
        SelectProjectOrTaskViewController *weakSelf = self;
        [weakSelf.listTableView.pullToRefreshView stopAnimating];
        [Util showOfflineAlert];
        return;
	}
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterDataRecieved:)
                                                     name:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION
                                                   object:nil];
        NSString *timesheetUri=self.selectedTimesheetUri;
        NSString *expenseSheetUri=self.selectedExpenseUri;
        if (selectedMode==CLIENT_MODE||selectedMode==PROGRAM_MODE)//DE20024//JUHI //MOBI-746
        {
            if ([entryDelegate isKindOfClass:[TimeEntryViewController class]])
            {
                if (isFromAttendance)
                {
                    [[RepliconServiceManager attendanceService]fetchProjectsBasedOnclientsWithSearchText:searchTextField.text withClientUri:self.selectedClientUri andDelegate:self];
                }
                else
                {
                    //MOBI-746
                    if (selectedMode==PROGRAM_MODE)
                    {
                        [[RepliconServiceManager timesheetService]fetchProjectsBasedOnProgramsForTimesheetUri:timesheetUri withSearchText:searchTextField.text withProgramUri:self.selectedClientUri andDelegate:self];
                    }
                    else
                    {
                        [[RepliconServiceManager timesheetService]fetchProjectsBasedOnclientsForTimesheetUri:timesheetUri withSearchText:searchTextField.text withClientUri:self.selectedClientUri andDelegate:self];
                    }
                    
                }
                
            }
            else if ([entryDelegate isKindOfClass:[ExpenseEntryViewController class]])
            {
                [[RepliconServiceManager expenseService]fetchProjectsBasedOnclientsForExpenseSheetUri:expenseSheetUri withSearchText:searchTextField.text withClientUri:self.selectedClientUri andDelegate:self];
            }
            
        }
        else
        {
            if ([entryDelegate isKindOfClass:[TimeEntryViewController class]])
            {
                if (isFromAttendance)
                {
                    [[RepliconServiceManager attendanceService]fetchTasksBasedOnProjectsWithSearchText:searchTextField.text withProjectUri:self.selectedProjectUri andDelegate:self];
                }
                else
                {
                    [[RepliconServiceManager timesheetService]fetchTasksBasedOnProjectsForTimesheetUri:timesheetUri withSearchText:searchTextField.text withProjectUri:self.selectedProjectUri andDelegate:self];
                }
                
            }
            else if ([entryDelegate isKindOfClass:[ExpenseEntryViewController class]])
            {
                
            }
            
        }

    }
}
/************************************************************************************************************
 @Function Name   : checkToShowMoreButton
 @Purpose         : To check to enable more action or not everytime view appears
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)checkToShowMoreButton
{
    NSNumber *count=nil;
    if (selectedMode==CLIENT_MODE ||selectedMode==PROGRAM_MODE)//DE20024//JUHI //MOBI-746
    {
        count =	[[NSUserDefaults standardUserDefaults]objectForKey:@"projectssDownloadCount"];
    }
    else
    {
        count =	[[NSUserDefaults standardUserDefaults]objectForKey:@"tasksDownloadCount"];
    }
    NSNumber *fetchCount  =    [[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];
    
    if (([count intValue]<[fetchCount intValue]))
    {
		self.listTableView.showsInfiniteScrolling=FALSE;
	}
    else
    {
        self.listTableView.showsInfiniteScrolling=TRUE;
    }

    
}

/************************************************************************************************************
 @Function Name   : refreshTableViewOnConnectionError
 @Purpose         : To refresh tableview on connection error
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)refreshTableViewOnConnectionError
{
    SelectProjectOrTaskViewController *weakSelf = self;
    [weakSelf.listTableView.infiniteScrollingView stopAnimating];
    
    self.listTableView.showsInfiniteScrolling=FALSE;
    self.listTableView.showsInfiniteScrolling=TRUE;
    
}
- (void)fetchProjectsOrTasksWithSearchText
{
    
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
	}
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterDataRecieved:) name:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION object:nil];
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        NSString *timesheetUri=self.selectedTimesheetUri;
        NSString *expenseSheetUri=self.selectedExpenseUri;
        if (selectedMode==CLIENT_MODE ||selectedMode==PROGRAM_MODE)//DE20024//JUHI //MOBI-746
        {
            if ([entryDelegate isKindOfClass:[TimeEntryViewController class]])
            {
               if (isFromAttendance)
                {
                    [[RepliconServiceManager attendanceService]fetchProjectsBasedOnclientsWithSearchText:searchTextField.text withClientUri:self.selectedClientUri andDelegate:self];
                }
                else
                {
                    //MOBI-746
                    if (selectedMode==PROGRAM_MODE)
                    {
                        [[RepliconServiceManager timesheetService]fetchProjectsBasedOnProgramsForTimesheetUri:timesheetUri withSearchText:searchTextField.text withProgramUri:self.selectedClientUri andDelegate:self];
                    }
                    else
                    {
                        [[RepliconServiceManager timesheetService]fetchProjectsBasedOnclientsForTimesheetUri:timesheetUri withSearchText:searchTextField.text withClientUri:self.selectedClientUri andDelegate:self];
                    }
                    
                }
                
            }
            else if ([entryDelegate isKindOfClass:[ExpenseEntryViewController class]])
            {
                [[RepliconServiceManager expenseService]fetchProjectsBasedOnclientsForExpenseSheetUri:expenseSheetUri withSearchText:searchTextField.text withClientUri:self.selectedClientUri andDelegate:self];
            }
            
        }
        else
        {
            if ([entryDelegate isKindOfClass:[TimeEntryViewController class]])
            {
               if (isFromAttendance)
                {
                    [[RepliconServiceManager attendanceService]fetchTasksBasedOnProjectsWithSearchText:searchTextField.text withProjectUri:self.selectedProjectUri andDelegate:self];
                }
                else
                {
                    [[RepliconServiceManager timesheetService]fetchTasksBasedOnProjectsForTimesheetUri:timesheetUri withSearchText:searchTextField.text withProjectUri:self.selectedProjectUri andDelegate:self];
                }
                
            }
            else if ([entryDelegate isKindOfClass:[ExpenseEntryViewController class]])
            {
                
            }
            
        }
        
        
    }
    
    
    
    [self.searchTimer invalidate];
}

-(void)cancelAction:(id)sender
{
    self.isTextFieldFirstResponder=NO;
    if ([entryDelegate isKindOfClass:[TimeEntryViewController class]])
    {
        for (UIView *view in self.view.subviews)
        {
            
            if ([view isKindOfClass:[CustomSelectedView class]])
            {
                
                    float yOffset=0.0;
                    if ([view tag]==0)
                    {
                        yOffset=0;
                    }
                    else if ([view tag]==1)
                    {
                        [[view viewWithTag:1] removeFromSuperview];
                        
                        searchTextField.placeholder=RPLocalizedString(SEARCHBAR_PROJECT_PLACEHOLDER,@"");
                        
                        if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
                        {
                            [Util setToolbarLabel:delegate withText:RPLocalizedString(ADD_PROJECT, @"") ];
                        }
                        else
                        {
                            [Util setToolbarLabel:self withText:RPLocalizedString(ADD_PROJECT, @"") ];
                        }
                        
                        
                        
                        if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
                        {
                            [delegate navigationItem].rightBarButtonItem=nil;
                            
                        }
                        else
                        {
                            [self navigationItem].rightBarButtonItem=nil;
                        }

                    }
                    CGRect frame=view.frame;
                    frame.origin.y=view.frame.origin.y-yOffset;
                    view.frame=frame;
                
                

                
                
            }
        }
        
        NSLog(@"1:::%@",currentSelectedItem);
        
                
        if (selectedMode==CLIENT_MODE||selectedMode==PROGRAM_MODE)//DE20024//JUHI MOBI-746
        {
            [self.navigationController popViewControllerAnimated:NO];
            return;
        }
        else if(selectedMode==PROJECT_MODE)
        {
            if (self.selectedClientUri==nil ||[self.selectedClientUri isKindOfClass:[NSNull class]]||[self.selectedClientUri isEqualToString:@""])
            {
                [self.navigationController popViewControllerAnimated:NO];
                return;
            }
            else if (self.directlyFromProjectTab)
            {
                [self.navigationController popViewControllerAnimated:NO];
                return;
            }
            self.currentSelectedItem=RPLocalizedString(Client, @"");
            selectedMode=CLIENT_MODE;
            self.isPreFilledSearchString=NO;
            self.searchProjectString=nil;
            self.searchTextField.text=@"";
            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
            [defaults setObject:self.searchTextField.text forKey:@"SearchString"];
            [defaults synchronize];
            
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
             [self fetchProjectsOrTasksWithSearchText];
        }

        
      
    }
    else if ([entryDelegate isKindOfClass:[ExpenseEntryViewController class]])
    {
        ExpenseEntryViewController *entryVC=(ExpenseEntryViewController *)entryDelegate;
        [self.navigationController popToViewController:entryVC animated:YES];
    }
    

    
    
}
-(void)addCustomViewWithTag:(int)tag
{
   
    CustomSelectedView *customView=[[CustomSelectedView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, customView_Height) andTag:tag];
    
     customView.deleteBtn.hidden=FALSE;
    
    // THIS IS FOR TASK ROW SELECTION IN TIME ENTRY VIEW CONTROLLER
    
    if(isFromTaskRowSelection)
    {
        customView.deleteBtn.hidden=TRUE;
    }
    
    
    if (selectedMode==CLIENT_MODE ||selectedMode==PROGRAM_MODE)//DE20024//JUHI MOBI-746
    {
        //Implementation for US8849//JUHI
        if (selectedMode==PROGRAM_MODE)
        {
            customView.fieldName.text=[NSString stringWithFormat:@"%@ : %@",RPLocalizedString(Program, @""),selectedValue] ;//MOBI-746
        }
        else
        {
          customView.fieldName.text=[NSString stringWithFormat:@"%@ : %@",RPLocalizedString(Client, @""),selectedValue] ;
        }
        
        customView.delegate=self;
        client=selectedValue; //JUHI
        [self.view addSubview:customView];
        
        CGRect frame=self.listTableView.frame;
        frame.origin.y=self.listTableView.frame.origin.y+customView_Height*tag;
        frame.size.height=frame.size.height-tabBar_Height-navBar_Height;
        self.listTableView.frame=frame;
        searchTextField.placeholder=RPLocalizedString(SEARCHBAR_PROJECT_PLACEHOLDER,@"");
     
        UIBarButtonItem *temprightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(@"Skip", @"") style:UIBarButtonItemStylePlain
                                                                                  target:self action:@selector(skipAction:)];
        
        if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
        {
            //[delegate navigationItem].rightBarButtonItem=nil;
            if (self.isTimeAllowedPermission)
            {
                [[delegate navigationItem ] setRightBarButtonItem:temprightButtonOuterBtn animated:NO];
            }
            else
            {
                [delegate navigationItem].rightBarButtonItem=nil;
            }
        
            
        }
        else
        {
            if (self.isTimeAllowedPermission)
            {
                [[self navigationItem ] setRightBarButtonItem:temprightButtonOuterBtn animated:NO];
            }
            else
            {
                [[self navigationItem ] setRightBarButtonItem:nil animated:NO];
            }
            
        }
        if (self.isTimeAllowedPermission)
        {
            temprightButtonOuterBtn.enabled=YES;
        }
        else
            temprightButtonOuterBtn.enabled=NO;
        
       
        [self setupListData];
    }
    else if (currentSelectedItem!=nil && [currentSelectedItem isEqualToString:RPLocalizedString(Project, @"")])
    {
         //JUHI
        self.project=selectedValue;
        if (self.isTaskPermission)
        {//Implementation for US8849//JUHI
            customView.fieldName.text=[NSString stringWithFormat:@"%@ : %@ ",RPLocalizedString(Project, @""),selectedValue] ;
            customView.delegate=self;
            
            [self.view addSubview:customView];
            
            searchTextField.placeholder=RPLocalizedString(SEARCHBAR_TASK_PLACEHOLDER,@"");
            
            if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
            {
                [Util setToolbarLabel:delegate withText:RPLocalizedString(ADD_TASK, @"") ];
            }
            else
            {
                [Util setToolbarLabel:self withText:RPLocalizedString(ADD_TASK, @"") ];
            }
            

            UIBarButtonItem *temprightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(@"Skip", @"") style:UIBarButtonItemStylePlain
                                                                                      target:self action:@selector(skipAction:)];
            
            if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
            {
                //[delegate navigationItem].rightBarButtonItem=nil;
                if (self.isTimeAllowedPermission)
                {
                    [[delegate navigationItem ] setRightBarButtonItem:temprightButtonOuterBtn animated:NO];
                }
                else
                {
                    [[delegate navigationItem ] setRightBarButtonItem:nil animated:NO];
                }
                
                
            }
            else
            {
                if (self.isTimeAllowedPermission)
                {
                    [[self navigationItem ] setRightBarButtonItem:temprightButtonOuterBtn animated:NO];
                }
                else
                {
                    [[self navigationItem ] setRightBarButtonItem:nil animated:NO];
                }
                 
            }
            if (self.isTimeAllowedPermission)
            {
                temprightButtonOuterBtn.enabled=YES;
            }
            else
                temprightButtonOuterBtn.enabled=NO;
            
 

            [self setupListData];
        }
        else{
           
            if (entryDelegate != nil && ![entryDelegate isKindOfClass:[NSNull class]] &&
                [entryDelegate conformsToProtocol:@protocol(UpdateEntryProjectAndTaskFieldProtocol)])
            {
                [entryDelegate updateFieldWithClient:client clientUri:selectedClientUri project:project projectUri:selectedProjectUri task:task andTaskUri:selectedTaskUri taskPermission: self.isTaskPermission timeAllowedPermission:self.isTimeAllowedPermission];
            }
            
            if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
            {
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            }
            else
            {
                 self.isForNoTaskDismiss=TRUE;
                
                if (self.isLoadedOnce)
                {
                     [self.navigationController popToViewController:(TimeEntryViewController *)entryDelegate animated:FALSE];
                }

               
            }
            
        
        }
    }
    else
    {
        customView.fieldName.text=RPLocalizedString(Task, @"");
        task=selectedValue; //JUHI
        searchTextField.placeholder=RPLocalizedString(SEARCHBAR_TASK_PLACEHOLDER,@"");
        if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
        {
            [Util setToolbarLabel:delegate withText:RPLocalizedString(ADD_TASK, @"") ];
        }
        else
        {
            [Util setToolbarLabel:self withText:RPLocalizedString(ADD_TASK, @"") ];
        }
 
 
        UIBarButtonItem *temprightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(@"Skip", @"") style:UIBarButtonItemStylePlain
                                                                                  target:self action:@selector(skipAction:)];
        
        if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
        {
            //[delegate navigationItem].rightBarButtonItem=nil;
            [[delegate navigationItem ] setRightBarButtonItem:temprightButtonOuterBtn animated:NO];
            
        }
        else
        {
            [[self navigationItem ] setRightBarButtonItem:temprightButtonOuterBtn animated:NO];
        }
        
        if (self.isTimeAllowedPermission)
        {
            temprightButtonOuterBtn.enabled=YES;
        }
        else
            temprightButtonOuterBtn.enabled=NO;
        
        
        
    }
   
    
    BOOL shouldDismissViewController=NO;
    if (tag==2)
    {
        shouldDismissViewController=YES;
    }
    if (shouldDismissViewController==YES)
    {
        //JUHI
        if (entryDelegate != nil && ![entryDelegate isKindOfClass:[NSNull class]] &&
            [entryDelegate conformsToProtocol:@protocol(UpdateEntryProjectAndTaskFieldProtocol)])
        {
            
            NSString *formattedTaskName=task;
            if (selectedPath!=nil && ![selectedPath isKindOfClass:[NSNull class]] && ![selectedPath isEqualToString:@""])
            {
                formattedTaskName=[selectedPath stringByAppendingString:task];
            }
           
            
            [entryDelegate updateFieldWithClient:client clientUri:selectedClientUri project:project projectUri:selectedProjectUri task:formattedTaskName andTaskUri:selectedTaskUri taskPermission: self.isTaskPermission timeAllowedPermission:self.isTimeAllowedPermission];
        }
        if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }
        else
        {
            if(selectedProjectUri!=nil && ![selectedProjectUri isKindOfClass:[NSNull class]] && ![selectedProjectUri isEqualToString:NULL_STRING])
            {
                [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self name:DEFAULT_BILLING_RECEIVED_NOTIFICATION object:nil];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDataForDefaultBilling:)
                                                             name:DEFAULT_BILLING_RECEIVED_NOTIFICATION
                                                           object:nil];
                
                [[RepliconServiceManager timesheetService]fetchDefaultBillingRateBasedOnProjectForTimesheetUri:self.selectedTimesheetUri withSearchText:@"" withProjectUri:selectedProjectUri taskUri:selectedTaskUri andDelegate:self];
            }
            
            else
            {
                [self.navigationController popToViewController:(TimeEntryViewController *)entryDelegate animated:FALSE];
            }
            
        }
    }
    
}
- (void)removeCustomView:(id)sender
{
    
    for (UIView *view in self.view.subviews)
    {
        
        if ([view isKindOfClass:[CustomSelectedView class]])
        {
            if ([view tag]==[sender tag]) {
                [[view viewWithTag:[sender tag]] removeFromSuperview];
            }
            else
            {
                float yOffset=0.0;
                if ([sender tag]==0) {
                    yOffset=customView_Height*([sender tag]+1);
                }
                else
                {
                    yOffset=customView_Height*([sender tag]-1);
                }
                CGRect frame=view.frame;
                frame.origin.y=view.frame.origin.y-yOffset;
                view.frame=frame;
            }
            
        }
    }
    
    BOOL customViewPresent=NO;
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[CustomSelectedView class]])
        {
            customViewPresent=YES;
        }
    }
    
    if (customViewPresent==NO)
    {
        [self.navigationController popViewControllerAnimated:NO];
        return;
    }

    if ([sender tag]==0)
    {
         self.currentSelectedItem=RPLocalizedString(Project,@"");//Implementation for US8902//JUHI
        searchTextField.placeholder=RPLocalizedString(SEARCHBAR_TASK_PLACEHOLDER,@"");
        
    }
    else
    {
        self.currentSelectedItem=RPLocalizedString(Client,@"");//Implementation for US8902//JUHI
        searchTextField.placeholder=RPLocalizedString(SEARCHBAR_PROJECT_PLACEHOLDER,@"");
        
        if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
        {
             [Util setToolbarLabel:delegate withText:RPLocalizedString(ADD_PROJECT, @"") ];
        }
        else
        {
              [Util setToolbarLabel:self withText:RPLocalizedString(ADD_PROJECT, @"") ];
        }
        
      
        
        if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
        {
            [delegate navigationItem].rightBarButtonItem=nil;
            
        }
        else
        {
            [self navigationItem].rightBarButtonItem=nil;
        }
            
    }
    
    self.isPreFilledSearchString=NO;
    self.searchProjectString=nil;
    self.searchTextField.text=@"";
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:self.searchTextField.text forKey:@"SearchString"];
    [defaults synchronize];

    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    
    [self fetchProjectsOrTasksWithSearchText];
}

- (void) doneSearching_Clicked:(id)sender
{
    [searchTextField resignFirstResponder];
    self.listTableView.scrollEnabled = YES;
	/*[ovController.view removeFromSuperview];
	
	ovController = nil;*/
}

-(void)skipAction:(id)sender
{
    if (entryDelegate != nil && ![entryDelegate isKindOfClass:[NSNull class]] &&
        [entryDelegate conformsToProtocol:@protocol(UpdateEntryProjectAndTaskFieldProtocol)])
    {
        [entryDelegate updateFieldWithClient:client clientUri:selectedClientUri project:project projectUri:selectedProjectUri task:task andTaskUri:selectedTaskUri taskPermission: self.isTaskPermission timeAllowedPermission:self.isTimeAllowedPermission];
    }
    if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
    else
    {
        
        if(selectedProjectUri!=nil && ![selectedProjectUri isKindOfClass:[NSNull class]] && ![selectedProjectUri isEqualToString:NULL_STRING])
        {
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:DEFAULT_BILLING_RECEIVED_NOTIFICATION object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDataForDefaultBilling:)
                                                         name:DEFAULT_BILLING_RECEIVED_NOTIFICATION
                                                       object:nil];
            
            [[RepliconServiceManager timesheetService]fetchDefaultBillingRateBasedOnProjectForTimesheetUri:self.selectedTimesheetUri withSearchText:@"" withProjectUri:selectedProjectUri taskUri:selectedTaskUri andDelegate:self];
        }
        
        else
        {
            [self.navigationController popToViewController:(TimeEntryViewController *)entryDelegate animated:FALSE];
        }
        
       
    }
    
    
}

- (void)refreshViewAfterDataRecieved:(NSNotification *)notificationObject
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION object:nil];
    [self.view setUserInteractionEnabled:YES];
    SelectProjectOrTaskViewController *weakSelf = self;
    if(!self.isMoreActionCalled)
    {
        [weakSelf.listTableView.pullToRefreshView stopAnimating];
    }
    self.isMoreActionCalled=FALSE;
    [weakSelf.listTableView.infiniteScrollingView stopAnimating];
    self.listTableView.showsInfiniteScrolling=TRUE;
    
    self.listTableView.scrollEnabled = YES;
    /*[ovController.view removeFromSuperview];
	
	ovController = nil;*/
    
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    
    NSDictionary *theData = [notificationObject userInfo];
    NSNumber *n = [theData objectForKey:@"isErrorOccured"];
    BOOL isErrorOccured = [n boolValue];
    if (isErrorOccured)
    {
        self.listTableView.showsInfiniteScrolling=FALSE;
    }
    else
    {
        [self checkToShowMoreButton];
        [self setupListData];
    }

    [self.listTableView setBottomContentInsetValue:0.0];
    
}
- (void)setupListData
{
    [listOfItems removeAllObjects];
    [arrayOfCharacters removeAllObjects];
    [objectsForCharacters removeAllObjects];
    
    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    ExpenseModel *expenseModel=[[ExpenseModel alloc]init];
    
    NSString *key=@"";
    if (selectedMode==CLIENT_MODE||selectedMode==PROGRAM_MODE)//DE20024//JUHI //MOBI-746
    {
        
        key=@"projectName";
        if ([entryDelegate isKindOfClass:[TimeEntryViewController class]])
        {
             self.listOfItems=[timesheetModel getAllProjectsDetailsFromDBForModule:@"Timesheet"];
        }
        else if ([entryDelegate isKindOfClass:[ExpenseEntryViewController class]])
        {
            self.listOfItems=[expenseModel getAllProjectsDetailsFromDBForModule:@"Expense"];
        }
       
        
        
    }
    else
    {
        key=@"taskName";
        if ([entryDelegate isKindOfClass:[TimeEntryViewController class]])
        {
            self.listOfItems=[timesheetModel getAllTasksDetailsFromDBForModule:@"Timesheet"];
            if (self.isTimeAllowedPermission)
            {
               NSDictionary *noneTaskDict= [NSDictionary dictionaryWithObjectsAndKeys:
                 RPLocalizedString(NONE_STRING, NONE_STRING),@"taskName",
                 @"null",@"taskUri",
                 @"",@"taskFullPath",
                 [NSNull null],@"startDate",
                 [NSNull null],@"endDate",
                 TIMESHEET_MODULE_NAME,@"moduleName",
                 nil];
                
                
                [self.listOfItems addObject:noneTaskDict];
            }
        }
        else if ([entryDelegate isKindOfClass:[ExpenseEntryViewController class]])
        {
            
        }
                
        
    }
    
    if (!isTextFieldFirstResponder)
    {
        NSSortDescriptor * brandDescriptor =[[NSSortDescriptor alloc] initWithKey:key ascending:YES comparator:^(id firstDocumentName, id secondDocumentName)
                                             {
                                                 static NSStringCompareOptions comparisonOptions =
                                                 NSCaseInsensitiveSearch | NSNumericSearch |
                                                 NSWidthInsensitiveSearch | NSForcedOrderingSearch;
                                                 return [firstDocumentName compare:secondDocumentName options:comparisonOptions];
                                             }];
        NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:brandDescriptor];
        
        NSArray *array = [listOfItems sortedArrayUsingDescriptors:sortDescriptors];
        self.listOfItems=[NSMutableArray arrayWithArray:array];
    }

    
    [self setupIndexDataBasedOnSectionAlphabets];
    
}

- (void)setupIndexDataBasedOnSectionAlphabets
{
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSMutableArray *arrayOfNames = [[NSMutableArray alloc] init];
    
    NSString *numbericSection    = @"#";
    NSString *firstLetter;
    NSString *name;
    
    for (NSDictionary *item in self.listOfItems)
    {
        NSDictionary *listOfitemDict=item;
        NSArray *allKeys=[listOfitemDict allKeys];
        TaskObject *taskObject=[[TaskObject alloc]init];
        ProjectObject *projectObject=[[ProjectObject alloc]init];
        for (NSString *tmpKey in allKeys)
        {
            if (selectedMode==CLIENT_MODE||selectedMode==PROGRAM_MODE)//DE20024//JUHI //MOBI-746
            {
                //Implementation for US8849//JUHI
                if ([tmpKey isEqualToString:@"projectName"])
                {
                    projectObject.projectName=[listOfitemDict objectForKey:tmpKey];
                }
                else if ([tmpKey isEqualToString:@"projectUri"])
                {
                    projectObject.projectUri=[listOfitemDict objectForKey:tmpKey];
                }
                else if ([tmpKey isEqualToString:@"clientName"])
                {
                    projectObject.clientName=[listOfitemDict objectForKey:tmpKey];
                }
                else if ([tmpKey isEqualToString:@"clientUri"])
                {
                    projectObject.clientUri=[listOfitemDict objectForKey:tmpKey];
                }
                
                else if ([tmpKey isEqualToString:@"isTimeAllocationAllowed"])
                {
                    NSString *tmpStr=[listOfitemDict objectForKey:tmpKey];
                    if (tmpStr!=nil &&![tmpStr isKindOfClass:[NSNull class]])
                    {
                        projectObject.isTimeAllocationAllowed=[[listOfitemDict objectForKey:tmpKey] boolValue];
                    }
                    
                }
                else if ([tmpKey isEqualToString:@"hasTasksAvailableForTimeAllocation"])
                {
                    NSString *tmpStr=[listOfitemDict objectForKey:tmpKey];
                    if (tmpStr!=nil &&![tmpStr isKindOfClass:[NSNull class]])
                    {
                        projectObject.hasTasksAvailableForTimeAllocation=[[listOfitemDict objectForKey:tmpKey] boolValue];
                    }
                    
                }

                
            }
            else
            {
                //Implementation for US8849//JUHI
                if ([tmpKey isEqualToString:@"taskName"])
                {
                    taskObject.taskName=[listOfitemDict objectForKey:tmpKey];
                }
                else if ([tmpKey isEqualToString:@"taskUri"])
                {
                    taskObject.taskUri=[listOfitemDict objectForKey:tmpKey];
                }
                else if ([tmpKey isEqualToString:@"taskFullPath"])
                {
                    taskObject.taskFullPath=[NSString stringWithFormat:@"%@",[listOfitemDict objectForKey:tmpKey]];
                }
                                
            }
            
            
        }

        NSString *key=@"";
        if (selectedMode==CLIENT_MODE||selectedMode==PROGRAM_MODE)//DE20024//JUHI //MOBI-746
        {
            key=@"projectName";
        }
        else
        {
            key=@"taskName";
        }
        name=[[listOfitemDict objectForKey:key] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        firstLetter = [[name substringToIndex:1] uppercaseString];
        
        NSData *data = [firstLetter dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *newStrfirstLetter = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        
        // Check if it's NOT a number
        NSString *accepatable=[NSString stringWithFormat:@"%@",ACCEPTABLE_CHARACTERS_SECTION_TABLEVIEW];
        
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
            
            
            if (selectedMode==CLIENT_MODE||selectedMode==PROGRAM_MODE)//DE20024//JUHI //MOBI_746
            {
                [arrayOfNames addObject:projectObject];
            }
            else
            {
                [arrayOfNames addObject:taskObject];
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
            
            if (selectedMode==CLIENT_MODE||selectedMode==PROGRAM_MODE)//DE20024//JUHI //MOBI-746
            {
                [arrayOfNames addObject:projectObject];
            }
            else
            {
                [arrayOfNames addObject:taskObject];
            }

            
            [self.objectsForCharacters setObject:[arrayOfNames copy] forKey:numbericSection];
        }
       
    }
    
    
    
    [self.listTableView reloadData];
}


#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.searchTextField=nil;
    self.listTableView=nil;
    
}


-(void)receivedDataForDefaultBilling:(NSNotification *)notificationObject
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DEFAULT_BILLING_RECEIVED_NOTIFICATION object:nil];
    
    NSDictionary *billingDict = [notificationObject userInfo];
    
    if ([entryDelegate isKindOfClass:[TimeEntryViewController class]])
    {
        TimeEntryViewController *timeEntryViewController=(TimeEntryViewController *)entryDelegate;
        if (billingDict!=nil)
        {
            [timeEntryViewController.timesheetObject setBillingName:[billingDict objectForKey:@"billingName"]];
            [timeEntryViewController.timesheetObject setBillingIdentity:[billingDict objectForKey:@"billingUri"]];
        }
        else
        {
            [timeEntryViewController.timesheetObject setBillingName:nil];
            [timeEntryViewController.timesheetObject setBillingIdentity:nil];
        }
        
        if(timeEntryViewController.isProjectAccess && timeEntryViewController.isBillingAccess)
        {
            NSIndexPath *billingPath=[NSIndexPath indexPathForRow:1 inSection:0];
            CurrentTimeSheetsCellView *billingselectedCell = (CurrentTimeSheetsCellView *)[timeEntryViewController.timeEntryTableView cellForRowAtIndexPath:billingPath];
            if (selectedProjectUri!=nil && ![selectedProjectUri isKindOfClass:[NSNull class]] && ![selectedProjectUri isEqualToString:NULL_STRING])
            {
                [billingselectedCell setUserInteractionEnabled:YES];
                [[billingselectedCell rightLb]setTextColor:RepliconStandardBlackColor];
            }
            else
            {
                [billingselectedCell setUserInteractionEnabled:NO];
                [[billingselectedCell rightLb]setTextColor:RepliconStandardGrayColor];
            }
            
            
            EntryCellDetails *billingDetailsObj=(EntryCellDetails *)[timeEntryViewController.timeEntryArray objectAtIndex:billingPath.row+1];
            if (billingDict!=nil)
            {
                [billingDetailsObj setFieldValue:[billingDict objectForKey:@"billingName"]];
                [[billingselectedCell rightLb]setText:[billingDict objectForKey:@"billingName"]];
            }
            else
            {
                [billingDetailsObj setFieldValue:RPLocalizedString(NOT_BILLABLE, NOT_BILLABLE)];
                [[billingselectedCell rightLb]setText:[billingDetailsObj fieldValue]];
            }
           
            
            NSIndexPath *tmpIndexpath=[NSIndexPath indexPathForRow:1 inSection:0];
            [timeEntryViewController.timeEntryTableView beginUpdates];
            [timeEntryViewController.timeEntryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:tmpIndexpath,nil] withRowAnimation:UITableViewRowAnimationFade];
            
            [timeEntryViewController.timeEntryTableView endUpdates];
        }
        
        
        [self.navigationController popToViewController:(TimeEntryViewController *)entryDelegate animated:FALSE];
       
    
    }

    
    
    
    

}

-(void)dealloc
{
    self.listTableView.delegate = nil;
    self.listTableView.dataSource = nil;
}


@end
