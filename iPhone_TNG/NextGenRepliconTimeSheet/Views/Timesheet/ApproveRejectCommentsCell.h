//
//  ApproveRejectCommentsCell.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 04/09/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "WidgetTSViewController.h"

@interface ApproveRejectCommentsCell : UITableViewCell

-(void)createCellLayoutWidgetTitle:(NSString *)title andComments:(NSString *)comments andVariableTextHeight:(float)height;
@property (nonatomic,weak)id delegate;
@end
