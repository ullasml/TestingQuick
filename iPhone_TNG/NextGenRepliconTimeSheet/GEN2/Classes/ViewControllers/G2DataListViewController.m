//
//  ProjectsAndClientsListViewController.m
//  Replicon
//
//  Created by Dipta Rakshit on 7/6/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2DataListViewController.h"
#import "G2ViewUtil.h"
#import "G2Constants.h"
#import "G2OverlayViewController.h"
#import "G2Util.h"
#import "G2TimeEntryViewController.h"
#import "G2AddNewExpenseViewController.h"
#import "G2EditExpenseEntryViewController.h"
#import "G2RepliconServiceManager.h"
#import "UISegmentedControlExtension.h"


#define kTagFirst 111
#define kTagSecond 112
#define RECENT_VIEW_TAG 0
#define ALL_VIEW_TAG 1

@interface G2DataListViewController(PrivateMethods)
-(void)segmentChanged:(id)sender;
-(void)setTextColorsForSegmentedControl:(UISegmentedControl*)segmented;
@end

@implementation G2DataListViewController
@synthesize mainTableView;
@synthesize titleStr;
@synthesize listOfItems;
@synthesize listOfItemsCopy;
@synthesize searchBar;
@synthesize letUserSelectRow;
@synthesize searching;
@synthesize selectedRowIdentity;
@synthesize parentDelegate;
@synthesize footerView;
@synthesize moreButton;
@synthesize moreImageView;
@synthesize noResultsLabel;
@synthesize isShowMoreButton;
@synthesize segmentedCtrl;
@synthesize setViewTag;
@synthesize allProjectsArr,recentProjectsArr;
@synthesize loadingFooterView;
@synthesize progressView;

#define FONT_SIZE 15.0

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
     permissionType = [G2PermissionsModel getProjectPermissionType];   
    [G2ViewUtil setToolbarLabel:self withText:titleStr];

    /*
    UISearchBar *tempsearchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    [tempsearchBar setTintColor:[UIColor colorWithRed:227/255.0 green:227/255.0 blue:227/255.0 alpha:1.0]];
    self.searchBar=tempsearchBar;
    if ([self.titleStr isEqualToString:RPLocalizedString(CHOOSE_CLIENT, CHOOSE_CLIENT)])
    {
        self.searchBar.placeholder=RPLocalizedString(FILTER_CLIENT, FILTER_CLIENT);
    }
    if ([self.titleStr isEqualToString:RPLocalizedString(CHOOSE_PROJECT, CHOOSE_PROJECT)])
    {
        self.searchBar.placeholder=RPLocalizedString(FILTER_PROJECT, FILTER_PROJECT);
    }
    
    
    
    
    //Add the search bar
	//self.mainTableView.tableHeaderView = searchBar;
    [self.view addSubview:self.searchBar];
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.delegate=self;
	searching = NO;
	letUserSelectRow = YES;
     
     */
    
    if (![self.titleStr isEqualToString:RPLocalizedString(CHOOSE_CLIENT, CHOOSE_CLIENT)] )
    {
        //UIView *firstSectionView=[[UIView alloc]initWithFrame:CGRectMake(0, 60, 320, 52)];
        UIView *firstSectionView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 52)];
        [firstSectionView setBackgroundColor:[UIColor colorWithRed:227/255.0 green:227/255.0 blue:227/255.0 alpha:1.0]];
        UIImageView *firstSectionImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 52, 320, 1)];
        firstSectionImageView.image=[G2Util thumbnailImage:G2Cell_HairLine_Image];
        [firstSectionView addSubview:firstSectionImageView];
        
        
        
        NSArray *items = [[NSArray alloc] initWithObjects:RPLocalizedString(RECENT_TOGGLE_TEXT, RECENT_TOGGLE_TEXT),RPLocalizedString(ALL_TOGGLE_TEXT, ALL_TOGGLE_TEXT),  nil];
        UISegmentedControl *tempSegmentCtrl = [[UISegmentedControl alloc] initWithItems:items];
      
        self.segmentedCtrl=tempSegmentCtrl;
        
//        [self.segmentedCtrl setSegmentedControlStyle:UISegmentedControlStylePlain];
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        if (version>=7.0)
        {
           [self.segmentedCtrl setTintColor:[UIColor colorWithRed:95/255.0 green:171/255.0 blue:221/255.0 alpha:1.0]];
            
            
            
            [self.segmentedCtrl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}
                                              forState:UIControlStateNormal];
            
            [self.segmentedCtrl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}
                                              forState:UIControlStateSelected];
            
            
           
        }
        else{
            [self.segmentedCtrl setTintColor:[UIColor lightGrayColor]];
        }
        [self.segmentedCtrl setBackgroundColor:[UIColor clearColor]];
        
        
        [self.segmentedCtrl setFrame:CGRectMake(5.0f, 8.5f, 310.0f, 34.0f)];
        [self.segmentedCtrl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
        
        [firstSectionView addSubview:self.segmentedCtrl];
        [firstSectionView bringSubviewToFront:self.segmentedCtrl];
        [self.segmentedCtrl setTag:kTagFirst forSegmentAtIndex:0];
        [self.segmentedCtrl setTag:kTagSecond forSegmentAtIndex:1];
        
        [self.view addSubview:firstSectionView];
       
        
        
        [self setTextColorsForSegmentedControl:self.segmentedCtrl];
        
        
        if ([self.recentProjectsArr count]>0)
        {
            [self addRecentView:TRUE];
        }
        else
        {
            [self.segmentedCtrl setEnabled:NO forSegmentAtIndex:0];
            [self addAllView:TRUE];
        }
        
        
        [self changeUISegmentFont:self.segmentedCtrl];

    }
    
       
    
    CGRect screenRect =[[UIScreen mainScreen] bounds];
    
