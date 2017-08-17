//
//  CurrentTimeSheetsCellView.m
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 18/12/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "CurrentTimeSheetsCellView.h"
#import "Constants.h"
#import "TimesheetSummaryViewController.h"
#import "Util.h"
#import "CurrentTimesheetViewController.h"
#import "TimeEntryViewController.h"

@implementation CurrentTimeSheetsCellView
@synthesize leftLb;
@synthesize rightLb;
@synthesize delegate;
@synthesize disclosureImageView;
@synthesize activityView;
@synthesize commentsImageView;
@synthesize detailObj;
@synthesize fieldType;
@synthesize fieldValue;
@synthesize numberKeyPad;
@synthesize decimalPoints;
@synthesize rowHeight;
#define OffSetFor4 100
#define OffSetFor5 190
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)createCellWithLeftString:(NSString *)leftstr
              andLeftStringColor:(UIColor *)leftColor
                  andRightString:(NSString *)rightStr
             andRightStringColor:(UIColor *)rightColor
                     hasComments:(BOOL)hasComments
                      hasTimeoff:(BOOL)hasTimeoff
                         withTag:(NSInteger)tag {

    if (self.leftLb==nil)
    {
        UILabel *tempupperLeftLb = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 8.0, (SCREEN_WIDTH-24)/2, 30.0)];
        if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
        {
            tempupperLeftLb.frame=CGRectMake(12.0, 8.0, SCREEN_WIDTH-112, 30.0);
        }else if ([delegate isKindOfClass:[TimeEntryViewController class]] && rightStr.length == 0)
        {
            tempupperLeftLb.frame=CGRectMake(12.0, 8.0, SCREEN_WIDTH-62, 30.0);
        }
        self.leftLb=tempupperLeftLb;

    }
    if (leftColor != nil)
    {
		[self.leftLb setTextColor:leftColor];
	}
    else
    {
        [self.leftLb setTextColor:RepliconStandardBlackColor];
    }
    [self.leftLb setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]];
    [self.leftLb setTextAlignment:NSTextAlignmentLeft];
    [self.leftLb setText:leftstr];
    [self.leftLb setTag:tag];
    [self.leftLb setBackgroundColor:[UIColor clearColor]];
    [self.leftLb setNumberOfLines:1];
    [self.contentView addSubview:self.leftLb];
    [self.leftLb setAccessibilityIdentifier:@"uia_timesheet_day_label_identifier"];

    if ([ fieldType isEqualToString:UDFType_NUMERIC]||[fieldType isEqualToString:NUMERIC_UDF_TYPE]||[fieldType isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
    {

        if (fieldValue==nil)
        {
            UITextField *tempfieldValue = [[UITextField alloc]init];
            self.fieldValue=tempfieldValue;

       }
        self.fieldValue.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.fieldValue setFrame:CGRectMake(SCREEN_WIDTH/2, 8.0,(SCREEN_WIDTH-24)/2 ,30.0)];
        [self.fieldValue setTextColor:RepliconStandardBlackColor];
        [self.fieldValue setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]];
        [self.fieldValue setTextAlignment:NSTextAlignmentRight];
        [self.fieldValue setBackgroundColor:[UIColor clearColor]];
        self.fieldValue.borderStyle = UITextBorderStyleNone;
        [self.fieldValue setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [self.fieldValue setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
        [self.fieldValue setDelegate:self];
        [self.fieldValue setHidden:NO];

        [self.fieldValue setAccessibilityIdentifier:@"uia_row_level_numeric_udf_value_identifier"];
        [self.fieldValue setText:rightStr];

        [self.fieldValue setTag:tag];
        [self.rightLb setHidden:YES];
        if ([ fieldType isEqualToString:UDFType_NUMERIC]||[fieldType isEqualToString:NUMERIC_UDF_TYPE]||[fieldType isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
        {
            self.fieldValue.keyboardType = UIKeyboardTypeNumberPad;
            //Fix for ios7//JUHI
            float version= [[UIDevice currentDevice].systemVersion newFloatValue];

            if (version>=7.0)
            {
                fieldValue.keyboardAppearance=UIKeyboardAppearanceDark;
            }
        }
        else{
            self.fieldValue.keyboardType = UIKeyboardTypeAlphabet;
              self.fieldValue.returnKeyType = UIReturnKeyDone;
        }
        [self.contentView addSubview:self.fieldValue];
        }

       else{
        if (self.rightLb==nil)
        {
            UILabel *tempupperRightLb = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 8.0,(SCREEN_WIDTH-24)/2 ,30.0)];
            self.rightLb=tempupperRightLb;

       }


        if (leftColor != nil)
        {
            [self.rightLb setTextColor:rightColor];
        }
        else
        {
            [self.rightLb setTextColor:RepliconStandardBlackColor];
        }
        [self.rightLb setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16]];
        [self.rightLb setTextAlignment:NSTextAlignmentRight];
        [self.rightLb setText:rightStr];
        [self.rightLb setTag:tag];
        [self.rightLb setBackgroundColor:[UIColor clearColor]];
        [self.rightLb setNumberOfLines:1];
        [self.fieldValue setHidden:YES];
        [self.contentView addSubview:self.rightLb];

        [self.rightLb setAccessibilityIdentifier:@"uia_row_level_udf_value_identifier"];


    }



    //COMMENTS IMAGE VIEW

    CGFloat rightImagePosition = SCREEN_WIDTH-95;

    if (hasComments) {
        UIImage *commentsImage = [UIImage imageNamed:@"icon_comments_blue"];
        UIImageView *tempCommentsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(rightImagePosition, 13.0, commentsImage.size.width,commentsImage.size.height)];
        self.commentsImageView=tempCommentsImageView;
        [self.commentsImageView setImage:commentsImage];
        [self.contentView addSubview:self.commentsImageView];

        rightImagePosition -= (CGRectGetWidth(self.commentsImageView.frame) + 8.0f);
    }

    if (hasTimeoff) {
        if (hasComments) {
            self.leftLb.frame = CGRectMake(12.0, 8.0, SCREEN_WIDTH-132, 30.0);
        }
        else
        {
            self.leftLb.frame = CGRectMake(12.0, 8.0, SCREEN_WIDTH-112, 30.0);
        }
        
        UIImage *timeOffImage = [UIImage imageNamed:@"icon_vacation_palmtree"];
        UIImageView *timeoffImageView = [[UIImageView alloc] initWithFrame:CGRectMake(rightImagePosition, 13.0, timeOffImage.size.width,timeOffImage.size.height)];
        [timeoffImageView setImage:timeOffImage];
        [self.contentView addSubview:timeoffImageView];
    }


    //DISCLOSURE IMAGE VIEW
    if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
    {

        UIImage *disclosureImage = [UIImage imageNamed:Disclosure_Box];
        if (self.disclosureImageView == nil)
        {
            UIImageView *tempDisclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-disclosureImage.size.width-5, 17, disclosureImage.size.width,disclosureImage.size.height)];
            self.disclosureImageView=tempDisclosureImageView;

        }
        CGFloat rightLbWidth = 80.0;
        rightLb.frame=CGRectMake(SCREEN_WIDTH-ArrowWidth-rightLbWidth, 8.0, rightLbWidth ,30.0);
        [self.disclosureImageView setImage:disclosureImage];
        [self.contentView addSubview:self.disclosureImageView];

    }

    //ACTIVITY VIEW

    if (self.activityView==nil)
    {
        UIActivityIndicatorView *tmpActivityView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityView=tmpActivityView;
    }

    [self.activityView setFrame:CGRectMake(240, 10, 30, 30)];
    [self.contentView addSubview:self.activityView];


    //SEPARATOR VIEW
    if ([delegate isKindOfClass:[CurrentTimesheetViewController class]]||[delegate isKindOfClass:[TimeEntryViewController class]])
    {
        float y=43;
        if ([delegate isKindOfClass:[TimeEntryViewController class]]&& tag==0)
        {
            y=rowHeight-2;
        }

        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, SCREEN_WIDTH, 1.0f)];
        [separatorView setBackgroundColor:[Util colorWithHex:@"#CCCCCC" alpha:1.0f]];
        [self.contentView addSubview:separatorView];
    }
}



