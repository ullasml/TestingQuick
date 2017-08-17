
#import "AddDescriptionViewController.h"
#import "Util.h"
#import "TimeOffDetailsViewController.h"
@implementation AddDescriptionViewController

@synthesize descTextView;
@synthesize textCountLable;
@synthesize clearButton;
@synthesize descControlDelegate;
@synthesize fromEditing;
@synthesize descTextString;
@synthesize navBarTitle;
@synthesize fromExpenseDescription;
@synthesize isNonEditable;
@synthesize fromTimeoffEntryComments;
@synthesize fromTextUdf;

#define CELL_PADDING 16
#define LABEL_PADDING 12
#define clearButtonFrame CGRectMake(LABEL_PADDING,120,150,25.0)
#define TEXTCOUNT_LABEL_WIDTH 87
#define TEXTCOUNT_LBEL_X SCREEN_WIDTH-(LABEL_PADDING+TEXTCOUNT_LABEL_WIDTH+2*CELL_PADDING)
#define textCountLableFrame CGRectMake(TEXTCOUNT_LBEL_X,115, 87.0,25.0)

- (void) setViewTitle: (NSString *)title
{
    [Util setToolbarLabel:self withText: RPLocalizedString(title, title) ];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];

    self.containerView = [[UIView alloc] init];
    self.containerView.layer.borderColor = [[Util colorWithHex:@"#CCCCCC" alpha:1.0]CGColor];
    self.containerView.layer.borderWidth = 2.0f;
    self.containerView.layer.cornerRadius = 12.0f;

    self.descTextView = [[UITextView alloc] init];
    self.descTextView.textColor = RepliconStandardBlackColor;
    self.descTextView.scrollEnabled = YES;
    [self.descTextView setShowsVerticalScrollIndicator:YES];
    [self.descTextView setShowsHorizontalScrollIndicator:NO];
    [self.descTextView setAccessibilityIdentifier:@"description_text_view"];

    /*if (fromExpenseDescription)
     {
     [self.descTextView setAutocorrectionType: UITextAutocorrectionTypeYes];
     }
     else
     {
     [self.descTextView setAutocorrectionType: UITextAutocorrectionTypeNo];
     }*/

    [self.descTextView setAutocorrectionType: UITextAutocorrectionTypeYes];
    [self.descTextView setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
    self.descTextView.layer.cornerRadius = 12.0f;
    self.descTextView.font = [UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14];
    self.descTextView.delegate = self;
    self.descTextView.returnKeyType = UIReturnKeyDefault;
    self.descTextView.keyboardType = UIKeyboardTypeASCIICapable;
    self.descTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.descTextView setBackgroundColor:[UIColor clearColor]];
    [self.descTextView becomeFirstResponder];
    [self.containerView addSubview: self.descTextView];
    [self.descTextView setAccessibilityIdentifier:@"uia_description_text_view_identifier"];


    UIBarButtonItem *leftButton1 = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(Cancel_Button_Title, @"")
                                                                    style: UIBarButtonItemStylePlain
                                                                   target: self
                                                                   action: @selector(cancelAction:)];
    if (self.isNonEditable)
    {
        [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    }
    else
    {
        [self.navigationItem setLeftBarButtonItem:leftButton1 animated:NO];
    }




    if (!isNonEditable)
    {
        UIBarButtonItem *rightButton1 = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(Done_Button_Title, @"")
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(saveAction:)];
        [rightButton1 setAccessibilityLabel:@"uia_description_done_button_identifier"];
        [self.navigationItem setRightBarButtonItem:rightButton1 animated:NO];

    }
    else
    {
        [self.descTextView setEditable:NO];
    }

    if (!isNonEditable)
    {
        if (textCountLable == nil) {
            textCountLable = [[UILabel alloc] initWithFrame:textCountLableFrame];
        }
        [textCountLable setBackgroundColor:[UIColor clearColor]];
        [textCountLable setTextAlignment:NSTextAlignmentCenter];
        [textCountLable setTextColor:[UIColor grayColor]];
        [textCountLable setFont:[UIFont fontWithName:RepliconFontFamily size:15.0]];
        [self.containerView addSubview:textCountLable];

        if (clearButton==nil) {
            UIButton *tempclearButton=[[UIButton alloc]initWithFrame:clearButtonFrame];
            self.clearButton=tempclearButton;

        }
        [self.clearButton setTitle:RPLocalizedString(@"Clear", @"Clear") forState:UIControlStateNormal];
        [self.clearButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:14.0]];
        [self.clearButton.titleLabel setTextColor:[UIColor blueColor]];
        [self.clearButton setBackgroundColor:[UIColor clearColor]];
        [self.clearButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];
        [self.clearButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateHighlighted];
        [self.clearButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.clearButton addTarget:self action:@selector(clearAction) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview: self.clearButton];

    }

    [self.view addSubview: self.containerView];



}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    [self.view setBackgroundColor:RepliconStandardBackgroundColor];

    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat cellPadding = CELL_PADDING;
    [self.containerView setFrame: CGRectMake(cellPadding, cellPadding-6, (width - (2 * cellPadding)), 145)];
    [self.descTextView setFrame:CGRectMake(0, 0, (width - (2 * cellPadding)), 130)];

    [self.navigationController.navigationItem setHidesBackButton:YES];
    if (descTextString!=nil && ![descTextString isKindOfClass:[NSNull class]])
    {
        if ([descTextString isEqualToString:RPLocalizedString(@"Add", @"") ]) {
            self.descTextView.text = @"";
        }else {
            if(descTextString!=nil && ![descTextString isKindOfClass:[NSNull class]] && ![descTextString isEqualToString:NULL_STRING])
            {
                self.descTextView.text=descTextString;
            }
            else
            {
                self.descTextView.text=@"";
            }
        }
    }
    else
    {
        self.descTextView.text=@"";
    }

}

