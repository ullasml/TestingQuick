//
//  EntriesTableFooterView.m
//  Replicon
//
//  Created by vijaysai on 5/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2EntriesTableFooterView.h"
#import "RepliconAppDelegate.h"

@implementation G2EntriesTableFooterView

@synthesize eventHandler;
@synthesize unsubmitAllowed;
@synthesize  totallabelView,footerButtonsView,submittedDetailsView;
@synthesize radioButton;
@synthesize disclaimerTitleLabel;
@synthesize disclaimerSelected;

enum  {
	DELETE_BUTTON_TAG,
	SUBMIT_BUTTON_TAG,
	UNSUBMIT_BUTTON_TAG,
    REOPEN_BUTTON_TAG_G2//US4660//Juhi
};


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		submitButton =[UIButton buttonWithType:UIButtonTypeCustom];
		UIImage *normalImg = [G2Util thumbnailImage:submitButtonImage];
		UIImage *highlightedImg = [G2Util thumbnailImage:submitButtonImageSelected];
		
		
		[submitButton setBackgroundImage:normalImg forState:UIControlStateNormal];
		[submitButton setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
		
		[submitButton setFrame:CGRectMake(40.0, 30, normalImg.size.width, normalImg.size.height)];
        submitButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
		[submitButton addTarget:self action:@selector(handleButtonClicks:) forControlEvents:UIControlEventTouchUpInside];
		[submitButton setTag:SUBMIT_BUTTON_TAG];
		
		UIView *temptotallabelView=[[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 30.00)];
		self.totallabelView=temptotallabelView;
       
		UIView *tempfooterButtonsView=[[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                               totallabelView.frame.origin.y + totallabelView.frame.size.height,
                                                                               self.frame.size.width,submitButton.frame.origin.y+submitButton.frame.size.height)];
		self.footerButtonsView=tempfooterButtonsView;
        
		
		G2SubmittedDetailsView *tempsubmittedDetailsView = [[G2SubmittedDetailsView alloc]initWithFrame:CGRectMake(0,
                                                                                                               footerButtonsView.frame.origin.y+footerButtonsView.frame.size.height
                                                                                                               ,320,250)];
		self.submittedDetailsView=tempsubmittedDetailsView;
        
		
        /*unsubmitButton =[[UIButton alloc]initWithFrame:CGRectMake(60,
         80,
         200, 30)];
         [unsubmitButton retain];*/
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame forSheetStatus:(NSString *)sheetStatus andDisclaimerAcceptedDate:(NSDate *)disclaimerAcceptedDate {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate]; 
        
       
        appDelegate.disclaimerTitleTimesheets=@"";
       if (disclaimerAcceptedDate!=nil && ![disclaimerAcceptedDate isKindOfClass:[NSNull class]]) 
        {
            appDelegate.disclaimerTitleTimesheets=[NSString stringWithFormat:@"%@ Accepted",appDelegate.attestationTitleTimesheets];
        }
        else 
        {
            appDelegate.disclaimerTitleTimesheets=[NSString stringWithFormat:@"Accept %@",appDelegate.attestationTitleTimesheets];
        }
        
    
        
        // Let's make an NSAttributedString first
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:appDelegate.attestationTitleTimesheets];
        //Add LineBreakMode
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];
        
        //Now let's make the Bounding Rect
        CGSize expectedAttestationTitleLabelSize = [attributedString boundingRectWithSize:CGSizeMake(300, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        UILabel *attestationTitlelabel=[[UILabel alloc] init];
        attestationTitlelabel.text=appDelegate.attestationTitleTimesheets ;
        attestationTitlelabel.textColor=RepliconStandardBlackColor;
        [attestationTitlelabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
        [attestationTitlelabel setBackgroundColor:[UIColor clearColor]];
        attestationTitlelabel.frame=CGRectMake(10.0,
                                               30,
                                               300.0,
                                              expectedAttestationTitleLabelSize.height);
          attestationTitlelabel.numberOfLines=100;
        
        
       
        
        // Let's make an NSAttributedString first
        attributedString = [[NSMutableAttributedString alloc] initWithString:appDelegate.attestationDescTimesheets];
        //Add LineBreakMode
       paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_15]} range:NSMakeRange(0, attributedString.length)];
        
        //Now let's make the Bounding Rect
        CGSize expectedAttestationDescLabelSize = [attributedString boundingRectWithSize:CGSizeMake(300, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        UILabel *attestationDesclabel=[[UILabel alloc] init];
        attestationDesclabel.text=appDelegate.attestationDescTimesheets ;
        attestationDesclabel.textColor=RepliconStandardBlackColor;
        [attestationDesclabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
        [attestationDesclabel setBackgroundColor:[UIColor clearColor]];
        
        if (appDelegate.attestationDescTimesheets==nil || [appDelegate.attestationDescTimesheets isKindOfClass:[NSNull class] ]  || [[appDelegate.attestationDescTimesheets stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]  ] isEqualToString:@"" ] || [appDelegate.attestationDescTimesheets isEqualToString:@"<null>" ] ) 
        {
            attestationDesclabel.frame=CGRectZero;
            
        }
        else 
        {
            attestationDesclabel.frame=CGRectMake(10.0,
                                                  attestationTitlelabel.frame.origin.y+10+attestationTitlelabel.frame.size.height,
                                                  300.0,
                                                  expectedAttestationDescLabelSize.height);
        }
        
        
        attestationDesclabel.numberOfLines=100;
        
              
     UIImage *radioDeselectedImage = nil;
        
        if (disclaimerAcceptedDate!=nil && ![disclaimerAcceptedDate isKindOfClass:[NSNull class]]) 
        {
            radioDeselectedImage = [G2Util thumbnailImage:G2CheckBoxSelectedImage];
            [self setDisclaimerSelected:YES];
        }
        else 
        {
            radioDeselectedImage = [G2Util thumbnailImage:G2CheckBoxDeselectedImage];
            [self setDisclaimerSelected:NO];
        }
        

               
     self.radioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        
        if (appDelegate.attestationDescTimesheets==nil || [appDelegate.attestationDescTimesheets isKindOfClass:[NSNull class] ]  || [[appDelegate.attestationDescTimesheets stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]  ] isEqualToString:@"" ] || [appDelegate.attestationDescTimesheets isEqualToString:@"<null>" ] ) 
        {
            [self.radioButton setFrame:CGRectMake(2.0,
                                                  attestationTitlelabel.frame.origin.y+expectedAttestationTitleLabelSize.height+5,
                                                  radioDeselectedImage.size.width+20.0,
                                                  radioDeselectedImage.size.height+19.0)];

            
        }
        else 
        {
            [self.radioButton setFrame:CGRectMake(2.0,
                                                  attestationDesclabel.frame.origin.y+expectedAttestationDescLabelSize.height+5,
                                                  radioDeselectedImage.size.width+20.0,
                                                  radioDeselectedImage.size.height+19.0)];

        }

              [self.radioButton setImage:radioDeselectedImage forState:UIControlStateNormal];
       [self.radioButton setImage:radioDeselectedImage forState:UIControlStateHighlighted];
        [self.radioButton setBackgroundColor:[UIColor clearColor]];
        
        [self.radioButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.radioButton setUserInteractionEnabled:YES];
        [self.radioButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 8.0, -6, 0.0)];
        
        
        [self.radioButton addTarget:self action:@selector(selectRadioButton:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([sheetStatus isEqualToString:G2WAITING_FOR_APRROVAL_STATUS] || [sheetStatus isEqualToString:APPROVED_STATUS])
        {
            if (disclaimerAcceptedDate!=nil && ![disclaimerAcceptedDate isKindOfClass:[NSNull class]]) 
            {
                 self.radioButton.enabled=FALSE;
            }
            else 
            {
                  self.radioButton.enabled=FALSE;
            }

          
        }
        else 
        {
             self.radioButton.enabled=TRUE;
        }
        
        
        
        // Let's make an NSAttributedString first
        attributedString = [[NSMutableAttributedString alloc] initWithString:appDelegate.disclaimerTitleTimesheets];
        //Add LineBreakMode
        paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];
        
        //Now let's make the Bounding Rect
        CGSize expectedDisclaimerTitleLabelSize = [attributedString boundingRectWithSize:CGSizeMake((300.0-(radioDeselectedImage.size.width+10.0)), 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        UILabel *tempDisclaimerTitleLabel=[[UILabel alloc] init];
        self.disclaimerTitleLabel=tempDisclaimerTitleLabel;
       
        self.disclaimerTitleLabel.text=appDelegate.disclaimerTitleTimesheets ;
        self.disclaimerTitleLabel.textColor=RepliconStandardBlackColor;
        [self.disclaimerTitleLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
        [self.disclaimerTitleLabel setBackgroundColor:[UIColor clearColor]];
        
        if (appDelegate.attestationDescTimesheets==nil || [appDelegate.attestationDescTimesheets isKindOfClass:[NSNull class] ]  || [[appDelegate.attestationDescTimesheets stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]  ] isEqualToString:@"" ] || [appDelegate.attestationDescTimesheets isEqualToString:@"<null>" ] ) 
        {
            self.disclaimerTitleLabel.frame=CGRectMake(radioDeselectedImage.size.width+20.0,
                                                       attestationTitlelabel.frame.origin.y+20.0+expectedAttestationTitleLabelSize.height,
                                                       (300.0-(radioDeselectedImage.size.width+10.0)),
                                                       expectedDisclaimerTitleLabelSize.height);

            
            
        }
        else 
        {
            self.disclaimerTitleLabel.frame=CGRectMake(radioDeselectedImage.size.width+20.0,
                                                       attestationDesclabel.frame.origin.y+20.0+expectedAttestationDescLabelSize.height,
                                                       (300.0-(radioDeselectedImage.size.width+10.0)),
                                                       expectedDisclaimerTitleLabelSize.height);
            
        }

        
                self.disclaimerTitleLabel.numberOfLines=100;
        
        
        
       
        
       
        
		submitButton =[UIButton buttonWithType:UIButtonTypeCustom];
		UIImage *normalImg = [G2Util thumbnailImage:submitButtonImage];
		UIImage *highlightedImg = [G2Util thumbnailImage:submitButtonImageSelected];
		
		
		[submitButton setBackgroundImage:normalImg forState:UIControlStateNormal];
		[submitButton setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
		
        
        if(!appDelegate.isAcceptanceOfDisclaimerRequired)
        {
            self.radioButton.frame=CGRectZero;
            self.disclaimerTitleLabel.frame=CGRectZero;
            
            if (appDelegate.attestationDescTimesheets==nil || [appDelegate.attestationDescTimesheets isKindOfClass:[NSNull class] ]  || [[appDelegate.attestationDescTimesheets stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]  ] isEqualToString:@"" ] || [appDelegate.attestationDescTimesheets isEqualToString:@"<null>" ] ) 
            {
                [submitButton setFrame:CGRectMake(40.0, attestationTitlelabel.frame.origin.y+attestationTitlelabel.frame.size.height+25.0, normalImg.size.width, normalImg.size.height)];
                
                
            }
            else 
            {
                [submitButton setFrame:CGRectMake(40.0, attestationDesclabel.frame.origin.y+attestationDesclabel.frame.size.height+25.0, normalImg.size.width, normalImg.size.height)];
                
            }

            
            
        }
        else
        {
            [submitButton setFrame:CGRectMake(40.0, disclaimerTitleLabel.frame.origin.y+disclaimerTitleLabel.frame.size.height+25.0, normalImg.size.width, normalImg.size.height)];
        }
		
        //US4505
        if ([sheetStatus isEqualToString:G2WAITING_FOR_APRROVAL_STATUS]  || [sheetStatus isEqualToString:APPROVED_STATUS])
        {
            if (disclaimerAcceptedDate==nil || [disclaimerAcceptedDate isKindOfClass:[NSNull class]]) 
            {
                self.radioButton.frame=CGRectZero;
                self.disclaimerTitleLabel.frame=CGRectZero;
                self.radioButton.hidden=TRUE;
                self.disclaimerTitleLabel.hidden=TRUE;
                
                if (appDelegate.attestationDescTimesheets==nil || [appDelegate.attestationDescTimesheets isKindOfClass:[NSNull class] ]  || [[appDelegate.attestationDescTimesheets stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]  ] isEqualToString:@"" ] || [appDelegate.attestationDescTimesheets isEqualToString:@"<null>" ] ) 
                {
                    [submitButton setFrame:CGRectMake(40.0, attestationTitlelabel.frame.origin.y+attestationTitlelabel.frame.size.height+25.0, normalImg.size.width, normalImg.size.height)];
                    
                    
                }
                else 
                {
                    [submitButton setFrame:CGRectMake(40.0, attestationDesclabel.frame.origin.y+attestationDesclabel.frame.size.height+25.0, normalImg.size.width, normalImg.size.height)];
                    
                }
                
                
            }
            
        }
        /////
        submitButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
		[submitButton addTarget:self action:@selector(handleButtonClicks:) forControlEvents:UIControlEventTouchUpInside];
		[submitButton setTag:SUBMIT_BUTTON_TAG];
		
		UIView *temptotallabelView=[[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 30.00)];
		self.totallabelView=temptotallabelView;
       
        
        
//        if ([sheetStatus isEqualToString:APPROVED_STATUS])
//        {
//            
//            submitButton.frame=CGRectZero;
//        }
        
        
		UIView *tempfooterButtonsView=[[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                               totallabelView.frame.origin.y + totallabelView.frame.size.height,
                                                                               self.frame.size.width,attestationTitlelabel.frame.origin.y+attestationTitlelabel.frame.size.height+attestationDesclabel.frame.origin.y+attestationDesclabel.frame.size.height+self.disclaimerTitleLabel.frame.origin.y+self.disclaimerTitleLabel.frame.size.height+submitButton.frame.origin.y+submitButton.frame.size.height)];
		self.footerButtonsView=tempfooterButtonsView;
      
        
        
        [self.footerButtonsView addSubview:attestationTitlelabel];
        
        if (appDelegate.attestationDescTimesheets!=nil && ![appDelegate.attestationDescTimesheets isKindOfClass:[NSNull class] ]  && ![[appDelegate.attestationDescTimesheets stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]  ] isEqualToString:@"" ] && ![appDelegate.attestationDescTimesheets isEqualToString:@"<null>" ] ) 
        {
            [self.footerButtonsView addSubview:attestationDesclabel];
        }
        
        
        if(appDelegate.isAcceptanceOfDisclaimerRequired)
        {
            [self.footerButtonsView addSubview:self.disclaimerTitleLabel];
            [self.footerButtonsView addSubview:self.radioButton];

        }
               
        
        
               
        
		
		G2SubmittedDetailsView *tempsubmittedDetailsView = [[G2SubmittedDetailsView alloc]initWithFrame:CGRectMake(0,
                                                                                                               footerButtonsView.frame.origin.y+footerButtonsView.frame.size.height
                                                                                                               ,320,250)];
		self.submittedDetailsView=tempsubmittedDetailsView;
        
        
        
        
        
		
        /*unsubmitButton =[[UIButton alloc]initWithFrame:CGRectMake(60,
         80,
         200, 30)];
         [unsubmitButton retain];*/
    }
    return self;
}


