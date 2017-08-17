//
//  TimesheetSubmitReasonViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by juhigautam on 10/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimesheetSubmitReasonViewController : UIViewController<UITextViewDelegate>{
    UIScrollView *mainScrollView;
    UITextView *reasonTextView;
    NSMutableArray * reasonDetailArray;
    NSString *sheetIdentity;
    BOOL					isMultiDayInOutTimesheetUser;
    NSMutableArray          *timesheetLevelUdfArray;
    NSMutableArray          *arrayOfEntriesForSave;
    BOOL                    isDisclaimerRequired;
    BOOL                    isExtendedInoutUser;
    NSString                *actionType;
    NSString                *comments;
    int count;
    CGPoint svos;
    id __weak                      delegate;
    NSString                *submitComments;
    CGPoint tempPoint;
}
@property (nonatomic,strong)UIScrollView *mainScrollView;
@property (nonatomic,strong) UITextView *reasonTextView;
@property (nonatomic,strong)NSMutableArray * reasonDetailArray;
@property (nonatomic,strong)NSString *sheetIdentity;
@property(nonatomic, strong) NSMutableArray          *timesheetLevelUdfArray;
@property(nonatomic, assign) BOOL					isMultiDayInOutTimesheetUser;
@property(nonatomic, strong) NSMutableArray          *arrayOfEntriesForSave;
@property(nonatomic, assign) BOOL                    isDisclaimerRequired;
@property(nonatomic, assign) BOOL                    isExtendedInoutUser;
@property(nonatomic, strong) NSString               *actionType;
@property(nonatomic, weak) id                     delegate;
@property(nonatomic, strong)NSString                *submitComments;
@property(nonatomic, assign) CGPoint tempPoint;
@end
