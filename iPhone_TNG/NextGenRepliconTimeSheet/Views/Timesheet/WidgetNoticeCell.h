//
//  WidgetNoticeCell.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 24/09/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface WidgetNoticeCell : UITableViewCell

@property(nonatomic,weak)id delegate;
-(void)createCellLayoutWidgetTitle:(NSString *)title andDescription:(NSString *)description andTitleTextHeight:(float)titleHeight anddescriptionTextHeight:(float)descriptionHeight showPadding:(BOOL)showPadding;
@end
