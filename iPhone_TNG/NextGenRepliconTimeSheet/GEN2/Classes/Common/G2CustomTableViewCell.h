//
//  CustomTableViewCell.h
//  Replicon
//
//  Created by Swapna P on 7/28/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2Constants.h"

@interface G2CustomTableViewCell : UITableViewCell<UITextFieldDelegate> {
	UILabel		*upperLeft;
	UILabel		*upperRight;
	UILabel		*lowerLeft;
	UILabel		*lowerRight;
	UIImageView    *lowerRightImageView;
	UIImageView    *lineImageView;
	UIImageView    *backGroundImageView;
    UIImageView    *clockImageView;
	UITextField      *commonTxtField;
	id __weak commonCellDelegate;
	NSIndexPath    *selectedindex;

}
//-(void)createCellLayoutWithParams:(NSString *)upperleftString  upperlefttextcolor:(UIColor *)_textcolor upperrightstr:(NSString *)upperrightString lowerleftstr:(NSString *)lowerleftString 
//					lowerrightstr:(NSString *)lowerrightString statuscolor:(UIColor *)_color 
//					imageViewflag:(BOOL)imgviewflag;
-(void)createCellLayoutWithParams:(NSString *)upperleftString  upperlefttextcolor:(UIColor *)_textcolor upperrightstr:(NSString *)upperrightString lowerleftstr:(NSString *)lowerleftString lowerlefttextcolor:(UIColor *)_textcolorlowerleftstr  lowerrightstr:(NSString *)lowerrightString statuscolor:(UIColor *)_color imageViewflag:(BOOL)imgviewflag hairlinerequired:(BOOL)_hairlinereq;
-(void)createCommonCellLayoutFields:(NSString *)_placeholder row:(NSInteger)_rowValue;
-(void)addReceiptImage;
-(void)setCellSelectedIndex:(NSIndexPath *)_index;
@property(nonatomic, strong)	UILabel			*upperLeft;
@property(nonatomic, strong)	UILabel			*upperRight;
@property(nonatomic, strong)	UILabel			*lowerLeft;
@property(nonatomic, strong)	UILabel			*lowerRight;
@property(nonatomic, strong)	UIImageView		*lowerRightImageView;
@property(nonatomic, strong)  UIImageView     *lineImageView,*clockImageView;
@property(nonatomic, strong)  UIImageView     *backGroundImageView;
@property(nonatomic, strong)  UITextField         *commonTxtField;
@property(nonatomic, weak)  id commonCellDelegate;
@property(nonatomic,strong)    NSIndexPath    *selectedindex;
//-(void)setActiveFieldAtCell:(int)_txtTag;

@end
