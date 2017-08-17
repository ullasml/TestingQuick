//
//  SubmittedDetailsView.h
//  Replicon
//
//  Created by Praveen on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"G2ServiceUtil.h"
#import"G2Constants.h"
#import"G2RepliconServiceManager.h"
#import "FrameworkImport.h"
#import"G2ExpensesModel.h"
#import<QuartzCore/QuartzCore.h>


@interface G2SubmittedDetailsView : UIView<UITextViewDelegate> {

	UILabel *detailsHeaderLabel;
	UILabel *submittedLabel;
	UILabel *approversLabel;
	UILabel *statusLabel;
	UILabel *historyLabel;
	UILabel *underlineLabel;
	UILabel *underlineLabelHistory;
	
	UILabel *detailsHeaderDescLabel;
	UILabel *submittedDescLabel;
	UILabel *approversDescLabel;
	UILabel *statusDescLabel;
	UILabel *historyDescLabel;
	UILabel *dotLabel;
	UILabel *approverNameLabel;
	UILabel *approverActionLabel;
	UILabel *approverdTimeLabel;
	NSString *sheetId;
	NSString *sheetStatus;
	
	
	UIButton *unsubmitButton;
	
	id __weak submitViewDelegate;
	G2ExpensesModel *expensesModel;
	
	UITextView *commentsTextView;
}
@property(nonatomic,strong)G2ExpensesModel *expensesModel;
@property(nonatomic,strong)UILabel *underlineLabelHistory;
@property(nonatomic,strong)	UITextView *commentsTextView;
@property(nonatomic,weak) id submitViewDelegate;
@property(nonatomic,strong)NSString *sheetId;
@property(nonatomic,strong)NSString *sheetStatus;
@property(nonatomic,strong)UILabel *detailsHeaderDescLabel;
@property(nonatomic,strong)UILabel *submittedDescLabel;
@property(nonatomic,strong)UILabel *underlineLabel;
@property(nonatomic,strong)UIButton *unsubmitButton;
@property(nonatomic,strong)UILabel *approversDescLabel;
@property(nonatomic,strong)UILabel *statusDescLabel;
@property(nonatomic,strong)UILabel *historyDescLabel;
@property(nonatomic,strong)UILabel *dotLabel;
@property(nonatomic,strong)UILabel *submittedLabel;
@property(nonatomic,strong)UILabel *approverNameLabel;
@property(nonatomic,strong)UILabel *approverActionLabel;
@property(nonatomic,strong)UILabel *approverdTimeLabel;
//-(void)unSubmitAction;
-(void)addUnsubmitLink;
-(void)addHistoryDescriptionLableWithMultiPleValues:(float)yPos;
-(void)addCommentsInHistory;
-(void)unSubmitAction:(id)sender;
@end
