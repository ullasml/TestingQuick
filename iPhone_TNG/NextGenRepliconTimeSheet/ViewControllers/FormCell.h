//
//  FormCell.h
//  Replicon
//
//  Created by Abhi on 3/30/14.
//  Copyright (c) 2014 Replicon INC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FormCell;

@protocol FormCellDelegate <NSObject>
@optional
-(void) formCellDidBeginEditing:(FormCell*)formCell;
@end


@interface FormCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, weak) id <FormCellDelegate> delegate;

@end