//    UITableView *tempmainTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 113.0, self.view.frame.size.width , self.view.frame.size.height-45-113.0) style:UITableViewStylePlain];
    UITableView *tempmainTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 53.0, self.view.frame.size.width , screenRect.size.height-45-72) style:UITableViewStylePlain];

    self.mainTableView=tempmainTableView;
    
    self.mainTableView.delegate=self;
    self.mainTableView.dataSource=self;
    //[self.mainTableView setBackgroundColor:G2RepliconStandardBackgroundColor];
    [self.view addSubview:self.mainTableView];

    if ([self.titleStr isEqualToString:RPLocalizedString(CHOOSE_CLIENT, CHOOSE_CLIENT)] )
    {
        //self.mainTableView.frame=CGRectMake(0, 60.0, self.view.frame.size.width,  self.view.frame.size.height-45-60);
        self.mainTableView.frame=CGRectMake(0, 0.0, self.view.frame.size.width,  self.view.frame.size.height-45);
    }
    
    
    //Initialize the copy array.
	NSMutableArray *tempcopyListOfItems = [[NSMutableArray alloc] init];
    self.listOfItemsCopy=tempcopyListOfItems;
    
    
    
    if (![self.titleStr isEqualToString:RPLocalizedString(CHOOSE_CLIENT, CHOOSE_CLIENT)] && isShowMoreButton)
    {
        UIView *tempfooterView=[[UIView alloc]initWithFrame:CGRectMake(0.0, 50.0, self.mainTableView.frame.size.width, 250.0)];
        self.footerView=tempfooterView;
        
        [footerView setBackgroundColor:RepliconStandardClearColor];
        self.moreButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [ self.moreButton setBackgroundColor:[UIColor clearColor]];
        UIImage *moreButtonImage=[G2Util thumbnailImage:G2MoreButtonIMage];
        
        // Let's make an NSAttributedString first
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:RPLocalizedString(MoreText,@"")];
        //Add LineBreakMode
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByClipping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];
        
        //Now let's make the Bounding Rect
        CGSize expectedLabelSize = [attributedString boundingRectWithSize:CGSizeMake(280, moreButtonImage.size.height+10) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        float totalSize=expectedLabelSize.width+10+moreButtonImage.size.width+1.0;
        int xOrigin=(320.0-totalSize)/2;
        [self.moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [ self.moreButton setFrame:CGRectMake(xOrigin, 30, expectedLabelSize.width+10.0,moreButtonImage.size.height+10 )];
        [ self.moreButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
        [ self.moreButton setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal];
        [ self.moreButton setTitle:RPLocalizedString(MoreText,@"") forState:UIControlStateNormal];
        [ self.moreButton addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
        [ self.moreButton setHidden: NO];
        
        UIImageView *tempimageView = [[UIImageView alloc]init];
        [tempimageView setImage:moreButtonImage];
        [tempimageView setFrame:CGRectMake(self.moreButton.frame.origin.x+expectedLabelSize.width+10.0+1.0,35, moreButtonImage.size.width, moreButtonImage.size.height)];
        [tempimageView setBackgroundColor:[UIColor clearColor]];
        [tempimageView setHidden: NO];
        [footerView addSubview:self.moreButton];
        [footerView addSubview:tempimageView];
        footerView.frame=CGRectMake(0.0, 0.0, self.mainTableView.frame.size.width, moreButtonImage.size.height+10+60.0);
        
        self.moreImageView=tempimageView;
        
        
        
        if (self.setViewTag!=RECENT_VIEW_TAG)
        {
            [self.mainTableView setTableFooterView:footerView];
        }
        
        
    }
    
    UILabel *tempnoResultsLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 20, 320, 20)];
    self.noResultsLabel=tempnoResultsLabel;
    
    self.noResultsLabel.text=NO_RESULTS_MSG;
    self.noResultsLabel.textColor=[UIColor blackColor];
    [self.noResultsLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];
    [self.noResultsLabel setBackgroundColor:[UIColor clearColor]];
    [self.noResultsLabel setTextAlignment:NSTextAlignmentCenter];
    
    
}