-(void)selectRadioButton:(id)sender {
	
    UIImage *currentRadioButtonImage= [sender imageForState:UIControlStateNormal];
//      RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (currentRadioButtonImage == [G2Util thumbnailImage:G2CheckBoxSelectedImage]) {
        UIImage *deselectedRadioImage = [G2Util thumbnailImage:G2CheckBoxDeselectedImage];
        if (sender != nil) {
            [sender setImage:deselectedRadioImage forState:UIControlStateNormal];
            [sender setImage:deselectedRadioImage forState:UIControlStateHighlighted];
            [self setDisclaimerSelected:NO];
            if (eventHandler != nil && [eventHandler conformsToProtocol:@protocol(EntriesFooterButtonsProtocol)]) 
            {
                [eventHandler updatedDisclaimerActionWithSelection:NO];
            }
        }
    }
    else
    {
        UIImage *selectedRadioImage = [G2Util thumbnailImage:G2CheckBoxSelectedImage];
        if (sender != nil) {
            [sender setImage:selectedRadioImage forState:UIControlStateNormal];
            [sender setImage:selectedRadioImage forState:UIControlStateHighlighted];

            [self setDisclaimerSelected:YES];
            if (eventHandler != nil && [eventHandler conformsToProtocol:@protocol(EntriesFooterButtonsProtocol)]) 
            {
                [eventHandler updatedDisclaimerActionWithSelection:YES];
            }
        }
    }
    
    
}

