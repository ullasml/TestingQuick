//
//  ApprovalTablesFooterView.m
//  Replicon
//
//  Created by Dipta Rakshit on 2/8/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "ApprovalTablesFooterView.h"
#import "Constants.h"
#import "Util.h"
#import "CurrentTimesheetViewController.h"
#import "ListOfExpenseEntriesViewController.h"
#import "WidgetTSViewController.h"
#import "TimeOffDetailsView.h"
#import "ButtonStylist.h"
#import "DefaultTheme.h"
#import "UIView+Additions.h"

#define WidthOfTextView 300
#define HeightTextView 80
#define hexcolor_code @"#333333"

@implementation ApprovalTablesFooterView
@synthesize  approveButton;
@synthesize  rejectButton;
@synthesize  commentsTextView;
@synthesize  delegate;
@synthesize timesheetStatus;
@synthesize commentsTextLbl;
@synthesize reopenButton;
@synthesize approverCommentsLabel;


- (id)initWithFrame:(CGRect)framee withStatus:(NSString *)status
{

    self =[super initWithFrame:framee];
    if (self) {
        self.timesheetStatus=status;
        [self drawLayout];
        
    }
    return self;
}

-(void)drawLayout
{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.origin.y, self.width, 1)];
    lineView.backgroundColor = [UIColor blackColor];
    //[self addSubview:lineView];
    
    float y=0.0;
    UILabel *label=[[UILabel alloc] init];
    label.text=RPLocalizedString(@"Approver Comments", @"") ;
    [label setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14]];
    label.frame=CGRectMake(10.0,self.frame.origin.y, self.width, 30.0);
    self.approverCommentsLabel=label;
    [self addSubview:label];
    y=label.frame.origin.y+label.frame.size.height;
   
    static CGFloat textViewOuterPadding = 10.0f;
    
    if (self.commentsTextView==nil)
    {
        UITextView *temptextField=[[UITextView alloc]initWithFrame:CGRectMake(textViewOuterPadding,y+5,self.width - textViewOuterPadding*2,HeightTextView)];
        self.commentsTextView=temptextField;
    }
    
    [[self.commentsTextView layer] setBorderColor:[[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.7] CGColor]];
    [[self.commentsTextView layer] setBorderWidth:1.0];
    [[self.commentsTextView layer] setCornerRadius:9];
    [self.commentsTextView setClipsToBounds: YES];
    [self.commentsTextView setScrollEnabled:TRUE];
    self.commentsTextView.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.commentsTextView.returnKeyType = UIReturnKeyDone;
    self.commentsTextView.keyboardType = UIKeyboardTypeASCIICapable;
    self.commentsTextView.textAlignment = NSTextAlignmentLeft;
    self.commentsTextView.textColor = RepliconStandardBlackColor;
    [self.commentsTextView setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14]];
    [[self.commentsTextView layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[self.commentsTextView layer] setBorderWidth:1.0];
    [[self.commentsTextView layer] setCornerRadius:9];
    [self.commentsTextView setClipsToBounds: YES];
    [self.commentsTextView setDelegate:self];
    [self.commentsTextView setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    DefaultTheme * theme = [[DefaultTheme alloc] init];
    ButtonStylist *buttonStylist = [[ButtonStylist alloc] initWithTheme:theme];

    CGFloat buttonWidth = self.width * 0.66f;
    CGFloat leftPadding = (self.width - buttonWidth) / 2.0f;

    static CGFloat buttonHeight = 35.0f;
    static CGFloat buttonInnerPadding = 10.0f;
    static CGFloat buttonOuterPadding = 25.0f;

    UIView *buttonContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, commentsTextView.frame.origin.y + commentsTextView.frame.size.height + buttonOuterPadding, self.width, buttonHeight * 2 + buttonInnerPadding + 2 * buttonOuterPadding)];
    [buttonContainerView setBackgroundColor:[theme supervisorDashboardBackgroundColor]];

    self.rejectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.rejectButton setFrame:CGRectMake(leftPadding, buttonOuterPadding, buttonWidth, buttonHeight)];

    [buttonStylist styleButton:self.rejectButton
                         title:RPLocalizedString(REJECT_TEXT, REJECT_TEXT)
                    titleColor:[theme approvalsRejectButtonColor]
               backgroundColor:[UIColor whiteColor]
                   borderColor:[theme standardButtonBorderColor]];

    [self.rejectButton setTitle:RPLocalizedString(REJECT_TEXT, REJECT_TEXT) forState:UIControlStateNormal];
    [self.rejectButton addTarget:self action:@selector(handleButtonClicks:) forControlEvents:UIControlEventTouchUpInside];
    [self.rejectButton setTag:REJECT_BUTTON_TAG];
    
    self.approveButton =[UIButton buttonWithType:UIButtonTypeSystem];
    [self.approveButton setFrame:CGRectMake(leftPadding, self.rejectButton.frame.origin.y + self.rejectButton.frame.size.height + buttonInnerPadding, buttonWidth, buttonHeight)];

    [buttonStylist styleButton:self.approveButton
                         title:RPLocalizedString(APPROVE_TEXT, APPROVE_TEXT)
                    titleColor:[theme approvalsApproveButtonColor]
               backgroundColor:[UIColor whiteColor]
                   borderColor:[theme standardButtonBorderColor]];
    

    [self.approveButton setTitle:RPLocalizedString(APPROVE_TEXT, APPROVE_TEXT) forState:UIControlStateNormal];
    [self.approveButton addTarget:self action:@selector(handleButtonClicks:) forControlEvents:UIControlEventTouchUpInside];
    [self.approveButton setTag:APPROVE_BUTTON_TAG];

    [buttonContainerView addSubview:self.rejectButton];
    [buttonContainerView addSubview:self.approveButton];

    [self addSubview:self.commentsTextView];
    [self addSubview:buttonContainerView];

    self.frame = CGRectMake(0, 0, self.width, CGRectGetMaxY(buttonContainerView.frame));
}

