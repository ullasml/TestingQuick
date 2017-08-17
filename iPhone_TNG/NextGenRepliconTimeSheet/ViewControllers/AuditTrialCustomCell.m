//
//  AuditTrialCustomCell.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 07/07/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "AuditTrialCustomCell.h"
#import "Constants.h"

@implementation AuditTrialCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}
-(void)createCellLayoutWithPunchType:(NSString *)uri punchTime:(NSString *)punchTime punchFormat:(NSString *)format commentsDict:(NSMutableDictionary *)commentsDict
{
    NSString *punchString=nil;
    UIImage *punchImage=nil;
    
    if ([uri isEqualToString:PUNCH_IN_URI]||[uri isEqualToString:PUNCH_TRANSFER_URI])
    {
        punchString=RPLocalizedString(IN_TEXT, @"");
        punchImage=[UIImage imageNamed:@"icon_IN-Tag-Green"];
    }
    else if ([uri isEqualToString:PUNCH_OUT_URI])
    {
        punchString=RPLocalizedString(OUT_TEXT, @"");
        punchImage=[UIImage imageNamed:@"icon_OUT-Tag-Gray"];
    }
    else
    {
        //punchString=RPLocalizedString(@"B", @"");
        punchImage=[UIImage imageNamed:@"icon_Break-Tag-Yellow"];
    }

    
    int y=9.0;
    UIView *topView=[[UIView alloc]initWithFrame:CGRectMake(15, 15.5, 130, 35)];
    topView.layer.borderColor = [UIColor blackColor].CGColor;
    topView.layer.borderWidth = 0.5f;
    UIImageView *imgView=[[UIImageView alloc]initWithFrame:CGRectMake(12, y, punchImage.size.width, punchImage.size.height)];
    [imgView setImage:punchImage];
    [topView setBackgroundColor:[UIColor whiteColor]];
    [topView addSubview:imgView];
    UILabel *punchLbl = [[UILabel alloc]initWithFrame:CGRectMake(12, y, punchImage.size.width, punchImage.size.height)];
    [punchLbl setBackgroundColor:[UIColor clearColor]];
    [punchLbl setText:punchString];
    if ([uri isEqualToString:PUNCH_IN_URI]||[uri isEqualToString:PUNCH_TRANSFER_URI])
    {
        [punchLbl setTextColor:RepliconStandardWhiteColor];
    }
    else if ([uri isEqualToString:PUNCH_OUT_URI])
    {
        [punchLbl setTextColor:RepliconStandardBlackColor];
    }
    [punchLbl setTextAlignment:NSTextAlignmentCenter];
    [punchLbl setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_10]];
    [topView addSubview:punchLbl];
    
    float xOffset=0;
    if (punchTime!=nil && ![punchTime isKindOfClass:[NSNull class]]&&![punchTime isEqualToString:@""])
    {
        NSArray *timeOutCompsArr=[punchTime componentsSeparatedByString:@":"];
        if ([timeOutCompsArr count]==2)
        {
            NSString *outhrstr=[timeOutCompsArr objectAtIndex:0];
            NSUInteger strLength=[outhrstr length];
            if (strLength==1) {
                xOffset=8;
            }
            
        }
    }
    
    UILabel *timeLbl = [[UILabel alloc]initWithFrame:CGRectMake(imgView.frame.origin.x+imgView.frame.size.width+10,y ,40-xOffset, punchImage.size.height)];
    [timeLbl setBackgroundColor:[UIColor clearColor]];
    [timeLbl setText:punchTime];
    [timeLbl setTextColor:RepliconStandardBlackColor];
    [timeLbl setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];
    [topView addSubview:timeLbl];
    
    UILabel *formatLbl = [[UILabel alloc]initWithFrame:CGRectMake(timeLbl.frame.origin.x+timeLbl.frame.size.width,y+2 ,50 ,10 )];
    [formatLbl setBackgroundColor:[UIColor clearColor]];
    [formatLbl setText:format];
    [formatLbl setTextColor:RepliconStandardBlackColor];
    [formatLbl setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_10]];
    [topView addSubview:formatLbl];

    NSString *str=[NSString stringWithFormat:@"%@",[commentsDict objectForKey:@"ChangesString"]];
    float height=[[commentsDict objectForKey:@"height"] newFloatValue];
    
    
    UIView *commentsView=[[UIView alloc]initWithFrame:CGRectMake(15,50 ,SCREEN_WIDTH-30 ,height )];
    [commentsView setBackgroundColor:[UIColor whiteColor]];
    commentsView.layer.borderColor = [UIColor blackColor].CGColor;
    commentsView.layer.borderWidth = 0.5f;
    
    UILabel *commentstLbl = [[UILabel alloc]initWithFrame:CGRectMake(15,0 ,commentsView.frame.size.width-30 ,height )];
    [commentstLbl setBackgroundColor:[UIColor whiteColor]];
    [commentstLbl setText:str];
    [commentstLbl setNumberOfLines:0];
    [commentstLbl setTextColor:RepliconStandardBlackColor];
    [commentstLbl setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
    [commentsView addSubview:commentstLbl];

    UIView *separatorView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    [separatorView setBackgroundColor:[UIColor grayColor]];
    [self.contentView addSubview:separatorView];
    
    [self.contentView addSubview:commentsView];
    [self.contentView addSubview:topView];
    [self.contentView setBackgroundColor:[Util colorWithHex:@"#f8f8f8" alpha:1]];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