-(void)setViewFrameSize
{

    
    float extraHeight=submitButton.frame.origin.y+submitButton.frame.size.height+30.0;
    CGRect frame=self.frame;
    float currentHeight=frame.size.height;
    if (currentHeight>extraHeight) {
        currentHeight=extraHeight;
        frame.size.height=currentHeight+30.0;
        ///The button shouldn't be radio button
        if (frame.size.height!=365.0)
        {
            self.frame=frame;
            
        }      
    }
    if ([eventHandler isKindOfClass:[G2ListOfTimeEntriesViewController class]])
    {
        G2ListOfTimeEntriesViewController *listOfEntriesCtrl=eventHandler;
         [listOfEntriesCtrl.timeEntriesTableView setTableFooterView:self];
    }     
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

-(void)addTotalLabelView : (NSString *)totalValue
{
	//if (totallabelView == nil) {
		 UIView *temptotallabelView=[[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 30.00)];
	//}
	
	[temptotallabelView setBackgroundColor:[UIColor whiteColor]];
//	[self addTotalValueLable: totalValue];
     self.totallabelView=temptotallabelView;
	[self addSubview:self.totallabelView];
   [self addTotalValueLable: totalValue];//Juhi
    
    //US4065//Juhi
    UIImage *totalLineImage=[G2Util thumbnailImage:G2Cell_HairLine_Image];
    UIImageView *totalLineImageview=[[UIImageView alloc]initWithImage:totalLineImage];
    totalLineImageview.frame=CGRectMake(0.0,
                                        29,
                                        totalLineImage.size.width,
                                        totalLineImage.size.height);
    
    
    [totalLineImageview setBackgroundColor:[UIColor clearColor]];
    [totalLineImageview setUserInteractionEnabled:NO];
    [totallabelView addSubview:totalLineImageview];
   

	
	
}
-(void)addTotalValueLable: (NSString *)totalLabelValue {
	
	UILabel *totalLabel=[[UILabel alloc]initWithFrame:G2EntriesTotalLabelFrame];
	[totalLabel setText:RPLocalizedString(G2TotalString,@"")];
	//[totalLabel setTextColor:RepliconStandardTotalColor];RepliconTimeEntryHeaderTextColor
	[totalLabel setTextColor:RepliconTimeEntryHeaderTextColor];

	//[totalLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_13]];
	[totalLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_18]];
	[totallabelView addSubview:totalLabel];
	
	UILabel *totalValueLabel=[[UILabel alloc]initWithFrame: G2EntriesTotalHoursLabelFrame];
	[totalValueLabel setText:totalLabelValue];
	//[totalValueLabel setTextColor: RepliconStandardTotalColor];
	[totalValueLabel setTextColor: RepliconTimeEntryHeaderTextColor];
	[totalValueLabel setTextAlignment: NSTextAlignmentRight];
	//[totalValueLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_14]];
	[totalValueLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_18]];
	[totallabelView addSubview:totalValueLabel];
	

}