-(void)handleButtonClicks:(id)sender
{
    [self.commentsTextView resignFirstResponder];
    UIButton *btn=(UIButton *)sender;
    
    if ([delegate respondsToSelector:@selector(handleButtonClickForFooterView:)])
        [delegate handleButtonClickForFooterView:btn.tag];
}

#pragma mark UITextView Delegates
#pragma mark -

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    //[self resetView:YES];
    if ([delegate respondsToSelector:@selector(resetViewForApprovalsCommentsAction:andComments:)] && [delegate isKindOfClass:[CurrentTimesheetViewController class]])
    {
        CurrentTimesheetViewController *ctrl=(CurrentTimesheetViewController *)delegate;
        [ctrl resetViewForApprovalsCommentsAction:YES andComments:textView.text];
    }
    if ([delegate respondsToSelector:@selector(resetViewForApprovalsCommentsAction:andComments:)] && [delegate isKindOfClass:[WidgetTSViewController class]])
    {
        WidgetTSViewController *ctrl=(WidgetTSViewController *)delegate;
        [ctrl resetViewForApprovalsCommentsAction:YES andComments:textView.text];
    }
    
    
    if ([delegate respondsToSelector:@selector(resetViewForApprovalsCommentsAction:andComments:forParentView:)] && [delegate isKindOfClass:[ListOfExpenseEntriesViewController class]])
    {
        ListOfExpenseEntriesViewController *ctrl=(ListOfExpenseEntriesViewController *)delegate;
        [ctrl resetViewForApprovalsCommentsAction:YES andComments:textView.text forParentView:self];
    }
    if ([delegate respondsToSelector:@selector(resetViewForApprovalsCommentAction:andComments:)] && [delegate isKindOfClass:[TimeOffDetailsView class]])
    {
        TimeOffDetailsView *ctrl=(TimeOffDetailsView *)delegate;
        [ctrl resetViewForApprovalsCommentAction:YES andComments:textView.text];
    }

    if ([delegate respondsToSelector:@selector(resetViewForApprovalsCommentWithIsReset:comments:)] && [delegate isKindOfClass:[MultiDayTimeOffViewController class]])
    {
        MultiDayTimeOffViewController *ctrl=(MultiDayTimeOffViewController *)delegate;
        [ctrl resetViewForApprovalsCommentWithIsReset:YES comments:textView.text];
    }
    
	return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{

}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView setSelectedRange:NSMakeRange(0, 0)];
    if ([delegate respondsToSelector:@selector(resetViewForApprovalsCommentsAction:andComments:)]&& [delegate isKindOfClass:[CurrentTimesheetViewController class]])
    {
         CurrentTimesheetViewController *ctrl=(CurrentTimesheetViewController *)delegate;
        [ctrl resetViewForApprovalsCommentsAction:NO andComments:textView.text];
    }
    if ([delegate respondsToSelector:@selector(resetViewForApprovalsCommentsAction:andComments:)] && [delegate isKindOfClass:[WidgetTSViewController class]])
    {
        WidgetTSViewController *ctrl=(WidgetTSViewController *)delegate;
        [ctrl resetViewForApprovalsCommentsAction:NO andComments:textView.text];
    }
    
    if ([delegate respondsToSelector:@selector(resetViewForApprovalsCommentsAction:andComments:forParentView:)] && [delegate isKindOfClass:[ListOfExpenseEntriesViewController class]])
    {
        ListOfExpenseEntriesViewController *ctrl=(ListOfExpenseEntriesViewController *)delegate;
        [ctrl resetViewForApprovalsCommentsAction:NO andComments:textView.text forParentView:self];
    }
    
    if ([delegate respondsToSelector:@selector(resetViewForApprovalsCommentAction:andComments:)] && [delegate isKindOfClass:[TimeOffDetailsView class]])
    {
        TimeOffDetailsView *ctrl=(TimeOffDetailsView *)delegate;
        [ctrl resetViewForApprovalsCommentAction:NO andComments:textView.text];
    }
    if ([delegate respondsToSelector:@selector(resetViewForApprovalsCommentWithIsReset:comments:)] && [delegate isKindOfClass:[MultiDayTimeOffViewController class]])
    {
        MultiDayTimeOffViewController *ctrl=(MultiDayTimeOffViewController *)delegate;
        [ctrl resetViewForApprovalsCommentWithIsReset:NO comments:textView.text];
    }
    return YES;
}
- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    }
    
    [txtView resignFirstResponder];
    return NO;
}

@end
