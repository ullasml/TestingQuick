//
//  SubmittedDetailsView.m
//  Replicon
//
//  Created by Praveen on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2SubmittedDetailsView.h"


@implementation G2SubmittedDetailsView
@synthesize sheetId,sheetStatus,detailsHeaderDescLabel,submittedLabel,underlineLabel,approverNameLabel,commentsTextView,underlineLabelHistory,
approverActionLabel,
approverdTimeLabel,
unsubmitButton,
submittedDescLabel,
//trackingDescLabel,
approversDescLabel,
statusDescLabel,
historyDescLabel,
dotLabel,
submitViewDelegate;
@synthesize expensesModel;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		

		[self setBackgroundColor:[UIColor whiteColor]];
		
		[NetworkMonitor sharedInstance];
		if (expensesModel == nil) {
			G2ExpensesModel *tempexpensesModel = [[G2ExpensesModel alloc] init];
            self.expensesModel=tempexpensesModel;
            
		}
		
		
		
		detailsHeaderLabel = [[UILabel alloc]init];
		detailsHeaderLabel.frame = CGRectMake(3,5,80,40);
		[detailsHeaderLabel setBackgroundColor:[UIColor clearColor]];//Added:for time sheet
		
		[detailsHeaderLabel setText:RPLocalizedString(@"DETAILS",@"")];
		detailsHeaderLabel.textAlignment =  NSTextAlignmentRight;
		[detailsHeaderLabel setFont:[UIFont boldSystemFontOfSize:16]];
		[self addSubview:detailsHeaderLabel];
		
		
		
		statusLabel= [[UILabel alloc]init];
		statusLabel.frame = CGRectMake(3,45,80,20);//105
		statusLabel.textAlignment =  NSTextAlignmentRight;
		[statusLabel setText:RPLocalizedString(@"Status",@"")];
		[statusLabel setFont:[UIFont boldSystemFontOfSize:14]];
		
		[statusLabel setBackgroundColor:[UIColor clearColor]];//Added:for time sheet
		
		[self addSubview:statusLabel];
		
		statusDescLabel= [[UILabel alloc]initWithFrame:CGRectMake(110,45,200,20)];//105
		statusDescLabel.textAlignment =  NSTextAlignmentLeft;
		[statusDescLabel setFont:[UIFont fontWithName:RepliconFontFamily size:15.0]];
		[statusDescLabel setBackgroundColor:[UIColor clearColor]];//Added:for time sheet
		
		[self addSubview:statusDescLabel];
		
		
		approversLabel= [[UILabel alloc]init];
		approversLabel.frame = CGRectMake(3,75,80,20);
		approversLabel.textAlignment =  NSTextAlignmentRight;
		[approversLabel setText:RPLocalizedString(@"Approvers",@"")];
		[approversLabel setFont:[UIFont boldSystemFontOfSize:14]];
		[approversLabel setBackgroundColor:[UIColor clearColor]];//Added:for time sheet
		
		[self addSubview:approversLabel];
		
		approversDescLabel= [[UILabel alloc]initWithFrame:CGRectMake(110,75,200,20)];
		approversDescLabel.textAlignment =  NSTextAlignmentLeft;
		[approversDescLabel setFont:[UIFont fontWithName:RepliconFontFamily size:15.0]];
		[approversDescLabel setBackgroundColor:[UIColor clearColor]];//Added:for time sheet
		
		[self addSubview:approversDescLabel];
		
		
		historyLabel= [[UILabel alloc]init];
		historyLabel.frame = CGRectMake(3,105,80,20);
		historyLabel.textAlignment =  NSTextAlignmentRight;
		[historyLabel setText:RPLocalizedString(@"History",@"")];
		[historyLabel setFont:[UIFont boldSystemFontOfSize:14]];
		[historyLabel setBackgroundColor:[UIColor clearColor]];//Added:for time sheet
		
		[self addSubview:historyLabel];
		
		historyDescLabel= [[UILabel alloc]initWithFrame:CGRectMake(110,105,200,20)];
		historyDescLabel.textAlignment =  NSTextAlignmentLeft;
		[historyDescLabel setFont:[UIFont fontWithName:RepliconFontFamily size:15.0]];
		[historyDescLabel setBackgroundColor:[UIColor clearColor]];//Added:for time sheet
		
		[self addSubview:historyDescLabel];
		
		
		
		submittedLabel = [[UILabel alloc]init];
		submittedLabel.frame = CGRectMake(3,165,80,20);
		[submittedLabel setText:RPLocalizedString(@"Submitted",@"")];
		submittedLabel.textAlignment =  NSTextAlignmentRight;
		[submittedLabel setFont:[UIFont fontWithName:RepliconFontFamily size:15.0]];
		[submittedLabel setBackgroundColor:[UIColor clearColor]];//Added:for time sheet
		
		[self addSubview:submittedLabel];
		
		//--------------------
		
		
		submittedDescLabel = [[UILabel alloc]initWithFrame:CGRectMake(110,165,200,20)];
		submittedDescLabel.textAlignment =  NSTextAlignmentLeft;
		[submittedDescLabel setFont:[UIFont fontWithName:RepliconFontFamily size:15.0]];
		[submittedDescLabel setBackgroundColor:[UIColor clearColor]];//Added:for time sheet
		
		[self addSubview:submittedDescLabel];
		
			
		dotLabel= [[UILabel alloc]initWithFrame:CGRectMake(110,145,200,20)];
		dotLabel.textAlignment =  NSTextAlignmentLeft;
		[dotLabel setText:@".........................................................."];
		[dotLabel setFont:[UIFont fontWithName:RepliconFontFamily size:15.0]];
		[dotLabel setBackgroundColor:[UIColor clearColor]];//Added:for time sheet
		
		[self addSubview:dotLabel];
		//--------------------
	//	UIButton *unsubmitButton;