-(void)createCellWithClientValue:(NSString *)clientValue  andProjectValue:(NSString *)projectValue andTaskValue:(NSString *)taskValue andHasClientAccess:(BOOL)hasClientAccess andHasProgramAccess:(BOOL)hasProgramAccess withTag:(NSInteger)tag{

    UILabel *projectLbl = [[UILabel alloc] init];
    UILabel *projectValueLbl = [[UILabel alloc] init];
    NSString *clientHeader=RPLocalizedString(Client, @"");
    if (hasProgramAccess) {
        clientHeader=RPLocalizedString(Program, @"");
    }
    NSString *projectHeader=RPLocalizedString(Project, @"");
    NSString *taskHeader=RPLocalizedString(Task, @"");
    float heightClient=0;
    float height=0;
    float maxLblWidth = (SCREEN_WIDTH-24)/2;
    float valueLbl_X_Offset = (SCREEN_WIDTH/2) + maxLblWidth;


    if (hasClientAccess||hasProgramAccess)
    {

        UILabel *clientLbl = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 8.0, maxLblWidth, 30.0)];
        [clientLbl setTextColor:RepliconStandardBlackColor];
        [clientLbl setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]];
        [clientLbl setTextAlignment:NSTextAlignmentLeft];
        [clientLbl setText:clientHeader];
        [clientLbl setTag:0];
        [clientLbl sizeToFit];
        [clientLbl setNumberOfLines:0];


        UILabel *clientValueLbl = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 8.0,maxLblWidth ,30.0)];
        if (clientValue)
        {

            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:clientValue];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]} range:NSMakeRange(0, attributedString.length)];

            //Now let's make the Bounding Rect
            CGSize mainSize = [attributedString boundingRectWithSize:CGSizeMake(maxLblWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;



            if (mainSize.width==0 && mainSize.height ==0)
            {
                mainSize=CGSizeMake(11.0, 18.0);
            }

            // Let's make an NSAttributedString first
            attributedString = [[NSMutableAttributedString alloc] initWithString:clientHeader];
            //Add LineBreakMode
           paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]} range:NSMakeRange(0, attributedString.length)];

            //Now let's make the Bounding Rect
            CGSize mainSizeHeader = [attributedString boundingRectWithSize:CGSizeMake(maxLblWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;


            if (mainSizeHeader.width==0 && mainSizeHeader.height ==0)
            {
                mainSizeHeader=CGSizeMake(11.0, 18.0);
            }
            CGSize  bestsize = [clientLbl sizeThatFits:CGSizeMake(maxLblWidth, mainSizeHeader.height)];
            clientLbl.frame=CGRectMake(12.0, 8.0, bestsize.width, bestsize.height);
            clientValueLbl.frame=CGRectMake(valueLbl_X_Offset-mainSize.width, 8.0, mainSize.width, mainSize.height+20.0);
            if (mainSizeHeader.height>mainSize.height) {
                heightClient = mainSizeHeader.height+20;
            }
            else
            {
                heightClient = mainSize.height+20;
            }
            if (mainSizeHeader.height<30 && mainSize.height<30)
            {
                heightClient=40;
            }

        }
        [clientValueLbl setTextColor:RepliconStandardBlackColor];
        [clientValueLbl setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]];
        [clientValueLbl setTextAlignment:NSTextAlignmentRight];
        [clientValueLbl setText:clientValue];
        [clientValueLbl setTag:1];
        [clientValueLbl setNumberOfLines:0];
        [clientValueLbl sizeToFit];
        [self.contentView addSubview:clientLbl];
        [self.contentView addSubview:clientValueLbl];





        if (projectValue)
        {

            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:projectValue];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]} range:NSMakeRange(0, attributedString.length)];

            //Now let's make the Bounding Rect
            CGSize mainSize = [attributedString boundingRectWithSize:CGSizeMake(maxLblWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

            if (mainSize.width==0 && mainSize.height ==0)
            {
                mainSize=CGSizeMake(11.0, 18.0);
            }

            // Let's make an NSAttributedString first
           attributedString = [[NSMutableAttributedString alloc] initWithString:projectHeader];
            //Add LineBreakMode
           paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]} range:NSMakeRange(0, attributedString.length)];

            //Now let's make the Bounding Rect
            CGSize mainSizeHeader = [attributedString boundingRectWithSize:CGSizeMake(maxLblWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

            if (mainSizeHeader.width==0 && mainSizeHeader.height ==0)
            {
                mainSizeHeader=CGSizeMake(11.0, 18.0);
            }

            projectLbl.frame=CGRectMake(12.0, heightClient+10.0, maxLblWidth, mainSizeHeader.height+20.0);
            projectValueLbl.frame=CGRectMake(valueLbl_X_Offset-mainSize.width,heightClient+10.0, mainSize.width, mainSize.height+20.0);
            if (mainSizeHeader.height>mainSize.height) {
                height = mainSizeHeader.height+20;
            }
            else
            {
                height = mainSize.height+20;
            }
            if (mainSizeHeader.height<30 && mainSize.height<30)
            {
                height=40;
            }

        }
    }

    else
    {

        if (projectValue)
        {

            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:projectValue];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]} range:NSMakeRange(0, attributedString.length)];

            //Now let's make the Bounding Rect
            CGSize mainSize = [attributedString boundingRectWithSize:CGSizeMake(maxLblWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

            if (mainSize.width==0 && mainSize.height ==0)
            {
                mainSize=CGSizeMake(11.0, 18.0);
            }

            // Let's make an NSAttributedString first
           attributedString = [[NSMutableAttributedString alloc] initWithString:projectHeader];
            //Add LineBreakMode
           paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]} range:NSMakeRange(0, attributedString.length)];

            //Now let's make the Bounding Rect
            CGSize mainSizeHeader = [attributedString boundingRectWithSize:CGSizeMake(maxLblWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

            if (mainSizeHeader.width==0 && mainSizeHeader.height ==0)
            {
                mainSizeHeader=CGSizeMake(11.0, 18.0);
            }
            projectLbl.frame=CGRectMake(12.0, 8, maxLblWidth, mainSizeHeader.height+20.0);
            projectValueLbl.frame=CGRectMake(valueLbl_X_Offset-mainSize.width, 8, mainSize.width, mainSize.height+20.0);

            if (mainSizeHeader.height>mainSize.height) {
                height = mainSizeHeader.height+20;
            }
            else
            {
                height = mainSize.height+20;
            }
            if (mainSizeHeader.height<30 && mainSize.height<30)
            {
                height=40;
            }
        }

    }





    [projectLbl setTextColor:RepliconStandardBlackColor];
    [projectLbl setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]];
    [projectLbl setTextAlignment:NSTextAlignmentLeft];
    [projectLbl setText:projectHeader];
    [projectLbl setTag:2];
    [projectLbl setNumberOfLines:0];
    [projectLbl sizeToFit];
    [self.contentView addSubview:projectLbl];





    [projectValueLbl setTextColor:RepliconStandardBlackColor];
    [projectValueLbl setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]];
    [projectValueLbl setTextAlignment:NSTextAlignmentRight];
    [projectValueLbl setText:projectValue];
    [projectValueLbl setTag:3];
    [projectValueLbl setNumberOfLines:0];
    [projectValueLbl sizeToFit];
    [self.contentView addSubview:projectValueLbl];


    height=height+heightClient;
    UILabel *taskLbl = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 8+height+5.0, maxLblWidth, 30.0)];
    [taskLbl setTextColor:RepliconStandardBlackColor];
    [taskLbl setBackgroundColor:[UIColor clearColor]];
    [taskLbl setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]];
    [taskLbl setTextAlignment:NSTextAlignmentLeft];
    [taskLbl setText:taskHeader];
    [taskLbl setTag:4];
    [taskLbl setNumberOfLines:0];
    [taskLbl sizeToFit];
    [self.contentView addSubview:taskLbl];


    UILabel *taskValueLbl = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 8+height+5.0,maxLblWidth ,30.0)];
    if (taskValue)
    {

        // Let's make an NSAttributedString first
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:taskValue];
        //Add LineBreakMode
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]} range:NSMakeRange(0, attributedString.length)];

        //Now let's make the Bounding Rect
        CGSize mainSize = [attributedString boundingRectWithSize:CGSizeMake(maxLblWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

        if (mainSize.width==0 && mainSize.height ==0)
        {
            mainSize=CGSizeMake(11.0, 18.0);
        }
        attributedString = [[NSMutableAttributedString alloc] initWithString:taskHeader];
        //Add LineBreakMode
        paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]} range:NSMakeRange(0, attributedString.length)];

        //Now let's make the Bounding Rect
        CGSize mainSizeHeader = [attributedString boundingRectWithSize:CGSizeMake(maxLblWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

        if (mainSizeHeader.width==0 && mainSizeHeader.height ==0)
        {
            mainSizeHeader=CGSizeMake(11.0, 18.0);
        }
        CGSize  bestsize = [taskLbl sizeThatFits:CGSizeMake(maxLblWidth, mainSizeHeader.height)];
        taskLbl.frame=CGRectMake(12.0, height+10.0, bestsize.width, bestsize.height);
        taskValueLbl.frame=CGRectMake(valueLbl_X_Offset-mainSize.width, height+10.0, mainSize.width, mainSize.height+20.0);
    }

    [taskValueLbl setTextColor:RepliconStandardBlackColor];
    [taskValueLbl setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]];
    [taskValueLbl setTextAlignment:NSTextAlignmentRight];
    [taskValueLbl setText:taskValue];
    [taskValueLbl setTag:5];
    [taskValueLbl setNumberOfLines:0];
    [taskValueLbl sizeToFit];
    [self.contentView addSubview:taskValueLbl];


    //LOWER IMAGE VIEW
    if ([delegate isKindOfClass:[TimeEntryViewController class]])
    {

        UIImage *lowerImage = [Util thumbnailImage:Cell_HairLine_Image];
        UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,rowHeight-2, SCREEN_WIDTH,lowerImage.size.height)];
        [lineImageView setImage:lowerImage];
        [self.contentView bringSubviewToFront:lineImageView];
        [self.contentView addSubview:lineImageView];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self.fieldValue setTextColor:RepliconStandardBlackColor];


}
#pragma TEXTFILED DELEGATES

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([delegate isKindOfClass:[TimeEntryViewController class]])
    {

        TimeEntryViewController *currentTimesheetCtrl=(TimeEntryViewController *)delegate;
        [currentTimesheetCtrl doneClicked];
        if ([currentTimesheetCtrl lastUsedTextField])
        {
            [currentTimesheetCtrl setLastUsedTextField:nil];
        }
        [currentTimesheetCtrl setLastUsedTextField:fieldValue];


        [currentTimesheetCtrl performSelector:@selector(showCustomPickerIfApplicable:) withObject:textField];

        [currentTimesheetCtrl resetTableSize:YES];


        if ([textField.text isEqualToString:ADD_STRING ])
        {
            textField.text=@"";
        }

        if ([fieldType isEqualToString:UDFType_NUMERIC]||[fieldType isEqualToString:NUMERIC_UDF_TYPE]||[fieldType isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
        {
           //movementDistance =screenRect.size.height-480;
            if (!self.numberKeyPad) {
                self.numberKeyPad.isDonePressed=NO;
                self.numberKeyPad =[NumberKeypadDecimalPoint keypadForTextField:textField withDelegate:delegate withMinus:YES andisDoneShown:YES withResignButton:NO];
                if ([textField textAlignment] == NSTextAlignmentRight) {
                    [self.numberKeyPad.decimalPointButton setTag:333];
                }
            }else {
                //if we go from one field to another - just change the textfield, don't reanimate the decimal point button
                self.numberKeyPad.currentTextField = textField;
            }
        }




    }


    // change size of UITableView


    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField textAlignment] == NSTextAlignmentRight) {
		[Util updateRightAlignedTextField:textField withString:string withRange:range withDecimalPlaces:decimalPoints];
		return NO;
	}
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == numberKeyPad.currentTextField) {
		/*
		 Hide the number keypad
		 */
		[self.numberKeyPad removeButtonFromKeyboard];
        if ([numberKeyPad isDonePressed])
        {
            if ([delegate isKindOfClass:[TimeEntryViewController class]])
            {
                TimeEntryViewController *currentTimesheetCtrl=(TimeEntryViewController *)delegate;

                 [currentTimesheetCtrl resetTableSize:NO];
                [[currentTimesheetCtrl timeEntryTableView] deselectRowAtIndexPath:[currentTimesheetCtrl selectedIndexPath] animated:YES];
            }
            numberKeyPad.isDonePressed=NO;

        }
		self.numberKeyPad = nil;
        if([textField.text length] > 0)
        {
            if ([delegate isKindOfClass:[TimeEntryViewController class]])
            {
                TimeEntryViewController *currentTimesheetCtrl=(TimeEntryViewController *)delegate;
                textField.text=[Util getRoundedValueFromDecimalPlaces:[textField.text newDoubleValue] withDecimalPlaces:decimalPoints];
                [currentTimesheetCtrl updateUDFNumber:textField.text forIndex:textField.tag];
            }

        }
	}
    if ([textField.text length] == 0 ){
        textField.text=ADD_STRING;
        if ([delegate isKindOfClass:[TimeEntryViewController class]])
        {
            TimeEntryViewController *currentTimesheetCtrl=(TimeEntryViewController *)delegate;
            [currentTimesheetCtrl updateUDFNumber:textField.text forIndex:textField.tag];
        }

    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([delegate isKindOfClass:[TimeEntryViewController class]])
    {
        TimeEntryViewController *currentTimesheetCtrl=(TimeEntryViewController *)delegate;
        [currentTimesheetCtrl resetTableSize:NO];

        [[currentTimesheetCtrl timeEntryTableView] deselectRowAtIndexPath:[currentTimesheetCtrl selectedIndexPath] animated:YES];
    }

    [textField resignFirstResponder];

    return YES;
}

@end
