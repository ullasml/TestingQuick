//
//  ShiftsViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 20/02/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SupportDataModel.h"
#import "ShiftsModel.h"
#import "ShiftMainPageViewController.h"

@protocol Theme;

@interface ShiftsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    int                                         refreshCount;
}


@property(nonatomic,assign) BOOL                isCalledFromMenu;
@property(nonatomic,strong) UITableView         *shiftsListTableView;
@property(nonatomic,strong) NSMutableArray      *shiftsListArray;
@property(nonatomic,strong) SupportDataModel    *supportDataModel;
@property(nonatomic,strong) ShiftsModel         *obj_ShiftsModel;
@property (nonatomic,readonly)id<Theme> theme;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithTheme:(id<Theme>)theme NS_DESIGNATED_INITIALIZER;
- (void)launchCurrentShift;
@end