//		unsubmitButton =[[UIButton alloc]initWithFrame:CGRectMake(50,300, 200, 30)];
//		[unsubmitButton addTarget:self action:@selector(unSubmitAction) forControlEvents:UIControlEventTouchUpInside];
//		[unsubmitButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal]; 
//		//[unsubmitButton setBackgroundColor:[UIColor redColor]];
//		[unsubmitButton setEnabled:YES];
//		[unsubmitButton setTitle:@"Unsubmit ThisExpense Sheet" forState:UIControlStateNormal];
//		unsubmitButton.titleLabel.font =[UIFont systemFontOfSize:15];
		
		
		/*UILabel *deleteUnderlineLabel = [[UILabel alloc]initWithFrame:CGRectMake(unsubmitButton.frame.origin.x,
																				 unsubmitButton.frame.origin.y-11,
																				 unsubmitButton.frame.size.width-50,2)];*/
	//	UILabel *deleteUnderlineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,22,unsubmitButton.frame.size.width,2)];

//		[deleteUnderlineLabel setText:@"_"];
//		[deleteUnderlineLabel setTextAlignment:NSTextAlignmentCenter];
//		[deleteUnderlineLabel setBackgroundColor:SignUpLabelTextColor];
//		[unsubmitButton addSubview:deleteUnderlineLabel];
//
//		//[self addSubview:deleteUnderlineLabel];
//		[self addSubview:unsubmitButton];

    }
    return self;
}

-(void)addHistoryDescriptionLableWithMultiPleValues:(float)yPos{
	historyDescLabel= [[UILabel alloc]initWithFrame:CGRectMake(110,yPos,200,60)];
	historyDescLabel.textAlignment =  NSTextAlignmentLeft;
	[historyDescLabel setNumberOfLines:3];
	[historyDescLabel setFont:[UIFont fontWithName:RepliconFontFamily size:15.0]];
	
	approverNameLabel= [[UILabel alloc]initWithFrame:CGRectMake(110,yPos,200,20)];
	approverNameLabel.textAlignment =  NSTextAlignmentLeft;
	[approverNameLabel setNumberOfLines:1];
	[approverNameLabel setFont:[UIFont fontWithName:RepliconFontFamily size:15.0]];
	[historyDescLabel addSubview:approverNameLabel];
	approverActionLabel= [[UILabel alloc]initWithFrame:CGRectMake(110,yPos+20,200,20)];
	approverActionLabel.textAlignment =  NSTextAlignmentLeft;
	[approverActionLabel setNumberOfLines:1];
	[approverActionLabel setFont:[UIFont fontWithName:RepliconFontFamily size:15.0]];
	[historyDescLabel addSubview:approverActionLabel];
	approverdTimeLabel= [[UILabel alloc]initWithFrame:CGRectMake(110,yPos+40,200,20)];
	approverdTimeLabel.textAlignment =  NSTextAlignmentLeft;
	[approverdTimeLabel setNumberOfLines:1];
	[approverdTimeLabel setFont:[UIFont fontWithName:RepliconFontFamily size:15.0]];
	[historyDescLabel addSubview:approverdTimeLabel];
	
	underlineLabelHistory = [[UILabel alloc]initWithFrame:CGRectMake(0,approverdTimeLabel.frame.size.height+38,approverdTimeLabel.frame.size.width,2)];
	[underlineLabelHistory setText:@"..."];
	[underlineLabelHistory setTextAlignment:NSTextAlignmentCenter];
	[underlineLabelHistory setBackgroundColor:SignUpLabelTextColor];
	[historyDescLabel addSubview:underlineLabelHistory];
//
	[historyDescLabel setBackgroundColor:[UIColor whiteColor]];
	
	[self addSubview:historyDescLabel];
}

