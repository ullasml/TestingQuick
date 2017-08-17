//
//  ApproverCommentDetailCellView.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 30/06/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApproverCommentDetailCellView : UITableViewCell{
    
}
-(void)createCellLayoutWithParamsStatus:(NSString*)status time:(NSString*)timeStr comments:(NSString*)commentsStr approver:(NSString*)approverStr WithTag:(NSInteger)tag;
@end
