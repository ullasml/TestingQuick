//
//  CommentsViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 25/01/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "TimeOffObject.h"
@class TimesheetListObject;
@class UdfObject;


@protocol CommentsActionDelegate <NSObject>
@optional
- (void)userEnteredCommentsOnUdfObject:(UdfObject *)udfObject;
@end

@interface CommentsViewController : UIViewController<UITextViewDelegate>
@property(nonatomic,assign)id <CommentsActionDelegate>commentsActionDelegate;
-(void)setUpCommentsViewControllerWithUdfObject:(UdfObject *)udfObject withNavigationFlow:(NavigationFlow)navigationFlow withTimesheetListObject:(TimesheetListObject *)timesheetListObject withTimeOffObj:(TimeOffObject *)timeOffObj;
@end
