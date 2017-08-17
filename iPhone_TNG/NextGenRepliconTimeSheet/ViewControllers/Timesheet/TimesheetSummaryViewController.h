//
//  TimesheetSummaryViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 21/12/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimesheetSummaryViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
   
    UITableView *timesheetSummaryTableView;
    UIView *footerView;
    
    NSMutableArray *projectArray;
    NSMutableArray *payrollArray;
    NSMutableArray *billingArray;
    NSString *totalHours;
    NSMutableArray *sectionArray;
    NSMutableArray *approvalArray;
    NSString    *sheetIdentity;
    
    NSMutableArray *activityArray;
    UINavigationController       *navcontroller;
    BOOL isProjectAccess;
    BOOL isActivityAccess;
    id __weak delegate;
}
@property (nonatomic,strong)UITableView *timesheetSummaryTableView;
@property (nonatomic,strong)UIView *footerView;
@property (nonatomic,strong)NSMutableArray *projectArray;
@property (nonatomic,strong)NSMutableArray *payrollArray;
@property (nonatomic,strong)NSMutableArray *billingArray;
@property (nonatomic,strong)NSString *totalHours;
@property (nonatomic,strong)NSMutableArray *approvalArray;
@property(nonatomic,strong)NSString    *sheetIdentity;
@property (nonatomic,strong)NSMutableArray *sectionArray;
@property (nonatomic,strong) NSMutableArray *activityArray;
@property(nonatomic,strong) UINavigationController       *navcontroller;
@property (nonatomic,weak)id delegate;
@end
