//
//  UdfDropDownView.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 25/01/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UdfDropDownView;
@class UdfObject;
@class TimesheetListObject;
@protocol UdfDropDownViewDelegate <NSObject>
@optional
- (void)udfDropDownView:(UdfDropDownView *)udfDropDownView withUdfObject:(UdfObject *)udfObject;
- (void)udfDropDownView:(UdfDropDownView *)udfDropDownView refreshAction:(id)sender;
- (void)udfDropDownView:(UdfDropDownView *)udfDropDownView moreAction:(id)sender;
@end

@protocol UdfDropDownNavigationDelegate <NSObject>
@optional
- (void)udfDropDownView:(UdfDropDownView *)udfDropDownView selectedIndexPath:(NSIndexPath *)indexpath;
- (void)udfDropDownView:(UdfDropDownView *)udfDropDownView refreshAction:(id)sender;
- (void)udfDropDownView:(UdfDropDownView *)udfDropDownView moreAction:(id)sender;
@end

@interface UdfDropDownView : UITableView<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,assign)id <UdfDropDownViewDelegate> udfDropDownViewDelegate;
@property(nonatomic,weak)id <UdfDropDownNavigationDelegate> udfDropDownNavigationDelegate;

-(void)setUpDropDownViewWithDropdownArray:(NSMutableArray *)dropDownOptionList withArrayOfCharacters:(NSMutableArray *)arrayOfCharacters withObjectsForCharacters:(NSMutableDictionary *)objectsForCharacters withUdfObject:(UdfObject *)udfObject withTimesheetListObject:(TimesheetListObject *)timesheetListObject;
@end
