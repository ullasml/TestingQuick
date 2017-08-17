//
//  ApprovalTablesHeaderView.m
//  Replicon
//
//  Created by Dipta Rakshit on 2/8/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "ApprovalTablesHeaderView.h"
#import "Constants.h"
#import "Util.h"
#import "DefaultTheme.h"
#import "Theme.h"
#import "UIView+Additions.h"


#define time_details_hexcolor_code @"#333333"
#define backgroundColor_hexcolor_code @"#e4e4e4"

@implementation ApprovalTablesHeaderView
@synthesize  previousButton;
@synthesize  nextButton;
@synthesize  userNameLbl;
@synthesize  durationLbl;
@synthesize  countLbl;
@synthesize delegate;

enum  {
	PREVIOUS_BUTTON_TAG,
	NEXT_BUTTON_TAG,
	
};


- (id)initWithFrame:(CGRect)frame
         withStatus:(NSString *)status
           userName:(NSString *)userName
         dateString:(NSString *)dateStr
          labelText:(NSString *)labelText
withApprovalModuleName:(NSString *)moduleName
  isWidgetTimesheet:(BOOL)isWidgetTimesheet
withErrorsAndWarningView:(UIView*)errorsAndWarningView
{
    self = [super initWithFrame:frame];
    if (self)
    {
        id<Theme> theme = [[DefaultTheme alloc] init];
        
        UILabel *tempuserNameLbl=[[UILabel alloc] init];
        self.userNameLbl=tempuserNameLbl;
        
        [self.userNameLbl setTextAlignment:NSTextAlignmentCenter];
        
        static CGFloat userNameOuterPadding = 35.0f;
        static CGFloat durationLabelOuterPadding = 35.0f;
        static CGFloat countLabelOuterPadding = 35.0f;
        static CGFloat nextAndPreviousButtonWidth = 40.0;
        static CGFloat nextAndPreviousButtonHeight = 40.0;

        CGFloat screenWidth = self.width;

        self.userNameLbl.text=userName;
        
        self.userNameLbl.frame=CGRectMake(userNameOuterPadding,2.0,screenWidth - userNameOuterPadding*2,20.0);
        
        [self addSubview:self.userNameLbl];
        
        UILabel *tempdurationLbl=[[UILabel alloc] init];
        self.durationLbl=tempdurationLbl;
       
        self.durationLbl.text=dateStr;
        [self.durationLbl setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_13]];
        [self.durationLbl setTextAlignment:NSTextAlignmentCenter];
        self.durationLbl.frame=CGRectMake(durationLabelOuterPadding,21.0,screenWidth - durationLabelOuterPadding*2,18.0);
        self.durationLbl.textColor = [theme approvalHeaderLightTextColor];
        [self addSubview:self.durationLbl];
        
        self.previousButton =[UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *indicatorImageLeft = [UIImage imageNamed:LEFT_INDICATOR_IMAGE];
        [self.previousButton setImage:indicatorImageLeft forState:UIControlStateNormal];
		[self.previousButton setFrame:CGRectMake(0.0, 10.0, nextAndPreviousButtonWidth, nextAndPreviousButtonHeight)];
		[self.previousButton addTarget:self action:@selector(handleButtonClicks:) forControlEvents:UIControlEventTouchUpInside];
		[self.previousButton setTag:PREVIOUS_BUTTON_TAG];
        [ self.previousButton setTitleColor:RepliconStandardBlackColor forState: UIControlStateNormal]  ;   
         self.previousButton.titleLabel.font=[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_14];
        [self addSubview:self.previousButton];
        
        self.nextButton =[UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *indicatorImage = [UIImage imageNamed:RIGHT_INDICATOR_IMAGE];
        [self.nextButton setImage:indicatorImage forState:UIControlStateNormal];
		[self.nextButton setFrame:CGRectMake(screenWidth-nextAndPreviousButtonWidth, 10.0, nextAndPreviousButtonWidth, nextAndPreviousButtonHeight)];
		[self.nextButton addTarget:self action:@selector(handleButtonClicks:) forControlEvents:UIControlEventTouchUpInside];
		[self.nextButton setTag:NEXT_BUTTON_TAG];
        [self.nextButton setTitleColor:RepliconStandardBlackColor forState: UIControlStateNormal]  ;
        self.nextButton.titleLabel.font=[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_14];
        [self addSubview:self.nextButton];
        
        
        UILabel *tempcountLbl=[[UILabel alloc] init];
        self.countLbl=tempcountLbl;
       
        
        [self.countLbl setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_13]];
        [self.countLbl setTextAlignment:NSTextAlignmentCenter];
        self.countLbl.frame=CGRectMake(countLabelOuterPadding,38.0,screenWidth - countLabelOuterPadding*2,16.0);
        self.countLbl.textColor = [theme approvalHeaderLightTextColor];
        [self addSubview:self.countLbl];
        
        if (isWidgetTimesheet)
        {
            UIView *errorAndWarningView=[[UIView alloc]init];
            errorAndWarningView=errorsAndWarningView;
            errorAndWarningView.frame=CGRectMake(0, self.countLbl.frame.origin.y+self.countLbl.frame.size.height+4, screenWidth, errorsAndWarningView.frame.size.height);
            UIButton *submitButton =[UIButton buttonWithType:UIButtonTypeCustom];
            [submitButton setFrame:CGRectMake(0,0, SCREEN_WIDTH, errorsAndWarningView.frame.size.height)];
            [submitButton addTarget:self action:@selector(errorsAndWarningsAction:) forControlEvents:UIControlEventTouchUpInside];
            [errorAndWarningView addSubview:submitButton];
            [self addSubview:errorAndWarningView];
        }
        else{
            if ([moduleName isEqualToString:APPROVALS_PREVIOUS_TIMESHEETS_MODULE]||
                [moduleName isEqualToString:APPROVALS_PREVIOUS_EXPENSES_MODULE]||
                [moduleName isEqualToString:APPROVALS_PREVIOUS_TIMEOFF_MODULE]||[moduleName isEqualToString:APPROVALS_PENDING_TIMEOFF_MODULE])
            {
                // No need to make the frame larger if count lable is empty
                if (self.countLbl.text != nil && self.countLbl.text.length > 0) {
                    [self  setFrame:CGRectMake(0, 0, screenWidth, self.countLbl.frame.origin.y+self.countLbl.frame.size.height+4)];
                }
            }
            else
            {
                UIView *dateSubmittedContainerView=[[UIView alloc]init];
                dateSubmittedContainerView.backgroundColor=[Util colorWithHex:@"#EEEEEE" alpha:1];
                dateSubmittedContainerView.frame=CGRectMake(0, self.countLbl.frame.origin.y+self.countLbl.frame.size.height+4, screenWidth, 30);
                [self addSubview:dateSubmittedContainerView];
                
                UILabel *dateSubmittedLabel=[[UILabel alloc]init];
                [dateSubmittedLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14]];
                [dateSubmittedLabel setTextAlignment:NSTextAlignmentCenter];
                dateSubmittedLabel.frame=CGRectMake(0.0,0.0,screenWidth,30.0);
                dateSubmittedLabel.text=[NSString stringWithFormat:@"%@",RPLocalizedString(labelText, @"")];
                [dateSubmittedContainerView addSubview:dateSubmittedLabel];
                [self  setFrame:CGRectMake(0, 0, screenWidth, dateSubmittedContainerView.frame.origin.y+dateSubmittedContainerView.frame.size.height )];
            }

        }
    }

    return self;
}

-(void)errorsAndWarningsAction:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    
    if ([delegate respondsToSelector:@selector(handleErrorsAndWarningsHeaderAction:)])
        [delegate handleErrorsAndWarningsHeaderAction:btn.tag];
    
    
}
-(void)handleButtonClicks:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    
    if ([delegate respondsToSelector:@selector(handleButtonClickForHeaderView:)])
        [delegate handleButtonClickForHeaderView:btn.tag];
}




@end