-(void)showLoadingFooterView
{
    UIView *temploadingFooterView=[[UIView alloc]initWithFrame:CGRectMake(0.0, 50.0, self.mainTableView.frame.size.width, 250.0)];
    self.loadingFooterView=temploadingFooterView;
    
    [loadingFooterView setBackgroundColor:RepliconStandardClearColor];
        
   
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0f) {
        indicatorView.color=[UIColor blackColor];
    }
    [indicatorView setFrame:CGRectMake(100.5, 25, 30, 30)];
    [indicatorView setHidesWhenStopped:YES];
    [indicatorView startAnimating];
    [self.loadingFooterView addSubview:indicatorView];
    
    
    
   
    // Let's make an NSAttributedString first
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:RPLocalizedString(LoadingMessage,@"")];
    //Add LineBreakMode
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByClipping];
    [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
    // Add Font
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];
    
    //Now let's make the Bounding Rect
    CGSize expectedLabelSize = [attributedString boundingRectWithSize:CGSizeMake(280, 30) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    UILabel *loadingLbl=[[UILabel alloc]initWithFrame:CGRectMake(135.5, 28, expectedLabelSize.width, expectedLabelSize.height)];
    loadingLbl.text=RPLocalizedString(LoadingMessage,@"");
    loadingLbl.backgroundColor=[UIColor clearColor];
    [loadingLbl setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
    [self.loadingFooterView addSubview:loadingLbl];
    
    

    self.loadingFooterView.frame=CGRectMake(0.0, 0.0, self.mainTableView.frame.size.width, indicatorView.frame.size.height+10+60.0);
    
  
    
    
    [self.mainTableView setTableFooterView: self.loadingFooterView];

    [self addTransparentOverlay];

}

-(void)addTransparentOverlay
{
    {
        if (progressView == nil) {
            UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320.0, 480.0)];
            tempView.backgroundColor=[UIColor whiteColor];
            tempView.alpha=0.5;
            self.progressView=tempView;
           
            
        }
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.progressView];
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
	return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self.noResultsLabel removeFromSuperview];
    
	if (searching)
    {
        
        if ([listOfItemsCopy count]==0)
        {
            
            [self.mainTableView addSubview:self.noResultsLabel];
            [self.mainTableView bringSubviewToFront:self.noResultsLabel];
            
        }
        return [listOfItemsCopy count];

    }
		
	else
    {
        
        if ([listOfItems count]==0)
        {
            
            [self.mainTableView addSubview:self.noResultsLabel];
            [self.mainTableView bringSubviewToFront:self.noResultsLabel];
            
        }

        return [self.listOfItems count];
    }
	
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
	static NSString *CellIdentifier = @"Cell";
	cell  = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	}
    
  
    
    NSString *name=nil;
    NSString *selectedIdentity=nil;
    if(searching)
    {
        NSDictionary *listOfitemDict=[listOfItemsCopy objectAtIndex:indexPath.row];
        name=[[listOfitemDict objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        selectedIdentity=[listOfitemDict objectForKey:@"identity"];
    }
    else
    {
        NSDictionary *listOfitemDict=[listOfItems objectAtIndex:indexPath.row];
        name=[[listOfitemDict objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        selectedIdentity=[listOfitemDict objectForKey:@"identity"];
    }
    
    
    if (selectedRowIdentity!=nil && ![selectedRowIdentity isKindOfClass:[NSNull class] ] && selectedIdentity!=nil && ![selectedIdentity isKindOfClass:[NSNull class] ])
    {
        if ([self.selectedRowIdentity isEqualToString:selectedIdentity])
        {
            //[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
             [cell setAccessoryType:UITableViewCellAccessoryNone];
            UIView *myView = [[UIView alloc] init];
            myView.backgroundColor = RepliconStandardBlueColor;
            cell.backgroundView = myView;
            cell.backgroundView.tag=indexPath.row;
            
            [cell.textLabel setTextColor:RepliconStandardWhiteColor];
            selectedIndex=indexPath.row;
        }
        else
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            UIView *myView = [[UIView alloc] init];
            myView.backgroundColor = RepliconStandardWhiteColor;
            cell.backgroundView = myView;
            cell.backgroundView.tag=indexPath.row;
            
            [cell.textLabel setTextColor:RepliconStandardBlackColor];
        }
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        UIView *myView = [[UIView alloc] init];
        myView.backgroundColor = RepliconStandardWhiteColor;
        cell.backgroundView = myView;
        cell.backgroundView.tag=indexPath.row;
       
        [cell.textLabel setTextColor:RepliconStandardBlackColor];
    }
    
    cell.textLabel.text=name;
    [cell.textLabel setFont:[UIFont fontWithName:RepliconFontFamily size:FONT_SIZE]];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    cell.textLabel.numberOfLines=5;
    
    
    
	return cell;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name=nil;
   
    if(searching)
    {
        NSDictionary *listOfitemDict=[listOfItemsCopy objectAtIndex:indexPath.row];
        name=[[listOfitemDict objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
    }
    else
    {
        NSDictionary *listOfitemDict=[listOfItems objectAtIndex:indexPath.row];
        name=[[listOfitemDict objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      
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
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:FONT_SIZE]} range:NSMakeRange(0, attributedString.length)];
        
        //Now let's make the Bounding Rect
        CGSize size = [attributedString boundingRectWithSize:CGSizeMake(250.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        
        if (size.width==0 && size.height ==0)
        {
            size=CGSizeMake(11.0, 18.0);
        }
        
        
        return size.height+24.0;
    }
    else
    {
        return 44.0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor whiteColor]];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(selectedIndex>0)
    {
        NSIndexPath *previousIndexPath=[NSIndexPath indexPathForRow:selectedIndex inSection:0 ];
        UITableViewCell *cell = [self.mainTableView cellForRowAtIndexPath:previousIndexPath];
        UIView *myView = [[UIView alloc] init];
        myView.backgroundColor = RepliconStandardWhiteColor;
        cell.backgroundView = myView;
        cell.backgroundView.tag=indexPath.row;
        
        [cell.textLabel setTextColor:RepliconStandardBlackColor];
    }
    
    
    NSString *selectedNameStr = nil;
    NSString *selectedIdentity = nil;
	
	if(searching)
    {
        NSDictionary *listOfitemDict=[listOfItemsCopy objectAtIndex:indexPath.row];
        selectedNameStr=[[listOfitemDict objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        selectedIdentity=[listOfitemDict objectForKey:@"identity"];
    }
	else {
        NSDictionary *listOfitemDict=[listOfItems objectAtIndex:indexPath.row];
        selectedNameStr=[[listOfitemDict objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        selectedIdentity=[listOfitemDict objectForKey:@"identity"];
	}
    
    
    if (selectedIdentity!=nil && ![selectedIdentity isKindOfClass:[NSNull class] ])
    {
        if ([selectedIdentity isEqualToString:@"null"])
        {
            selectedIdentity=nil;
        }
    }
    
    
    if([parentDelegate isKindOfClass:[G2AddNewExpenseViewController class]] || [parentDelegate isKindOfClass:[G2EditExpenseEntryViewController class]])
    {
        id expenseCtrl=nil;
        if ([parentDelegate isKindOfClass:[G2AddNewExpenseViewController class]])
        {
            expenseCtrl=(G2AddNewExpenseViewController *)parentDelegate;
        }
        else if ([parentDelegate isKindOfClass:[G2EditExpenseEntryViewController class]])
        {
            expenseCtrl=(G2EditExpenseEntryViewController *)parentDelegate;
        }
        
        if ([self.titleStr isEqualToString:RPLocalizedString(CHOOSE_CLIENT, CHOOSE_CLIENT)])
        {
          
//            [expenseCtrl enableExpenseFieldAtIndex: [NSIndexPath indexPathForRow:1 inSection:0]];
            
            if (selectedIdentity==nil && ![selectedIdentity isKindOfClass:[NSNull class]]) {
				selectedIdentity=@"null";
//                [expenseCtrl disableExpenseFieldAtIndex: [NSIndexPath indexPathForRow:1 inSection:0]];
			}
            if (selectedNameStr!=nil && !![selectedIdentity isKindOfClass:[NSNull class]]) {
				selectedNameStr=RPLocalizedString(NONE_STRING, @"");
//                [expenseCtrl disableExpenseFieldAtIndex: [NSIndexPath indexPathForRow:1 inSection:0]];
			}
           
            NSMutableDictionary *clientDict =  [[expenseCtrl firstSectionfieldsArray] objectAtIndex:0];
            [clientDict setObject:selectedNameStr forKey:@"clientName"];
            [clientDict setObject:selectedIdentity forKey:@"clientIdentity"];
            if (!searching) {
                [clientDict setObject: [NSNumber numberWithInteger:indexPath.row] forKey:@"selectedClientIndex"];
            }
            else
            {
                for (int i=0; i<[self.listOfItems count]; i++)
                {
                    if ([[[self.listOfItems objectAtIndex:i] objectForKey:@"identity" ] isEqualToString:[[self.listOfItemsCopy objectAtIndex:indexPath.row] objectForKey:@"identity" ]])
                    {
                         [clientDict setObject: [NSNumber numberWithInt:i] forKey:@"selectedClientIndex"];
                        break;
                    }
                }
            }
            
            [clientDict setObject:selectedNameStr forKey:@"defaultValue"];
            
           
            
            G2ExpenseEntryCellView *expenseEntryCellView =(G2ExpenseEntryCellView *)[[expenseCtrl tnewExpenseEntryTable] cellForRowAtIndexPath:
                                                           [NSIndexPath indexPathForRow:0 inSection:0]];
            [expenseEntryCellView.fieldButton setTitle:selectedNameStr forState:UIControlStateNormal];
            
            
                      
            NSMutableDictionary *projecttDict =  [[expenseCtrl firstSectionfieldsArray] objectAtIndex:1];
            [projecttDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"projectName"];
            [projecttDict setObject:@"null" forKey:@"projectIdentity"];
            
            
            [projecttDict setObject: [NSNumber numberWithInt:0] forKey:@"selectedProjectIndex"];
           
            
           
            [projecttDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            
            
            
            G2ExpenseEntryCellView *expenseProjectEntryCellView =(G2ExpenseEntryCellView *)[[expenseCtrl tnewExpenseEntryTable] cellForRowAtIndexPath:
                                                                                 [NSIndexPath indexPathForRow:1 inSection:0]];
            //Ullas-ML
            if (permissionType==PermType_ProjectSpecific )
            {
                [expenseProjectEntryCellView.fieldButton setTitle:RPLocalizedString(@"Select", @"") forState:UIControlStateNormal];
            }
            else if(permissionType==PermType_Both ) 
            {
                [expenseProjectEntryCellView.fieldButton setTitle:RPLocalizedString(NONE_STRING, @"") forState:UIControlStateNormal];
            }
            
            [expenseCtrl updateTypePickerOn_Client_ProjectChange];
            
        }
        
        else if ([self.titleStr isEqualToString:RPLocalizedString(CHOOSE_PROJECT, CHOOSE_PROJECT)])
        {
            
            if (selectedIdentity==nil && ![selectedIdentity isKindOfClass:[NSNull class]]) {
				selectedIdentity=@"null";
			}
            if (selectedNameStr!=nil && !![selectedIdentity isKindOfClass:[NSNull class]]) {
				selectedNameStr=RPLocalizedString(NONE_STRING, @"");
			}
            
            NSMutableDictionary *projecttDict =  [[expenseCtrl firstSectionfieldsArray] objectAtIndex:1];
            [projecttDict setObject:selectedNameStr forKey:@"projectName"];
            [projecttDict setObject:selectedIdentity forKey:@"projectIdentity"];
            
            if (self.setViewTag==RECENT_VIEW_TAG)
            {
                NSString *recentProjID=nil;
                
                if (!searching)
                {
                    recentProjID=[[self.recentProjectsArr objectAtIndex:indexPath.row]objectForKey:@"identity" ];
                }
                
                else
                {
                    recentProjID=[[self.listOfItemsCopy objectAtIndex:indexPath.row]objectForKey:@"identity" ];
                }
                
                for (int k=0; k<[self.listOfItems count]; k++)
                {
                    if ([[[self.listOfItems objectAtIndex:k] objectForKey:@"identity" ] isEqualToString:recentProjID])
                    {
                        [projecttDict setObject: [NSNumber numberWithInt:k] forKey:@"selectedProjectIndex"];
                        break;
                    }
                }
             
            }
            else
            {
                if (!searching) {
                    [projecttDict setObject: [NSNumber numberWithInteger:indexPath.row] forKey:@"selectedProjectIndex"];
                }
                else
                {
                    for (int i=0; i<[self.listOfItems count]; i++)
                    {
                        if ([[[self.listOfItems objectAtIndex:i] objectForKey:@"identity" ] isEqualToString:[[self.listOfItemsCopy objectAtIndex:indexPath.row] objectForKey:@"identity" ]])
                        {
                            [projecttDict setObject: [NSNumber numberWithInt:i] forKey:@"selectedProjectIndex"];
                            break;
                        }
                    }
                }

            }
                        
            
            
            [projecttDict setObject:selectedNameStr forKey:@"defaultValue"];
            
           
            
            G2ExpenseEntryCellView *expenseEntryCellView =(G2ExpenseEntryCellView *)[[expenseCtrl tnewExpenseEntryTable] cellForRowAtIndexPath:
                                                                                 [NSIndexPath indexPathForRow:1 inSection:0]];
            [expenseCtrl didSelectRowFromDataList:indexPath.row inComponent:1];
            [expenseEntryCellView.fieldButton setTitle:selectedNameStr forState:UIControlStateNormal];
            [expenseCtrl setFromReloaOfDataView:YES];
            if ([parentDelegate isKindOfClass:[G2EditExpenseEntryViewController class]])
            {
                [expenseCtrl setProjectChanged:YES];
            }
            [expenseCtrl updateTypePickerOn_Client_ProjectChange];
        }
    }
 
    if([parentDelegate isKindOfClass:[G2TimeEntryViewController class]])
    {
        G2TimeEntryViewController *timeEntryCtrl=(G2TimeEntryViewController *)parentDelegate;
        
        if ([self.titleStr isEqualToString:RPLocalizedString(CHOOSE_PROJECT, CHOOSE_PROJECT)])
        {
            [timeEntryCtrl.timeSheetEntryObject setClientAllocationId:nil];
            
            timeEntryCtrl.timeSheetEntryObject.projectName=selectedNameStr;
            timeEntryCtrl.timeSheetEntryObject.projectIdentity=selectedIdentity;
            G2SupportDataModel *supportDataModel=[[G2SupportDataModel alloc]init];
            NSString *projectBillingStatus = [supportDataModel getProjectBillableStatus:
											  selectedIdentity];
            timeEntryCtrl.timeSheetEntryObject.projectBillableStatus=projectBillingStatus;
            
             NSString *billingIdentity = [G2SupportDataModel getBillingTypeByProjRoleName: timeEntryCtrl.timeSheetEntryObject.billingName];
            
            
            
            if (billingIdentity==nil) {
                billingIdentity=BILLING_NONBILLABLE;
            }
            
            
            [timeEntryCtrl.timeSheetEntryObject setBillingIdentity:billingIdentity];
            
            [timeEntryCtrl updateFieldAtIndex:timeEntryCtrl.selectedIndexPath WithSelectedValues:selectedNameStr];
            
            [timeEntryCtrl resetTaskSelection];

        }
        if ([self.titleStr isEqualToString:RPLocalizedString(CHOOSE_CLIENT, CHOOSE_CLIENT)])
        {
            timeEntryCtrl.timeSheetEntryObject.clientName=selectedNameStr;
            timeEntryCtrl.timeSheetEntryObject.clientIdentity=selectedIdentity;
            if (timeEntryCtrl.timeSheetEntryObject.clientIdentity == nil || [timeEntryCtrl.timeSheetEntryObject.clientIdentity isKindOfClass:[NSNull class]])
            {
                [timeEntryCtrl.timeSheetEntryObject setClientIdentity: @"null"];
            }
            [timeEntryCtrl updateFieldAtIndex:timeEntryCtrl.selectedIndexPath WithSelectedValues:selectedNameStr];
            
            BOOL bothPermission = [[timeEntryCtrl permissionsObj] bothAgainstAndNotAgainstProject];
            
            NSString *projDefaultValue = bothPermission?RPLocalizedString(NONE_STRING, @"") :RPLocalizedString(SelectString, @"") ;
            if( [timeEntryCtrl screenMode] == VIEW_TIME_ENTRY )
            {
                projDefaultValue=RPLocalizedString(NONE_STRING, @"");
            }
           
            [timeEntryCtrl.timeSheetEntryObject setProjectName: projDefaultValue];
            [timeEntryCtrl.timeSheetEntryObject setProjectIdentity: @"null"];
            [timeEntryCtrl.timeSheetEntryObject setBillingIdentity:BILLING_NONBILLABLE];
            
            
            timeEntryCtrl.timeSheetEntryObject.projectBillableStatus=nil;
            
            NSIndexPath *projectindexPath=[NSIndexPath indexPathForRow:1 inSection:1];
            [timeEntryCtrl updateFieldAtIndex:projectindexPath WithSelectedValues:projDefaultValue];
            
            [timeEntryCtrl resetTaskSelection];
            
            
            
        }
        
        G2SupportDataModel *supportDataModel=[[G2SupportDataModel alloc]init];
        NSString *clientAllocationId = [supportDataModel getClientAllocationId:timeEntryCtrl.timeSheetEntryObject.clientIdentity projectIdentity:timeEntryCtrl.timeSheetEntryObject.projectIdentity];
        if (clientAllocationId != nil) {
            [timeEntryCtrl.timeSheetEntryObject setClientAllocationId:clientAllocationId];
        }
    
        
    }
  
    [self.navigationController popViewControllerAnimated:TRUE];
}

#pragma mark -
#pragma mark Search Bar

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	
    //This method is called again when the user clicks back from the detail view.
	//So the overlay is displayed on the results, which is something we do not want to happen.
	if(searching)
		return;
	
	//Add the overlay view.
	if(ovController == nil)
		ovController = [[G2OverlayViewController alloc] initWithNibName:@"OverlayView" bundle:[NSBundle mainBundle]];
	
	//CGFloat yaxis = self.navigationController.navigationBar.frame.size.height;
    CGFloat yaxis = 0.0;
	CGFloat width = self.view.frame.size.width;
	CGFloat height = self.view.frame.size.height;
	
	//Parameters x = origion on x-axis, y = origon on y-axis.
	CGRect frame = CGRectMake(0, yaxis, width, height);
	ovController.view.frame = frame;
	ovController.view.backgroundColor = [UIColor grayColor];
	ovController.view.alpha = 0.5;
	
    //	ovController.parentDelegate = self;
	
	[self.mainTableView insertSubview:ovController.view aboveSubview:self.parentViewController.view];
	
    if([self.searchBar.text length] > 0) {
		
		[ovController.view removeFromSuperview];
		searching = YES;
		letUserSelectRow = YES;
		self.mainTableView.scrollEnabled = YES;
		[self searchTableView];
	}
	else {
		
		[self.mainTableView insertSubview:ovController.view aboveSubview:self.parentViewController.view];
		
		searching = NO;
		letUserSelectRow = NO;
		self.mainTableView.scrollEnabled = NO;
	}
	
	[self.mainTableView reloadData];
	
	//Add the done button.
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
											   target:self action:@selector(doneSearching_Clicked:)];
	
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    
	//Remove all objects first.
	[listOfItemsCopy removeAllObjects];
	
	if([searchText length] > 0) {
		
		[ovController.view removeFromSuperview];
		searching = YES;
		letUserSelectRow = YES;
		self.mainTableView.scrollEnabled = YES;
		[self searchTableView];
	}
	else {
		
		[self.mainTableView insertSubview:ovController.view aboveSubview:self.parentViewController.view];
		
		searching = NO;
		letUserSelectRow = NO;
		self.mainTableView.scrollEnabled = NO;
	}
	
	[self.mainTableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	
	[self searchTableView];
}

- (void) searchTableView {
	
	NSString *searchText = searchBar.text;
	NSMutableArray *searchArray = [[NSMutableArray alloc] init];
	
	for (NSDictionary *listOfItemsDict in listOfItems)
	{
		[searchArray addObject:listOfItemsDict];
	}
	
	for (NSDictionary *sDict in searchArray)
	{
		NSRange titleResultsRange = [[[sDict objectForKey:@"name"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] rangeOfString:searchText options:NSCaseInsensitiveSearch];
		
		if (titleResultsRange.length > 0)
			[listOfItemsCopy addObject:sDict];
	}
	
	
	searchArray = nil;
    
    [self.mainTableView setTableFooterView:nil];
}

- (void) doneSearching_Clicked:(id)sender {
    
	
	searchBar.text = @"";
	[searchBar resignFirstResponder];
	
	letUserSelectRow = YES;
	searching = NO;
	self.navigationItem.rightBarButtonItem = nil;
	self.mainTableView.scrollEnabled = YES;
	
	[ovController.view removeFromSuperview];
	
	ovController = nil;
	
	[self.mainTableView reloadData];
    
    if (self.setViewTag!=RECENT_VIEW_TAG) {
        [self.mainTableView setTableFooterView:self.footerView];
    }
    
    
}


-(void)moreAction
{
    if([parentDelegate isKindOfClass:[G2AddNewExpenseViewController class]] || [parentDelegate isKindOfClass:[G2EditExpenseEntryViewController class]])
    {
        id expenseCtrl=nil;
        if ([parentDelegate isKindOfClass:[G2AddNewExpenseViewController class]])
        {
            expenseCtrl=(G2AddNewExpenseViewController *)parentDelegate;
        }
        else if ([parentDelegate isKindOfClass:[G2EditExpenseEntryViewController class]])
        {
            expenseCtrl=(G2EditExpenseEntryViewController *)parentDelegate;
        }
        
        if ([self.titleStr isEqualToString:RPLocalizedString(CHOOSE_PROJECT, CHOOSE_PROJECT)])
        {
            
            NSMutableDictionary *clientDict =  [[expenseCtrl firstSectionfieldsArray] objectAtIndex:0];
            
            if (![NetworkMonitor isNetworkAvailableForListener:self]) {
                
                [G2Util showOfflineAlert];
                return;
                
            }
            else
            {
                [[G2RepliconServiceManager expensesService] sendRequestToGetExpenseProjectsByClient:[clientDict objectForKey:@"clientIdentity"] withDelegate:[G2RepliconServiceManager expensesService]];
               
//                [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
                
                [self performSelector:@selector(showLoadingFooterView) withObject:nil];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                name:PROJECTSBYCLIENTS_FINSIHED_DOWNLOADING object:nil];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(expensesFinishedDownloadingProjects:)
                                                             name:PROJECTSBYCLIENTS_FINSIHED_DOWNLOADING object:nil];
            }
            
        }
    }
    else  if([parentDelegate isKindOfClass:[G2TimeEntryViewController class]] )
    {
        G2TimeEntryViewController *timeEntryCtrl=(G2TimeEntryViewController *)parentDelegate;
       
        
        if ([self.titleStr isEqualToString:RPLocalizedString(CHOOSE_PROJECT, CHOOSE_PROJECT)])
        {
            
            NSString *clientIdentity =  [[timeEntryCtrl timeSheetEntryObject] clientIdentity];
            
            if (![NetworkMonitor isNetworkAvailableForListener:self]) {
                
                [G2Util showOfflineAlert];
                return;
                
            }
            else
            {
                [[G2RepliconServiceManager timesheetService] sendRequestToGetAllProjectsByClientID:clientIdentity];
                
                //                [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
                
                [self performSelector:@selector(showLoadingFooterView) withObject:nil];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                name:TIMESHEETSPROJECTS_FINSIHED_DOWNLOADING object:nil];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timesheetsFinishedDownloadingProjects:)
                                                             name:TIMESHEETSPROJECTS_FINSIHED_DOWNLOADING object:nil];
            }
            
        }
    }
    
    
}

-(void)expensesFinishedDownloadingProjects: (id)notificationObject 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:PROJECTSBYCLIENTS_FINSIHED_DOWNLOADING object:nil];
    
    if([parentDelegate isKindOfClass:[G2AddNewExpenseViewController class]] || [parentDelegate isKindOfClass:[G2EditExpenseEntryViewController class]])
    {
        self.allProjectsArr=[parentDelegate genarateProjectsListForDtaListView];
        self.listOfItems=self.allProjectsArr;
        
        [self.mainTableView reloadData];
    }
    
    
    id isNotMoreProjectsAvailable = ((NSNotification *)notificationObject).object;
    
    if ([isNotMoreProjectsAvailable boolValue])
    {
        [self.mainTableView setTableFooterView:nil];
    }
    else
    {
        [self.mainTableView setTableFooterView:footerView];
    }
    
      [self.progressView removeFromSuperview];
}

-(void)timesheetsFinishedDownloadingProjects: (id)notificationObject
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TIMESHEETSPROJECTS_FINSIHED_DOWNLOADING object:nil];
    
    if([parentDelegate isKindOfClass:[G2TimeEntryViewController class]])
    {
       G2TimeEntryViewController *timeEntryCtrl=(G2TimeEntryViewController *)parentDelegate;
        G2SupportDataModel *supportDataModel=[[G2SupportDataModel alloc]init];
        self.allProjectsArr=[supportDataModel getProjectsForClientWithClientId:[[timeEntryCtrl timeSheetEntryObject] clientIdentity]];
       
        self.listOfItems=self.allProjectsArr;
        
        [self.mainTableView reloadData];
    }
    
    
    id isNotMoreProjectsAvailable = ((NSNotification *)notificationObject).object;
    
    if ([isNotMoreProjectsAvailable boolValue])
    {
        [self.mainTableView setTableFooterView:nil];
    }
    else
    {
        [self.mainTableView setTableFooterView:footerView];
    }
    
    [self.progressView removeFromSuperview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)activeScrollView
{
    [self.searchBar resignFirstResponder];
    
}

-(void)addRecentView:(BOOL)flag

{
     
    [self doneSearching_Clicked:nil];
    self.listOfItems=self.recentProjectsArr;
    [self.mainTableView reloadData];
    self.setViewTag=RECENT_VIEW_TAG;
    
    [self.mainTableView setTableFooterView:nil];
}


-(void)addAllView:(float )delayTime

{
   
    
    [self doneSearching_Clicked:nil];
    self.listOfItems=self.allProjectsArr;
    [self.mainTableView reloadData];
    self.setViewTag=ALL_VIEW_TAG;
    
    if (isShowMoreButton)
    {
        [self.mainTableView setTableFooterView:footerView];
    }
    
}

-(void) changeUISegmentFont:(UIView*) myView {
    
    if ([myView isKindOfClass:[UILabel class]]) {  // Getting the label subview of the passed view
        
        UILabel* label = (UILabel*)myView;
        
        [label setTextAlignment:NSTextAlignmentCenter];
        
        [label setFont:[UIFont boldSystemFontOfSize:15]]; // Set the font size you want to change to
        
        [label sizeToFit];
        
    }
    
    NSArray* subViewArray = [myView subviews]; // Getting the subview array
    
    NSEnumerator* iterator = [subViewArray objectEnumerator]; // For enumeration
    
    UIView* subView;
    
    while (subView = [iterator nextObject]) { // Iterating through the subviews of the view passed
        
        [self changeUISegmentFont:subView]; // Recursion
        
    }
    
}


-(void)segmentChanged:(id)sender {
    // when a segment is selected, it resets the text colors
    // so set them back
    UISegmentedControl *segmentCtrl=(UISegmentedControl *)sender;
    
    
    [self setTextColorsForSegmentedControl:(UISegmentedControl*)sender];
    
    
    
    switch (segmentCtrl.selectedSegmentIndex) {
        case 1:
            if (self.setViewTag!=ALL_VIEW_TAG)
            {
                [self.view setBackgroundColor:[UIColor clearColor]];
                
                
                [self addAllView:0.0];
                
                // set up an animation for the transition between the views
                CATransition *animation = [CATransition animation];
                [animation setDuration:0.5];
                [animation setType:kCATransitionPush];
                [animation setSubtype:kCATransitionFromRight];
                [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                
                [[self.mainTableView layer] addAnimation:animation forKey:@"SwitchToView2"];
                
                //                [UIView beginAnimations:nil context:nil];
                //                [UIView setAnimationDuration:1.0];
                //                [self addSummaryView:0.5];
                //                [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:true];
            }
            
            break;
        case 0:
            if (self.setViewTag!=RECENT_VIEW_TAG)
            {
                [self.view setBackgroundColor:[UIColor clearColor]];
                
                
                [self addRecentView:FALSE];
                
                // set up an animation for the transition between the views
                CATransition *animation = [CATransition animation];
                [animation setDuration:0.5];
                [animation setType:kCATransitionPush];
                [animation setSubtype:kCATransitionFromLeft];
                [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                
                [[self.mainTableView layer] addAnimation:animation forKey:@"SwitchToView1"];
                
                //                [UIView beginAnimations:nil context:nil];
                //                [UIView setAnimationDuration:1.0];
                //                [self addCalendarView:FALSE];
                //                [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:true];
            }
            
            
            break;
        default:
            break;
    }
    
    
    
    
    [UIView commitAnimations];
    
    self.segmentedCtrl.selectedSegmentIndex=-1;
    [self changeUISegmentFont:self.segmentedCtrl];
}

-(void)setTextColorsForSegmentedControl:(UISegmentedControl*)segmented {
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    
    
    switch (segmented.selectedSegmentIndex) {
        case 0:
            if (version<7.0)//Fix for ios7//JUHI
            {
                [self.segmentedCtrl setTintColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:201/255.0 alpha:1.0] forTag:kTagFirst];
                [self.segmentedCtrl setTintColor:[UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1.0] forTag:kTagSecond];
                [segmented setShadowColor:[UIColor blackColor] forTag:kTagFirst];
                [segmented setShadowColor:[UIColor whiteColor] forTag:kTagSecond];
                [segmented setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] forTag:kTagFirst];
                [segmented setTextColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] forTag:kTagSecond];
            }
            else {
                
                [self.segmentedCtrl setBackgroundColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:201/255.0 alpha:1.0]  forTag:kTagFirst ];
                [self.segmentedCtrl setBackgroundColor:[UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1.0] forTag:kTagSecond];
            }
            
            
            
            
            break;
        case 1:
            if ([self.recentProjectsArr count]>0)
            {
                if (version<7.0)//Fix for ios7//JUHI
                {
                    [self.segmentedCtrl setTintColor:[UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1.0] forTag:kTagFirst];
                    [self.segmentedCtrl setTintColor:RepliconStandardNavBarTintColor forTag:kTagSecond];
                    [segmented setShadowColor:[UIColor whiteColor] forTag:kTagFirst];
                    [segmented setShadowColor:[UIColor blackColor] forTag:kTagSecond];
                    [segmented setTextColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] forTag:kTagFirst];
                    [segmented setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] forTag:kTagSecond];
                }
                else {
                    [self.segmentedCtrl setBackgroundColor:[UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1.0]  forTag:kTagFirst ];
                    [self.segmentedCtrl setBackgroundColor:RepliconStandardNavBarTintColor forTag:kTagSecond];
                }
                
                
                
            }
            
            
            
            break;
        default:
            
            if ([self.recentProjectsArr count]>0)
            {
                if (version<7.0)//Fix for ios7//JUHI
                {
                    [self.segmentedCtrl setTintColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:201/255.0 alpha:1.0] forTag:kTagFirst];
                    [self.segmentedCtrl setTintColor:[UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1.0] forTag:kTagSecond];
                    [segmented setShadowColor:[UIColor blackColor] forTag:kTagFirst];
                    [segmented setShadowColor:[UIColor whiteColor] forTag:kTagSecond];
                    [segmented setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] forTag:kTagFirst];
                    [segmented setTextColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] forTag:kTagSecond];

                }
                else {
                    [self.segmentedCtrl setBackgroundColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:201/255.0 alpha:1.0] forTag:kTagFirst ];
                    [self.segmentedCtrl setBackgroundColor:[UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1.0] forTag:kTagSecond];
                }
                
                
            }
            else
            {
                if (version<7.0)//Fix for ios7//JUHI
                {
                    [self.segmentedCtrl setTintColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:201/255.0 alpha:1.0] forTag:kTagSecond];
                    [self.segmentedCtrl setTintColor:[UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1.0] forTag:kTagFirst];
                    [segmented setShadowColor:[UIColor blackColor] forTag:kTagSecond];
                    [segmented setShadowColor:[UIColor whiteColor] forTag:kTagFirst];
                    [segmented setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] forTag:kTagSecond];
                    [segmented setTextColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] forTag:kTagFirst];
                    
                }
                else {
                    
                    [self.segmentedCtrl setBackgroundColor:[UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1.0]  forTag:kTagFirst ];
                    [self.segmentedCtrl setBackgroundColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:201/255.0 alpha:1.0]  forTag:kTagSecond];
                    
                }
                
            }
            
            
            break;
    }
    
    //    [self changeUISegmentFont:self.segmentedCtrl];
    
    
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.mainTableView=nil;
    self.footerView=nil;
    self.moreButton=nil;
    self.moreImageView=nil;
    
}




@end
