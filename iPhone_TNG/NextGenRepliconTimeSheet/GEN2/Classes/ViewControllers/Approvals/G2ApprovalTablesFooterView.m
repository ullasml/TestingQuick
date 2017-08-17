//
//  ApprovalTablesFooterView.m
//  Replicon
//
//  Created by Dipta Rakshit on 2/8/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2ApprovalTablesFooterView.h"
#import "G2Constants.h"
#import "G2Util.h"

@implementation G2ApprovalTablesFooterView
@synthesize  approveButton;
@synthesize  rejectButton;
@synthesize  commentsTextView;
@synthesize  delegate;
@synthesize timesheetStatus;
@synthesize commentsTextLbl;
@synthesize reopenButton;
@synthesize moreButton;
@synthesize moreImageView;
@synthesize approverCommentsLabel;
enum  {
	APPROVE_BUTTON_TAG_G2,
	REJECT_BUTTON_TAG_G2,
	COMMENTS_TEXTVIEW_TAG_G2,
    REOPEN_BUTTON_TAG_G2,
};

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
        [self drawLayout];
    
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame andStatus:(NSString *)status
{
    self = [super initWithFrame:frame];
    if (self) {
        self.timesheetStatus=status;
        [self drawLayout];
        
    }
    return self;
}

-(void)drawLayout
{
    // Initialization code
    self.moreButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setBackgroundColor:[UIColor clearColor]];
    UIImage *moreImage = [G2Util thumbnailImage:G2MoreButtonIMage];
    
   
    // Let's make an NSAttributedString first
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:RPLocalizedString(MoreText,@"")];
    //Add LineBreakMode
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByClipping];
    [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
    // Add Font
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];
    
    //Now let's make the Bounding Rect
    CGSize expectedLabelSize = [attributedString boundingRectWithSize:CGSizeMake(280, moreImage.size.height+10) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    float totalSize=expectedLabelSize.width+10+moreImage.size.width+1.0;
    int xOrigin=(320.0-totalSize)/2;
    [self.moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [ self.moreButton setFrame:CGRectMake(xOrigin, 30, expectedLabelSize.width+10.0,moreImage.size.height+10 )];
    
    
    [self.moreButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
    [self.moreButton setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal];
    [self.moreButton setTitle:RPLocalizedString(MoreText,@"") forState:UIControlStateNormal];
    [self.moreButton addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    //[moreButton setImage:moreImage forState:UIControlStateNormal];
    [self addSubview:self.moreButton];
    
    UIImageView *tempimageView = [[UIImageView alloc]init];
    [tempimageView setImage:moreImage];
    [tempimageView setFrame:CGRectMake(moreButton.frame.origin.x+expectedLabelSize.width+10.0+1.0,35, moreImage.size.width, moreImage.size.height)];
    [tempimageView setBackgroundColor:[UIColor clearColor]];
    self.moreImageView=tempimageView;
    [self addSubview:moreImageView];
   

    UILabel *label=[[UILabel alloc] init];
    label.text=@"Approver Comments";
    [label setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
    [label setBackgroundColor:[UIColor clearColor]];
    label.frame=CGRectMake(10.0,
                           30,
                           340.0,
                           30.0);
    self.approverCommentsLabel=label;
    [self addSubview:label];
    
    
    
    
    if ([timesheetStatus isEqualToString:APPROVED_STATUS] || [timesheetStatus isEqualToString:REJECTED_STATUS])
    {
        if (self.commentsTextLbl==nil) {
            UILabel *tempcommentsTextLbl=[[UILabel alloc]initWithFrame:CGRectMake(15.0,
                                                                                  60.0,
                                                                                  290.0,
                                                                                  35.0)];
            self.commentsTextLbl=tempcommentsTextLbl;
            
        }
        
        self.commentsTextLbl.textAlignment = NSTextAlignmentLeft;
        self.commentsTextLbl.textColor = RepliconStandardBlackColor;
        [self.commentsTextLbl setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
        [self.commentsTextLbl setBackgroundColor:[UIColor clearColor]];
        self.commentsTextLbl.lineBreakMode = NSLineBreakByWordWrapping; 
        self.commentsTextLbl.numberOfLines = 9999;
       
        //[self.commentsTextLbl sizeToFit]; 
       
        self.reopenButton =[UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *normalImg = [G2Util thumbnailImage:REMINDER_UNPRESSED_IMG];
        UIImage *highlightedImg = [G2Util thumbnailImage:REMINDER_PRESSED_IMG];
        
        
        [self.reopenButton setBackgroundImage:normalImg forState:UIControlStateNormal];
        [self.reopenButton setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
        [self.reopenButton setTitle:RPLocalizedString(REOPEN_TEXT, REOPEN_TEXT) forState:UIControlStateNormal];
        [self.reopenButton setFrame:CGRectMake(20.0, 109, normalImg.size.width, normalImg.size.height)];
        [self.reopenButton addTarget:self action:@selector(handleButtonClicks:) forControlEvents:UIControlEventTouchUpInside];
        self.reopenButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
        [self.reopenButton setTag:REOPEN_BUTTON_TAG_G2];
        
        
        
        [self addSubview:commentsTextLbl];
        [self addSubview:reopenButton];
       

    }
    
    else
    {
        if (self.commentsTextView==nil) {
            UITextView *temptextField=[[UITextView alloc]initWithFrame:CGRectMake(10.0,
                                                                                  65.0,
                                                                                  300.0,
                                                                                  44.0)];//US4065//Juhi
            self.commentsTextView=temptextField;
           
        }
        
        self.commentsTextView.keyboardAppearance = UIKeyboardAppearanceDefault;
        self.commentsTextView.returnKeyType = UIReturnKeyDefault;
        self.commentsTextView.keyboardType = UIKeyboardTypeDefault;
        self.commentsTextView.textAlignment = NSTextAlignmentLeft;
        self.commentsTextView.textColor = RepliconStandardBlackColor;
        [self.commentsTextView setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
        
        // For the border and rounded corners
        [[self.commentsTextView layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
        [[self.commentsTextView layer] setBorderWidth:1.0];
        [[self.commentsTextView layer] setCornerRadius:9];
        [self.commentsTextView setClipsToBounds: YES];
        [self.commentsTextView setScrollEnabled:FALSE];
        //		[self.commentsTextField setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
        [self.commentsTextView setDelegate:self];
        //		[self.commentsTextField setHidden:YES];
        
        
        
        
        self.rejectButton =[UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *normalImg = [G2Util thumbnailImage:G2REJECT_UNPRESSED_IMG];
        UIImage *highlightedImg = [G2Util thumbnailImage:G2REJECT_PRESSED_IMG];
        
        
        [self.rejectButton setBackgroundImage:normalImg forState:UIControlStateNormal];
        [self.rejectButton setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
        [self.rejectButton setTitle:RPLocalizedString(REJECT_TEXT, REJECT_TEXT) forState:UIControlStateNormal];
        [self.rejectButton setFrame:CGRectMake(15.0, commentsTextView.frame.origin.y+commentsTextView.frame.size.height+30, normalImg.size.width, normalImg.size.height)];
        [self.rejectButton addTarget:self action:@selector(handleButtonClicks:) forControlEvents:UIControlEventTouchUpInside];
        self.rejectButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
        [self.rejectButton setTag:REJECT_BUTTON_TAG_G2];
        
        
        
        self.approveButton =[UIButton buttonWithType:UIButtonTypeCustom];
        normalImg = [G2Util thumbnailImage:G2APPROVE_UNPRESSED_IMG];
        highlightedImg = [G2Util thumbnailImage:G2APPROVE_PRESSED_IMG];
        
        
        [self.approveButton setBackgroundImage:normalImg forState:UIControlStateNormal];
        [self.approveButton setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
        [self.approveButton setTitle:RPLocalizedString(APPROVE_TEXT, APPROVE_TEXT) forState:UIControlStateNormal];
        
        [self.approveButton setFrame:CGRectMake(165.0, commentsTextView.frame.origin.y+commentsTextView.frame.size.height+30, normalImg.size.width, normalImg.size.height)];
        [self.approveButton addTarget:self action:@selector(handleButtonClicks:) forControlEvents:UIControlEventTouchUpInside];
         self.approveButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
        [self.approveButton setTag:APPROVE_BUTTON_TAG_G2];
        
        
        [self addSubview:commentsTextView];
        [self addSubview:approveButton];
        [self addSubview:rejectButton];

    }
    
    [self  setFrame:CGRectMake(0, 0, 360.0, self.approveButton.frame.origin.y+self.approveButton.frame.size.height+30.0 )];

}

-(void)handleButtonClicks:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    
    if ([delegate respondsToSelector:@selector(handleButtonClickForFooterView:)])
        [delegate handleButtonClickForFooterView:btn.tag];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([delegate respondsToSelector:@selector(handleButtonClickForFooterView:)])
        [delegate handleButtonClickForFooterView:COMMENTS_TEXTVIEW_TAG_G2];
    
    return NO;
}
-(void)moreAction:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    
    if ([delegate respondsToSelector:@selector(moreButtonClickForFooterView:)])
        [delegate moreButtonClickForFooterView:btn.tag];
}

-(void)hideMoreButton
{
    [self.moreButton setHidden:YES];
    [self.moreImageView setHidden:YES];
    
    
    
    CGRect frame=self.commentsTextLbl.frame;
    frame.origin.y=60;
    self.commentsTextLbl.frame=frame;
    
    frame=self.approverCommentsLabel.frame;
    frame.origin.y=30;
    self.approverCommentsLabel.frame=frame;
    
    frame=self.commentsTextView.frame;
    frame.origin.y=65;
    self.commentsTextView.frame=frame;
    
    frame=self.rejectButton.frame;
    frame.origin.y=commentsTextView.frame.origin.y+commentsTextView.frame.size.height+30;
    self.rejectButton.frame=frame;
    
    frame=self.approveButton.frame;
    frame.origin.y=commentsTextView.frame.origin.y+commentsTextView.frame.size.height+30;
    self.approveButton.frame=frame;
    
    [self  setFrame:CGRectMake(0, 0, 360.0, self.approveButton.frame.origin.y+self.approveButton.frame.size.height+30.0 )];
}

-(void)showMoreButton
{
    [self.moreButton setHidden:NO];
    [self.moreImageView setHidden:NO];
    
    
    
    CGRect frame=self.commentsTextLbl.frame;
    frame.origin.y=90;
    self.commentsTextLbl.frame=frame;
    
    frame=self.approverCommentsLabel.frame;
    frame.origin.y=60;
    self.approverCommentsLabel.frame=frame;
    
    frame=self.commentsTextView.frame;
    frame.origin.y=95;
    self.commentsTextView.frame=frame;
    
    frame=self.rejectButton.frame;
    frame.origin.y=commentsTextView.frame.origin.y+commentsTextView.frame.size.height+30;
    self.rejectButton.frame=frame;
    
    frame=self.approveButton.frame;
    frame.origin.y=commentsTextView.frame.origin.y+commentsTextView.frame.size.height+30;
    self.approveButton.frame=frame;
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    
    if (version>=7.0)
    {
        frame=CGRectMake(0, 0, 360.0, self.approveButton.frame.origin.y+self.approveButton.frame.size.height+100.0 );
        
    }
    else{
        frame=CGRectMake(0, 0, 360.0, self.approveButton.frame.origin.y+self.approveButton.frame.size.height+30.0 );
    }
    [self  setFrame:frame];
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
