//
//  HRFormCell.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 11/09/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HRFormCell;

@protocol FormCellDelegate <NSObject>
@optional
-(void) formCellDidBeginEditing:(HRFormCell*)formCell;
@end

@interface HRFormCell : UITableViewCell<UITextFieldDelegate>
@property (nonatomic, weak) id <FormCellDelegate> delegate;
@end
