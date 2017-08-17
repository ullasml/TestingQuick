//
//  ApproverCommentViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 30/06/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApproverCommentViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    
    UITableView *approverCommentTableView;
    NSMutableArray *approverCommentDetailArray;
    NSString *sheetIdentity;
    id __weak delegate;
    NSString *viewType;
    NSString *approvalsModuleName;
    
}
@property (nonatomic,strong) UITableView *approverCommentTableView;
@property (nonatomic,strong)  NSMutableArray *approverCommentDetailArray;
@property (nonatomic,strong)   NSString *sheetIdentity;
@property (nonatomic,weak)id delegate;
@property (nonatomic,strong)   NSString *viewType;
@property (nonatomic,strong)   NSString *approvalsModuleName;


@end
