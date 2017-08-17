//
//  ApproverCommentDetailCellView.m
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 30/06/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "ApproverCommentDetailCellView.h"
#import "Constants.h"
#import <CoreText/CoreText.h>

@implementation ApproverCommentDetailCellView
-(void)createCellLayoutWithParamsStatus:(NSString*)status time:(NSString*)timeStr comments:(NSString*)commentsStr approver:(NSString*)approverStr WithTag:(NSInteger)tag
{
    self.contentView.backgroundColor=RepliconStandardBackgroundColor;
    UIImage *cellImg=nil;
    float width=SCREEN_WIDTH-14;
    /*
    //Fix for ios7//JUHI
    float version= [[UIDevice currentDevice].systemVersion newFloatValue];
    
    if (version>=7.0)
    {
        width=306;
    }
    */
    NSString *statusStr=nil;
    NSString *colorCode=nil;
    
    if (tag==0)
    {
        if ([status isEqualToString:Submit_Action_URI])
        {
            statusStr=RPLocalizedString(WAITING_FOR_APRROVAL_STATUS, @"");
            cellImg=[Util thumbnailImage:Waiting_For_Approval_Cell_Img];
            colorCode=@"#333333";
        }
        else if ([status isEqualToString:Reject_Action_URI])
        {
            statusStr=RPLocalizedString(REJECTED_STATUS, @"");
            cellImg=[Util thumbnailImage:Rejected_Cell_Img];
            colorCode=@"#FFFFFF";
        }
        else if ([status isEqualToString:Approved_Action_URI]||[status isEqualToString:SystemApproved_Action_URI])
        {
            statusStr=RPLocalizedString(APPROVED_STATUS, @"");
            cellImg=[Util thumbnailImage:Approved_Cell_Img];
            colorCode=@"#333333";
        }
        else if ([status isEqualToString:Reopen_Action_URI])
        {
            statusStr=RPLocalizedString(@"Reopened", @"");
            cellImg=[Util thumbnailImage:Not_Submitted_Reopened_Cell_Img];
            colorCode=@"#333333";
        }
        else
        {
            statusStr=RPLocalizedString(NOT_SUBMITTED_STATUS, @"");
            cellImg=[Util thumbnailImage:Not_Submitted_Reopened_Cell_Img];
            colorCode=@"#333333";
        }
        
        CGFloat statusWidth = (cellImg.size.width/320)*SCREEN_WIDTH;
        UIView *firstCellView=[[UIView alloc]initWithFrame:CGRectMake(7, 0,width, cellImg.size.height)];
        
        UIImageView *statusCellView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, statusWidth, cellImg.size.height)];
        statusCellView.image=cellImg;

        [firstCellView addSubview:statusCellView];
        float height=0.0;
        if (statusStr)
        {
            
            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:statusStr];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_15]} range:NSMakeRange(0, attributedString.length)];
            
            //Now let's make the Bounding Rect
            CGSize mainSize = [attributedString boundingRectWithSize:CGSizeMake(250.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            if (mainSize.width==0 && mainSize.height ==0)
            {
                mainSize=CGSizeMake(11.0, 18.0);
            }
            
            height= mainSize.height+20;
            
        }
        UILabel *statusLb = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 0.0, statusWidth-12, height)];
        [statusLb setBackgroundColor:[UIColor clearColor]];
        
        [statusLb setTextColor:[Util colorWithHex:colorCode alpha:1]];
        [statusLb setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];
        [statusLb setTextAlignment:NSTextAlignmentLeft];
        [statusLb setText:statusStr];
        [statusLb setNumberOfLines:0];
        [statusCellView addSubview:statusLb];
        [statusLb setAccessibilityIdentifier:@"uia_approval_details_status_label_identifier"];
        
        
        UIView *timeSliderNotch=[[UIView alloc]init];
        timeSliderNotch.backgroundColor=[Util colorWithHex:@"#999999" alpha:1];
        timeSliderNotch.frame=CGRectMake(statusWidth, 0, 1, cellImg.size.height);
        [firstCellView addSubview:timeSliderNotch];
        
        UIImage *dateCellImg=[Util thumbnailImage:Date_Cell_Img];
        UIView *dateCellView=[[UIView alloc]initWithFrame:CGRectMake(statusWidth+1, 0, width-statusWidth, dateCellImg.size.height)];
        //dateCellView.image=dateCellImg;
        dateCellView.backgroundColor=[UIColor whiteColor];
        [firstCellView addSubview:dateCellView];
        
        
        UILabel *dateLb = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 0.0, dateCellView.bounds.size.width-12, dateCellImg.size.height)];
        [dateLb setBackgroundColor:[UIColor clearColor]];
        
        [dateLb setTextColor:[Util colorWithHex:@"#666666" alpha:1]];
        [dateLb setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
        [dateLb setTextAlignment:NSTextAlignmentLeft];
        if (timeStr!=nil &&![timeStr isKindOfClass:[NSNull class]] && ![timeStr isEqualToString:@""])
        {
            [dateLb setText:timeStr];
        }
        
        [dateLb setNumberOfLines:2];
        [dateCellView addSubview:dateLb];
        [[firstCellView layer] setBorderColor:[[Util colorWithHex:@"#999999" alpha:1] CGColor]];
        [[firstCellView layer] setBorderWidth:1.0];
        [[firstCellView layer] setCornerRadius:1];
        [firstCellView setClipsToBounds: YES];
        [self.contentView addSubview:firstCellView];
        
    }
    else if(tag==1)
    {
        UILabel *approverDetailLb = [[UILabel alloc] init];
        UIView *approvalDetailView=[[UIView alloc]init];
        NSString *nameStr=nil;
        if (commentsStr!=nil && ![commentsStr isKindOfClass:[NSNull class]] && ![commentsStr isEqualToString:NULL_STRING])
        {
            if (approverStr!=nil)
            {
                 nameStr=[NSString stringWithFormat:@"%@ : %@ ",approverStr,commentsStr];
            }
            else
                 nameStr=[NSString stringWithFormat:@"%@",commentsStr];
           
        }
        else
            nameStr=[NSString stringWithFormat:@"%@",approverStr];
        
        float height=44.0;
        if (nameStr)
        {
           
            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:nameStr];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_15]} range:NSMakeRange(0, attributedString.length)];
            
            //Now let's make the Bounding Rect
            CGSize mainSize = [attributedString boundingRectWithSize:CGSizeMake(250.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            if (mainSize.width==0 && mainSize.height ==0)
            {
                mainSize=CGSizeMake(11.0, 18.0);
            }
            
            height= mainSize.height+20;
            if (height<44)
            {
                height=44.0;
            }
            
        }
        approvalDetailView.frame=CGRectMake(7, 0, width, height);
        approvalDetailView.backgroundColor=[UIColor whiteColor];
        [approverDetailLb setBackgroundColor:[UIColor clearColor]];
        approverDetailLb.frame=CGRectMake(10, 0,approvalDetailView.frame.size.width-20, height);
        
        approverDetailLb.textColor=[Util colorWithHex:@"#666666" alpha:1];
        approverDetailLb.font=[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15];
         approverDetailLb.numberOfLines=0;

        NSMutableAttributedString *tmpattributedString = [[NSMutableAttributedString alloc]  initWithString:nameStr];
        NSString *string = nil;
        if (commentsStr!=nil && ![commentsStr isKindOfClass:[NSNull class]] && ![commentsStr isEqualToString:NULL_STRING])
        {
            if (approverStr!=nil)
            {
                string=[NSString stringWithFormat:@"%@ :",approverStr];
            }

            
        }
        else
            string=approverStr;
        NSString *statusColor=@"";
        
        statusColor=[NSString stringWithFormat:@"#333333"];
        
        NSString *ver = [[UIDevice currentDevice] systemVersion];
        float ver_float = [ver newFloatValue];
        if (ver_float < 6.0)
        {
            if (string!=nil)
            {
                NSRange textRange=[nameStr rangeOfString:string options:NSBackwardsSearch];
                NSUInteger index=textRange.location;
                
                [tmpattributedString addAttribute:(NSString*)kCTForegroundColorAttributeName
                                            value:(id)[Util colorWithHex:statusColor alpha:1]
                                            range:NSMakeRange(index,[string length])];
                [tmpattributedString addAttribute:(NSString*)NSFontAttributeName
                                            value:(id)[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]
                                            range:NSMakeRange(index,[string length])];
                
            }
           
            
            
            
        }
        else
        {
            if (string!=nil)
            {
                NSRange textRange=[nameStr rangeOfString:string options:NSBackwardsSearch];
                NSUInteger index=textRange.location;
                
                [tmpattributedString addAttribute:NSForegroundColorAttributeName value:[Util colorWithHex:statusColor alpha:1] range:NSMakeRange(index,[string length])];
                [tmpattributedString addAttribute:(NSString*)NSFontAttributeName
                                            value:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]
                                            range:NSMakeRange(index,[string length])];
            }
           
        }
        if (tmpattributedString!=nil)
        {
            if (ver_float > 6.0)
            {
                [approverDetailLb setAttributedText:tmpattributedString];
            }
            else
            {
                [approverDetailLb setText:[tmpattributedString string]];
            }
        }
        
        
        [approvalDetailView addSubview:approverDetailLb];
        [[approvalDetailView layer] setBorderColor:[[Util colorWithHex:@"#999999" alpha:1] CGColor]];
        [[approvalDetailView layer] setBorderWidth:1.0];
        [[approvalDetailView layer] setCornerRadius:1];
        [approvalDetailView setClipsToBounds: YES];
        [self.contentView addSubview:approvalDetailView];
        
    }
    
    
    
}
@end
