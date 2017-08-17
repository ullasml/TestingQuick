//
//  AuditTrialViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 07/07/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "AuditTrialViewController.h"
#import "ImageNameConstants.h"
#import "Constants.h"
#import "RepliconServiceManager.h"
#import "UIView+Additions.h"

@interface AuditTrialViewController ()

@end

@implementation AuditTrialViewController
@synthesize auditTrialInfoList;
@synthesize auditTrialInfoTableView;
@synthesize headerDateString;
@synthesize userName;
@synthesize isFromTeamTime;
@synthesize isFromAuditHistoryForPunch;
@synthesize punchActionuri;
@synthesize punchTime;
@synthesize punchTimeFormat;

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
    [self.view setBackgroundColor:RepliconStandardBackgroundColor];
    [Util setToolbarLabel: self withText: userName];
    UITableView *tempAuditTrialTableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.height) style:UITableViewStylePlain];
    
    self.auditTrialInfoTableView=tempAuditTrialTableView;
    self.auditTrialInfoTableView.separatorColor=[UIColor clearColor];
    self.auditTrialInfoTableView.backgroundColor = [UIColor clearColor];
    [self.auditTrialInfoTableView setDelegate:self];
    [self.auditTrialInfoTableView setDataSource:self];
    [self.view addSubview:self.auditTrialInfoTableView];
    
    
    UIView *bckView = [UIView new];
    [bckView setBackgroundColor:RepliconStandardBackgroundColor];
    [self.auditTrialInfoTableView setBackgroundView:bckView];
    
    
    
	UILabel	*headerViewLabl = [[UILabel alloc] initWithFrame:
                               CGRectMake(0.0,0.0,self.view.frame.size.width,30.0)];
	[headerViewLabl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1]];
    [headerViewLabl setTextColor:RepliconStandardBlackColor];
	[headerViewLabl setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
    [headerViewLabl setText:self.headerDateString];
    [self.auditTrialInfoTableView setTableHeaderView:headerViewLabl];

    if (isFromTeamTime)
    {
        UIBarButtonItem *tempLeftButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(Done,@"")
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self action:@selector(doneAction:)];
        [self.navigationItem setRightBarButtonItem:tempLeftButtonOuterBtn animated:NO];
    }
    
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect frame =  self.view.frame;
    self.auditTrialInfoTableView.frame = frame;
}