-(void)addSubmitButton : (NSString *)buttonTitle 
{
	// add submit button to footerbuttonview
	[submitButton setTitle:RPLocalizedString(buttonTitle,@"") forState:UIControlStateNormal];
	[footerButtonsView addSubview:submitButton];

	
}
-(void)addFooterButtonView
{
	if (footerButtonsView==nil) {
	UIView *tempfooterButtonsView=[[UIView alloc] initWithFrame:CGRectMake(0.0,
															totallabelView.frame.origin.y + totallabelView.frame.size.height,
															self.frame.size.width,100.00)];
        self.footerButtonsView=tempfooterButtonsView;
        
	}
	[self.footerButtonsView setBackgroundColor:G2RepliconStandardBackgroundColor];
	[self addSubview:self.footerButtonsView];
}

-(void)addSubmittedDetailsView
{
	if (submittedDetailsView == nil) {
		//submittedDetailsView = [[SubmittedDetailsView alloc]initWithFrame:CGRectMake(0,
		//													footerButtonsView.frame.origin.y+footerButtonsView.frame.size.height
		//													,320,250)];
		G2SubmittedDetailsView *tempsubmittedDetailsView = [[G2SubmittedDetailsView alloc]initWithFrame:CGRectMake(0,
														0
														,320,250)];
        self.submittedDetailsView = tempsubmittedDetailsView;
        
	}
	[ self.submittedDetailsView setBackgroundColor:G2RepliconStandardBackgroundColor];
	//[self addSubview:submittedDetailsView];
}

