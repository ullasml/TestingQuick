//
//  TimesheetSubmitReasonViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by juhigautam on 10/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "TimesheetSubmitReasonViewController.h"
#import "TimesheetModel.h"
#import "TimesheetSubmitReasonView.h"
#import "RepliconServiceManager.h"
#import "FrameworkImport.h"
#import "AppDelegate.h"
#import "ApprovalActionsViewController.h"
#import "CurrentTimesheetViewController.h"
@interface TimesheetSubmitReasonViewController ()

@end

@implementation TimesheetSubmitReasonViewController
@synthesize mainScrollView;
@synthesize reasonDetailArray;
@synthesize reasonTextView;
@synthesize sheetIdentity;
@synthesize timesheetLevelUdfArray;
@synthesize isMultiDayInOutTimesheetUser;
@synthesize arrayOfEntriesForSave;
@synthesize isDisclaimerRequired;
@synthesize isExtendedInoutUser;
@synthesize actionType;
@synthesize delegate;
@synthesize submitComments;
@synthesize tempPoint;

#define textMovementDistanceFor4 166.66
#define textMovementDistanceFor5 94.11



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
    
     [Util setToolbarLabel: self withText: RPLocalizedString(ReasonForChange, @"")];
    
    
    UIBarButtonItem *tempLeftButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(Cancel_Button_Title,@"")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(cancelAction:)];
    
    self.navigationItem.leftBarButtonItem=tempLeftButtonOuterBtn;
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(Submit_Button_title,@"")
                                                             style:UIBarButtonItemStylePlain
                                                            target:self action:@selector(submitAction:)];
    self.navigationItem.rightBarButtonItem = item;
    self.navigationItem.rightBarButtonItem.enabled=NO;
    //[self createReasonData];
    UIScrollView * contentScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+100)];
    self.mainScrollView=contentScrollView;
    self.mainScrollView.scrollEnabled=YES;
    self.mainScrollView.showsVerticalScrollIndicator=YES;
    self.mainScrollView.backgroundColor = [Util colorWithHex:@"#EEEEEE" alpha:1];
    [self.mainScrollView setUserInteractionEnabled:YES];
    [self.view addSubview:self.mainScrollView];
    [self initializeView];
}

