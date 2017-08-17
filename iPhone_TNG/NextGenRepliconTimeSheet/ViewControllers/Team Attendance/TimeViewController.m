//
//  TimeViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 18/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "TimeViewController.h"
#import "Constants.h"
#import "TeamTimeModel.h"
#import "PunchHistoryModel.h"
#import "TeamTimeUserCell.h"
#import "TeamTimePairCell.h"
#import "DarkGraySectionHeader.h"
#import "TeamTimeActivityCell.h"
#import "TeamTimeUserObject.h"
#import "TeamTimeActivityObject.h"
#import "TeamTimePunchObject.h"
#import "TeamTimeBreakObject.h"
#import "TeamTimeBreakCell.h"
#import "PunchEntryViewController.h"
#import "TeamTimeViewController.h"
#import "TeamTimeNoEntriesCell.h"
#import "TeamTimePlaceholderCell.h"


@interface TimeViewController ()

@end




@implementation TimeViewController
@synthesize delegate;
@synthesize infoTableView;
@synthesize dataArray;
@synthesize currentDateString;
@synthesize btnClicked;
@synthesize isEditPunchAllowed,isFromPunchHistory;

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
    [self.view setBackgroundColor:RepliconStandardBackgroundColor];
    UIImage *separtorImage=[Util thumbnailImage:TOP_SEPARATOR];
    UIView *separatorView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    [separatorView setBackgroundColor:[UIColor colorWithPatternImage:separtorImage]];
    [self.view addSubview:separatorView];
    if (infoTableView==nil)
    {
        float height=0.0;
        float version= [[UIDevice currentDevice].systemVersion newFloatValue];
        
        if (version<7.0)
        {
            height=145;
            
        }
        else
        {
            height=215;
        }

        
        UITableView *temptimeSheetsTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 1, self.view.frame.size.width, self.view.frame.size.height-height) style:UITableViewStylePlain];
		self.infoTableView=temptimeSheetsTableView;
        self.infoTableView.separatorColor=[UIColor clearColor];
        
	}
	self.infoTableView.delegate=self;
	self.infoTableView.dataSource=self;
	[self.view addSubview:infoTableView];
	
    UIView *bckView = [UIView new];
	[bckView setBackgroundColor:[UIColor clearColor]];
	[self.infoTableView setBackgroundView:bckView];
    self.infoTableView.tableHeaderView=nil;
    
    [self.infoTableView registerNib:[UINib nibWithNibName:USER_CELL bundle:[NSBundle mainBundle]] forCellReuseIdentifier:USER_CELL];
    [self.infoTableView registerNib:[UINib nibWithNibName:ACTIVITY_CELL bundle:[NSBundle mainBundle]] forCellReuseIdentifier:ACTIVITY_CELL];
    [self.infoTableView registerNib:[UINib nibWithNibName:PUNCH_CELL bundle:[NSBundle mainBundle]] forCellReuseIdentifier:PUNCH_CELL];
    [self.infoTableView registerNib:[UINib nibWithNibName:BREAK_CELL bundle:[NSBundle mainBundle]] forCellReuseIdentifier:BREAK_CELL];
    [self.infoTableView registerNib:[UINib nibWithNibName:NO_ENTRIES_CELL bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NO_ENTRIES_CELL];
    [self.infoTableView registerNib:[UINib nibWithNibName:PLACEHOLDER_CELL bundle:[NSBundle mainBundle]] forCellReuseIdentifier:PLACEHOLDER_CELL];
    
	// Do any additional setup after loading the view.
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSMutableArray *tempDataarray=[NSMutableArray array];
    
    for (int i=0; i<[self.dataArray count]; i++)
    {
         id tmpObj=[self.dataArray objectAtIndex:i];
        
        [tempDataarray addObject:tmpObj];
        if([tmpObj isKindOfClass:[TeamTimePunchObject class]])
        {
            
            
            if (i<[self.dataArray count]-1)
            {
                id tmpObj1=[self.dataArray objectAtIndex:i+1];
                if([tmpObj1 isKindOfClass:[TeamTimeUserObject class]])
                {
                    [tempDataarray addObject:@""];
                }
            }
        }
    }
    
    self.dataArray=tempDataarray;
                                   
    return [self.dataArray count];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id tmpObj=[self.dataArray objectAtIndex:indexPath.row];
    if([tmpObj isKindOfClass:[TeamTimeActivityObject class]])
    {
        TeamTimeActivityObject *activityObj=(TeamTimeActivityObject *)tmpObj;
        NSString *activityName=activityObj.activityName;
        if (activityName==nil||[activityName isKindOfClass:[NSNull class]]||[activityName isEqualToString:@""]) {
            return 25;
        }
    }
    
    else if ([tmpObj isKindOfClass:[NSString class]])
    {
        
        if ([tmpObj isEqualToString:@""])
        {
            return 10.0;
        }
        
        
        
        
    }

    
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    
    id tmpObj=[self.dataArray objectAtIndex:indexPath.row];
    NSString *CellIdentifier = nil;
    if ([tmpObj isKindOfClass:[NSString class]])
    {
        if ([tmpObj isEqualToString:RPLocalizedString(NO_ENTRIES_TEXT, NO_ENTRIES_TEXT)])
        {
            CellIdentifier = @"TeamTimeNoEntriesCell";
        }
        else
        {
            CellIdentifier = PLACEHOLDER_CELL;
        }
        
    }
    else{
        CellIdentifier = [tmpObj CellIdentifier];
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if ([tmpObj isKindOfClass:[TeamTimeUserObject class]])
    {
        
        TeamTimeUserObject *userObj=(TeamTimeUserObject *)tmpObj;
        TeamTimeUserCell *tcell = (TeamTimeUserCell*)cell;
        tcell.delegate=self;
        [tcell setIndexPath:indexPath];
        if (tcell == nil) {
            
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TeamTimeUserCell" owner:self options:nil];
            tcell = [objects objectAtIndex:0];
        }
        
        NSString *totalHours=[NSString stringWithFormat:@"%@",userObj.totalHours];
        if ([totalHours newFloatValue]==0) {
            totalHours=@"0.00";
        }
        if (self.isFromPunchHistory)
        {
            tcell.titleLabel.text = RPLocalizedString(TOTAL, @"");
            tcell.titleLabel.hidden=YES;
            tcell.durationLabel.hidden=YES;
            tcell.breakHoursLabel.text = [NSString stringWithFormat:@"%@:",RPLocalizedString(BREAK_HOURS_TITLE, @"")];
            tcell.regularHoursLabel.text = [NSString stringWithFormat:@"%@:",RPLocalizedString(WORK_HOURS_TITLE, @"")];
            tcell.breakHoursValueLabel.text = userObj.breakHours;
            tcell.regularHoursValueLabel.text = userObj.regularHours;
            
            
        }
        else
        {
            tcell.breakHoursLabel.hidden=YES;
            tcell.regularHoursLabel.hidden=YES;
            tcell.breakHoursValueLabel.hidden=YES;
            tcell.regularHoursValueLabel.hidden=YES;
            tcell.titleLabel.text = userObj.userName;
        }
        
        tcell.durationLabel.text = userObj.durationInHrsMins;
        if (isEditPunchAllowed)
        {
            
            tcell.durationLabel.frame=CGRectMake(220, 11, 57, 21);
            [tcell.addButton setHidden:NO];
        }
        else
        {
            tcell.durationLabel.frame=CGRectMake(240, 11, 57, 21);
            [tcell.addButton setHidden:YES];
        }
        
        
        
        
        if (userObj.isUserHasNoData == TRUE) {
            [tcell.titleLabel setTextColor:[Util colorWithHex:@"#777777" alpha:1]];
            [tcell.durationLabel setTextColor:[Util colorWithHex:@"#777777" alpha:1]];
        }
        else
        {
            tcell.titleLabel.textColor = RepliconStandardBlackColor;
            tcell.durationLabel.textColor = RepliconStandardBlackColor;
        }
        if (isFromPunchHistory)
        {
            [tcell.addButton setHidden:YES];
        }
        
        
        NSString* bgImage = @"bg_teamTimeUserCell";
        tcell.backgroundImage = [UIImage imageNamed:bgImage];
        return tcell;
    }
    else if([tmpObj isKindOfClass:[TeamTimeActivityObject class]])
    {
        TeamTimeActivityObject *activityObj=(TeamTimeActivityObject *)tmpObj;
        TeamTimeActivityCell *tcell = (TeamTimeActivityCell*)cell;
        if (tcell == nil) {
            
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TeamTimeActivityCell" owner:self options:nil];
            tcell = [objects objectAtIndex:0];
        }
        NSString *totalHours=[NSString stringWithFormat:@"%@",activityObj.totalHours];
        if ([totalHours newFloatValue]==0) {
            totalHours=@"0.00";
        }
        tcell.contentView.backgroundColor=[UIColor whiteColor];
        tcell.titleLabel.text = activityObj.activityName;
        tcell.durationLabel.text = activityObj.durationInHrsMins;
        tcell.durationLabelLeading.active = NO;//Prithiviraj J
        [tcell.durationLabel setHidden:YES];//Ullas M L
        return tcell;
    }
    else if([tmpObj isKindOfClass:[TeamTimeBreakObject class]])
    {
        TeamTimeBreakObject *breakObj=(TeamTimeBreakObject *)tmpObj;
        TeamTimeBreakCell *tcell = (TeamTimeBreakCell*)cell;
        if (tcell == nil) {
            
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TeamTimeBreakCell" owner:self options:nil];
            tcell = [objects objectAtIndex:0];
        }
        NSString *totalHours=[NSString stringWithFormat:@"%@",breakObj.totalHours];
        if ([totalHours newFloatValue]==0) {
            totalHours=@"0.00";
        }
        tcell.contentView.backgroundColor=[UIColor whiteColor];
        tcell.titleLabel.text = breakObj.breakName;
        tcell.durationLabel.text = breakObj.durationInHrsMins;
        tcell.durationLabelLeading.active = NO;//Prithiviraj J
        [tcell.durationLabel setHidden:YES];//Ullas M L
        return tcell;
    }
    else if ([tmpObj isKindOfClass:[TeamTimePunchObject class]])
    {
        TeamTimePunchObject *punchObj=(TeamTimePunchObject *)tmpObj;
        TeamTimePairCell *tCell =(TeamTimePairCell*)cell;
        tCell.delegate=self;
        [tCell setIndexPath:indexPath];
        if (tCell == nil) {
            
            NSArray *Objects = [[NSBundle mainBundle] loadNibNamed:@"TeamTimePairCell" owner:self options:nil];
            tCell = [Objects objectAtIndex:0];
        }
        
        BOOL hasInPunch=NO;
        BOOL hasOutPunch=NO;
        NSString *startTimeString=punchObj.PunchInTime;
        NSString *endTimeString=punchObj.PunchOutTime;
        NSString *punchInUri=punchObj.punchInUri;
        NSString *punchOutUri=punchObj.punchOutUri;
        
        
        if (punchInUri!=nil && ![punchInUri isKindOfClass:[NSNull class]]&& ![punchInUri isEqualToString:@""])
        {
            hasInPunch=YES;
        }
        
        if (punchOutUri!=nil && ![punchOutUri isKindOfClass:[NSNull class]]&& ![punchOutUri isEqualToString:@""])
        {
            hasOutPunch=YES;
        }
        
        for (id views in tCell.inImageView.subviews)
        {
            [views removeFromSuperview];
        }
        
        for (id views in tCell.outImageView.subviews)
        {
            [views removeFromSuperview];
        }
        
        tCell.inPunchLabel.text=RPLocalizedString(IN_TEXT, IN_TEXT);
        tCell.outPunchLabel.text=RPLocalizedString(OUT_TEXT, OUT_TEXT);
        tCell.inMissingPunchLabel.text=RPLocalizedString(IN_TEXT, IN_TEXT);
        tCell.outMissingPunchLabel.text=RPLocalizedString(OUT_TEXT, OUT_TEXT);
        
        tCell.inPunchLabel.hidden=FALSE;
        tCell.outPunchLabel.hidden=FALSE;
        tCell.inMissingPunchLabel.hidden=FALSE;
        tCell.outMissingPunchLabel.hidden=FALSE;

        
        if (punchObj.isBreakPunch)
        {
            if (hasInPunch) {
                tCell.inImageView.image=[UIImage imageNamed:@"icon_Break-Tag-Yellow"];
            }
            if (hasOutPunch) {
                tCell.outImageView.image=[UIImage imageNamed:@"icon_Break-Tag-Yellow"];
            }

            tCell.inPunchLabel.hidden=TRUE;
            tCell.outPunchLabel.hidden=TRUE;
            tCell.inMissingPunchLabel.hidden=TRUE;
            tCell.outMissingPunchLabel.hidden=TRUE;
        }
        else
        {
            if (hasInPunch) {
                tCell.inImageView.image=[UIImage imageNamed:@"icon_IN-Tag-Green"];
            }
            if (hasOutPunch) {
                tCell.outImageView.image=[UIImage imageNamed:@"icon_OUT-Tag-Gray"];
            }
        }
        [tCell.inmanualImageView setHidden:YES];
        [tCell.outmanualImageView setHidden:YES];
        if (punchObj.isInManualEditPunch)
        {
            [tCell.inmanualImageView setHidden:NO];
        }
        if (punchObj.isOutManualEditPunch)
        {
            [tCell.outmanualImageView setHidden:NO];
        }

        BOOL _isCollapsed=YES;
        BOOL _isReadOnly=YES;
        tCell.showAsCollapsed = _isCollapsed;
        tCell.userInteractionEnabled = (!_isReadOnly && !_isCollapsed);
        tCell.selectionStyle = (_isReadOnly || _isCollapsed) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
        if(_isCollapsed) {
            tCell.backgroundImageName = @"bg_timePairCollapsed";
        }
        else
        {
            tCell.backgroundImageName = @"bg_timePair";
            //tCell.backgroundImageName = rowInfo.isFirst ? @"bg_timePair-First" : @"bg_timePair";
        }
        tCell.transferredTag.hidden = YES;
        tCell.transferredTag2.hidden = YES;
        NSString *status=punchObj.punchTransferredStatus;
        if ([status isEqualToString:TRANSFERRED_STATUS_URI]) {
            tCell.transferredTag.hidden = NO;
            tCell.transferredTag2.hidden = NO;
            tCell.transferredTag.image=[UIImage imageNamed:@"icon_transferredTag-Green"];
            tCell.transferredTag2.image=[UIImage imageNamed:@"icon_transferredTag-Green"];
        }
        else if([status isEqualToString:TRANSFERRED_ERROR_STATUS_URI])
        {
            tCell.transferredTag.hidden = NO;
            tCell.transferredTag2.hidden = NO;
            tCell.transferredTag.image=[UIImage imageNamed:@"icon_transferredTag-Red"];
            tCell.transferredTag2.image=[UIImage imageNamed:@"icon_transferredTag-Red"];
        }

        
        [tCell layoutIfNeeded];
        tCell.missingInTag.hidden = hasInPunch;
        tCell.missingOutTag.hidden = hasOutPunch;
        tCell.inMissingPunchLabel.hidden = hasInPunch;
        tCell.outMissingPunchLabel.hidden = hasOutPunch;
        tCell.inTimeLabel.hidden = tCell.inAMPMLabel.hidden = !hasInPunch;
        tCell.outTimeLabel.hidden = tCell.outAMPMLabel.hidden = !hasOutPunch;
        
        BOOL isInTimePM = NO;
        BOOL isOutTimePM = NO;
        
        
        if (hasInPunch)
        {
            NSDictionary *startTimeDict=[Util getOnlyTimeFromStringWithAMPMString:startTimeString];
            if ([[[startTimeDict objectForKey:@"FORMAT"] lowercaseString] isEqualToString:@"pm"])
            {
                isInTimePM=YES;
            }
            tCell.inTimeLabel.text = [startTimeDict objectForKey:@"TIME"];
        }
        if (hasOutPunch)
        {
            NSDictionary *endTimeDict=[Util getOnlyTimeFromStringWithAMPMString:endTimeString];
            if ([[[endTimeDict objectForKey:@"FORMAT"] lowercaseString] isEqualToString:@"pm"])
            {
                isOutTimePM=YES;
            }
            tCell.outTimeLabel.text = [endTimeDict objectForKey:@"TIME"];
        }
        
        
        
        
        NSString *hoursText=nil;
        if (startTimeString==nil||[startTimeString isKindOfClass:[NSNull class]]||
            endTimeString==nil||[endTimeString isKindOfClass:[NSNull class]])
        {
            hoursText=@"-";//hoursText=@"0:00";
//            tCell.hoursLabel.frame=CGRectMake(228, 15, 57, 21);
        }
        else
        {
            
//            tCell.hoursLabel.frame=CGRectMake(240, 15, 57, 21);
            //MOBI- 595 JUHI
            id punchInTS=punchObj.PunchInDateTimestamp;
            id punchOutTS=punchObj.PunchOutDateTimestamp;
            NSString *PunchInDateTimestamp=nil;
            if (punchInTS!=nil && ![punchInTS isKindOfClass:[NSNull class]])
            {
                PunchInDateTimestamp=[NSString stringWithFormat:@"%@",punchObj.PunchInDateTimestamp];
            }
            NSString *PunchOutDateTimestamp=nil;
            if (punchOutTS!=nil && ![punchOutTS isKindOfClass:[NSNull class]])
            {
                PunchOutDateTimestamp=[NSString stringWithFormat:@"%@",punchObj.PunchOutDateTimestamp];
            }
            if (PunchInDateTimestamp!=nil && ![PunchInDateTimestamp isKindOfClass:[NSNull class]]&& ![PunchInDateTimestamp isEqualToString:@""]&& PunchOutDateTimestamp!=nil && ![PunchOutDateTimestamp isKindOfClass:[NSNull class]]&& ![PunchOutDateTimestamp isEqualToString:@""] )
            {
                NSDate *inPunchDate=[Util convertTimestampFromDBToDate:PunchInDateTimestamp];
                NSDate *outPunchDate=[Util convertTimestampFromDBToDate:PunchOutDateTimestamp];
                NSMutableDictionary *diffDict=[Util getDifferenceDictionaryForInTimeDate:inPunchDate outTimeDate:outPunchDate];
                int hours=[[diffDict objectForKey:@"hour"] intValue];
                int minutes=[[diffDict objectForKey:@"minute"] intValue];
                if (minutes<10)
                {
                    hoursText=[NSString stringWithFormat:@"%d:0%d",hours,minutes];
                }
                else
                {
                    hoursText=[NSString stringWithFormat:@"%d:%d",hours,minutes];
                }
            }
            
            
            
            

            
        }
        
        tCell.inAMPMLabel.text = isInTimePM ? @"PM" : @"AM";
        tCell.outAMPMLabel.text = isOutTimePM ? @"PM" : @"AM";
        tCell.hoursLabel.text = hoursText;
        tCell.hoursLabel.textColor = (hasInPunch && hasOutPunch) ? [UIColor blackColor] : [UIColor redColor];
        tCell.indexPath=indexPath;
        
       
        tCell.userInteractionEnabled=TRUE;
        
        return tCell;
    }
    else if ([tmpObj isKindOfClass:[NSString class]])
    {
        
        if ([tmpObj isEqualToString:RPLocalizedString(NO_ENTRIES_TEXT, NO_ENTRIES_TEXT)])
        {
            TeamTimeNoEntriesCell *tcell = (TeamTimeNoEntriesCell*)cell;
            if (tcell == nil) {
                
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TeamTimeNoEntriesCell" owner:self options:nil];
                tcell = [objects objectAtIndex:0];
            }
            tcell.titleLabel.text = RPLocalizedString(NO_ENTRIES_TEXT, @"");
            return tcell;
        }
        else
        {
            TeamTimePlaceholderCell *tcell = (TeamTimePlaceholderCell*)cell;
            if (tcell == nil) {
                
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:PLACEHOLDER_CELL owner:self options:nil];
                tcell = [objects objectAtIndex:0];
            }
            tcell.titleLabel.text = @"";
            return tcell;
        }

        
       
    }

	
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"--didselect");
}
- (void)didSelectRowWithIndexPath:(NSIndexPath *)indexPath
{
    if ([delegate isKindOfClass:[TeamTimeViewController class]])
    {
        [delegate setBtnClicked:btnClicked];
        [delegate setDataArray:dataArray];
        [delegate didSelectRowAtIndexPath:indexPath];


    }
   
    
    
}
- (void)addPunch:(NSIndexPath *)indexPath
{
    if ([delegate isKindOfClass:[TeamTimeViewController class]] )
    {
        TeamTimeViewController *tc=(TeamTimeViewController *)delegate;
        [tc setBtnClicked:@"In"];
        [tc setDataArray:dataArray];
        [tc addPunch:indexPath isFRomAddPunch:YES];
        
        
    }
    
    
    
}
-(void )getHeader
{
    static NSString *CellIdentifier = @"TeamTimePunchCustomCellIdentifier";
    DarkGraySectionHeader *cell = (DarkGraySectionHeader*)[self.infoTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"DarkGraySectionHeader" owner:self options:nil];
        cell = [objects objectAtIndex:0];
    }
    cell.titleLabel.text = self.currentDateString;
    [self.infoTableView setTableHeaderView:cell];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSObject

-(void)dealloc
{
    self.infoTableView.delegate = nil;
    self.infoTableView.dataSource = nil;
}

@end
