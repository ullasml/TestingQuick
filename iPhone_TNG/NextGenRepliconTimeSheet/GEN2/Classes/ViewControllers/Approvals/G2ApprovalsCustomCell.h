//
//  ApprovalsCustomCell.h
//  Replicon
//
//  Created by Dipta Rakshit on 2/7/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G2ApprovalsCustomCell : UITableViewCell
{
    UILabel		*leftLbl;
	UILabel		*rightLbl;
    UIImageView    *lineImageView;
    id __weak commonCellDelegate;
}

@property(nonatomic, strong) UILabel		*leftLbl;
@property(nonatomic, strong) UILabel		*rightLbl;
@property(nonatomic, strong) UIImageView    *lineImageView;
@property(nonatomic, weak)  id commonCellDelegate;

-(void)createCellLayoutWithParams:(NSString *)leftString   rightstr:(NSString *)rightString hairlinerequired:(BOOL)_hairlinereq;

@end
