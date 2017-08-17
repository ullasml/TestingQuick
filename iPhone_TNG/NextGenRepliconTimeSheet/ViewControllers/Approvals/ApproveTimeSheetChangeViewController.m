//
//  ApproveTimeSheetChangeViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 11/04/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "ApproveTimeSheetChangeViewController.h"
#import "Constants.h"
#import "CustomTimesheetReasonCell.h"

@interface ApproveTimeSheetChangeViewController ()

@end

@implementation ApproveTimeSheetChangeViewController
@synthesize changesListArray;
@synthesize obj_approvalsModel;
@synthesize sheetIdentity;
@synthesize changesListScrollView;

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
    [self.view setBackgroundColor:[Util colorWithHex:@"#EEEEEE" alpha:1]];
}

-(void)loadView
{
    
    [Util setToolbarLabel:self withText: RPLocalizedString(TimeSheetChangeHistoryTabbarTitle, @"") ];
    [super loadView];
    
    
    //Fix for ios7//JUHI
    float version= [[UIDevice currentDevice].systemVersion newFloatValue];
    float height=44.0;
    if (version>=7.0)
    {
        height=64.0;
    }
    

    
    self.changesListArray = [[NSMutableArray alloc] init];
    
    obj_approvalsModel =  [[ ApprovalsModel alloc] init];
    
    self.changesListArray=[obj_approvalsModel getPendingTimesheetChangeReasonEntriesFromDB:sheetIdentity];
    
    if ([self.changesListArray count]>1) {
        //[self createFooter];
    }
    
    UIScrollView *tempScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0,0 ,SCREEN_WIDTH,self.view.frame.size.height- height)];
    self.changesListScrollView=tempScrollView;
    [self.changesListScrollView setBackgroundColor:[UIColor clearColor]];
    

    [self.view addSubview:changesListScrollView];
    [self loadData];
}

