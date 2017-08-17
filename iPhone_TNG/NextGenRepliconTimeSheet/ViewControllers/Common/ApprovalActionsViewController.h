//
//  ApprovalActionsViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 3/28/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimeOffResubmitProtocol <NSObject>
-(void)resubmitComments:(NSString *)comments;

@end

@interface ApprovalActionsViewController : UIViewController<UITextViewDelegate>
{
    //Labels
	UILabel					*reasonLabel;
	
	//Buttons
	UIButton				*resubmitButton;
	UIBarButtonItem			*cancelButton;
	
	//Views
	UITextView				*submitTextView;
	
	//General
	NSString				*sheetIdentity;
	NSString				*selectedSheet;
    NSString                *actionType;
    id __weak                      delegate;
    BOOL                    isReopenClicked;
    BOOL					allowBlankComments;
    BOOL					isMultiDayInOutTimesheetUser;
    NSMutableArray          *timesheetLevelUdfArray;
    NSMutableArray          *arrayOfEntriesForSave;
    BOOL                    isDisclaimerRequired;
    BOOL                    isExtendedInoutUser;

    
}
@property(nonatomic, strong) UITextView				*submitTextView;
@property(nonatomic, strong) UIButton				*resubmitButton;
@property(nonatomic, strong) UILabel				*reasonLabel;
@property(nonatomic, strong) UIBarButtonItem		*cancelButton;
@property(nonatomic, strong) NSString				*sheetIdentity;
@property(nonatomic, strong) NSString				*selectedSheet;
@property(nonatomic, strong) NSString               *actionType;
@property(nonatomic, strong) NSMutableArray          *timesheetLevelUdfArray;
@property(nonatomic, weak) id  <TimeOffResubmitProtocol>    delegate;
@property(nonatomic, assign) BOOL                   isReopenClicked;
@property(nonatomic, assign) BOOL					allowBlankComments;
@property(nonatomic, assign) BOOL					isMultiDayInOutTimesheetUser;
@property(nonatomic, strong) NSMutableArray          *arrayOfEntriesForSave;
@property(nonatomic, assign) BOOL                    isDisclaimerRequired;
@property(nonatomic, assign) BOOL                    isExtendedInoutUser;
@property(nonatomic, assign) BOOL hasAttestationWidgetPermission;
@property(nonatomic, assign) BOOL isAttestationSelected;

-(void)cancelButtonAction;
-(void)popToListOfExpenseSheets;
-(void)popToListOfTimeSheets;

-(void)setUpWithSheetUri:(NSString *)sheetUri selectedSheet:(NSString *)sheet allowBlankComments:(BOOL)commentsAllow actionType:(NSString *)action delegate:(id)parentDelegate;
@end
