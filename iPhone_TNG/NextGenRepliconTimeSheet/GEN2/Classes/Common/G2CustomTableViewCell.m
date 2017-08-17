//
//  CustomTableViewCell.m
//  Replicon
//
//  Created by Swapna P on 7/28/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import "G2CustomTableViewCell.h"
#import "G2ListOfTimeEntriesViewController.h"
#import "G2ApprovalsUsersListOfTimeEntriesViewController.h"
#import "G2FreeTrialViewController.h"
@implementation G2CustomTableViewCell
@synthesize upperLeft;
@synthesize upperRight;
@synthesize lowerLeft;
@synthesize lowerRight;
@synthesize lowerRightImageView;
@synthesize lineImageView;
@synthesize backGroundImageView;
@synthesize commonTxtField;
@synthesize commonCellDelegate;
@synthesize selectedindex;
@synthesize clockImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}
//-(void)createCellLayoutWithParams:(NSString *)upperleftString  upperlefttextcolor:(UIColor *)_textcolor upperrightstr:(NSString *)upperrightString lowerleftstr:(NSString *)lowerleftString 
//								 lowerrightstr:(NSString *)lowerrightString statuscolor:(UIColor *)_color 
//								 imageViewflag:(BOOL)imgviewflag{
-(void)createCellLayoutWithParams:(NSString *)upperleftString  upperlefttextcolor:(UIColor *)_textcolor upperrightstr:(NSString *)upperrightString lowerleftstr:(NSString *)lowerleftString lowerlefttextcolor:(UIColor *)_textcolorlowerleftstr  lowerrightstr:(NSString *)lowerrightString statuscolor:(UIColor *)_color imageViewflag:(BOOL)imgviewflag hairlinerequired:(BOOL)_hairlinereq

{
	if (upperLeft == nil) {
		UILabel *tempupperLeft = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 8.0, 145.0, 20.0)];//US4065//Juhi
        self.upperLeft=tempupperLeft;
        
	}
	[upperLeft setBackgroundColor:[UIColor clearColor]];
	if (_textcolor != nil) {
		[upperLeft setTextColor:_textcolor];
	}else {
		[upperLeft setTextColor:RepliconStandardBlackColor];
	}
	/*if ([_entrytype isEqualToString:@"AdhocTimeOffEntry"] ||
		[_entrytype isEqualToString:@"BookedTimeOffEntry"] ) {
		[upperLeft setTextColor:[UIColor grayColor]];
	}else {
		[upperLeft setTextColor:RepliconStandardBlackColor];
	}*/
	[upperLeft setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
	[upperLeft setTextAlignment:NSTextAlignmentLeft];
	[upperLeft setText:upperleftString];
	[upperLeft setNumberOfLines:1];
	[self.contentView addSubview:upperLeft];
	
	if (upperRight == nil) {
		UILabel *tempupperRight = [[UILabel alloc] initWithFrame:CGRectMake(160.0, 8.0, 150.0, 20.0)];
        self.upperRight=tempupperRight;
        
	}
	if (_textcolor != nil) {
		[upperRight setTextColor:_textcolor];
	}else {
		[upperRight setTextColor:RepliconStandardBlackColor];
	}
	[upperRight setBackgroundColor:[UIColor clearColor]];
	[upperRight setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];
	[upperRight setText:upperrightString];
	[upperRight setTextAlignment:NSTextAlignmentRight];
	[upperRight setNumberOfLines:1];
	[self.contentView addSubview:upperRight];
	
	
	if (lowerLeft == nil) {
		//lowerLeft = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 35.0, 160.0, 14.0)];
		UILabel *templowerLeft = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 35.0, 133.0, 14.0)];//US4065//Juhi
        self.lowerLeft=templowerLeft;
        
	}
	[lowerLeft setBackgroundColor:[UIColor clearColor]];
	[lowerLeft setTextColor:_textcolorlowerleftstr];
	[lowerLeft setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
	[lowerLeft setText:lowerleftString];
	[lowerLeft setTextAlignment:NSTextAlignmentLeft];
	[lowerLeft setNumberOfLines:1];
	[self.contentView addSubview:lowerLeft];
	
	if (lowerRight == nil) {
		//lowerRight = [[UILabel alloc] initWithFrame:CGRectMake(160.0, 35.0, 148.0, 14.0)];
        CGRect frame;
        if([commonCellDelegate isKindOfClass:[G2ListOfTimeEntriesViewController class] ] || [commonCellDelegate isKindOfClass:[G2ApprovalsUsersListOfTimeEntriesViewController class] ])
        {
            frame=CGRectMake(133.0, 35.0, 177.0, 14.0);//US4065//Juhi
        }
        else
        {
            frame=CGRectMake(133.0, 35.0, 185.0, 14.0);
        }
        
		UILabel *templowerRight = [[UILabel alloc] initWithFrame:frame];
        self.lowerRight=templowerRight;
        
	}
    if (clockImageView == nil) {
		//lowerRight = [[UILabel alloc] initWithFrame:CGRectMake(160.0, 35.0, 148.0, 14.0)];
        CGRect frame;
        if([commonCellDelegate isKindOfClass:[G2ListOfTimeEntriesViewController class] ]|| [commonCellDelegate isKindOfClass:[G2ApprovalsUsersListOfTimeEntriesViewController class] ])
        {
            
            frame=CGRectMake(295.0, 30.0, 19.0, 22.0);
            
            UIImageView *tempclockImageView = [[UIImageView alloc] initWithFrame:frame];
            tempclockImageView.image=[G2Util thumbnailImage:@"G2clockIcon_timesheetPage.png"];
            tempclockImageView.highlightedImage=[G2Util thumbnailImage:@"G2clockIcon_timesheetPage_WHITE.png"];
            self.clockImageView=tempclockImageView;
            
        }
        
        

	}

    
    
	[lowerRight setBackgroundColor:[UIColor clearColor]];
    
    
    if([commonCellDelegate isKindOfClass:[G2ListOfTimeEntriesViewController class]] || [commonCellDelegate isKindOfClass:[G2ApprovalsUsersListOfTimeEntriesViewController class] ])
    {
        [lowerRight setTextColor:RepliconStandardBlackColor];
        [lowerRight setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
    }
    else
    {
        [lowerRight setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_12]];
    }
	
	[lowerRight setText:lowerrightString];
	if (_color != nil) {
		[lowerRight setTextColor:_color];
	}
	[lowerRight setTextAlignment:NSTextAlignmentRight];
	[lowerRight setNumberOfLines:1];
	
	[self.contentView addSubview:lowerRight];
    
    if (imgviewflag) {
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        CGRect frame=lowerRight.frame;
        if (version>=7.0)
        {
            frame.origin.x=120;
            lowerRight.frame=frame;
        }
        
        [self.contentView addSubview:clockImageView];
    }
    else
    {
        [clockImageView removeFromSuperview];
    }
    
	
	[upperLeft setHighlightedTextColor:iosStandaredWhiteColor];
	[upperRight setHighlightedTextColor:iosStandaredWhiteColor];
	[lowerLeft setHighlightedTextColor:iosStandaredWhiteColor];
	[lowerRight setHighlightedTextColor:iosStandaredWhiteColor];
	
	UIImage *lineImage = [G2Util thumbnailImage:G2Cell_HairLine_Image];
	if (lineImageView == nil) {
		UIImageView *templineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 56.0, 320.0,lineImage.size.height)];
        self.lineImageView=templineImageView;
       
	}
	[lineImageView setImage:lineImage];
	if (_hairlinereq) {
		[self.contentView addSubview:lineImageView];
	}
    
    if (lowerleftString==nil && lowerrightString==nil)
    {
        self.upperLeft.frame=CGRectMake(10.0, 11.5, 145.0, 20.0);
        self.upperRight.frame=CGRectMake(160.0, 11.5, 150.0, 20.0);
        if (imgviewflag)
        {
           
            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[self.upperLeft.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]} range:NSMakeRange(0, attributedString.length)];
            
            //Now let's make the Bounding Rect
            CGSize size = [attributedString boundingRectWithSize:CGSizeMake(290.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            self.clockImageView.frame=CGRectMake(10.0+size.width+2.0, 10.5, 19.0, 22.0);
        }
      
    }
    
}
-(void)addReceiptImage{
	UIImage *receiptImage=[G2Util thumbnailImage:Receipt_Camera_Image];
	if (lowerRightImageView == nil) {
		UIImageView *templowerRightImageView=[[UIImageView alloc] initWithFrame:CGRectMake(292.0, 
																		  35.0, 
																		  receiptImage.size.width, 
																		  receiptImage.size.height)];
        self.lowerRightImageView=templowerRightImageView;
        self.lowerRightImageView.highlightedImage=[G2Util thumbnailImage:Receipt_Camera_Image_White];
       
	}
	[self.contentView addSubview:lowerRightImageView];
}

