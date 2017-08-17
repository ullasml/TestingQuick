//
//  AuditTrialCustomCell.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 07/07/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuditTrialCustomCell : UITableViewCell
-(void)createCellLayoutWithPunchType:(NSString *)uri punchTime:(NSString *)punchTime punchFormat:(NSString *)format commentsDict:(NSMutableDictionary *)commentsDict;
@end