/*-(void)addUnsubmitButton{
	
	if (unsubmitButton == nil) {
		unsubmitButton =[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		
	}
	UIImage *normalImg = [Util thumbnailImage:submitButtonImage];
	UIImage *highlightedImg = [Util thumbnailImage:submitButtonImageSelected];
	[unsubmitButton setBackgroundImage:normalImg forState:UIControlStateNormal];
	[unsubmitButton setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
    [unsubmitButton setFrame:CGRectMake(40.0, 60, normalImg.size.width, normalImg.size.height)];//US4065//Juhi
//	[unsubmitButton setFrame:CGRectMake(40.0, 40, normalImg.size.width, normalImg.size.height)];
    unsubmitButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
	[unsubmitButton setTitle:RPLocalizedString(UNSUBMIT,UNSUBMIT) forState:UIControlStateNormal];
	[unsubmitButton setTag:UNSUBMIT_BUTTON_TAG];
	
	[unsubmitButton addTarget:self action:@selector(handleButtonClicks:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:unsubmitButton];
}*/

//US4660//Juhi
-(void)populateFooterView: (NSString *)sheetStatus :(BOOL)unsubmitted  :(BOOL)reopenAllow :(BOOL)isRemainingApproval {
 
	
	if ([sheetStatus isEqualToString:G2WAITING_FOR_APRROVAL_STATUS]) {
		
		//[self addSubmitButton:@"Submit Timesheet"];
		//[self addSubmittedDetailsView];
		
		//self.frame = CGRectMake(0.0,0.0,
//								self.frame.size.width,
//								self.frame.size.height+200);
		[self addFooterButtonView];
 		if (unsubmitAllowed) {
			//[self addUnsubmitButton];
            [self addSubmitButton:UNSUBMIT];
            [submitButton setTag:UNSUBMIT_BUTTON_TAG];
		}
        //US4660//Juhi
		else if(reopenAllow && isRemainingApproval)
        {
            [self addSubmitButton:REOPEN];
            [submitButton setTag:REOPEN_BUTTON_TAG_G2];
            
        }
		
	}else if ([sheetStatus isEqualToString:NOT_SUBMITTED_STATUS]){
		[self addFooterButtonView];
		if (unsubmitted) {
			//[self addSubmitButton:@"Resubmit Timesheet"];
			[self addSubmitButton:RESUBMIT];
            [submitButton setTag:SUBMIT_BUTTON_TAG];
		}
		else {
			//[self addSubmitButton:@"Submit Timesheet"];//SUBMIT
			[self addSubmitButton:SUBMIT];
             [submitButton setTag:SUBMIT_BUTTON_TAG];
		}
		//[self addSubmittedDetailsView];
	}
	//[footerButtonsView setBackgroundColor:G2RepliconStandardBackgroundColor];
	
	
	if ([sheetStatus isEqualToString:APPROVED_STATUS]) {
		
		//[self addSubmittedDetailsView];
		[self addFooterButtonView];
        //US4660//Juhi
        if (reopenAllow) {
            [self addSubmitButton:REOPEN];
            [submitButton setTag:REOPEN_BUTTON_TAG_G2];
        }
        else
            submitButton.frame=CGRectZero;
       
 	}
	[self setBackgroundColor:[UIColor clearColor]];
	
	if ([sheetStatus isEqualToString:REJECTED_STATUS]) {
		[self addFooterButtonView];
		//[self addSubmitButton:@"Resubmit Timesheet"];
		[self addSubmitButton:RESUBMIT];
         [submitButton setTag:SUBMIT_BUTTON_TAG];
		//[self addSubmittedDetailsView];
	}
}

