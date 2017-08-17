//
//  CommentsViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 25/01/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "CommentsViewController.h"
#import "TimesheetListObject.h"
#import "UdfObject.h"

#define DESCRIPTION_VIEW_PADDING 7
#define DESCRIPTION_VIEW_WIDTH (SCREEN_WIDTH - (2*DESCRIPTION_VIEW_PADDING))
#define descriptionParentViewFrame CGRectMake(DESCRIPTION_VIEW_PADDING, 7, DESCRIPTION_VIEW_WIDTH, 185)
#define descriptionTextViewFrame CGRectMake(0, 0, DESCRIPTION_VIEW_WIDTH, 160)
#define LEFT_PADDING 12
#define clearButtonFrame CGRectMake(LEFT_PADDING,155,45.0,25.0)
#define TEXTCOUNT_LABEL_WIDTH 87
#define TEXTCOUNT_LBEL_X SCREEN_WIDTH-(LEFT_PADDING+TEXTCOUNT_LABEL_WIDTH+2*DESCRIPTION_VIEW_PADDING)
#define textCountLableFrame CGRectMake(TEXTCOUNT_LBEL_X,155, TEXTCOUNT_LABEL_WIDTH,25.0)

@interface CommentsViewController ()
@property(nonatomic,strong)UITextView *commentsTextView;
@property(nonatomic,strong)UILabel *textCountLabel;
@property(nonatomic,strong)UIButton *clearButton;
@property(nonatomic,strong)UdfObject *udfObject;
@end

@implementation CommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpCommentsViewControllerWithUdfObject:(UdfObject *)udfObject withNavigationFlow:(NavigationFlow)navigationFlow withTimesheetListObject:(TimesheetListObject *)timesheetListObject withTimeOffObj:(TimeOffObject *)timeOffObj
{
    [self setUdfObject:udfObject];
    [Util setToolbarLabel: self withText: [udfObject udfName]];
    [self.view setBackgroundColor:RepliconStandardBackgroundColor];
    NSString *sheetStatus=timesheetListObject.timesheetStatus;
    BOOL cannotEdit=([sheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||([sheetStatus isEqualToString:APPROVED_STATUS ]));
    UIView *view = [[UIView alloc] init];
    [view setFrame: descriptionParentViewFrame];
    [view setBackgroundColor: [UIColor whiteColor]];
    view.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    view.layer.borderWidth = 2.0f;
    view.layer.cornerRadius = 12.0f;
    
    
    UITextView *_tmpCommentsTextView=[[UITextView alloc] init];
    self.commentsTextView = _tmpCommentsTextView;
    [_tmpCommentsTextView setFrame:descriptionTextViewFrame];
    _tmpCommentsTextView.textColor = RepliconStandardBlackColor;
    _tmpCommentsTextView.scrollEnabled = YES;
    [_tmpCommentsTextView setShowsVerticalScrollIndicator:YES];
    [_tmpCommentsTextView setShowsHorizontalScrollIndicator:NO];
    [_tmpCommentsTextView setAutocorrectionType: UITextAutocorrectionTypeNo];
    [_tmpCommentsTextView setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
    _tmpCommentsTextView.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15];
    _tmpCommentsTextView.delegate = self;
    _tmpCommentsTextView.backgroundColor = [UIColor whiteColor];
    _tmpCommentsTextView.returnKeyType = UIReturnKeyDefault;
    _tmpCommentsTextView.keyboardType = UIKeyboardTypeASCIICapable;
    _tmpCommentsTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [_tmpCommentsTextView setBackgroundColor:[UIColor clearColor]];
    [view addSubview: _tmpCommentsTextView];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(Cancel_Button_Title, @"")
                                                                    style: UIBarButtonItemStylePlain
                                                                   target: self
                                                                   action: @selector(cancelAction:)];
    
    if (cannotEdit || (!timeOffObj.canEdit))
    {
        [self.navigationItem setLeftBarButtonItem:nil animated:NO];
        [self.commentsTextView setEditable:NO];
    }
    else
    {
        [self.commentsTextView becomeFirstResponder];
        [self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(Done_Button_Title, @"")
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(saveAction:)];
        [self.navigationItem setRightBarButtonItem:doneButton animated:NO];
        UILabel *textCountLable = [[UILabel alloc] initWithFrame:textCountLableFrame];
        [textCountLable setBackgroundColor:[UIColor clearColor]];
        [textCountLable setTextAlignment:NSTextAlignmentCenter];
        [textCountLable setTextColor:[UIColor grayColor]];
        [textCountLable setFont:[UIFont fontWithName:RepliconFontFamily size:15.0]];
        [view addSubview:textCountLable];
        self.textCountLabel=textCountLable;
        
        UIButton *_tmpClearButton=[[UIButton alloc]initWithFrame:clearButtonFrame];
        self.clearButton=_tmpClearButton;
        [_tmpClearButton setTitle:RPLocalizedString(@"Clear", @"Clear") forState:UIControlStateNormal];
        [_tmpClearButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:14.0]];
        [_tmpClearButton.titleLabel setTextColor:[UIColor blueColor]];
        [_tmpClearButton setBackgroundColor:[UIColor clearColor]];
        [_tmpClearButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];
        [_tmpClearButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateHighlighted];
        [_tmpClearButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_tmpClearButton addTarget:self action:@selector(clearAction) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview: self.clearButton];
    }
    NSString *defaultValue=[udfObject defaultValue];
    if (defaultValue!=nil && ![defaultValue isKindOfClass:[NSNull class]]) {
        if (![[udfObject defaultValue] isEqualToString:@""])
           self.commentsTextView.text=[udfObject defaultValue];
    }
    [self.view addSubview:view];
    
}


-(void)clearAction
{
    CLS_LOG(@"-----Clear Action on CommentsViewController -----");
    [self.clearButton setTitleColor:clearButtonHighlighetedColor forState:UIControlStateHighlighted];
    [self.clearButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];
    [self.commentsTextView setText:@""];
}
-(void)cancelAction:(id)sender
{
    CLS_LOG(@"-----Cancel Action on CommentsViewController -----");
    [self.commentsTextView resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)saveAction:(id)sender
{
    CLS_LOG(@"-----Done Action on CommentsViewController -----");
    [self.commentsTextView resignFirstResponder];
    [self.udfObject setDefaultValue:self.commentsTextView.text];
    if ([self.commentsActionDelegate respondsToSelector:@selector(userEnteredCommentsOnUdfObject:)]) {
        [self.commentsActionDelegate userEnteredCommentsOnUdfObject:self.udfObject];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextView Delegates
#pragma mark -

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{
    if (self.commentsTextView.contentSize.height>140)
    {
        [self.textCountLabel setFrame:textCountLableFrame];
        [self.clearButton setFrame:clearButtonFrame];
    }
}



@end
