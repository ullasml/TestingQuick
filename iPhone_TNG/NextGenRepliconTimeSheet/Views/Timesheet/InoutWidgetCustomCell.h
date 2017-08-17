//
//  InoutWidgetCustomCell.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 26/08/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
@interface InoutWidgetCustomCell : UITableViewCell

-(void)createCellLayoutInoutWidgetTitle:(NSString *)title
                           regularHours:(NSString *)_regularHours
                             breakHours:(NSString *)_breakHours
                           timeoffHours:(NSString *)_timeoffHours
                         isLoadedWidget:(BOOL)isWidgetLoaded
                            andPaddingY:(float)yPadding
                            andPaddingH:(float)hPadding
                     shouldBreakBeShown:(BOOL)shouldBreakBeShown
                   shouldTimeoffBeShown:(BOOL)shouldTimeoffBeShown
                          isPunchWidget:(BOOL)isPunchWidget;
@end