-(void)populateFooterViewWithApprovalHistory: (id)approvalDetails {
	
	if (approvalDetails != nil && [approvalDetails isKindOfClass:[NSMutableArray class]]) {
		NSMutableArray *approvalDetailArray = (NSMutableArray *)approvalDetails;
		NSDictionary *statusDict  = [approvalDetailArray objectAtIndex:0];
		NSString *sheetStatus = nil;
		if (statusDict != nil) {
			sheetStatus = [statusDict objectForKey:@"status"];
		}		
		if (sheetStatus!=nil && [sheetStatus isEqualToString:@"Open"]) {
			sheetStatus = NOT_SUBMITTED_STATUS;
		}else if (sheetStatus!=nil && [sheetStatus isEqualToString:@"Waiting"]) {
			sheetStatus = G2WAITING_FOR_APRROVAL_STATUS;
		}else if (sheetStatus!=nil && 
				  ([sheetStatus isEqualToString:@"Rejected"] || [sheetStatus isEqualToString:@"SystemRejected"])) {
			sheetStatus = REJECTED_STATUS;
		}else if (sheetStatus!=nil && 
				  ([sheetStatus isEqualToString:@"Approved"] || [sheetStatus isEqualToString:@"SystemApproved"])) {
			sheetStatus = APPROVED_STATUS;
		}else{
			sheetStatus=NOT_SUBMITTED_STATUS;
		}
		[submittedDetailsView.statusDescLabel setText:sheetStatus];
		
		NSDictionary *approverNameDict = [approvalDetailArray objectAtIndex:1];
		NSMutableString *approverName=[NSMutableString stringWithString:[approverNameDict objectForKey:@"firstName"]];
		for (int i=2; i<[approvalDetailArray count]; i++) {
			NSString *approverFirstName = [[approvalDetailArray objectAtIndex:i]objectForKey:@"firstName"];
            if (![approverName isKindOfClass:[NSNull class] ]) 
            {
                if ([approverName isEqualToString:approverFirstName]) {
                    [approverName replaceOccurrencesOfString:approverName withString:approverFirstName
                                                     options:0 range:NSMakeRange(0, [approverName length])];
                }else {
                    [approverName appendString:[NSString stringWithFormat:@",%@",approverFirstName]];
                }
            }
			
		}
		
		[submittedDetailsView.approversDescLabel setText:approverName];
		if ([sheetStatus isEqualToString:NOT_SUBMITTED_STATUS]) {
			[submittedDetailsView.historyDescLabel setText:@""];
			[submittedDetailsView.submittedDescLabel setHidden:YES];
			[submittedDetailsView.submittedLabel setHidden:YES];
	
		}else if ([sheetStatus isEqualToString:APPROVED_STATUS] || 
			  [sheetStatus isEqualToString:G2WAITING_FOR_APRROVAL_STATUS] ||
			  [sheetStatus isEqualToString:REJECTED_STATUS]) 
		{
		
			for (NSUInteger i=[approvalDetailArray count]-1; i>=1; i--) {
				NSDictionary *detailDictionary = [approvalDetailArray objectAtIndex:i];
				NSString *firstName = [detailDictionary objectForKey:@"firstName"];
				NSString *approverAction = [detailDictionary objectForKey:@"approverAction"];
				NSString *effectiveDate = [detailDictionary objectForKey:@"effectiveDate"];
				[submittedDetailsView addHistoryDescriptionLableWithMultiPleValues:105+(([approvalDetailArray count]-1)-i)*60];					
				[submittedDetailsView.approverNameLabel setText:firstName];
				[submittedDetailsView.approverActionLabel setText:approverAction];
				[submittedDetailsView.approverdTimeLabel  setText:effectiveDate];
				[submittedDetailsView.historyDescLabel setText:[NSString stringWithFormat:@"%@\n%@\n%@\n%@\n",firstName,
									approverAction,effectiveDate,submittedDetailsView.underlineLabelHistory.text]];
				if ([approverAction isEqualToString:APPROVED_STATUS]) {
					UIImage *_img=[G2Util thumbnailImage:G2Check_ON_Image];
					UIImageView	*checkMarkImage=[[UIImageView alloc]initWithFrame:CGRectMake(90, 0, _img.size.width,_img.size.height)];
					UIView *approvedView=[[UIView alloc] initWithFrame:
									  CGRectMake(submittedDetailsView.approverActionLabel.frame.origin.x,
												submittedDetailsView.approverActionLabel.frame.origin.x,
												submittedDetailsView.approverActionLabel.frame.size.width,
												submittedDetailsView.approverActionLabel.frame.size.height)];
					//[approvedView addSubview:submittedDetailsView.approverActionLabel];
					[approvedView addSubview:checkMarkImage];
					[submittedDetailsView.approverActionLabel addSubview:approvedView];
					//Handling Leaks
					
				
				}
			}
		
			if ([ sheetStatus isEqualToString:APPROVED_STATUS] || [sheetStatus isEqualToString:REJECTED_STATUS])
			{
				[submittedDetailsView addCommentsInHistory];
				[submittedDetailsView.commentsTextView setFrame:
													CGRectMake(110,[approvalDetailArray count]*60+105,200,20)];
				[submittedDetailsView addSubview:submittedDetailsView.commentsTextView];
				NSMutableString *commentString = [NSMutableString stringWithString:@"Comments:"];
				for (NSUInteger i=[approvalDetailArray count]-1; i>=1; i--) {
					NSString *comments = [[approvalDetailArray objectAtIndex:i]objectForKey:@"comments"];
					if (![comments isKindOfClass:[NSNull class] ]) 
                    {
                        if (comments != nil && [comments length] > 0) {
                            [commentString appendString:[NSString stringWithFormat:@"\n%@",comments]];
                        }
                    }
					
				}
				[submittedDetailsView.commentsTextView setText:commentString];
			}
		//	[submittedDetailsView.submittedLabel setFrame:
		//			CGRectMake(110,105+[approvalDetailArray count]*60+submittedDetailsView.commentsTextView.contentSize.height+20,80,20)];
		//	[submittedDetailsView.submittedDescLabel setFrame:
		//	 CGRectMake(110,105+[approvalDetailArray count]*60+submittedDetailsView.commentsTextView.contentSize.height+40,200,20)];
		
			[submittedDetailsView setFrame:
			 CGRectMake(0,totallabelView.frame.size.height,
						320,
						submittedDetailsView.commentsTextView.contentSize.height
						+[approvalDetailArray count]*60+350)];
			
			if ([ sheetStatus isEqualToString:G2WAITING_FOR_APRROVAL_STATUS]) {
				if (unsubmitAllowed) {
				
					for (NSUInteger i=[approvalDetailArray count]-1; i>=1; i--) {
						if ([[[approvalDetailArray objectAtIndex:i]objectForKey:@"approverAction"] isEqualToString:APPROVED_STATUS]) {
						//[self.unsubmitButton setHidden:YES];
						}else {
						//[self.unsubmitButton setHidden:NO];
						}
					}
					[unsubmitButton setFrame:CGRectMake(40,[approvalDetailArray count]*60+130, 220, 30)];
					//[submittedDetailsView.underlineLabel setFrame:CGRectMake(50,[unsubmittedApproveArray count]*60+210, 220, 2)];
					//[submittedDetailsView addSubview:submittedDetailsView.underlineLabel];
					//[submittedDetailsView addSubview:submittedDetailsView.unsubmitButton];
				}
			}
		
			if ([ sheetStatus isEqualToString:REJECTED_STATUS]) {
				[footerButtonsView setFrame:CGRectMake(0.0,
									totallabelView.frame.size.height,self.frame.size.width,
									100)];
				[submittedDetailsView setFrame:CGRectMake(0.0, 
												footerButtonsView.frame.origin.y + footerButtonsView.frame.size.height
												,submittedDetailsView.frame.size.width,
														  submittedDetailsView.frame.size.height)];
			}
		
		
			[self setFrame:CGRectMake(0,0,320,totallabelView.frame.size.height+submittedDetailsView.frame.size.height+200)];
			[self setBackgroundColor:[UIColor clearColor]];
		}
		
		BOOL unsubmitted = NO;
	
		if ([sheetStatus isEqualToString:NOT_SUBMITTED_STATUS]) {
			[[submittedDetailsView statusDescLabel] setTextColor:[UIColor blackColor]];
		
		
		} else if ([sheetStatus isEqualToString:G2WAITING_FOR_APRROVAL_STATUS]) {
			[[submittedDetailsView statusDescLabel] setTextColor:WaitingTextColor];
	
		}else if ([sheetStatus isEqualToString:REJECTED_STATUS]) {
			[[submittedDetailsView statusDescLabel] setTextColor:RejectedTextColor];
		
		}else if ([sheetStatus isEqualToString:APPROVED_STATUS]) {
			[[submittedDetailsView statusDescLabel] setTextColor:ApprovedTextColor];
		}
		[self populateFooterView:sheetStatus :unsubmitted :NO :NO];//US4660//Juhi
	}
	
}

