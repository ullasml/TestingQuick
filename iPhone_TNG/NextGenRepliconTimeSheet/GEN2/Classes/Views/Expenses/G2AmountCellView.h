//
//  AmountCellView.h
//  Replicon
//
//  Created by Manoj  on 25/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G2Constants.h"
#import "G2NumberKeypadDecimalPoint.h"
#import "G2Util.h"

@interface G2AmountCellView : UITableViewCell <UITextFieldDelegate>{
	
	UILabel *fieldLable;
	UIButton *fieldButton;
	id __weak amountDelegate;
	UITextField *fieldText;
	G2NumberKeypadDecimalPoint *numberKeyPad;
	UILabel *clientProjectlabel;
	UIButton *clientProjectButton;
	UIImageView *folderImageView;
	
	id __weak clientProjectTaskDelegate;
	id __weak taskViewControllerDelegate;
}
-(void)addFieldLabelAndButton:(NSInteger)tagValue;
-(void)buttonAction:(UIButton*)sender withEvent:(UIEvent*)event;
-(void)addFieldsForClientProjectTaskcell;
-(void)addFieldsForTaskViewController:(int)tagValue;
-(void) setCellViewState: (BOOL)isSelected;

@property (nonatomic, strong) G2NumberKeypadDecimalPoint *numberKeyPad;
@property(nonatomic,strong)	UITextField *fieldText;
@property(nonatomic,weak)	id amountDelegate;
@property(nonatomic,strong)	UILabel *fieldLable;
@property(nonatomic,strong)	UIButton *fieldButton;
@property(nonatomic,strong)UILabel *clientProjectlabel;
@property(nonatomic,strong)UIButton *clientProjectButton;
@property(nonatomic,weak)id  taskViewControllerDelegate;
@property(nonatomic,strong)UIImageView *folderImageView;
@property(nonatomic,weak) id clientProjectTaskDelegate;

@end