#pragma mark ButtonActions
#pragma mark -

-(void)clearAction
{
    CLS_LOG(@"-----Clear Action on AddDescriptionViewController -----");
    [clearButton setTitleColor:clearButtonHighlighetedColor forState:UIControlStateNormal];
    [self performSelector:@selector(resetClearButtonColor) withObject:nil afterDelay:0.5];
    [self.descTextView setText:RPLocalizedString(@"",@"")];

}

-(void)resetClearButtonColor
{
    [clearButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];
}
-(void)cancelAction:(id)sender
{
    CLS_LOG(@"-----Cancel Action on AddDescriptionViewController -----");
    [self.navigationController popViewControllerAnimated:YES];

}
-(void)saveAction:(id)sender
{
    CLS_LOG(@"-----Done Action on AddDescriptionViewController -----");
    [self.descTextView resignFirstResponder];
    if (fromTimeoffEntryComments) {
        if ([descControlDelegate isKindOfClass:[TimeOffDetailsViewController class]])
        {
            [descControlDelegate setIsComment:TRUE];
            [descControlDelegate performSelector:@selector(updateComments:) withObject:self.descTextView.text];
        }
    }
    else{
        if (fromTextUdf)
        {
            [descControlDelegate performSelector:@selector(updateTextUdf:) withObject:self.descTextView.text];
        }
        else
            [descControlDelegate performSelector:@selector(setDescription:) withObject:self.descTextView.text];
    }
    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark -
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

    if (self.descTextView.contentSize.height>140)
    {

        [textCountLable setFrame:textCountLableFrame];
        [clearButton setFrame:clearButtonFrame];
    }
}
-(void)setDescriptionText:(NSString *)description
{
    [self.descTextView setText:RPLocalizedString(description,@"set Description")];
    self.descTextView.text = RPLocalizedString(@"TEST",@"TEST");
}

-(void)changeButtonFramesDynamically
{
    [textCountLable setFrame:CGRectMake(TEXTCOUNT_LBEL_X,self.descTextView.contentSize.height-10,85.0,45.0)];
    
    [clearButton setFrame:CGRectMake(LABEL_PADDING,self.descTextView.contentSize.height-10,45.0,45.0)];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.descTextView=nil;
    self.clearButton=nil;
}

@end