#pragma mark Handle Button clicks

-(void) handleButtonClicks : (id) sender {
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
	if (eventHandler != nil && [eventHandler conformsToProtocol:@protocol(EntriesFooterButtonsProtocol)]) {
		if ([sender tag] == SUBMIT_BUTTON_TAG ) {
            
            if (appDelegate.isAcceptanceOfDisclaimerRequired && appDelegate.isAttestationPermissionTimesheets) 
            {
                if (disclaimerSelected) 
                {
                     [eventHandler handleSubmitAction];
                }
                else
                {
                    [G2Util errorAlert:[NSString stringWithFormat:@"%@ %@ %@",RPLocalizedString(ATTESTATION_SUBMIT_RESUMBIT_VALIDATION_MSG1,ATTESTATION_SUBMIT_RESUMBIT_VALIDATION_MSG1),appDelegate.attestationTitleTimesheets,RPLocalizedString(ATTESTATION_SUBMIT_RESUMBIT_VALIDATION_MSG2,ATTESTATION_SUBMIT_RESUMBIT_VALIDATION_MSG2)]   errorMessage:@""];
                }
            }
            else 
            {
                [eventHandler handleSubmitAction];
            }
            
			
		}else if ([sender tag] == UNSUBMIT_BUTTON_TAG) {
            if (appDelegate.isAcceptanceOfDisclaimerRequired && appDelegate.isAttestationPermissionTimesheets) 
            {
//                if (disclaimerSelected) 
//                {
                    [eventHandler handleUnsubmitAction];
//                }
//                else
//                {
//                    [Util errorAlert:[NSString stringWithFormat:@"%@ %@ %@",RPLocalizedString(ATTESTATION_SUBMIT_RESUMBIT_VALIDATION_MSG1,ATTESTATION_SUBMIT_RESUMBIT_VALIDATION_MSG1),appDelegate.attestationTitleTimesheets,RPLocalizedString(ATTESTATION_SUBMIT_RESUMBIT_VALIDATION_MSG2,ATTESTATION_SUBMIT_RESUMBIT_VALIDATION_MSG2)]   errorMessage:@""];
//                }
            }
            else 
            {
               [eventHandler handleUnsubmitAction];
            }

			
		}
        //US4660//Juhi
        else if([sender tag]==REOPEN_BUTTON_TAG_G2)
        {
            [eventHandler handleReopenAction];
            
        }
		else if ([sender tag] == DELETE_BUTTON_TAG) {
			[eventHandler handleDeleteAction];
		}
	}
}




@end
