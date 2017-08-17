//
//  PunchHistoryCustomCell.h
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 06/02/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimesheetEntryObject.h"


@interface PunchHistoryCustomCell : UITableViewCell <UITextFieldDelegate>


@property(nonatomic,strong)TimesheetEntryObject *tsEntryObject;
@property(nonatomic,assign)BOOL                 isProjectAccess;
@property(nonatomic,assign)BOOL                 isActivityAccess;
@property(nonatomic,assign)BOOL                 isBillingAccess;
@property(nonatomic,assign)BOOL                 isBreakAccess;
@property (nonatomic,weak) id                   delegate;



// methods
-(void)createCellLayoutWithParams : (BOOL)isExtended  isProjectAccess:(BOOL)ProjectAccess isActivityAccess:(BOOL)ActivityAccess isBillingAccess:(BOOL)BillingAccess  isBreakAccess:(BOOL)isBreaksAccess row:(NSInteger)row data:(NSMutableDictionary*)data isStartBtnEnabled:(BOOL)isStartBtnEnabled;
-(UIView *)projectViewHeader;
-(float)getHeightForString:(NSString *)string fontSize:(int)fontSize forWidth:(float)width;
-(NSString *)getTheAttributedTextForEntryObject;
-(UIView *)initialiseView:(NSMutableDictionary *)dataDict;
-(BOOL)checkIfBothProjectAndClientIsNull:(NSString *)timeEntryClientName projectName:(NSString *)timeEntryProjectName;
-(void)startIconButtonAction :(id) sender;


@end

@protocol PunchTimeCellClickDelegate <NSObject>
@optional
-(void) cellClickedAtIndex:(NSInteger)row ;
@end

