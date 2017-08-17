//
//  ShiftDetailViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 27/02/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"
#import "ShiftsModel.h"
@interface ShiftDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic,strong)NSString            *headerDateString;
@property(nonatomic,strong)ShiftsModel         *obj_ShiftsModel;
@property (nonatomic,strong)UITableView        *shiftDetailTableView;
@property (nonatomic,readonly)ShiftDetailsPresenter *shiftDetailsPresenter;

//Method
-(void)getDataFromDB :(double)timeStamp;
-(instancetype)initWithPresenter:(ShiftDetailsPresenter *)shiftDetailsPresenter;
@end
