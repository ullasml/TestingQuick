//
//  UdfDropDownViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 25/01/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "UdfDropDownViewController.h"
#import "UdfObject.h"
#import "RepliconServiceManager.h"
#import "UdfDropDownView.h"
#import "LoginModel.h"
#import "DropDownOption.h"
#import "FrameworkImport.h"
#import "SVPullToRefresh.h"
#import "RepliconServiceManager.h"
#import "TimesheetListObject.h"

#define ACCEPTABLE_CHARACTERS @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

@interface UdfDropDownViewController ()
@property(nonatomic,strong)UdfDropDownView *udfDropDownView;
@property(nonatomic,strong)NSMutableArray *dropDownOptionList;
@property(nonatomic,strong)NSMutableArray *arrayOfCharacters;
@property(nonatomic,strong)NSMutableDictionary *objectsForCharacters;
@property(nonatomic,strong)UdfObject *udfObject;
@property(nonatomic,strong)TimesheetListObject *timesheetListObject;
@end

@implementation UdfDropDownViewController

- (void)loadView {
    [super loadView];
    
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [Util setToolbarLabel: self withText: RPLocalizedString(DropDownOptionTilte, DropDownOptionTilte)] ;
    self.udfDropDownView = [[UdfDropDownView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.udfDropDownView setUdfDropDownViewDelegate:self.delegate];
    [self.udfDropDownView setUdfDropDownNavigationDelegate:self];
    self.view = self.udfDropDownView;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DROPDOWN_OPTION_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DROPDOWN_NEXT_OPTION_RECEIVED_NOTIFICATION object:nil];
}
-(void)intialiseDropDownViewWithUdfObject:(UdfObject *)udfEntryObject withNaviagtion:(NavigationFlow)navigationFlow withTimesheetListObject:(TimesheetListObject *)timesheetListObject withTimeOffObj:(TimeOffObject *)timeOffObj
{
    [self setTimesheetListObject:timesheetListObject];
    [self setUdfObject:udfEntryObject];
    self.dropDownOptionList=[NSMutableArray array];
    self.arrayOfCharacters=[NSMutableArray array];
    self.objectsForCharacters=[NSMutableDictionary dictionary];
    ;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DROPDOWN_OPTION_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createDropDownOptionList)
                                                 name:DROPDOWN_OPTION_RECEIVED_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:SHOW_TRANSPARENT_LOADING_OVERLAY_NOTIFICATION object:nil];
    [[RepliconServiceManager loginService]sendrequestToDropDownOptionForDropDownUri:[udfEntryObject udfUri] WithDelegate:self];
    BOOL isNonEditable=[[self.timesheetListObject timesheetStatus] isEqualToString:APPROVED_STATUS ]||[[self.timesheetListObject timesheetStatus] isEqualToString:WAITING_FOR_APRROVAL_STATUS ];
    if (!isNonEditable)
    {
        UIBarButtonItem *tempLeftButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(CANCEL_STRING, @"")
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self action:@selector(cancelAction:)];
        [self navigationItem].rightBarButtonItem=nil;
        [[self navigationItem ] setLeftBarButtonItem:tempLeftButtonOuterBtn animated:NO];
    }
    
}

-(void)cancelAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)createDropDownOptionList{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DROPDOWN_OPTION_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:HIDE_TRANSPARENT_LOADING_OVERLAY_NOTIFICATION object:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self _setupListData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.udfDropDownView setUpDropDownViewWithDropdownArray:self.dropDownOptionList withArrayOfCharacters:self.arrayOfCharacters withObjectsForCharacters:self.objectsForCharacters withUdfObject:self.udfObject withTimesheetListObject:self.timesheetListObject];
        });
    });
}

- (void)_setupListData
{
    [self.dropDownOptionList removeAllObjects];
    [self.arrayOfCharacters removeAllObjects];
    [self.objectsForCharacters removeAllObjects];
    
    LoginModel *loginModel=[[LoginModel alloc]init];
    self.dropDownOptionList=[loginModel getDropDownOptionsFromDatabase];
    NSString *key=@"name";
    if ([self.dropDownOptionList count]>0)
    {
        NSSortDescriptor * brandDescriptor =[[NSSortDescriptor alloc] initWithKey:key ascending:YES comparator:^(id firstDocumentName, id secondDocumentName) {
            static NSStringCompareOptions comparisonOptions =NSCaseInsensitiveSearch | NSNumericSearch |NSWidthInsensitiveSearch | NSForcedOrderingSearch;
            return [firstDocumentName compare:secondDocumentName options:comparisonOptions];
            
        }];
        NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:brandDescriptor];
        NSArray *array = [self.dropDownOptionList sortedArrayUsingDescriptors:sortDescriptors];
        self.dropDownOptionList=[NSMutableArray arrayWithArray:array];
        
    }
    [self _setupIndexDataBasedOnSectionAlphabets];
    
    
}
- (void)_setupIndexDataBasedOnSectionAlphabets
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSMutableArray *arrayOfNames = [[NSMutableArray alloc] init];
    NSMutableArray *arrayOfNamesForNumeric=[[NSMutableArray alloc] init];
    NSString *numbericSection    = @"#";
    NSString *firstLetter;
    NSString *name;
    
    for (NSDictionary *item in self.dropDownOptionList) {
        NSDictionary *listOfitemDict=item;
        NSArray *allKeys=[listOfitemDict allKeys];
        DropDownOption *dropDownOptionObject=[[DropDownOption alloc]init];
        
        for (NSString *tmpKey in allKeys)
        {
            
            if ([tmpKey isEqualToString:@"name"])
            {
                dropDownOptionObject.dropDownOptionName=[listOfitemDict objectForKey:tmpKey];
            }
            else if ([tmpKey isEqualToString:@"uri"])
            {
                dropDownOptionObject.dropDownOptionUri=[listOfitemDict objectForKey:tmpKey];
            }
            
        }
        NSString *key=@"name";
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
                [arrayOfNamesForNumeric removeAllObjects];
                [self.arrayOfCharacters addObject:numbericSection];
            }
            [arrayOfNamesForNumeric addObject:dropDownOptionObject];
            [self.objectsForCharacters setObject:[arrayOfNamesForNumeric copy] forKey:numbericSection];
        }
        
        
    }
}

