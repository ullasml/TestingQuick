//
//  TimeOffRequestedCellView.h
//  NextGenRepliconTimeSheet
//
//  Created by Vijay M on 2/18/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeOffRequestedCellView : UITableViewCell
@property(nonatomic,strong)UILabel *requestedTitleLbl;
@property(nonatomic,strong)UILabel *balanceTitleLbl;
@property(nonatomic,strong)UILabel *requestedValueLbl;
@property(nonatomic,strong)UILabel *balanceValueLbl;
@property(nonatomic,assign)int rowHeight;
-(void)createRequestedBalanceCellView:(NSString *)trackingOption :(NSString *)type :(NSString *)commentsStr :(NSString*)approvalStatus;
@end
