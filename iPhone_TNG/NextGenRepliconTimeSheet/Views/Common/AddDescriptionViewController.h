
#import <UIKit/UIKit.h>
#import<QuartzCore/QuartzCore.h>
#import "Constants.h"

@interface AddDescriptionViewController : UIViewController<UITextViewDelegate> {

	UITextView *descTextView;
	
	NSString *descTextString;
	UILabel *textCountLable;
	UIButton *clearButton;
	id __weak descControlDelegate;
	BOOL fromEditing;
	NSString *navBarTitle;
	BOOL isNonEditable;
	BOOL fromExpenseDescription;
    BOOL fromTimeoffEntryComments;
    BOOL fromTextUdf;
	
}
- (void)saveAction:(id)sender;
- (void)cancelAction:(id)sender;
- (void)clearAction;
- (void)setDescriptionText:(NSString *)description;
- (void) setViewTitle: (NSString *)title;
- (void)changeButtonFramesDynamically;
- (void)resetClearButtonColor; 

@property(nonatomic,assign) NavigationFlow navigationFlow;
@property(nonatomic,weak)	id descControlDelegate;
@property(nonatomic,strong)	UIButton *clearButton;
@property(nonatomic,strong)	UILabel *textCountLable;
@property(nonatomic,strong)	UITextView *descTextView;
@property(nonatomic,strong)	UIView *containerView;
@property(nonatomic,strong)	NSString *descTextString;
@property(nonatomic,assign) BOOL fromEditing;
@property(nonatomic,strong) NSString *navBarTitle;
@property(nonatomic,assign) BOOL isNonEditable;
@property(nonatomic,assign) BOOL fromExpenseDescription;
@property(nonatomic,assign) BOOL fromTimeoffEntryComments;
@property(nonatomic,assign) BOOL fromTextUdf;
@end
