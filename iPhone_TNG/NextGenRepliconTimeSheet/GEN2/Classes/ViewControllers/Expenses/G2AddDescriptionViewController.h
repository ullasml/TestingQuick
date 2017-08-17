//
//  AddDescriptionViewController.h
//  Replicon
//
//  Created by Devi Malladi on 3/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import<QuartzCore/QuartzCore.h>
#import "G2Constants.h"

@interface G2AddDescriptionViewController : UIViewController<UITextViewDelegate> {

	UITextView *descTextView;
	
	NSString *descTextString;
	UILabel *textCountLable;
	UIButton *clearButton;
	id __weak descControlDelegate;
	BOOL fromEditing;
	
	NSString *navBarTitle;
	id __weak timeEntryParentController;
	BOOL fromTimeEntryComments,fromTimeEntryUDF, fromExpenseDescription;
	
}
- (void)saveAction:(id)sender;
- (void)cancelAction:(id)sender;
- (void)clearAction;
- (void)setDescriptionText:(NSString *)description;
- (void) setViewTitle: (NSString *)title;
-(void)changeButtonFramesDynamically;
-(void)resetClearButtonColor; 

//Properties
@property(nonatomic,weak)	id descControlDelegate;
@property(nonatomic,strong)	UIButton *clearButton;
@property(nonatomic,strong)	UILabel *textCountLable;
@property(nonatomic,strong)	UITextView *descTextView;
@property(nonatomic,strong)	NSString *descTextString;
@property(nonatomic,assign)BOOL fromEditing;
@property(nonatomic,strong) NSString *navBarTitle;
@property(nonatomic,weak) id timeEntryParentController;
@property(nonatomic,assign) BOOL fromTimeEntryComments,fromTimeEntryUDF,fromExpenseDescription;
@end
