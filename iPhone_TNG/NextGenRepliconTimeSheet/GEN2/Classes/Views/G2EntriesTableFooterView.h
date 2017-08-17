//
//  EntriesTableFooterView.h
//  Replicon
//
//  Created by vijaysai on 5/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2SubmittedDetailsView.h"
#import "G2Constants.h"
#import "G2Util.h"

@protocol EntriesFooterButtonsProtocol

@required

-(void) handleSubmitAction;
-(void) handleUnsubmitAction;
-(void) updatedDisclaimerActionWithSelection:(BOOL)selectionStatus;

@optional

-(void) handleDeleteAction;
//US4660//Juhi
-(void)handleReopenAction;

@end


@interface G2EntriesTableFooterView : UIView {

	G2SubmittedDetailsView *submittedDetailsView;
	
	UIButton *submitButton;
	UIButton *unsubmitButton;
	UIView   *footerButtonsView;
	UILabel  *underlineLabel;
	UIView   *totallabelView;
	id		 eventHandler;
	
	BOOL unsubmitAllowed;
    UIButton* radioButton;
    UILabel *disclaimerTitleLabel;
    BOOL disclaimerSelected;
    
    
}

@property(nonatomic, assign) BOOL disclaimerSelected;
@property(nonatomic,strong) UILabel *disclaimerTitleLabel;
@property(nonatomic,strong) UIButton* radioButton;
@property(nonatomic,strong) G2SubmittedDetailsView *submittedDetailsView;
@property(nonatomic,strong) UIView   *totallabelView,*footerButtonsView;
@property(nonatomic,strong) id eventHandler;
@property(nonatomic, assign) BOOL unsubmitAllowed;

-(void)addTotalLabelView :(NSString *)totalLabelValue;
-(void)addTotalValueLable : (NSString *)totalLabelValue;
-(void)addSubmitButton : (NSString *)buttonTitle;
-(void)addFooterButtonView;
-(void)addSubmittedDetailsView;
/*-(void)addUnsubmitButton;*/
-(void)populateFooterView: (NSString *)sheetStatus :(BOOL)unsubmitted  :(BOOL)reopenAllow :(BOOL)isRemainingApproval;//US4660//Juhi
-(void) populateFooterViewWithApprovalHistory: (id)approvalDetails;
-(void) handleButtonClicks : (id) sender;
-(void)selectRadioButton:(id)sender;
- (id)initWithFrame:(CGRect)frame forSheetStatus:(NSString *)sheetStatus andDisclaimerAcceptedDate:(NSDate *)disclaimerAcceptedDate;
-(void)setViewFrameSize;
@end
