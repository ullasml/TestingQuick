//
//  DayTimeEntryCustomCell.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 10/01/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NumberKeypadDecimalPoint.h"
#import "EntryCellDetails.h"
#import "TimesheetEntryObject.h"
@interface DayTimeEntryCustomCell : UITableViewCell<UITextFieldDelegate>

{
    UILabel		*upperLeft;
    UILabel		*middleLeft;
    UILabel		*lowerLeft;
    UITextField	*upperRight;
    
    UIImageView *commentsIcon;
    id          __weak delegate;
    NumberKeypadDecimalPoint *numberKeyPad;
    
    UIToolbar *toolBar;
    NSIndexPath *selectedPath;
    EntryCellDetails *rowdetails;
    NSMutableArray *udfArray;
    NSString *timeEntryComments;
    BOOL isTimeoffRow;
    BOOL isCellRowEditable;
    NSMutableAttributedString *attributedString;
    UIBarButtonItem         *doneButton;
    UIBarButtonItem         *spaceButton;
    UIBarButtonItem *cancelButton;
    NSString *previousDateUdfValue;
    UIBarButtonItem *pickerClearButton;
   
}
@property(nonatomic,strong)UILabel *upperLeft;
@property(nonatomic,strong)UILabel *middleLeft;
@property(nonatomic,strong)UILabel *lowerLeft;
@property(nonatomic,strong)UITextField *upperRight;
@property(nonatomic,strong)UIImageView  *commentsIcon;
@property(nonatomic,weak)id delegate;
@property(nonatomic,strong)NumberKeypadDecimalPoint *numberKeyPad;
@property(nonatomic,strong)UIToolbar *toolBar;
@property(nonatomic,strong) NSIndexPath *selectedPath;
@property(nonatomic,strong)EntryCellDetails *rowdetails;
@property(nonatomic,strong)NSMutableArray *udfArray;
@property(nonatomic,strong)NSString *timeEntryComments;
@property(nonatomic,assign)BOOL isTimeoffRow;
@property(nonatomic,assign)BOOL isCellRowEditable;
@property(nonatomic,strong)NSMutableAttributedString *attributedString;
@property(nonatomic,strong) UIBarButtonItem *cancelButton;
@property(nonatomic,strong) NSString *previousDateUdfValue;
@property(nonatomic,strong) UIBarButtonItem *doneButton;
@property(nonatomic,strong) UIBarButtonItem *spaceButton;
@property(nonatomic,strong) UIBarButtonItem *pickerClearButton;
@property(nonatomic,assign)BOOL isCommentRequired;
@property(nonatomic,strong)UIDatePicker *datePicker;
@property(nonatomic,strong)NSString *approvalsModuleName;

-(void)createCellLayoutWithParams:(TimesheetEntryObject *)tsEntryObject
                  isProjectAccess:(BOOL)isProjectAccess
                  isClientAccess:(BOOL)isClientAccess
                 isActivityAccess:(BOOL)isActivityAccess
                  isBillingAccess:(BOOL)isBillingAccess
                 isTimeoffSickRow:(BOOL)isTimeoffSickRow
                    upperrightstr:(NSString *)upperrightString
                      commentsStr:(NSString *)commentsStr
            commentsImageRequired:(BOOL )isCommentsImageRequired
                              tag:(NSInteger)tag
                lastUsedTextField:(UITextField *)lastUsedTextField
                         udfArray:(NSMutableArray *)tmpUdfArray
                        isTimeoff:(BOOL)isTimeoff
                    withEditState:(BOOL)canEdit
                     withDelegate:(id)_delegate
                       heightDict:(NSMutableDictionary *)heightDict
                    timeSheetFormat:(NSString *)timeSheetFormat
                    hasCommentsAccess:(BOOL)hasCommentsAccess
             hasNegativeTimeEntry:(BOOL)allowNegativeTimeEntry;


-(void)doneClicked;
@end
