//
//  TimeViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 18/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>


@property (nonatomic,assign)id delegate;
@property (nonatomic,strong)UITableView *infoTableView;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)NSString *currentDateString;
@property (nonatomic,strong)NSString *btnClicked;
@property (nonatomic,assign)BOOL isEditPunchAllowed;
@property (nonatomic,assign)BOOL isFromPunchHistory;


-(void )getHeader;
- (void)didSelectRowWithIndexPath:(NSIndexPath *)indexPath;
- (void)addPunch:(NSIndexPath *)indexPath;

@end

