//
//  ListOfExpenseEntriesCustomCell.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 26/03/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "ListOfExpenseEntriesCustomCell.h"
#import "Util.h"
#import "Constants.h"
#import "UIView+Additions.h"

@implementation ListOfExpenseEntriesCustomCell

-(void)createCellLayoutWithParams:(NSString *)upperleftString
                    upperrightstr:(NSString *)upperrightString
                    lowerrightStr:(NSString *)lowerrightStr
               isReceiptAvailable:(BOOL)isReceiptAvailable
         isReimburesmentAvailable:(BOOL)isReimburesmentAvailable
                            width:(CGFloat)width

{
    static CGFloat leftPadding = 12.0;
    CGFloat labelWidth = (width-(3*leftPadding))/2;
    CGSize mainSize;
    if (upperleftString)
    {
      
        // Let's make an NSAttributedString first
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:upperleftString];
        //Add LineBreakMode
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];
        
        //Now let's make the Bounding Rect
       mainSize = [attributedString boundingRectWithSize:CGSizeMake(labelWidth, 22) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        if (mainSize.width==0 && mainSize.height ==0)
        {
            mainSize=CGSizeMake(11.0, 18.0);
        }
        
        
    }
    //UPPER LEFT STRING LABEL
    
    UILabel *upperLeft = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, 4.0, labelWidth, mainSize.height)];
   	[upperLeft setTextColor:RepliconStandardBlackColor ];
	[upperLeft setBackgroundColor:[UIColor clearColor]];
	[upperLeft setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
	[upperLeft setTextAlignment:NSTextAlignmentLeft];
	[upperLeft setText:upperleftString];
	[upperLeft setNumberOfLines:1];
	[self.contentView addSubview:upperLeft];
    
	
    //UPPER RIGHT STRING LABEL
	
    UILabel *upperRight = [[UILabel alloc] initWithFrame:CGRectMake(upperLeft.right+leftPadding, 4.0, labelWidth, 20.0)];
	[upperRight setTextColor:RepliconStandardBlackColor ];
	[upperRight setBackgroundColor:[UIColor clearColor]];
	[upperRight setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16]];
	[upperRight setText:upperrightString];
	[upperRight setTextAlignment:NSTextAlignmentRight];
	[upperRight setNumberOfLines:1];;
    [self.contentView addSubview:upperRight];
   
    
    //LOWER RIGHT STRING LABEL
	
    UILabel *lowerRight = [[UILabel alloc] initWithFrame:CGRectMake(upperLeft.right+leftPadding,  upperLeft.frame.origin.y+upperLeft.frame.size.height, labelWidth, 20.0)];
	[lowerRight setTextColor:[Util colorWithHex:@"#999999" alpha:1.0f] ];
	[lowerRight setBackgroundColor:[UIColor clearColor]];
	[lowerRight setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
	[lowerRight setText:lowerrightStr];
	[lowerRight setTextAlignment:NSTextAlignmentRight];
	[lowerRight setNumberOfLines:1];
    [self.contentView addSubview:lowerRight];
   
    
    if (isReceiptAvailable)
    {
        UIImage *cameraImg =[UIImage imageNamed:@"camera_img"] ;
        UIImageView *lowerLeftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(leftPadding, upperLeft.frame.origin.y+upperLeft.frame.size.height+3, cameraImg.size.width,cameraImg.size.height)];
        [lowerLeftImageView setImage:cameraImg];
        [self.contentView addSubview:lowerLeftImageView];
       

    }

    if (isReimburesmentAvailable)
    {
        UIImage *reimbursementImg =[UIImage imageNamed:@"expense_img"] ;
        UIImageView *lowerLeftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(leftPadding, upperLeft.frame.origin.y+upperLeft.frame.size.height+3, reimbursementImg.size.width,reimbursementImg.size.height)];
        if (isReceiptAvailable)
        {
            lowerLeftImageView.frame=CGRectMake(leftPadding+reimbursementImg.size.width+leftPadding, upperLeft.frame.origin.y+upperLeft.frame.size.height+3, reimbursementImg.size.width,reimbursementImg.size.height);
        }
        
        
        [lowerLeftImageView setImage:reimbursementImg];
        [self.contentView addSubview:lowerLeftImageView];

        
    }

    //CELL SEPARATOR IMAGE VIEW
    UIImage *lowerImage = [Util thumbnailImage:Cell_HairLine_Image];
	UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, lowerRight.frame.origin.y+lowerRight.frame.size.height+3, width,lowerImage.size.height)];
    [lineImageView setImage:lowerImage];
    [self.contentView bringSubviewToFront:lineImageView];
	[self.contentView addSubview:lineImageView];

    
    
    
}




@end
