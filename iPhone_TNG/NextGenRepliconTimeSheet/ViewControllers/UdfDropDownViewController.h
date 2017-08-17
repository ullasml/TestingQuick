//
//  UdfDropDownViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 25/01/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdfDropDownView.h"
#import "TimeOffObject.h"
#import "Constants.h"

@class UdfObject;

@interface UdfDropDownViewController : UIViewController<UdfDropDownNavigationDelegate,UdfDropDownViewDelegate>
@property(nonatomic,assign)id <UdfDropDownViewDelegate>delegate;
-(void)intialiseDropDownViewWithUdfObject:(UdfObject *)udfEntryObject withNaviagtion:(NavigationFlow)navigationFlow withTimesheetListObject:(TimesheetListObject *)timesheetListObject withTimeOffObj:(TimeOffObject *)timeOffObj;
@end
