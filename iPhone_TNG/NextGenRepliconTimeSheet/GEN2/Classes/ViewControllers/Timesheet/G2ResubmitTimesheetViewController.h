//
//  ResubmitTimesheetViewController.h
//  ResubmitTimesheet
//
//  Created by Sridhar on 29/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2Constants.h"
#import "G2TimesheetService.h"
#import "G2RepliconServiceManager.h"
#import "FrameworkImport.h"
#import "G2NavigationTitleView.h"


@interface G2ResubmitTimesheetViewController : UIViewController<UITextViewDelegate> {
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
	
	G2NavigationTitleView		*navigationTitleView;
	
	BOOL					allowBlankComments;
    
    //US2669//Juhi
    NSString              *actionType;
    id __weak                      delegate;
    
    //US4754
    BOOL                    isSaveEntry;
    BOOL                    isReopenClicked;//US4805

}
@property(nonatomic, strong) UITextView				*submitTextView;
@property(nonatomic, strong) UIButton				*resubmitButton;
@property(nonatomic, strong) UILabel				*reasonLabel;
@property(nonatomic, strong) UIBarButtonItem		*cancelButton;
@property(nonatomic, strong) NSString				*sheetIdentity;
@property(nonatomic, strong) NSString				*selectedSheet;
@property(nonatomic, assign) BOOL					allowBlankComments;
//US2669//Juhi
@property(nonatomic, strong) NSString               *actionType;
@property(nonatomic, weak) id                     delegate;
//US4754
@property(nonatomic, assign) BOOL					isSaveEntry;
//US4805
@property(nonatomic,assign)  BOOL                   isReopenClicked;
 
-(void)resubmitButtonAction;
-(void)cancelButtonAction;
-(void)popToListOfTimeSheets;
-(void) confirmAlert :(NSString *)_buttonTitle confirmMessage:(NSString*) message;//US4275//Juhi
@end