-(void)initializeView{
    float y=8.0;
    float height =58;
    float viewHeight=0.0;
    if ([reasonDetailArray count]>0)
    {
        UILabel *titleLb=[[UILabel alloc]initWithFrame:CGRectMake(12,y, self.view.frame.size.width-12, 40)];
        titleLb.numberOfLines=2;
        [titleLb setText:RPLocalizedString(FollowingChangesWereMadeToThisTimesheet, @"")];
        [titleLb setTextColor:RepliconStandardBlackColor];
        [titleLb setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
        [titleLb setUserInteractionEnabled:NO];
        [titleLb setBackgroundColor:[UIColor clearColor]];
        [titleLb setHighlightedTextColor:RepliconStandardWhiteColor];
        [self.mainScrollView addSubview:titleLb];
        y=y+height;
        NSMutableArray *heightArray=[NSMutableArray array];
        for (int i=0; i<[reasonDetailArray count]; i++)
        {
            NSDictionary *firstDetaildict=[reasonDetailArray objectAtIndex:i];
            NSMutableArray *secondArray=[firstDetaildict objectForKey:@"modificationSets"];
            
            
            float firstHeaderHeight=[self getHeightForString:[firstDetaildict objectForKey:@"header"] forWidth:(self.view.frame.size.width-12)];
            float subReasonTotalHeight=0.0;
            float subHeaderHeightTotal=0.0;
            if ([secondArray count]>0)
            {
                
                for (int j=0; j<[secondArray count]; j++)
                {
                    NSDictionary *dsubReasondict=[secondArray objectAtIndex:j];
                    NSMutableArray *subReasonDetail=[dsubReasondict objectForKey:@"modifications"];
                    float header=[self getHeightForString:[dsubReasondict objectForKey:@"header"] forWidth:(self.view.frame.size.width-12)];
                    subHeaderHeightTotal=subHeaderHeightTotal+header;
                    
                    
                    for (int k=0; k<[subReasonDetail count]; k++)
                    {
                        float resonHgt=[self getHeightForString:[subReasonDetail objectAtIndex:k] forWidth:(self.view.frame.size.width-12)];
                        subReasonTotalHeight=subReasonTotalHeight+resonHgt;
                    }

                }
                
                
                
                
            }
            [heightArray addObject:[NSNumber numberWithFloat:subReasonTotalHeight+subHeaderHeightTotal+firstHeaderHeight+30]];
        }
        
        
        
        for (int i=0; i<[reasonDetailArray count]; i++)
        {
            NSDictionary *detaildict=[reasonDetailArray objectAtIndex:i];
            NSMutableArray *reasonDetail=[detaildict objectForKey:@"modificationSets"];
            float headerHeight=[self getHeightForString:[detaildict objectForKey:@"header"] forWidth:(self.view.frame.size.width-12)];
            float viewDisplayHeight=[[heightArray objectAtIndex:i] newFloatValue];
            height=viewDisplayHeight;
            TimesheetSubmitReasonView *timesheetReasonView=[[TimesheetSubmitReasonView alloc]initWithFrame:CGRectMake(0,y, self.view.frame.size.width, height) andReasonData:reasonDetail headerHeight:headerHeight];
                
                timesheetReasonView.reasonDate.text=[detaildict objectForKey:@"header"];
                
                [self.mainScrollView addSubview:timesheetReasonView];
                y=y+height;
                viewHeight=viewHeight+height;
                
        }
           
        y=y+20;
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.7];
       [self.mainScrollView addSubview:lineView];
        y=y+1;
        viewHeight+=1;
        UILabel *reasonLb=[[UILabel alloc]initWithFrame:CGRectMake(0,y, self.view.frame.size.width, 30)];
        [reasonLb setText:[NSString stringWithFormat:@"  %@",RPLocalizedString(PleaseProvideReasonForTheseChanges, @"")]];
        [reasonLb setTextColor:[Util colorWithHex:@"#999999" alpha:1]];
        [reasonLb setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
        [reasonLb setUserInteractionEnabled:NO];
        [reasonLb setBackgroundColor:RepliconStandardWhiteColor];
        [reasonLb setHighlightedTextColor:RepliconStandardWhiteColor];
        [self.mainScrollView addSubview:reasonLb];
        
        y=y+30;
        viewHeight+=30;
        UITextView * mainContent = [[UITextView alloc]initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 100)];
         self.reasonTextView=mainContent;
        NSString *commentString= comments;
        CGSize expectedLabelSize ;
        
        if (commentString!=nil && ![commentString isEqualToString:@""]) {
            CGRect frame = self.reasonTextView.frame;
            
            
            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:commentString];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_15]} range:NSMakeRange(0, attributedString.length)];
            
            //Now let's make the Bounding Rect
            expectedLabelSize  = [attributedString boundingRectWithSize:CGSizeMake(290.0, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            
            if (expectedLabelSize.width==0 && expectedLabelSize.height ==0)
            {
                expectedLabelSize=CGSizeMake(11.0, 18.0);
            }
            frame.size.height = expectedLabelSize.height+22;
            if (frame.size.height>100)
            {
                
                self.reasonTextView.frame = frame;
                
            }
            self.reasonTextView.text = commentString;

        }
        else{
            self.reasonTextView.text =RPLocalizedString(AddComments,@"");
        }
        
        self.reasonTextView.returnKeyType=UIReturnKeyDone;
        self.reasonTextView.textColor = [UIColor blackColor];
        self.reasonTextView.font=[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14];
        self.reasonTextView.delegate=self;
        [self.mainScrollView addSubview:self.reasonTextView];
        
       viewHeight+=expectedLabelSize.height+reasonTextView.frame.size.height;
        self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width,viewHeight+270);
         svos = self.mainScrollView.contentOffset;
        
    }
}
-(float)getHeightForString:(NSString *)string forWidth:(float)width
{
    
    // Let's make an NSAttributedString first
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    //Add LineBreakMode
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
    // Add Font
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_14]} range:NSMakeRange(0, attributedString.length)];
    
    //Now let's make the Bounding Rect
    CGSize mainSize  = [attributedString boundingRectWithSize:CGSizeMake(290.0, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    
    if (mainSize.width==0 && mainSize.height ==0)
    {
        mainSize=CGSizeMake(0,0);
    }
    float version= [[UIDevice currentDevice].systemVersion newFloatValue];
    if (version>=7.0)
    {
        CGSize maxSize = CGSizeMake(width, MAXFLOAT);
        CGRect labelRect = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]} context:nil];
        return labelRect.size.height;
    }

    return mainSize.height;
}
-(void)cancelAction:(id)sender
{
    CLS_LOG(@"-----Cancel Action on TimesheetSubmitReasonViewController -----");

    [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                   otherButtonTitle:nil
                                           delegate:self
                                            message:RPLocalizedString(Cancel_Msg,@"")
                                              title:nil
                                                tag:0];

	
	
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)submitAction:(id)sender
{
    CLS_LOG(@"-----Submit Action on TimesheetSubmitReasonViewController -----");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SUBMITTED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reSubmitTimeSheetReceivedData:) name:SUBMITTED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    
    [[RepliconServiceManager timesheetService]sendRequestToSaveTimesheetDataForTimesheetURI:self.sheetIdentity  withEntryArray:self.arrayOfEntriesForSave withDelegate:self isMultiInOutTimeSheetUser:self.isMultiDayInOutTimesheetUser isNewAdhocEntryDict:nil isTimesheetSubmit:YES sheetLevelUdfArray:self.timesheetLevelUdfArray submitComments:submitComments isAutoSave:@"NO" isDisclaimerAccepted:self.isDisclaimerRequired rowUri:nil actionMode:0 isExtendedInOutUser:self.isExtendedInoutUser reasonForChange:self.reasonTextView.text];
    
}
-(void)reSubmitTimeSheetReceivedData:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SUBMITTED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    
    [self popToListOfTimeSheets];
    
}