-(void)loadData
{
    float previousLabelHeightAndOrigin = 0;
    for (int arrayIndex = 0; arrayIndex<[changesListArray count]; arrayIndex++) {
        id entryDetail = [changesListArray objectAtIndex:arrayIndex];
        if (arrayIndex == 0) {
            float stringlabelHeight = [self getHeightForString:FollowingChangesWereMadeToThisTimesheet fontSize:RepliconFontSize_14 forWidth:290];
            
            UILabel  *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 290, stringlabelHeight)];
            headerLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14];
            headerLabel.textColor =  RepliconStandardBlackColor;
            headerLabel.textAlignment = NSTextAlignmentLeft;
            headerLabel.backgroundColor =[ UIColor clearColor] ;
            headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
            headerLabel.numberOfLines = 0;
            headerLabel.text = entryDetail;
            [self.changesListScrollView addSubview:headerLabel];
            previousLabelHeightAndOrigin = previousLabelHeightAndOrigin+stringlabelHeight+15;
        }
        else{
            previousLabelHeightAndOrigin= previousLabelHeightAndOrigin+10;
            NSString *reasonForString = @"";
            for (int index= 0; index < [entryDetail count]; index++) {
                NSString *dateString=[[[entryDetail objectAtIndex:index] objectAtIndex:0] objectForKey:@"header"];
                float dateStringlabelHeight = [self getHeightForString:dateString fontSize:RepliconFontSize_14 forWidth:290];
                UILabel  *dateStringLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 7+previousLabelHeightAndOrigin, 290, dateStringlabelHeight)];
                dateStringLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14];
                dateStringLabel.textColor =  RepliconStandardBlackColor;
                dateStringLabel.textAlignment = NSTextAlignmentLeft;
                dateStringLabel.backgroundColor =[ UIColor clearColor] ;
                dateStringLabel.lineBreakMode = NSLineBreakByWordWrapping;
                dateStringLabel.numberOfLines = 0;
                dateStringLabel.text = dateString;
                //[dateStringLabel sizeToFit];
                [self.changesListScrollView addSubview:dateStringLabel];
                NSMutableArray *dataArray = [entryDetail objectAtIndex:index];
                previousLabelHeightAndOrigin = previousLabelHeightAndOrigin +  dateStringlabelHeight  ;
                for (int i=0; i<[dataArray count]; i++) {
                    NSDictionary *dataDict =  [dataArray objectAtIndex:i];
                    NSString *entryHeaderString = [NSString stringWithFormat:@"- %@", [dataDict objectForKey:@"entryHeader"]];
                    float entryHeaderStringLabelabelHeight = [self getHeightForString:entryHeaderString fontSize:RepliconFontSize_14 forWidth:290];
                    UILabel  *entryHeaderStringLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, previousLabelHeightAndOrigin+7, 290, entryHeaderStringLabelabelHeight)];
                    entryHeaderStringLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14];
                    entryHeaderStringLabel.textColor =  RepliconStandardBlackColor;
                    entryHeaderStringLabel.text = entryHeaderString;
                    entryHeaderStringLabel.textAlignment = NSTextAlignmentLeft;
                    entryHeaderStringLabel.backgroundColor =[ UIColor clearColor] ;
                    entryHeaderStringLabel.lineBreakMode = NSLineBreakByWordWrapping;
                    entryHeaderStringLabel.numberOfLines = 0;
                    BOOL isSameHeader = false;
                    if ([dataArray count] >1 && i>0) {
                        NSString *prevoiusHeader = [[dataArray objectAtIndex:i-1] objectForKey:@"entryHeader"];
                        NSString *currentHeader = [[dataArray objectAtIndex:i] objectForKey:@"entryHeader"];
                        if ([currentHeader isEqualToString:prevoiusHeader]) {
                            isSameHeader =TRUE;
                        }
                    }
                    
                    float y_offset = 0;
                    if (isSameHeader) {
                        NSString *prevoiusHeader = [[dataArray objectAtIndex:i] objectForKey:@"entryHeader"];
                        float entryHeaderStringLabelabelHeight = [self getHeightForString:prevoiusHeader fontSize:RepliconFontSize_14 forWidth:290];
                        y_offset = -entryHeaderStringLabelabelHeight;
                    }
                    
                    
                    NSString *changeString = [NSString stringWithFormat:@"* %@", [dataDict objectForKey:@"change"]];
                    float changelabelHeight = [self getHeightForString:changeString fontSize:RepliconFontSize_14 forWidth:290];
                    UILabel  *reasonForChangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, previousLabelHeightAndOrigin+entryHeaderStringLabelabelHeight+4+y_offset, 290, changelabelHeight)];
                    reasonForChangeLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14];
                    reasonForChangeLabel.textColor =  RepliconStandardBlackColor;
                    reasonForChangeLabel.text = changeString;
                    reasonForChangeLabel.textAlignment = NSTextAlignmentLeft;
                    reasonForChangeLabel.backgroundColor =[ UIColor clearColor] ;
                    reasonForChangeLabel.lineBreakMode = NSLineBreakByWordWrapping;
                    reasonForChangeLabel.numberOfLines = 0;
                    if (![[dataDict objectForKey:@"change"] isKindOfClass:[NSNull class]] && [dataDict objectForKey:@"change"] != nil) {
                        [self.changesListScrollView addSubview:reasonForChangeLabel];
                        if (!isSameHeader) {
                            [self.changesListScrollView addSubview:entryHeaderStringLabel];
                            previousLabelHeightAndOrigin = previousLabelHeightAndOrigin+entryHeaderStringLabelabelHeight+changelabelHeight+4;
                        }
                        else{
                            previousLabelHeightAndOrigin = previousLabelHeightAndOrigin+changelabelHeight+4;
                        }
                    }
                    else
                    {
                            [self.changesListScrollView addSubview:entryHeaderStringLabel];
                            previousLabelHeightAndOrigin = previousLabelHeightAndOrigin+entryHeaderStringLabelabelHeight+4;
                    }
                    
                    reasonForString = [dataDict objectForKey:@"reasonForChange"];
                }
            }
            
            
            UIImage *lowerImage = [Util thumbnailImage:Cell_HairLine_Image];
            UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0, SCREEN_WIDTH,lowerImage.size.height)];
            [lineImageView setImage:lowerImage];
            
            float changeStringlabelHeight = [self getHeightForString:ReasonForChange fontSize:RepliconFontSize_12 forWidth:290];
            float reasonStringlabelHeight = [self getHeightForString:reasonForString fontSize:RepliconFontSize_14 forWidth:290];
            
            UIView *footer=[[UIView alloc] initWithFrame:CGRectMake(0,previousLabelHeightAndOrigin+16,SCREEN_WIDTH,changeStringlabelHeight+reasonStringlabelHeight +45)];
            
            [footer setBackgroundColor:[UIColor whiteColor]];
            
            
            UILabel  *reasonForChangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH, changeStringlabelHeight)];
            reasonForChangeLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12];
            reasonForChangeLabel.textColor =  RepliconStandardGrayColor;
            reasonForChangeLabel.text = RPLocalizedString(ReasonForChange, @"");
            reasonForChangeLabel.backgroundColor = [UIColor clearColor];
            
            
            UILabel  *reasonLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, reasonForChangeLabel.frame.size.height+reasonForChangeLabel.frame.origin.y+10, 290, reasonStringlabelHeight)];
            reasonLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14];
            reasonLabel.textColor =  RepliconStandardBlackColor;
            reasonLabel.backgroundColor = [UIColor clearColor];
            reasonLabel.lineBreakMode = NSLineBreakByWordWrapping;
            reasonLabel.numberOfLines = 0;
            reasonLabel.text = reasonForString;
            [reasonLabel sizeToFit];
            [footer addSubview:lineImageView];
            [footer addSubview:reasonForChangeLabel];
            [footer addSubview:reasonLabel];
            [self.changesListScrollView addSubview:footer];
            
            previousLabelHeightAndOrigin = previousLabelHeightAndOrigin+16+footer.frame.size.height;
        }
    }
    self.changesListScrollView.contentSize = CGSizeMake(self.view.frame.size.width,previousLabelHeightAndOrigin+70);
}




-(float)getHeightForString:(NSString *)string fontSize:(int)fontSize forWidth:(float)width
{
   
    // Let's make an NSAttributedString first
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    //Add LineBreakMode
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
    // Add Font
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} range:NSMakeRange(0, attributedString.length)];
    
    //Now let's make the Bounding Rect
    CGSize mainSize = [attributedString boundingRectWithSize:CGSizeMake(width, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    
    if (mainSize.width==0 && mainSize.height ==0)
    {
        mainSize=CGSizeMake(0,0);
    }
    return mainSize.height;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
