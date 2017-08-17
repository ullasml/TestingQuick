//
//  LocationViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 18/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "LocationViewController.h"
#import "Constants.h"
#import "TeamTimeModel.h"
#import "PunchHistoryModel.h"
#import "TeamTimeUserCell.h"
#import "TeamTimeLocationCell.h"
#import "DarkGraySectionHeader.h"
#import "TeamTimeUserObject.h"
#import "TeamTimeActivityObject.h"
#import "TeamTimePunchObject.h"
#import "TeamTimeNoEntriesCell.h"

@interface LocationViewController ()

@end

@implementation LocationViewController
@synthesize infoTableView;
@synthesize dataArray;
@synthesize currentDateString;
@synthesize isFromPunchHistory;

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [self.infoTableView registerNib:[UINib nibWithNibName:LOCATION_PAIR_CELL bundle:[NSBundle mainBundle]] forCellReuseIdentifier:LOCATION_PAIR_CELL];
    
     [self.infoTableView registerNib:[UINib nibWithNibName:NO_ENTRIES_CELL bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NO_ENTRIES_CELL];

}

-(void)getHeader
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id tmpObj=[self.dataArray objectAtIndex:indexPath.row];
    if ([tmpObj isKindOfClass:[TeamTimeUserObject class]])
    {
        return 44;
    }
    else if ([tmpObj isKindOfClass:[NSString class]])
    {
        return 44;
    }
    else
    {
        return 65;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    
    id tmpObj=[self.dataArray objectAtIndex:indexPath.row];
     NSString *CellIdentifier = nil;
    if ([tmpObj isKindOfClass:[NSString class]]) {
        CellIdentifier = @"TeamTimeNoEntriesCell";
    }
    else{
        CellIdentifier = [tmpObj CellIdentifier];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if ([tmpObj isKindOfClass:[TeamTimeUserObject class]])
    {
        
        TeamTimeUserObject *userObj=(TeamTimeUserObject *)tmpObj;
        TeamTimeUserCell *tcell = (TeamTimeUserCell*)cell;
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
        [tcell.addButton setHidden:YES];
        if (userObj.isUserHasNoData == TRUE) {
            [tcell.titleLabel setTextColor:[Util colorWithHex:@"#777777" alpha:1]];
            [tcell.durationLabel setTextColor:[Util colorWithHex:@"#777777" alpha:1]];
        }
        else
        {
            tcell.titleLabel.textColor = RepliconStandardBlackColor;
            tcell.durationLabel.textColor = RepliconStandardBlackColor;
        }

        NSString* bgImage = @"bg_teamTimeUserCell";
        tcell.backgroundImage = [UIImage imageNamed:bgImage];
        return tcell;
    }
    else if ([tmpObj isKindOfClass:[TeamTimePunchObject class]])
    {

        
        TeamTimePunchObject *punchObj=(TeamTimePunchObject *)tmpObj;
        TeamTimeLocationCell *tCell = (TeamTimeLocationCell*)cell;
        if (tCell == nil) {
            
            NSArray *Objects = [[NSBundle mainBundle] loadNibNamed:@"TeamTimeImagesCell" owner:self options:nil];
            tCell = [Objects objectAtIndex:0];
        }
        
        BOOL hasInPunch=NO;
        BOOL hasOutPunch=NO;
        NSString *startTimeString=punchObj.PunchInTime;
        NSString *endTimeString=punchObj.PunchOutTime;
        NSString *punchInUri=punchObj.punchInUri;
        NSString *punchOutUri=punchObj.punchOutUri;
        NSString *punchInAddress=punchObj.PunchInAddress;
        NSString *punchOutAddress=punchObj.PunchOutAddress;
//        NSString *inPunchImagePath=punchObj.punchInFullSizeImageLink;
//        NSString *outPunchImagePath=punchObj.punchOutFullSizeImageLink;
//        NSString *inlatitude=punchObj.PunchInLatitude;
//        NSString *inlongitude=punchObj.PunchInLongitude;
//        NSString *outlatitude=punchObj.PunchOutLatitude;
//        NSString *outlongitude=punchObj.PunchOutLongitude;

        
        
        
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
        
//        BOOL _isReadOnly=FALSE;
        BOOL _isReadOnly=TRUE;
        tCell.userInteractionEnabled = !_isReadOnly;
        tCell.accessoryType = _isReadOnly ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
        
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
        
        
        tCell.inAMPMLabel.text = isInTimePM ? @"PM" : @"AM";
        tCell.outAMPMLabel.text = isOutTimePM ? @"PM" : @"AM";
        
        
        
        
        if(punchInAddress != nil && ![punchInAddress isKindOfClass:[NSNull class]])
        {
        
            tCell.inLocationLabel.text = punchInAddress;
            tCell.inLocationLabel.textColor = [UIColor grayColor];
        } else {
            tCell.inLocationLabel.text = RPLocalizedString(LOCATION_UNAVAILABLE_STRING, LOCATION_UNAVAILABLE_STRING);
            tCell.inLocationLabel.textColor = [UIColor redColor];
        }
        
        if(punchOutAddress != nil &&![punchOutAddress isKindOfClass:[NSNull class]])
        {
            tCell.outLocationLabel.text = punchOutAddress;
            tCell.outLocationLabel.textColor = [UIColor grayColor];
        } else {
            tCell.outLocationLabel.text = RPLocalizedString(LOCATION_UNAVAILABLE_STRING, LOCATION_UNAVAILABLE_STRING);
            tCell.outLocationLabel.textColor = [UIColor redColor];
        }
        
        tCell.transferredTag.hidden = YES;
        tCell.transferredTag2.hidden = YES;
        NSString *status=punchObj.punchTransferredStatus;
        
        if (status==nil || [status isKindOfClass:[NSNull class]])
        {
            status=@"";
        }
        
        
        else if ([status isEqualToString:TRANSFERRED_STATUS_URI]) {
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
        return tCell;
    }
    
    else if ([tmpObj isKindOfClass:[NSString class]]) {
        TeamTimeNoEntriesCell *tcell = (TeamTimeNoEntriesCell*)cell;
        if (tcell == nil) {
            
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TeamTimeNoEntriesCell" owner:self options:nil];
            tcell = [objects objectAtIndex:0];
        }
        tcell.titleLabel.text = RPLocalizedString(NO_ENTRIES_TEXT, @"");
        return tcell;
    }
	
    return nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    self.infoTableView.delegate = nil;
    self.infoTableView.dataSource = nil;
}

@end