-(void)popToListOfTimeSheets
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    TimesheetModel *timeSheetModel=[[TimesheetModel alloc]init];
    
    NSArray *timeSheetsArr = [timeSheetModel getTimeSheetInfoSheetIdentity:self.sheetIdentity];
    
    if ([timeSheetsArr count]>0)
    {
        NSMutableDictionary *timeSheetDict=[[timeSheetsArr objectAtIndex:0]mutableCopy];
        if ([self.actionType isEqualToString:@"Re-Submit"]||[self.actionType isEqualToString:@"Submit"])
        {
            [timeSheetDict setObject:WAITING_FOR_APRROVAL_STATUS forKey:@"approvalStatus" ];
        }
        if ([self.actionType isEqualToString:@"Unsubmit"])
        {
            [timeSheetDict setObject:NOT_SUBMITTED_STATUS forKey:@"approvalStatus" ];
        }
        
        
        NSMutableDictionary *tmpDict=[NSMutableDictionary dictionaryWithDictionary:timeSheetDict];
        for (int i=0; i<[[timeSheetDict allValues] count]; i++)
        {
            id str = [[timeSheetDict allValues] objectAtIndex:i];
            NSString *key =[[timeSheetDict allKeys] objectAtIndex:i];
            if (str==nil || [str isKindOfClass:[NSNull class]])
            {
                [tmpDict removeObjectForKey:key];
            }
        }
        //Fix for defect time-288//JUHI
        [myDB updateTable:@"Timesheets" data:tmpDict where:[NSString stringWithFormat:@"timesheetUri = '%@'",sheetIdentity] intoDatabase:@""];
        
    }
    

    if ([delegate isKindOfClass:[ApprovalActionsViewController class]] )
    {
        ApprovalActionsViewController *viewCtrl=(ApprovalActionsViewController*)delegate;
        if ([[viewCtrl delegate] isKindOfClass:[CurrentTimesheetViewController class]] )
        {
            CurrentTimesheetViewController *delegateViewCtrl=(CurrentTimesheetViewController*)[viewCtrl delegate];
            [delegateViewCtrl RecievedData];//Fix for defect time-288//JUHI
 //           [self.navigationController popToViewController:delegateViewCtrl animated:TRUE];
            [self.navigationController popToRootViewControllerAnimated:TRUE];
        }
        
    }
    else
    {
        //[self.navigationController popViewControllerAnimated:TRUE];
        [self.navigationController popToRootViewControllerAnimated:TRUE];
    }
    
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
		[textView resignFirstResponder];
	}
    
      return YES;
   
    
}
-(BOOL)textViewShouldReturn:(UITextView *)textView
{
    
    [textView resignFirstResponder];
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    
    if ([textView.text isEqualToString:RPLocalizedString(AddComments, AddComments)]) {
        textView.text=@"";
    }
    
    self.mainScrollView.userInteractionEnabled=NO;
    [self resetView:YES];
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{
   
    reasonTextView.text=textView.text;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
     self.mainScrollView.userInteractionEnabled=YES;
    comments=textView.text;
    [self resetView:NO];
    if (![textView.text isEqualToString:@""]&& ![textView.text isEqualToString:RPLocalizedString(AddComments,@"")])
    {
        self.navigationItem.rightBarButtonItem.enabled=YES;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled=FALSE;
    }
    //[textView setSelectedRange:NSMakeRange(0, 0)];
    return YES;
}
-(void)resetView:(BOOL)isReset{
    //Fix for Animation Click of Back Button
    if(isReset){
       
        tempPoint=self.mainScrollView.contentOffset;
        CGPoint pt;
        CGRect rc = [reasonTextView bounds];
        rc = [reasonTextView convertRect:rc toView:mainScrollView];
        pt = rc.origin;
        pt.x = 0;
        pt.y -= 60;
        [self.mainScrollView setContentOffset:pt animated:YES];
        
    }
    else{
        
        [self initializeView];
        [self.mainScrollView setContentOffset:tempPoint animated:YES];
        
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