#pragma mark Pull To Refresh/ More action
/************************************************************************************************************
 @Function Name   : udfDropDownView_selectedIndexPath
 @Purpose         : To pop view controller
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
- (void)udfDropDownView:(UdfDropDownView *)udfDropDownView selectedIndexPath:(NSIndexPath *)indexpath
{
    [self.navigationController popViewControllerAnimated:YES];
}

/************************************************************************************************************
 @Function Name   : refreshAction_From_udfDropDownView
 @Purpose         : To fetch modified records of Udf Dropdown
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
- (void)udfDropDownView:(UdfDropDownView *)udfDropDownView refreshAction:(id)sender
{
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [self.view setUserInteractionEnabled:YES];
        UdfDropDownViewController *weakSelf = self;
        [weakSelf.udfDropDownView.pullToRefreshView stopAnimating];
        [Util showOfflineAlert];
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DROPDOWN_OPTION_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterPullToRefreshAction:)
                                                 name:DROPDOWN_OPTION_RECEIVED_NOTIFICATION
                                               object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    [[RepliconServiceManager loginService]sendrequestToDropDownOptionForDropDownUri:self.udfObject.udfUri WithDelegate:self];
}
/************************************************************************************************************
 @Function Name   : moreAction_From_udfDropDownView
 @Purpose         : To fetch more records of Udf Dropdown
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
- (void)udfDropDownView:(UdfDropDownView *)udfDropDownView moreAction:(id)sender;
{
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        UdfDropDownViewController *weakSelf = self;
        [weakSelf.udfDropDownView.infiniteScrollingView stopAnimating];
        self.udfDropDownView.showsInfiniteScrolling=TRUE;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DROPDOWN_NEXT_OPTION_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterMoreAction:) name:DROPDOWN_NEXT_OPTION_RECEIVED_NOTIFICATION object:nil];
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    [[RepliconServiceManager loginService]sendrequestForNextDropDownOptionForDropDownUri:self.udfObject.udfUri WithDelegate:self];
    
}

/************************************************************************************************************
 @Function Name   : pullToRefresh_DataRecieved_callback_from_service
 @Purpose         : To let controller handle removal of observers and let udfDropDownView handle UI
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)refreshViewAfterPullToRefreshAction:(NSNotification *)notificationObject
{
    [self.view setUserInteractionEnabled:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DROPDOWN_OPTION_RECEIVED_NOTIFICATION object:nil];
    UdfDropDownViewController *weakSelf = self;
    [weakSelf.udfDropDownView.pullToRefreshView stopAnimating];
    self.udfDropDownView.showsInfiniteScrolling=TRUE;
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    NSDictionary *theData = [notificationObject userInfo];
    NSNumber *n = [theData objectForKey:@"isErrorOccured"];
    BOOL isErrorOccured = [n boolValue];
    if (!isErrorOccured)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self _setupListData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.udfDropDownView setUpDropDownViewWithDropdownArray:self.dropDownOptionList withArrayOfCharacters:self.arrayOfCharacters withObjectsForCharacters:self.objectsForCharacters withUdfObject:self.udfObject withTimesheetListObject:self.timesheetListObject];
            });
        });
    }
    [self.udfDropDownView setBottomContentInsetValue:0.0];
    
}

/************************************************************************************************************
 @Function Name   : moreActionDataRecieved_callback_from_service
 @Purpose         : To let controller handle removal of observers and let udfDropDownView handle UI
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
-(void)refreshViewAfterMoreAction:(NSNotification *)notificationObject
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DROPDOWN_NEXT_OPTION_RECEIVED_NOTIFICATION object:nil];
    [self.view setUserInteractionEnabled:YES];
    UdfDropDownViewController *weakSelf = self;
    [weakSelf.udfDropDownView.infiniteScrollingView stopAnimating];
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    NSDictionary *theData = [notificationObject userInfo];
    NSNumber *n = [theData objectForKey:@"isErrorOccured"];
    BOOL isErrorOccured = [n boolValue];
    if (isErrorOccured)
    {
        self.udfDropDownView.showsInfiniteScrolling=FALSE;
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self _setupListData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.udfDropDownView setUpDropDownViewWithDropdownArray:self.dropDownOptionList withArrayOfCharacters:self.arrayOfCharacters withObjectsForCharacters:self.objectsForCharacters withUdfObject:self.udfObject withTimesheetListObject:self.timesheetListObject];
            });
        });
    }
    [self.udfDropDownView setBottomContentInsetValue:0.0];
}


@end
