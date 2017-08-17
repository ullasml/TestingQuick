//
//  AuditTrialViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 07/07/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuditTrialPunchObject.h"
#import "AuditTrialCustomCell.h"
@interface AuditTrialViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)NSMutableArray *auditTrialInfoList;
@property(nonatomic,strong)UITableView *auditTrialInfoTableView;
@property(nonatomic,strong)NSString *headerDateString;
@property(nonatomic,strong)NSString *userName;
@property(nonatomic,assign)BOOL isFromTeamTime;
@property(nonatomic,assign)BOOL isFromAuditHistoryForPunch;
@property(nonatomic,strong)NSString *punchActionuri;
@property(nonatomic,strong)NSString *punchTime;
@property(nonatomic,strong)NSString *punchTimeFormat;

-(void)auditTrialDataReceivedAction:(NSNotification *)notification;
@end
