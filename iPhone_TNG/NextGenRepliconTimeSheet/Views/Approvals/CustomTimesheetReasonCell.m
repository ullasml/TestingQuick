//
//  CustomTimesheetReasonCell.m
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 11/04/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "CustomTimesheetReasonCell.h"
#import "Constants.h"

@implementation CustomTimesheetReasonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)createCellWithReasonForChanges :(id)entryDetail rowIndex: (int)index
{
    if (index == 0) {
        float stringlabelHeight = [self getHeightForString:FollowingChangesWereMadeToThisTimesheet fontSize:RepliconFontSize_14 forWidth:290];

        UILabel  *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 290, stringlabelHeight)];
        headerLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14];
        headerLabel.textColor =  RepliconStandardBlackColor;
        headerLabel.textAlignment = NSTextAlignmentLeft;
        headerLabel.backgroundColor =[ UIColor clearColor] ;
        headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
        headerLabel.numberOfLines = 0;
        headerLabel.text = entryDetail;
        [self.contentView addSubview:headerLabel];
    }
    else{
        
        
        
        float previousLabelHeightAndOrigin = 0;
        NSString *reasonForString = @"";
        for (int index= 0; index < [entryDetail count]; index++) {
            NSString *dateString=[[[entryDetail objectAtIndex:index] objectAtIndex:0] objectForKey:@"header"];
            float dateStringlabelHeight = [self getHeightForString:dateString fontSize:RepliconFontSize_14 forWidth:290];
            UILabel  *dateStringLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10+previousLabelHeightAndOrigin, 290, dateStringlabelHeight)];
            dateStringLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14];
            dateStringLabel.textColor =  RepliconStandardBlackColor;
            dateStringLabel.textAlignment = NSTextAlignmentLeft;
            dateStringLabel.backgroundColor =[ UIColor clearColor] ;
            dateStringLabel.lineBreakMode = NSLineBreakByWordWrapping;
            dateStringLabel.numberOfLines = 0;
            dateStringLabel.text = dateString;
            //[dateStringLabel sizeToFit];
            [self.contentView addSubview:dateStringLabel];
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
                    [self.contentView addSubview:reasonForChangeLabel];
                    if (!isSameHeader) {
                        [self.contentView addSubview:entryHeaderStringLabel];
                        previousLabelHeightAndOrigin = previousLabelHeightAndOrigin+entryHeaderStringLabelabelHeight+changelabelHeight+4;
                    }
                    else{
                        previousLabelHeightAndOrigin = previousLabelHeightAndOrigin+changelabelHeight+4;
                    }
                }
                else
                {
                    if (!isSameHeader) {
                        [self.contentView addSubview:entryHeaderStringLabel];
                        previousLabelHeightAndOrigin = previousLabelHeightAndOrigin+entryHeaderStringLabelabelHeight+4;
                    }
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
        [self.contentView addSubview:footer];
    }
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


@end
