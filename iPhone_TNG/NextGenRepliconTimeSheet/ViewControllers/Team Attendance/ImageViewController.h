//
//  ImageViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 18/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong)UITableView *infoTableView;
@property (nonatomic,strong)NSString *currentDateString;
@property (nonatomic,assign)BOOL isFromPunchHistory;
-(void)getHeader;
@end