-(void)createCommonCellLayoutFields:(NSString *)_placeholder row:(NSInteger)_rowValue{
	if (commonTxtField == nil) {
		UITextField *tempcommonTxtField = [[UITextField alloc] initWithFrame:CGRectMake(05.0, 0.0, 290, self.frame.size.height)];
        self.commonTxtField=tempcommonTxtField;
        
	}
	[commonTxtField setDelegate:self];
	commonTxtField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[commonTxtField setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];
	commonTxtField.placeholder= RPLocalizedString( _placeholder,_placeholder);
	commonTxtField.returnKeyType = UIReturnKeyDone;
	commonTxtField.keyboardType = UIKeyboardTypeDefault;
	commonTxtField.borderStyle = UITextBorderStyleNone;
	commonTxtField.autocorrectionType = UITextAutocorrectionTypeNo;
	commonTxtField.clearButtonMode = UITextFieldViewModeWhileEditing;
	commonTxtField.textAlignment = NSTextAlignmentLeft;
	commonTxtField.textColor = [UIColor blackColor];
	[commonTxtField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	if (_rowValue == 2012 || _rowValue == 2013) {
		commonTxtField.secureTextEntry = YES;
	}
	commonTxtField.tag=_rowValue;
	[commonTxtField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	//[commonTxtField setDelegate:self];
	[commonTxtField setBackgroundColor:[UIColor clearColor]];
	[self.contentView addSubview:commonTxtField];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	[commonCellDelegate performSelector:@selector(moveTableToTopAtIndexPath:) withObject:nil];
	return YES;
}
-(void)setCellSelectedIndex:(NSIndexPath *)_index{
	self.selectedindex = _index;
}

/*- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
	
}*/
- (void)textFieldDidBeginEditing:(UITextField *)textField{
	//DLog(@"textFieldDidBeginEditing");
	[commonCellDelegate performSelector:@selector(moveTableToTopAtIndexPath:) withObject:self.selectedindex];
}
/*- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
	
}*/
- (void)textFieldDidEndEditing:(UITextField *)textField{
	
}




@end
