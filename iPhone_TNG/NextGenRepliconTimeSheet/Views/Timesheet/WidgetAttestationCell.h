//
//  WidgetAttestationCell.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 6/23/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@class WidgetAttestationCell;

@protocol WidgetAttestationCellDelegate <NSObject>
@optional
- (void)widgetAttestationCell:(WidgetAttestationCell *)widgetAttestationCell isAttestationAccepted:(BOOL)isAttestationAccepted;
@end


@interface WidgetAttestationCell : UITableViewCell

@property (nonatomic,assign) id<WidgetAttestationCellDelegate> widgetAttestationCellDelegate;

-(void)createCellLayoutWidgetAttestation:(NSString *)title andDescription:(NSString *)description andTitleTextHeight:(float)titleHeight anddescriptionTextHeight:(float)descriptionHeight showPadding:(BOOL)showPadding andAttestationStatus:(BOOL)isSelected andTimeSheetStatus:(NSString *)timeSheetStatus;



@end
