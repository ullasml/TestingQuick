//
//  TimeOffDetailsTableFooterView.m
//  NextGenRepliconTimeSheet
//
//  Created by Vijay M on 2/4/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "TimeOffDetailsTableFooterView.h"
#import "Constants.h"
#import "TimesheetUdfView.h"
#import "LoginModel.h"
#import "ApprovalsModel.h"
#import "ApprovalTablesFooterView.h"
#import "ApprovalsScrollViewController.h"
#import "UIView+Additions.h"

#define ROW_HEIGHT 58.0


@interface TimeOffDetailsTableFooterView() <approvalTablesFooterViewDelegate>
{
    UIButton *deletButton;
    UIButton *submitButton;
    float commentTextHeight;
    
}
@property(nonatomic,assign) BOOL isStatusView;
@property(nonatomic,strong)UILabel *requestedTimeOffValueLb;
@property(nonatomic,strong)UITextView *commentsTextView;
@property(nonatomic,strong)NSMutableArray *customFieldArray;
@end

@implementation TimeOffDetailsTableFooterView

-(void)setUpTimeOffTableFooterView:(TimeOffObject *)timeoffDetailsObj :(NSString *)commentsStr :(NSInteger)screenMode :(NSString *)balanceTracking
{
    CGFloat width = CGRectGetWidth(self.bounds);

    self.timeOffDetailsObj =timeoffDetailsObj;
    float y = 10;
    CGRect deleteBtnFrame=CGRectZero;
    if (self.add_editFlow==TIMEOFF_EDIT) {
        deleteBtnFrame=submitButton.frame;
        deleteBtnFrame.origin.y = 10;
    }
    else {
        deleteBtnFrame=submitButton.frame;
        deleteBtnFrame.origin.y = 10;
    }
    float extraSpaceDueToApprovals=0.0;
    //Approval context Flow for Expenses
    if (self.navigationFlow == PENDING_APPROVER_NAVIGATION || self.navigationFlow == PREVIOUS_APPROVER_NAVIGATION)
    {
        //if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMEOFF_MODULE])
         if (self.navigationFlow == PENDING_APPROVER_NAVIGATION)
        {
            int approvalsFooterViewHeight=205.0;
            ApprovalTablesFooterView *approvalTablesfooterView=[[ApprovalTablesFooterView alloc]initWithFrame:CGRectMake(0,deleteBtnFrame.origin.y, self.width, approvalsFooterViewHeight ) withStatus:[self.timeOffDetailsObj approvalStatus]];
            approvalTablesfooterView.delegate=self.timeOffDetailsViewControllerDelegate;
            [self addSubview:approvalTablesfooterView];
            [self sendSubviewToBack:approvalTablesfooterView];
            extraSpaceDueToApprovals=approvalsFooterViewHeight;
            
            CGRect frame = approvalTablesfooterView.frame;
            frame.size.height=deleteBtnFrame.origin.y+frame.size.height+100.0;
            self.frame = frame;
        }
    }
    else if (self.navigationFlow == TIMEOFF_BOOKING_NAVIGATION || self.navigationFlow == TIMESHEET_PERIOD_NAVIGATION)
    {
        
        if (self.add_editFlow==TIMEOFF_EDIT && ![self.approvalsDelegate isKindOfClass:[ApprovalsScrollViewController class]]) {
            deletButton =[UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *normalImg = [Util thumbnailImage:DeleteTimesheetButtonImage];
            UIImage *highlightedImg = [Util thumbnailImage:DeleteTimesheetPressedButtonImage];
            [deletButton setBackgroundImage:normalImg forState:UIControlStateNormal];
            [deletButton setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
            [deletButton setTitle:RPLocalizedString(@"Delete",@"Delete") forState:UIControlStateNormal];
            [deletButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
            [deletButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
            deletButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            [self addSubview:deletButton];

            submitButton =[UIButton buttonWithType:UIButtonTypeCustom];
            [submitButton setTitleColor:[Util colorWithHex:@"#0078cc" alpha:1.0f] forState:UIControlStateNormal];
            submitButton.cornerRadius = 22.0f;
            submitButton.layer.borderColor = [[Util colorWithHex:@"#cccccc" alpha:1.0f] CGColor];
            submitButton.layer.borderWidth = 1.0f;
            [submitButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
            [submitButton addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
            submitButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            submitButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [self addSubview:submitButton];

            if (self.isStatusView)
            {
                if ([self.customFieldArray count]>0)
                {
                    deleteBtnFrame.origin.y=y+40;
                }
                [submitButton setFrame:CGRectMake((width - 240) / 2, deleteBtnFrame.origin.y, 240, 44)];
                [submitButton setTitle:RPLocalizedString(EDIT,@"Edit") forState:UIControlStateNormal];
                deletButton.hidden=YES;
            }
            else{
                [submitButton setTitle:RPLocalizedString(Resubmit_Button_title,@"") forState:UIControlStateNormal];
                if ([self.customFieldArray count]>0)
                {
                    deleteBtnFrame.origin.y=y+40;
                }
                [submitButton setFrame:CGRectMake((width - 240) / 2, deleteBtnFrame.origin.y, 240, 44)];
                deleteBtnFrame.origin.y=normalImg.size.height+deleteBtnFrame.origin.y+15;
                [deletButton setFrame:CGRectMake(20, deleteBtnFrame.origin.y,normalImg.size.width, normalImg.size.height)];
                if ([[self.timeOffDetailsObj approvalStatus] isEqualToString:REJECTED_STATUS] && self.isDeleteAcess)
                {
                    deletButton.hidden=NO;
                }
                else{
                    deletButton.hidden=YES;
                    CGRect buttonFrame = submitButton.frame;
                    buttonFrame.origin.y =buttonFrame.size.height+5;
                    submitButton.frame = buttonFrame;
                }
            }
        }
        if ((self.add_editFlow == TIMEOFF_ADD ||self.add_editFlow==TIMEOFF_VIEW) && ![self.approvalsDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            submitButton =[UIButton buttonWithType:UIButtonTypeCustom];
            [submitButton setTitleColor:[Util colorWithHex:@"#0078cc" alpha:1.0f] forState:UIControlStateNormal];
            submitButton.cornerRadius = 22.0f;
            submitButton.layer.borderColor = [[Util colorWithHex:@"#cccccc" alpha:1.0f] CGColor];
            submitButton.layer.borderWidth = 1.0f;
            if (self.add_editFlow==TIMEOFF_VIEW)
            {
                if (![[self.timeOffDetailsObj approvalStatus] isEqualToString:APPROVED_STATUS] && ![[self.timeOffDetailsObj approvalStatus] isEqualToString:WAITING_FOR_APRROVAL_STATUS])
                {
                    [submitButton setTitle:RPLocalizedString(Resubmit_Button_title,@"") forState:UIControlStateNormal];
                }
                else
                {
                    [submitButton setTitle:RPLocalizedString(EDIT,@"Edit") forState:UIControlStateNormal];
                }

            }
            else{
                [submitButton setTitle:RPLocalizedString(SUBMIT_BTN_MSG,@"Submit") forState:UIControlStateNormal];
                if ([self.timeOffDetailsObj bookedEndDate]!=nil && [self.timeOffDetailsObj bookedStartDate]!=nil)
                {
                    submitButton.userInteractionEnabled=YES;
                }
                else{
                    submitButton.userInteractionEnabled=NO;
                }
            }
            [submitButton setFrame:CGRectMake((width - 240) / 2, deleteBtnFrame.origin.y, 240, 44)];
            if (self.add_editFlow == TIMEOFF_ADD) {
                CGRect buttonFrame = submitButton.frame;
                buttonFrame.origin.y =buttonFrame.size.height+5;
                submitButton.frame = buttonFrame;
            }
            [submitButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_17]];
            [submitButton addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
            submitButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            if ([[self.timeOffDetailsObj approvalStatus] isEqualToString:APPROVED_STATUS] && !self.isEditAcess)
            {
                submitButton.hidden=YES;
            }
            else if(![[self.timeOffDetailsObj approvalStatus] isEqualToString:APPROVED_STATUS] && !self.isEditAcess && self.add_editFlow!=TIMEOFF_ADD)
            {
                submitButton.hidden=YES;
            }
            if (self.isDeleteAcess && (self.add_editFlow==TIMEOFF_VIEW))
            {
                deletButton =[UIButton buttonWithType:UIButtonTypeCustom];
                [deletButton setTitleColor:[Util colorWithHex:@"#0078cc" alpha:1.0f] forState:UIControlStateNormal];
                deletButton.cornerRadius = 22.0f;
                deletButton.layer.borderColor = [[Util colorWithHex:@"#cccccc" alpha:1.0f] CGColor];
                deletButton.layer.borderWidth = 1.0f;
                [deletButton setTitle:RPLocalizedString(@"Delete",@"Delete") forState:UIControlStateNormal];
                [deletButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
                
                [deletButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
                deletButton.contentHorizontalAlignment= UIControlContentHorizontalAlignmentCenter;
                if (self.isEditAcess)
                {
                    if (deleteBtnFrame.size.height>0.0)
                    {
                        deleteBtnFrame.origin.y=deleteBtnFrame.origin.y+60;
                    }
                    else
                        deleteBtnFrame.origin.y=deleteBtnFrame.size.height+deleteBtnFrame.origin.y+60;
                }

                [deletButton setFrame:CGRectMake((width - 240) / 2, deleteBtnFrame.origin.y, 240, 44)];
                [self addSubview:deletButton];
            }
            [submitButton setAccessibilityLabel:@"uia_timeoff_submit_button_identifier"];
            [self addSubview:submitButton];
        }
    }
    else
    {
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMEOFF_MODULE])
        {
            deleteBtnFrame.origin.y=y;
            int approvalsFooterViewHeight=205.0;
            ApprovalTablesFooterView *approvalTablesfooterView=[[ApprovalTablesFooterView alloc]initWithFrame:CGRectMake(0,deleteBtnFrame.origin.y, self.width, approvalsFooterViewHeight ) withStatus:[self.timeOffDetailsObj approvalStatus]];
            approvalTablesfooterView.delegate=self;
            [self addSubview:approvalTablesfooterView];
            [self sendSubviewToBack:approvalTablesfooterView];
            extraSpaceDueToApprovals=approvalsFooterViewHeight;
            
            CGRect frame = approvalTablesfooterView.frame;
            frame.size.height=deleteBtnFrame.origin.y+frame.size.height+50.0;;
            self.frame = frame;
        }
        
    }
}
-(void)saveAction:(id)sender
{
    if([self.timeOffSaveDeleteDelegate respondsToSelector:@selector(ActionForSave_Edit)])
    {
        TimeoffModel *timeoffModel=[[TimeoffModel alloc]init];
        NSMutableArray *timeOffTypesArray=[timeoffModel getAllTimeOffTypesFromDB];
        if ([timeOffTypesArray count]==0)
        {
            [Util errorAlert:@"" errorMessage:RPLocalizedString(noTimeOffTypesAssigned, @"")];
            return;
        }
        [self.timeOffSaveDeleteDelegate ActionForSave_Edit];
    }
}

-(void)deleteAction:(id)sender
{
    if([self.timeOffSaveDeleteDelegate respondsToSelector:@selector(ActionForDelete)])
    {
        [self.timeOffSaveDeleteDelegate ActionForDelete];
    }
    
}

@end