-(void)doneAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)auditTrialDataReceivedAction:(NSNotification *)notification
{
    self.auditTrialInfoList=[[NSMutableArray alloc]init];
    NSDictionary *dict=notification.userInfo;
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AUDIT_TRIAL_NOTIFICATION object:nil];
    id responseDict=[dict objectForKey:@"DataResponse"];
    NSMutableArray *responseArray=[[responseDict objectForKey:@"response"] objectForKey:@"d"];
    if (isFromAuditHistoryForPunch)
    {
        AuditTrialPunchObject *auditTrialObj = [[AuditTrialPunchObject alloc]init];
        auditTrialObj.punchActionuri=punchActionuri;
        auditTrialObj.punchDate=nil;
        auditTrialObj.punchTime=punchTime;
        auditTrialObj.punchTimeFormat=punchTimeFormat;
        auditTrialObj.punchtimeInUtc=nil;
        auditTrialObj.commentsList = [self createCommentList:responseArray];
        
        NSString *finalStr=@"";
        for (NSUInteger k=[auditTrialObj.commentsList count]; k>0; k--)
        {
            NSString *str=[NSString stringWithFormat:@"%@",[auditTrialObj.commentsList objectAtIndex:k-1]];
            
            if (k==[auditTrialObj.commentsList count])
            {
                if ([auditTrialObj.commentsList count]==1)
                {
                    finalStr=[finalStr stringByAppendingFormat:@"\n%@\n\n",str];
                }
                else
                {
                    finalStr=[finalStr stringByAppendingFormat:@"\n%@",str];
                }
            }
            else
            {
                if (k==1)
                {
                    finalStr=[finalStr stringByAppendingFormat:@"\n\n%@\n\n",str];
                }
                else
                {
                    finalStr=[finalStr stringByAppendingFormat:@"\n\n%@",str];
                }
                
            }
            
            
        }
        
        
        float height=[self getHeightForString:finalStr fontSize:12 forWidth:260];
        
        NSMutableDictionary *commentsInfoDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:finalStr,@"ChangesString",[NSNumber numberWithFloat:height],@"height", nil];
        auditTrialObj.commentsInfoDict=commentsInfoDict;
        [auditTrialInfoList addObject:auditTrialObj];

    }
    else
    {
        for(int i=0; i<[responseArray count]; i++)
        {
            NSMutableDictionary *dict=[responseArray objectAtIndex:i];
            AuditTrialPunchObject *auditTrialObj = [[AuditTrialPunchObject alloc]init];
            auditTrialObj.punchActionuri=[[dict objectForKey:@"timePunch"]objectForKey:@"actionUri"];
            auditTrialObj.punchDate=[Util convertDateToString:[Util convertApiDateDictToDateTimeFormat:[[dict objectForKey:@"timePunch"] objectForKey:@"punchTime"]]];
            NSString *punchTimeTemp=[Util convertDateToGetTimeOnly:[Util convertApiDateDictToDateTimeFormat:[[dict objectForKey:@"timePunch"] objectForKey:@"punchTime"]]];
            
            auditTrialObj.punchTime=[NSString stringWithFormat:@"%@",[Util return12HourStringOnlyWithoutAMPPM:punchTimeTemp]];
            auditTrialObj.punchTimeFormat=[Util convertDateToGetFormatOnly:[Util convertApiDateDictToDateTimeFormat:[[dict objectForKey:@"timePunch"] objectForKey:@"punchTime"]]];
            auditTrialObj.punchtimeInUtc=[Util convertDateToString:[Util convertApiDateDictToDateTimeFormat:[[[dict objectForKey:@"timePunch"] objectForKey:@"punchTime"]objectForKey:@"valueInUtc"]]];
            auditTrialObj.commentsList = [self createCommentList:[dict objectForKey:@"auditRecords"]];
            
            NSString *finalStr=@"";
            for (NSUInteger k=[auditTrialObj.commentsList count]; k>0; k--)
            {
                NSString *str=[NSString stringWithFormat:@"%@",[auditTrialObj.commentsList objectAtIndex:k-1]];
                
                if (k==[auditTrialObj.commentsList count])
                {
                    if ([auditTrialObj.commentsList count]==1)
                    {
                        finalStr=[finalStr stringByAppendingFormat:@"\n%@\n\n",str];
                    }
                    else
                    {
                        finalStr=[finalStr stringByAppendingFormat:@"\n%@",str];
                    }
                }
                else
                {
                    if (k==1)
                    {
                        finalStr=[finalStr stringByAppendingFormat:@"\n\n%@\n\n",str];
                    }
                    else
                    {
                        finalStr=[finalStr stringByAppendingFormat:@"\n\n%@",str];
                    }
                    
                }
                
                
            }
            
            
            float height=[self getHeightForString:finalStr fontSize:12 forWidth:260];
            
            NSMutableDictionary *commentsInfoDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:finalStr,@"ChangesString",[NSNumber numberWithFloat:height],@"height", nil];
            auditTrialObj.commentsInfoDict=commentsInfoDict;
            [auditTrialInfoList addObject:auditTrialObj];
            
        }
        if ([responseArray count]==0)
        {
            
            
            UILabel	*placeHolderLabl = [[UILabel alloc] initWithFrame:
                                        CGRectMake(0,150,self.view.frame.size.width,50)];
            [placeHolderLabl setBackgroundColor:[UIColor clearColor]];
            [placeHolderLabl setTextColor:RepliconStandardBlackColor];
            [placeHolderLabl setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
            [placeHolderLabl setText:RPLocalizedString(NO_AUDIT_TRIAL_DATA, @"")];
            [placeHolderLabl setTextAlignment:NSTextAlignmentCenter];
            [self.view addSubview:placeHolderLabl];
        }
    }
    
    [self.auditTrialInfoTableView reloadData];
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
    float version= [[UIDevice currentDevice].systemVersion newFloatValue];
    if (version>=7.0)
    {
        NSString *fontName=RepliconFontFamily;
        CGSize maxSize = CGSizeMake(width, MAXFLOAT);
        CGRect labelRect = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize]} context:nil];
        return labelRect.size.height;
    }
    return mainSize.height;
}


