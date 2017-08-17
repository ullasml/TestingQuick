//
//  ApproveTimeSheetChangeViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 11/04/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApprovalsModel.h"

@interface ApproveTimeSheetChangeViewController : UIViewController
{
    
}

@property(nonatomic,strong) UIScrollView         *changesListScrollView;

@property(nonatomic,strong) NSMutableArray      *changesListArray;
@property(nonatomic,strong) ApprovalsModel      *obj_approvalsModel;
@property(nonatomic,strong) NSString            *sheetIdentity;


@end
