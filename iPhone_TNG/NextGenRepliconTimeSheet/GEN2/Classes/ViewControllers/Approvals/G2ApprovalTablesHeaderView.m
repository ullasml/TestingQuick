//
//  ApprovalTablesHeaderView.m
//  Replicon
//
//  Created by Dipta Rakshit on 2/8/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2ApprovalTablesHeaderView.h"
#import "G2Constants.h"
#import "G2ApprovalsUsersListOfTimeEntriesViewController.h"

@implementation G2ApprovalTablesHeaderView
@synthesize  previousButton;
@synthesize  nextButton;
@synthesize  userNameLbl;
@synthesize  durationLbl;
@synthesize  countLbl;
@synthesize delegate;
@synthesize timesheetStatus;

enum  {
	PREVIOUS_BUTTON_TAG,
	NEXT_BUTTON_TAG,
	
};

- (id)initWithFrame:(CGRect)frame :(NSString *)status
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.timesheetStatus=status;
        
        UILabel *tempuserNameLbl=[[UILabel alloc] init];
        self.userNameLbl=tempuserNameLbl;
        
        self.userNameLbl.text=@"Sally Fields";
        [self.userNameLbl setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_13]];
        [self.userNameLbl setBackgroundColor:[UIColor clearColor]];
        [self.userNameLbl setTextAlignment:NSTextAlignmentCenter];
        self.userNameLbl.frame=CGRectMake(35.0,
                               2.0,
                               250.0,
                               15.0);
        [self addSubview:self.userNameLbl];
        
        UILabel *tempdurationLbl=[[UILabel alloc] init];
        self.durationLbl=tempdurationLbl;
       
        self.durationLbl.text=@"Nov 28, 2011 - Dec 20, 2011";
        [self.durationLbl setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_13]];
        [self.durationLbl setBackgroundColor:[UIColor clearColor]];
        [self.durationLbl setTextAlignment:NSTextAlignmentCenter];
        self.durationLbl.frame=CGRectMake(35.0,
                                          19.0,
                                          250.0,
                                          15.0);
        [self addSubview:self.durationLbl];
        
        
        self.previousButton =[UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *indicatorImage = [G2Util thumbnailImage:DISCLOSURE_INDICATOR_LEFT_IMAGE];
//		[self.previousButton setTitle:@"<" forState:UIControlStateNormal];
        [self.previousButton setImage:indicatorImage forState:UIControlStateNormal];
		[self.previousButton setFrame:CGRectMake(0.0, 7.0, 40.0, 40.0)];
		[self.previousButton addTarget:self action:@selector(handleButtonClicks:) forControlEvents:UIControlEventTouchUpInside];
		[self.previousButton setTag:PREVIOUS_BUTTON_TAG];
        [ self.previousButton setTitleColor:RepliconStandardBlackColor forState: UIControlStateNormal]  ;   
         self.previousButton.titleLabel.font=[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_14];
        [self addSubview:self.previousButton];
        
        self.nextButton =[UIButton buttonWithType:UIButtonTypeCustom];
        indicatorImage = [G2Util thumbnailImage:DISCLOSURE_INDICATOR_IMAGE];
//		[self.nextButton setTitle:@">" forState:UIControlStateNormal];
        [self.nextButton setImage:indicatorImage forState:UIControlStateNormal];
		[self.nextButton setFrame:CGRectMake(280.0, 7.0, 40.0, 40.0)];
		[self.nextButton addTarget:self action:@selector(handleButtonClicks:) forControlEvents:UIControlEventTouchUpInside];
		[self.nextButton setTag:NEXT_BUTTON_TAG];
        [ self.nextButton setTitleColor:RepliconStandardBlackColor forState: UIControlStateNormal]  ;
        self.nextButton.titleLabel.font=[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_14];
        [self addSubview:self.nextButton];
        
        
        UILabel *tempcountLbl=[[UILabel alloc] init];
        self.countLbl=tempcountLbl;
        
        
        [self.countLbl setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_13]];
        [self.countLbl setBackgroundColor:[UIColor clearColor]];
        [self.countLbl setTextAlignment:NSTextAlignmentCenter];
        self.countLbl.frame=CGRectMake(35.0,
                                          36.0,
                                          250.0,
                                          16.0);
        self.countLbl.textColor=[UIColor blackColor];
        

        [self addSubview:self.countLbl];

        
        UIImage *lineImage = nil;
        UIImageView *lineImageView =nil;
//        if ([delegate isKindOfClass:[ApprovalsUsersListOfTimeEntriesViewController class]]) {
            lineImage = [G2Util thumbnailImage:G2Cell_HairLine_Image];
//        }
//        else
//        {
//            lineImage = [Util thumbnailImage:G2TimeSheets_ContentsPage_Header];
//        }
        
        
       lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 54.0, 320.0,2)];
        [lineImageView setImage:lineImage];
       [self addSubview:lineImageView];
        
        
        
        [self  setFrame:CGRectMake(0, 0, 360.0, 55.0 )];
    }
    return self;
}


-(void)handleButtonClicks:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    
    if ([delegate respondsToSelector:@selector(handleButtonClickForHeaderView:)])
        [delegate handleButtonClickForHeaderView:btn.tag];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/




@end
