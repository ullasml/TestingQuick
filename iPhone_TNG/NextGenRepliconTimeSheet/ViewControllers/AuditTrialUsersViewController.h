//
//  AuditTrialUsersViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 08/07/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuditTrialViewController.h"

@interface AuditTrialUsersViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView *auditTrialInfoTableView;
@property(nonatomic,strong)NSMutableArray *listDataArray;
@property(nonatomic,strong)NSString *dateString;
@property(nonatomic,strong)NSDictionary *dateDict;
@end