-(NSArray*)createCommentList:(NSArray*)auditRecords
{
    NSMutableArray *commentsArray = [NSMutableArray array];
    
    for(int i =0; i <[auditRecords count]; i++)
    {
        NSDictionary *dict =[auditRecords objectAtIndex:i];
        
        NSString *changeByUser=nil;
        if([dict objectForKey:@"effectiveUser"]!=nil && ![[dict objectForKey:@"effectiveUser"] isKindOfClass:[NSNull class]])
        {
            changeByUser=[[dict objectForKey:@"effectiveUser"] objectForKey:@"displayText"];
        }
        
        NSDate *changedDateAndTime=nil;
        NSDate *changedTimeFromService=nil;
        if([dict objectForKey:@"timestamp"]!=nil && ![[dict objectForKey:@"timestamp"] isKindOfClass:[NSNull class]])
        {
            changedDateAndTime=[Util convertApiDateDictToDateTimeFormat:[dict objectForKey:@"timestamp"]];
            changedTimeFromService=[Util convertApiDateDictToDateTimeFormat:[dict objectForKey:@"timestamp"]];
        }
        
        NSString *fromAgent=nil;
        if([[dict objectForKey:@"clientAgent"] objectForKey:@"agentTypeUri"] !=nil && ![[[dict objectForKey:@"clientAgent"] objectForKey:@"agentTypeUri"] isKindOfClass:[NSNull class]])
        {
            fromAgent=[[dict objectForKey:@"clientAgent"] objectForKey:@"agentTypeUri"];
        }
        
        NSString *changedDate =[Util convertDateToString:changedDateAndTime];
        NSString *changedTimeTemp =[Util convertDateToGetOnlyTime:changedTimeFromService];
        
        NSString *changedTime=[NSString stringWithFormat:@"%@",[Util return12HourStringOnlyWithAMPPM:changedTimeTemp]];
        
        NSString *commonString= nil;
        NSString *strAgent = nil;
        
        if(fromAgent !=nil && ![fromAgent isKindOfClass:[NSNull class]])
        {
            strAgent = [[dict objectForKey:@"clientAgent"] objectForKey:@"displayText"];
            
            
            
            commonString = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@",RPLocalizedString(@"by", @""),changeByUser,RPLocalizedString(@"On", @""),changedDate,RPLocalizedString(@"@", @""),changedTime];//Change
            
            if (strAgent!=nil && ![strAgent isKindOfClass:[NSNull class]])
            {
                commonString=[commonString stringByAppendingString:[NSString stringWithFormat:@" %@ %@",RPLocalizedString(@"via", @""),strAgent]];
            }
            
        }
        else
        {
            commonString = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@",RPLocalizedString(@"by", @""),changeByUser,RPLocalizedString(@"On", @""),changedDate,RPLocalizedString(@"@", @""),changedTime];//Change
        }
        
        NSString *commentString = nil;
        if([[dict objectForKey:@"modificationTypeUri"] isEqualToString:MODIFICATION_TYPE_ORIGINAL])
        {
            NSString *originalString = @"";
            if([[dict objectForKey:@"newPunchActionUri"] isEqualToString:PUNCH_ACTION_URI_IN])
            {
                //change
                if([dict objectForKey:@"newActivity"]!=nil && ![[dict objectForKey:@"newActivity"] isKindOfClass:[NSNull class]])
                {
                    originalString = [NSString stringWithFormat:@"%@ %@ \"%@\", %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"IN", @""),RPLocalizedString(@"activity", @""),[[dict objectForKey:@"newActivity"]objectForKey:@"displayText"]];
                }
                else
                {
                    originalString = [NSString stringWithFormat:@"%@ %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"IN", @"")];
                }
                //change
            }
            else if([[dict objectForKey:@"newPunchActionUri"] isEqualToString:PUNCH_ACTION_URI_OUT])
            {
                originalString = [NSString stringWithFormat:@"%@ %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"OUT", @"")];
            }
            else if([[dict objectForKey:@"newPunchActionUri"] isEqualToString:PUNCH_ACTION_URI_TRANSFER])
            {
                if([dict objectForKey:@"newActivity"]!=nil && ![[dict objectForKey:@"newActivity"] isKindOfClass:[NSNull class]])
                {
                    originalString = [NSString stringWithFormat:@"%@ %@ \"%@\", %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"TRANSFER", @""),RPLocalizedString(@"activity", @""),[[dict objectForKey:@"newActivity"]objectForKey:@"displayText"]];//Change
                }
                else
                {
                    originalString = [NSString stringWithFormat:@"%@ %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"TRANSFER", @"")];//Change
                }
            }
            else if([[dict objectForKey:@"newPunchActionUri"] isEqualToString:PUNCH_ACTION_URI_BREAK])
            {
                originalString = [NSString stringWithFormat:@"%@ %@ \"%@\", %@ %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"BREAK", @""),RPLocalizedString(@"break", @""),RPLocalizedString(@"type", @""),[[dict objectForKey:@"newBreakType"]objectForKey:@"displayText"]];
            }
            
            NSString *changedTime =@"";
            if([dict objectForKey:@"newPunchTime"]!=nil && ![[dict objectForKey:@"newPunchTime"] isKindOfClass:[NSNull class]])
            {
                NSString *timeTemp = [Util convertDateToGetOnlyTime:[Util convertApiDateDictToDateTimeFormat:[dict objectForKey:@"newPunchTime"]]];
                
                 changedTime=[NSString stringWithFormat:@"%@",[Util return12HourStringOnlyWithAMPPM:timeTemp]];
            }
            
            if([dict objectForKey:@"geolocation"]!=nil && ![[dict objectForKey:@"geolocation"] isKindOfClass:[NSNull class]])
            {
                if([[dict objectForKey:@"geolocation"]objectForKey:@"address"]!=nil && ![[[dict objectForKey:@"geolocation"]objectForKey:@"address"] isKindOfClass:[NSNull class]])
                {
                    
                    if(![[[dict objectForKey:@"geolocation"]objectForKey:@"address"] isEqualToString:@""])
                    {
                        
                        originalString = [NSString stringWithFormat:@"%@, %@ \"%@\"",originalString,RPLocalizedString(@"location", @""),[[dict objectForKey:@"geolocation"]objectForKey:@"address"]];
                    }
                }
            }
            
            
            if(strAgent !=nil)
            {
                commentString = [NSString stringWithFormat:@"%@ %@, %@ %@ %@ %@ %@ %@ %@",RPLocalizedString(@"Original time", @""),changedTime,originalString,RPLocalizedString(@"by", @""),changeByUser,RPLocalizedString(@"On", @""),changedDate,RPLocalizedString(@"via", @""),strAgent];
            }
            else
            {
                commentString = [NSString stringWithFormat:@"%@ %@, %@ %@ %@ %@ %@",RPLocalizedString(@"Original time", @""),changedTime,originalString,RPLocalizedString(@"by", @""),changeByUser,RPLocalizedString(@"On", @""),changedDate];
            }
            
        }
        else if([[dict objectForKey:@"modificationTypeUri"] isEqualToString:MODIFICATION_TYPE_ADDED])
        {
            NSString *addedString = @"";
            if([[dict objectForKey:@"newPunchActionUri"] isEqualToString:PUNCH_ACTION_URI_IN])
            {
                
                //Change
                if([dict objectForKey:@"newActivity"]!=nil && ![[dict objectForKey:@"newActivity"] isKindOfClass:[NSNull class]])
                {
                    addedString = [NSString stringWithFormat:@"%@ %@ \"%@\", %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"IN", @""),RPLocalizedString(@"activity", @""),[[dict objectForKey:@"newActivity"]objectForKey:@"displayText"]];
                }
                else
                {
                    addedString = [NSString stringWithFormat:@"%@ %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"IN", @"")]; // NO Activity Present Then it is display as just IN
                }
                //Change
            }
            else if([[dict objectForKey:@"newPunchActionUri"] isEqualToString:PUNCH_ACTION_URI_OUT])
            {
                addedString = [NSString stringWithFormat:@"%@ %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"OUT", @"")];
            }
            else if([[dict objectForKey:@"newPunchActionUri"] isEqualToString:PUNCH_ACTION_URI_TRANSFER])
            {
                if([dict objectForKey:@"newActivity"]!=nil && ![[dict objectForKey:@"newActivity"] isKindOfClass:[NSNull class]])
                {
                    addedString = [NSString stringWithFormat:@"%@ %@ \"%@\", %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"TRANSFER", @""),RPLocalizedString(@"activity", @""),[[dict objectForKey:@"newActivity"]objectForKey:@"displayText"]];
                }
                else
                {
                    addedString = [NSString stringWithFormat:@"%@ %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"TRANSFER", @"")]; // NO Activity Present Then it is display as just IN//Change
                }
            }
            else if([[dict objectForKey:@"newPunchActionUri"] isEqualToString:PUNCH_ACTION_URI_BREAK])
            {
                addedString = [NSString stringWithFormat:@"%@ %@ \"%@\", %@ %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"BREAK", @""),RPLocalizedString(@"break", @""),RPLocalizedString(@"type", @""),[[dict objectForKey:@"newBreakType"]objectForKey:@"displayText"]];
            }
            
            NSString *changedTime =@"";
            if([dict objectForKey:@"newPunchTime"]!=nil && ![[dict objectForKey:@"newPunchTime"] isKindOfClass:[NSNull class]])
            {
                NSString *timeTemp = [Util convertDateToGetOnlyTime:[Util convertApiDateDictToDateTimeFormat:[dict objectForKey:@"newPunchTime"]]];
                changedTime=[NSString stringWithFormat:@"%@",[Util return12HourStringOnlyWithAMPPM:timeTemp]];
            }
            
            commentString = [NSString stringWithFormat:@"%@ %@, %@ %@",RPLocalizedString(@"Added", @""),changedTime, addedString,commonString];
        }
        else if ([[dict objectForKey:@"modificationTypeUri"] isEqualToString:MODIFICATION_TYPE_EDITED])
        {
            NSString *editedString = [self createEditedString:dict];
            if (editedString==nil||[editedString isKindOfClass:[NSNull class]]||[editedString isEqualToString:@""])
            {
                NSString *noChangeString = [self createNoChangeEditString:dict];  //change
                commentString = [NSString stringWithFormat:@"%@ %@ %@ %@",RPLocalizedString(@"Edited", @""),RPLocalizedString(@"to", @""),noChangeString,commonString];//change
            }
            else
            {
                commentString = [NSString stringWithFormat:@"%@ %@ %@ %@",RPLocalizedString(@"Edited", @""),RPLocalizedString(@"to", @""),editedString,commonString];
            }
            
        }
        else if([[dict objectForKey:@"modificationTypeUri"] isEqualToString:MODIFICATION_TYPE_DELETED])
        {
            commentString = [NSString stringWithFormat:@"%@ %@",RPLocalizedString(@"Deleted", @""),commonString];
        }
        
        [commentsArray addObject:commentString];
        
        
    }
    
    return commentsArray;
}

-(NSString*)createEditedString:(NSDictionary*)dict
{
    
    
    NSString *editedString=nil;
    if(![[dict objectForKey:@"newPunchActionUri"] isEqualToString:[dict objectForKey:@"originalPunchActionUri"]])
    {
        if([[dict objectForKey:@"newPunchActionUri"] isEqualToString:PUNCH_ACTION_URI_IN])
        {
            //change
            if([dict objectForKey:@"newActivity"]!=nil && ![[dict objectForKey:@"newActivity"] isKindOfClass:[NSNull class]])
            {
                if([dict objectForKey:@"originalActivity"]!=nil && ![[dict objectForKey:@"originalActivity"] isKindOfClass:[NSNull class]])
                {
                    if(![[dict objectForKey:@"newActivity"] isEqualToDictionary:[dict objectForKey:@"originalActivity"]])
                    {
                        editedString = [NSString stringWithFormat:@"%@ %@ \"%@\", %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"IN", @""),RPLocalizedString(@"activity", @""),[[dict objectForKey:@"newActivity"]objectForKey:@"displayText"]];
                    }
                    else
                    {
                        editedString = [NSString stringWithFormat:@"%@ %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"IN", @"")];
                        
                    }
                }
                else
                {
                    
                    
                    editedString = [NSString stringWithFormat:@"%@ %@ \"%@\", %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"IN", @""),RPLocalizedString(@"activity", @""),[[dict objectForKey:@"newActivity"]objectForKey:@"displayText"]];
                    
                }
                
                
            }
            else
            {
                if([dict objectForKey:@"originalActivity"]!=nil && ![[dict objectForKey:@"originalActivity"] isKindOfClass:[NSNull class]])
                {
                    editedString = [NSString stringWithFormat:@"%@ %@ \"%@\", %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"IN", @""),RPLocalizedString(@"activity", @""),RPLocalizedString(@"No Activity", @"")];
                }
                else
                {
                    editedString = [NSString stringWithFormat:@"%@ %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"IN", @"")];
                }
            }
            //change
        }
        else if([[dict objectForKey:@"newPunchActionUri"] isEqualToString:PUNCH_ACTION_URI_OUT])
        {
            editedString = [NSString stringWithFormat:@"%@ %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"OUT", @"")];
        }
        else if([[dict objectForKey:@"newPunchActionUri"] isEqualToString:PUNCH_ACTION_URI_TRANSFER])
        {
            
            if([dict objectForKey:@"newActivity"]!=nil && ![[dict objectForKey:@"newActivity"] isKindOfClass:[NSNull class]])
            {
                
                if([dict objectForKey:@"originalActivity"]!=nil && ![[dict objectForKey:@"originalActivity"] isKindOfClass:[NSNull class]])
                {
                    if(![[dict objectForKey:@"newActivity"] isEqualToDictionary:[dict objectForKey:@"originalActivity"]])
                    {
                        editedString = [NSString stringWithFormat:@"%@ %@ \"%@\", %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"TRANSFER", @""),RPLocalizedString(@"activity", @""),[[dict objectForKey:@"newActivity"]objectForKey:@"displayText"]];
                    }
                    else
                    {
                        editedString = [NSString stringWithFormat:@"%@ %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"TRANSFER", @"")];
                    }
                }
                else
                {
                    
                    
                    editedString = [NSString stringWithFormat:@"%@ %@ \"%@\", %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"TRANSFER", @""),RPLocalizedString(@"activity", @""),[[dict objectForKey:@"newActivity"]objectForKey:@"displayText"]];
                    
                }
                
                
            }
            else
            {
                if([dict objectForKey:@"originalActivity"]!=nil && ![[dict objectForKey:@"originalActivity"] isKindOfClass:[NSNull class]])
                {
                    editedString = [NSString stringWithFormat:@"%@ %@ \"%@\", %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"TRANSFER", @""),RPLocalizedString(@"activity", @""),RPLocalizedString(@"No Activity", @"")];
                }
                else
                {
                    editedString = [NSString stringWithFormat:@"%@ %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"TRANSFER", @"")];
                }
                
            }
            
        }
        else if([[dict objectForKey:@"newPunchActionUri"] isEqualToString:PUNCH_ACTION_URI_BREAK])
        {
            editedString = [NSString stringWithFormat:@"%@ %@ \"%@\", %@ %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"BREAK", @""),RPLocalizedString(@"break", @""),RPLocalizedString(@"type", @""),[[dict objectForKey:@"newBreakType"]objectForKey:@"displayText"]];//change
            
        }
        
        
        
    }
    
    // Activity is changed, original activity null is handled
    
    else if([dict objectForKey:@"newActivity"]!=nil && ![[dict objectForKey:@"newActivity"] isKindOfClass:[NSNull class]])
    {
        if([dict objectForKey:@"originalActivity"]!=nil && ![[dict objectForKey:@"originalActivity"] isKindOfClass:[NSNull class]])
        {
            if(![[dict objectForKey:@"newActivity"] isEqualToDictionary:[dict objectForKey:@"originalActivity"]])
            {
                editedString = [NSString stringWithFormat:@"%@ \"%@\"",RPLocalizedString(@"activity", @""),[[dict objectForKey:@"newActivity"]objectForKey:@"displayText"]];
                
            }
        }
        else
        {
            editedString = [NSString stringWithFormat:@"%@ \"%@\"",RPLocalizedString(@"activity", @""),[[dict objectForKey:@"newActivity"]objectForKey:@"displayText"]];
        }
    }
    
    // Activity is changed, new activity null is handled
    
    else if([dict objectForKey:@"originalActivity"]!=nil && ![[dict objectForKey:@"originalActivity"] isKindOfClass:[NSNull class]])
    {
        if([dict objectForKey:@"newActivity"]!=nil && ![[dict objectForKey:@"newActivity"] isKindOfClass:[NSNull class]])
        {
            if(![[dict objectForKey:@"newActivity"] isEqualToDictionary:[dict objectForKey:@"originalActivity"]])
            {
                editedString = [NSString stringWithFormat:@"%@ \"%@\"",RPLocalizedString(@"activity", @""),[[dict objectForKey:@"newActivity"]objectForKey:@"displayText"]];
                
            }
        }
        else
        {
            editedString = [NSString stringWithFormat:@"%@ \"%@\"",RPLocalizedString(@"activity", @""),RPLocalizedString(@"No Activity", @"")];
            
        }
    }
    
    // Change in Break is handled
    
    else if([dict objectForKey:@"newBreakType"]!=nil && ![[dict objectForKey:@"newBreakType"] isKindOfClass:[NSNull class]])
    {
        if([dict objectForKey:@"originalBreakType"]!=nil && ![[dict objectForKey:@"originalBreakType"] isKindOfClass:[NSNull class]])
        {
            if(![[dict objectForKey:@"newBreakType"] isEqualToDictionary:[dict objectForKey:@"originalBreakType"]])
            {
                
                editedString = [NSString stringWithFormat:@"%@ %@ \"%@\"",RPLocalizedString(@"break", @""),RPLocalizedString(@"type", @""),[[dict objectForKey:@"newBreakType"]objectForKey:@"displayText"]];
                
            }
        }
    }
    
    
    
    if([dict objectForKey:@"newPunchUser"]!=nil && ![[dict objectForKey:@"newPunchUser"] isKindOfClass:[NSNull class]])
    {
        
    }
    if([dict objectForKey:@"newTask"]!=nil && ![[dict objectForKey:@"newTask"] isKindOfClass:[NSNull class]])
    {
        
    }
    if([dict objectForKey:@"newBillingRate"]!=nil && ![[dict objectForKey:@"newBillingRate"] isKindOfClass:[NSNull class]])
    {
        
    }
    if([dict objectForKey:@"newProject"]!=nil && ![[dict objectForKey:@"newProject"] isKindOfClass:[NSNull class]])
    {
        
    }
    
    //  Change in Time is handled.
    
    NSString *finalTimeEditedString=nil;
    
    if([dict objectForKey:@"newPunchTime"]!=nil && ![[dict objectForKey:@"newPunchTime"] isKindOfClass:[NSNull class]])
    {
        if([dict objectForKey:@"originalPunchTime"]!=nil && ![[dict objectForKey:@"originalPunchTime"] isKindOfClass:[NSNull class]])
        {
            if(![[dict objectForKey:@"newPunchTime"] isEqualToDictionary:[dict objectForKey:@"originalPunchTime"]])
            {
                NSDictionary *newPunchTimeDict = [dict objectForKey:@"newPunchTime"];
                NSDictionary *originalPunchTimeDict = [dict objectForKey:@"originalPunchTime"];
                NSString *changedDay=nil;
                NSString *changedTime=nil;
                
                
                // Checking For Change of day
                if(![[newPunchTimeDict objectForKey:@"day"]    isEqualToNumber:[originalPunchTimeDict objectForKey:@"day"]]    ||
                   (![[newPunchTimeDict objectForKey:@"month"] isEqualToNumber:[originalPunchTimeDict objectForKey:@"month"]]) ||
                   (![[newPunchTimeDict objectForKey:@"year"]  isEqualToNumber:[originalPunchTimeDict objectForKey:@"year"]]))
                {
                    changedDay = [Util convertDateToString:[Util convertApiDateDictToDateTimeFormat:[dict objectForKey:@"newPunchTime"]]];
                }
                
                // Checking for Change of Time
                if((![[newPunchTimeDict objectForKey:@"hour"]   isEqualToNumber:[originalPunchTimeDict objectForKey:@"hour"]])   ||
                   (![[newPunchTimeDict objectForKey:@"minute"] isEqualToNumber:[originalPunchTimeDict objectForKey:@"minute"]]) ||
                   (![[newPunchTimeDict objectForKey:@"second"] isEqualToNumber:[originalPunchTimeDict objectForKey:@"second"]]))
                {
                    NSString *timeTemp = [Util convertDateToGetOnlyTime:[Util convertApiDateDictToDateTimeFormat:[dict objectForKey:@"newPunchTime"]]];
                    changedTime=[NSString stringWithFormat:@"%@",[Util return12HourStringOnlyWithAMPPM:timeTemp]];
                }
                
                if(changedTime!=nil && ![changedTime isKindOfClass:[NSNull class]]) // Only TimeChanged
                {
                    finalTimeEditedString = changedTime;
                }
                if(changedDay!=nil && ![changedDay isKindOfClass:[NSNull class]])  // Only DateChanged
                {
                    finalTimeEditedString = changedDay;
                }
                if((changedDay!=nil && ![changedDay isKindOfClass:[NSNull class]]) && (changedTime!=nil && ![changedTime isKindOfClass:[NSNull class]])) //Both Date and Time Changed
                {
                    finalTimeEditedString = [changedDay stringByAppendingString:[NSString stringWithFormat:@" @ %@",changedTime]];
                }
                
                if(editedString!=nil)
                {
                    finalTimeEditedString = [NSString stringWithFormat:@"%@, %@",finalTimeEditedString,editedString];
                }
            }
        }
    }
    
    if(!finalTimeEditedString)
    {
        return editedString;
    }
    else
    {
        return finalTimeEditedString;
    }
}
-(NSString*)createNoChangeEditString:(NSDictionary*)dict
{
    NSString *noChangeEditString = @"";
    if([[dict objectForKey:@"newPunchActionUri"] isEqualToString:PUNCH_ACTION_URI_IN])
    {
        
        if([dict objectForKey:@"newActivity"]!=nil && ![[dict objectForKey:@"newActivity"] isKindOfClass:[NSNull class]])
        {
            noChangeEditString = [NSString stringWithFormat:@"%@ %@ \"%@\", %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"IN", @""),RPLocalizedString(@"activity", @""),[[dict objectForKey:@"newActivity"]objectForKey:@"displayText"]];
        }
        else
        {
            noChangeEditString = [NSString stringWithFormat:@"%@ %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"IN", @"")];
        }
        
    }
    else if([[dict objectForKey:@"newPunchActionUri"] isEqualToString:PUNCH_ACTION_URI_OUT])
    {
        noChangeEditString = [NSString stringWithFormat:@"%@ %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"OUT", @"")];
    }
    else if([[dict objectForKey:@"newPunchActionUri"] isEqualToString:PUNCH_ACTION_URI_TRANSFER])
    {
        if([dict objectForKey:@"newActivity"]!=nil && ![[dict objectForKey:@"newActivity"] isKindOfClass:[NSNull class]])
        {
            noChangeEditString = [NSString stringWithFormat:@"%@ %@ \"%@\", %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"TRANSFER", @""),RPLocalizedString(@"activity", @""),[[dict objectForKey:@"newActivity"]objectForKey:@"displayText"]];
        }
        else
        {
            noChangeEditString = [NSString stringWithFormat:@"%@ %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"TRANSFER", @"")];
        }
    }
    else if([[dict objectForKey:@"newPunchActionUri"] isEqualToString:PUNCH_ACTION_URI_BREAK])
    {
        noChangeEditString = [NSString stringWithFormat:@"%@ %@ \"%@\", %@ %@ \"%@\"",RPLocalizedString(@"punch", @""),RPLocalizedString(@"type", @""),RPLocalizedString(@"BREAK", @""),RPLocalizedString(@"break", @""),RPLocalizedString(@"type", @""),[[dict objectForKey:@"newBreakType"]objectForKey:@"displayText"]];
    }
    
    NSString *changedTime =@"";
    if([dict objectForKey:@"newPunchTime"]!=nil && ![[dict objectForKey:@"newPunchTime"] isKindOfClass:[NSNull class]])
    {
        NSString *timeTemp = [Util convertDateToGetOnlyTime:[Util convertApiDateDictToDateTimeFormat:[dict objectForKey:@"newPunchTime"]]];
       changedTime=[NSString stringWithFormat:@"%@",[Util return12HourStringOnlyWithAMPPM:timeTemp]];

    }
    
    noChangeEditString = [NSString stringWithFormat:@"%@, %@",changedTime, noChangeEditString];
    
    return noChangeEditString;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AuditTrialPunchObject *auditTrialObj = (AuditTrialPunchObject *)[auditTrialInfoList objectAtIndex:indexPath.row];
    float height=[[auditTrialObj.commentsInfoDict objectForKey:@"height"] newFloatValue];
	return 15+35+height+15;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [auditTrialInfoList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"AuditTrialCustomCell";
	AuditTrialCustomCell *cell = (AuditTrialCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil)
    {
        cell = [[AuditTrialCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.contentView.backgroundColor = [Util colorWithHex:@"#f8f8f8" alpha:1];
        
	}
    
    //auditTrialObj.punchTime
    AuditTrialPunchObject *auditTrialObj = (AuditTrialPunchObject *)[auditTrialInfoList objectAtIndex:indexPath.row];
    [cell createCellLayoutWithPunchType:auditTrialObj.punchActionuri punchTime:auditTrialObj.punchTime punchFormat:auditTrialObj.punchTimeFormat commentsDict:[NSMutableDictionary dictionaryWithDictionary:auditTrialObj.commentsInfoDict]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    self.auditTrialInfoTableView.delegate = nil;
    self.auditTrialInfoTableView.dataSource = nil;
}
@end