-(void)addUnsubmitLink{

	DLog(@"Unsubmit This Expense Sheet");
	unsubmitButton =[[UIButton alloc]initWithFrame:CGRectMake(50,200, 200, 30)];
	[unsubmitButton addTarget:self action:@selector(unSubmitAction:) forControlEvents:UIControlEventTouchUpInside];
	[unsubmitButton setTitleColor:FreeTrailLabelTextColor forState:UIControlStateNormal]; 
	//[unsubmitButton setBackgroundColor:[UIColor redColor]];
	[unsubmitButton setEnabled:YES];
	[unsubmitButton setTitle:RPLocalizedString( @"Unsubmit This Expense Sheet",@"") forState:UIControlStateNormal];
	//unsubmitButton.titleLabel.font =[UIFont systemFontOfSize:15];
	unsubmitButton.titleLabel.font =[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_14];
	
	underlineLabel = [[UILabel alloc]initWithFrame:CGRectMake(50,22,unsubmitButton.frame.size.width,2)];
	[underlineLabel setText:@"_"];
	[underlineLabel setTextAlignment:NSTextAlignmentLeft];
	[underlineLabel setBackgroundColor:FreeTrailLabelTextColor];
	[unsubmitButton addSubview:underlineLabel];
	//[self addSubview:underlineLabel];
	[self addSubview:unsubmitButton];
	
	

}

-(void)unSubmitAction:(id)sender
{

	//[[NSNotificationCenter defaultCenter]postNotificationName:@"UnsubmitExpenseSheetNotification" object:nil];
	
	[submitViewDelegate performSelector:@selector(unSubmitAction:) withObject:sender];
}
-(void)addCommentsInHistory
{
	if (commentsTextView == nil) {
		commentsTextView = [[UITextView alloc] init];
	}
	commentsTextView.textColor = [UIColor blackColor];
	[commentsTextView setShowsVerticalScrollIndicator:NO];
	commentsTextView.font = [UIFont fontWithName:RepliconFontFamily size:15];
	[commentsTextView setUserInteractionEnabled:NO];
	commentsTextView.delegate = self;
	commentsTextView.backgroundColor = [UIColor clearColor];
	commentsTextView.returnKeyType = UIReturnKeyDefault;
	commentsTextView.keyboardType = UIKeyboardTypeDefault;
	commentsTextView.scrollEnabled = NO;
	commentsTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	commentsTextView.layer.borderColor = [[UIColor lightGrayColor]CGColor];
	commentsTextView.layer.borderWidth = 0.0;
	commentsTextView.layer.cornerRadius =0.0; 
}
/*- (void) serverDidRespondWithResponse:(id) response{
	if ([[[response objectForKey:@"response"]objectForKey:@"Status"]isEqualToString:@"OK"]) {
		if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == ApprovalsDetailsOnUnsubmit_30) {
			NSArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
			if (responseArray!=nil && [responseArray count]!=0) {
			[expensesModel insertApprovalsDetailsIntoDbForUnsubmittedSheet:response];
			}
			
			
		}else if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == ApprovalsDetailsForSubmittedSheet_31) {
			
		}
	}else {
				[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
				[Util confirmAlert:[[response objectForKey:@"response"]objectForKey:@"Status"] errorMessage:[[response objectForKey:@"response"]objectForKey:@"Message"]];
			}
}
- (void) serverDidFailWithError:(NSError *) error {
}*/

- (void)drawRect:(CGRect)rect {
    // Drawing code
}





@end
