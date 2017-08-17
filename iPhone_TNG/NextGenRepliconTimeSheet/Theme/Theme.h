#import <Foundation/Foundation.h>


@protocol Theme <NSObject>

- (UIColor *)punchInColor;
- (CGColorRef)punchInButtonBorderColor;
- (CGFloat)punchInButtonBorderWidth;
- (UIFont *)punchInButtonTitleFont;
- (UIColor *)punchInButtonTitleColor;
- (UIFont *)punchedSinceLabelFont;
- (UIColor *)punchedSinceLabelTextColor;
- (UIFont *)addressLabelFont;
- (UIColor *)addressLabelTextColor;
- (UIColor *)punchOutAddressLabelContainerBackgroundColor;
- (UIColor *)onBreakBackgroundColor;
- (UIColor *)onBreakClockOutButtonTitleColor;
- (UIColor *)onBreakClockOutButtonBackgroundColor;
- (UIColor *)timesheetBreakHoursNewBigFontColor;
- (UIColor *)resumeWorkButtonTitleColor;
- (UIColor *)resumeWorkButtonBackgroundColor;
- (UIColor *)punchOutButtonBackgroundColor;
- (UIColor *)punchOutButtonBorderColor;
- (UIColor *)takeBreakButtonBackgroundColor;
- (UIColor *)takeBreakButtonBorderColor;
- (UIColor *)transparentColor;
- (UIColor *)takeBreakButtonTitleColor;
- (UIColor *)transferButtonTitleColor;
- (UIColor *)transferButtonBackgroundColor;
- (UIColor *)defaultleftBarButtonColor;

#pragma mark - Time Summary

- (UIColor *)childControllerDefaultBackgroundColor;
- (UIFont *)durationLabelLittleTimeUnitBigFont;
- (UIColor *)timeCardSummaryBackgroundColor;
- (UIColor *)timeCardSummaryDateTextColor;
- (UIFont *)timeCardSummaryDateTextFont;
- (UIColor *)timeCardSummaryRegularTimeTextColor;
- (UIColor *)timeCardSummaryOnBreakTimeTextColor;
- (UIColor *)timeCardSummaryOverTimeTextColor;
- (UIFont *)timeCardSummaryRegularTimeTextFont;
- (UIColor *)timeCardSummaryTimeDescriptionTextColor;
- (UIFont *)timeCardSummaryTimeDescriptionTextFont;

#pragma mark - Timesheet Breakdown

- (UIColor *)timesheetBreakdownBackgroundColor;
- (UIColor *)timesheetBreakdownRegularTimeTextColor;
- (UIColor *)timesheetBreakdownBreakTimeTextColor;
- (UIFont *)timesheetBreakdownTimeFont;
- (UIFont *)timesheetBreakdownDateFont;
- (UIColor *)timesheetBreakdownSeparatorColor;
- (UIFont *)timesheetBreakdownViolationCountFont;
- (UIColor *)timesheetBreakdownViolationCountColor;
- (UIFont *)timesheetRegularTimeFont;
- (UIFont *)timesheetWidgetTitleFont;
- (UIFont *)timesheetNoticeWidgetDescriptionFont;
- (UIColor *)timesheetWidgetTitleTextColor;
- (UIColor *)attestationSwitchColor;


#pragma mark - UISegmentedControl
- (UIColor *)segmentedControlTintColor;
- (UIColor *)segmentedControlTextColor;
- (UIFont *)segmentedControlFont;

#pragma mark - UIButton

- (UIFont *)regularButtonFont;
- (UIColor *)regularButtonTitleColor;
- (UIColor *)regularButtonBackgroundColor;
- (UIColor *)regularButtonBorderColor;
- (UIColor *)destructiveButtonTitleColor;

#pragma mark - Supervisor Dashboard

- (UIColor *)supervisorDashboardBackgroundColor;
- (UIColor *)supervisorTimesheetDetailsControllerBackGroundColor;
- (UIColor *)supervisorTimesheetDetailsControllerSummaryCardBackGroundColor;

- (CGColorRef)cardContainerBorderColor;
- (CGFloat)cardContainerBorderWidth;
- (UIFont *)cardContainerHeaderFont;
- (UIColor *)cardContainerHeaderColor;
- (UIColor *)cardContainerSeparatorColor;
- (UIColor *)cardContainerBackgroundColor;

- (UIFont *)inboxRowFont;

#pragma mark - Supervisor Team Timesheets

- (UIColor *)timesheetUsersTableViewHeaderColor;
- (UIFont *)timesheetUsersTableViewHeaderFont;
- (UIFont *)timesheetUserNameFont;
- (UIFont *)timesheetUserWorkHoursFont;
- (UIFont *)timesheetUserBreakHoursFont;

- (UIColor *)timesheetUserBreakHoursColor;
- (UIColor *)timesheetUserOvertimeAndViolationsColor;

- (UIFont *)supervisorTeamTimesheetsSectionHeaderFont;
- (UIColor *)supervisorTeamTimesheetsSectionFontColor;

#pragma mark - Violations

- (UIFont *)violationsCellTitleFont;
- (UIColor *)violationsCellTitleTextColor;

- (UIFont *)violationsCellTimeAndStatusFont;
- (UIColor *)violationsCellTimeAndStatusTextColor;
- (UIColor *)violationsButtonTitleColor;
- (UIColor *)violationsButtonBackgroundColor;
- (UIColor *)violationsButtonBorderColor;

#pragma mark - Delete Punch

- (UIColor *)deletePunchButtonBackgroundColor;
- (UIColor *)deletePunchButtonBorderColor;
- (UIColor *)deletePunchButtonTitleColor;

#pragma mark - Team Status

- (UIFont *)teamStatusTitleFont;
- (UIColor *)teamStatusTitleColor;
- (UIFont *)teamStatusValueFont;
- (UIColor *)teamStatusInColor;
- (UIColor *)teamStatusOutColor;
- (UIColor *)teamStatusBreakColor;

- (UIColor *)userSummaryCellBackgroundColor;
- (UIFont *)userSummaryCellNameFont;
- (UIColor *)userSummaryCellNameColor;
- (UIFont *)userSummaryCellDetailsFont;
- (UIColor *)userSummaryCellDetailsColor;
- (UIFont *)userSummaryCellHoursFont;
- (UIColor *)userSummaryCellHoursColor;
- (UIColor *)userSummaryCellHoursInactiveColor;

- (UIFont *)teamTableViewSectionHeaderFont;
- (UIColor *)teamTableViewSectionHeaderTextColor;
- (UIColor *)teamTableViewSectionHeaderBackgroundColor;

- (UIFont *)teamStatusCellNoUsersFont;
- (UIColor *)teamStatusCellNoUsersColor;
- (UIColor *)teamStatusTableFooterBackgroundColor;

#pragma mark - Duration

- (UIColor *)durationLabelTextColor;
- (UIFont *)durationLabelBigNumberFont;
- (UIFont *)durationLabelLittleNumberFont;
- (UIFont *)durationLabelBigTimeUnitFont;
- (UIFont *)durationLabelLittleTimeUnitFont;

#pragma mark - Timeline

- (UIFont *)timeLineCellTimeLabelFont;
- (UIFont *)timeLineCellDescriptionLabelFont;
- (UIColor *)timeLineCellTimeLabelTextColor;
- (UIColor *)newTimeLineCellTimeLabelTextColor;
- (UIColor *)timeLineCellDescriptionLabelTextColor;
- (UIColor *)timeLineCellVerticalLineColor;
- (UIFont *)clientLabelLittleNumberFont;
- (UIColor *)addPunchButtonBackgroundColor;
- (UIColor *)addPunchButtonTitleColor;
- (UIColor *)addPunchButtonBorderColor;
- (UIFont *)timeLineMetadataFont;
- (UIColor *)timeLineMetadataTextColor;
- (UIFont *)actualPunchTimeFont;
- (UIFont *)timeLineMetaDataBolderFont;
- (UIFont *)punchDurationFont;
- (UIFont *)violationCountFont;
- (UIColor *)actualPunchTimeTextColor;
- (UIColor *)timeLinePunchTypeTextColor;
- (UIColor *)punchDurationTextColor;
- (UIColor *)violationCountHighlightedTextColor;
- (UIColor *)violationCountTextColor;
- (UIFont *)timeLinePunchTypeTexFont;
- (UIColor *)timelineSelectedCellColor;

#pragma mark - Timesheet Button Controller

- (UIColor *)viewTimesheetButtonBorderColor;
- (UIColor *)viewTimesheetButtonTitleColor;
- (UIColor *)viewTimesheetButtonBackgroundColor;


#pragma mark - Timesheet Detail

- (UIFont *)timesheetDetailDateRangeFont;
- (UIFont *)timesheetDetailCurrentPeriodFont;
- (UIColor *)timesheetDetailsBackgroundColor;
- (UIColor *)timesheetDetailsBorderColor;
- (UIColor *)timesheetDetailCurrentPeriodTextColor;
- (UIColor *)timesheetDetailDateRangeTextColor;


#pragma mark - Navigation

- (UIColor *)navigationBarBackgroundColor;
- (UIColor *)navigationBarTintColor;
- (UIFont *)navigationBarTitleFont;

#pragma mark - UITableViews

- (UIFont *)defaultTableViewCellFont;
- (UIColor *)defaultTableViewSecondRowTextColor;
- (UIColor *)defaultTableViewHeaderBackgroundColor;
- (UIFont *)defaultTableViewHeaderButtonFont;
- (UIColor *)defaultTableViewSeparatorColor;

#pragma mark - Search TextFields

- (UIFont *)searchTextFieldFont;
- (UIColor *)searchTextFieldBackgroundColor;


#pragma mark - DayController

- (UIColor *)dayControllerBackgroundColor;
- (UIColor *)dayControllerBorderColor;

#pragma mark - PunchOverViewController

- (UIColor *)punchOverviewBackgroundColor;

#pragma mark - PunchDetailsController

- (UIColor *)punchDetailsBorderLineColor;
- (UIColor *)punchDetailsContentViewBackgroundColor;
- (UIFont *)punchDetailsAddressLabelFont;
- (UIColor *)punchDetailsAddressLabelTextColor;

#pragma mark - ApprovalStatus labels

- (UIColor *)approvalStatusNotSubmittedColor;
- (UIColor *)approvalStatusWaitingForApprovalColor;
- (UIColor *)approvalStatusRejectedColor;
- (UIColor *)approvalStatusTimesheetNotApprovedColor;
- (UIColor *)approvalStatusDefaultColor;

#pragma mark - MultiDayTimeOff Status

- (UIColor *)timeOffStatusWaitingForApprovalColor;
- (UIColor *)timeOffStatusApprovedColor;
- (UIColor *)timeOffStatusRejectedColor;

#pragma mark - Waivers

- (UIColor *)waiverBackgroundColor;
- (UIColor *)waiverSeparatorColor;

- (UIColor *)waiverViolationTitleTextColor;
- (UIFont *)waiverViolationTitleFont;

- (UIColor *)waiverSectionTitleTextColor;
- (UIFont *)waiverSectionTitleFont;

- (UIColor *)waiverDisplayTextColor;
- (UIFont *)waiverDisplayTextFont;

- (UIColor *)waiverResponseButtonBackgroundColor;
- (UIColor *)waiverResponseButtonBorderColor;
- (UIColor *)waiverResponseButtonTextColor;
- (UIFont *)waiverResponseButtonTitleFont;

#pragma mark - Expenses

- (UIColor *)expenseEntriesTableBackgroundColor;

#pragma mark - AddPunchController

- (UIColor *)separatorViewBackgroundColor;
- (UIColor *)datePickerBackgroundColor;

#pragma mark - Schedules

- (UIColor *)shiftUnassignedTextColor;
- (UIColor *)shiftWorkBreakHoursTextColor;
- (UIColor *)shiftNotesFromManagerHeaderTextColor;
- (UIColor *)shiftCellsTextColor;
- (UIColor *)shiftTimeOffNotSubmittedStatusColor;
- (UIFont *)shiftCellsBoldFont;
- (UIFont *)shiftCellsLightFont;
- (UIFont *)shiftCellsBoldSmallFont;
- (UIFont *)shiftCellsLightBigFont;
- (UIFont *)shiftCellStatusFont;


#pragma mark - Tab Bar

- (UIColor *)tabBarTintColor;

#pragma mark - Offline Banner

- (UIColor *)offlineBannerBackgroundColor;
- (UIColor *)offlineBannerTextColor;
- (UIFont *)offlineBannerFont;

#pragma mark - Error Banner

- (UIColor *)errorBannerBackgroundColor;
- (UIColor *)errorBannerCountTextColor;
- (UIFont *)errorBannerCountFont;
- (UIColor *)errorBannerDateTextColor;
- (UIFont *)errorBannerDateFont;

#pragma mark - Error Details

- (UIColor *)errorDetailsBackgroundColor;
- (UIColor *)errorDetailsTextColor;
- (UIFont *)errorDetailsFont;
- (UIColor *)errorDetailsHeaderTextColor;
- (UIFont *)errorDetailsHeaderFont;
- (UIColor *)errorDetailsCellShadowColor;

#pragma mark - Timeoff

- (UIColor *)timeOffDayRangeColor;

#pragma mark - GrossPayController

- (UIFont *)grossPayFont;
- (UIFont *)grossPayHeaderFont;
- (UIColor *)grossPayTextColor;
- (UIColor *)grossPaySeparatorBackgroundColor;

#pragma mark - GrossPayLegends

- (UIFont *)legendsGrossPayFont;
- (UIFont *)legendsGrossPayHeaderFont;

#pragma mark Last Update time for legends
- (UIFont *)lastUpdateTimeFont;

#pragma mark - ApprovalsCommentsController

- (UIColor *)rejectButtonColor;
- (UIColor *)approvalPlaceholderTextColor;
- (UIFont *)approvalPlaceholderTextFont;


#pragma mark - Spinner

- (UIColor *)spinnerColor;

#pragma mark - Supervisor Clocked In Employee Chart

- (UIColor *)plotBarColor;
- (UIFont *)plotLabelFont;
- (UIColor *)plotLabelTextColor;
- (UIColor *)plotHorizontalLineColor;
- (UIFont *)plotNoCheckinsLabelFont;

#pragma mark - Audit Trail

- (UIFont *)auditTrailLogLabelFont;
- (UIColor *)auditTrailLogLabelTextColor;

- (UIFont *)auditTrailTitleLabelFont;
- (UIColor *)auditTrailTitleLabelTextColor;

#pragma mark - Attendance screens

- (UIColor *)punchConfirmationHeaderBackgroundColor;
- (UIColor *)clockedInLabelColor;
- (UIColor *)clockedOutLabelColor;
- (UIColor *)clockingInLabelColor;
- (UIColor *)clockingOutLabelColor;
- (UIColor *)punchConfirmationLightTextColor;
- (UIColor *)punchConfirmationDarkTextColor;

#pragma mark - Approvals screens

- (UIColor *)approvalHeaderLightTextColor;
- (UIColor *)approvalsRejectButtonColor;
- (UIColor *)approvalsApproveButtonColor;
- (UIColor *)standardButtonBorderColor;

#pragma mark - Settings screen

- (UIColor *)logoutButtonTitleColor;
- (UIColor *)sendFeedbackButtonTitleColor;
- (UIFont *)debugLabelFont;
- (UIColor *)debugLabelColor;
- (UIColor *)nodeJSTitleColor;

#pragma mark - Previous Approvals Button Controller

- (UIColor *)viewPreviousApprovalsButtonBorderColor;
- (UIColor *)viewPreviousApprovalsButtonTitleColor;
- (UIColor *)viewPreviousApprovalsButtonBackgroundColor;

#pragma mark - ForgotPasswordViewController

- (UIFont *)resetPasswordButtonTitleFont;
- (UIColor *)resetPasswordButtonTitleColor;
- (CGColorRef)forgotPasswordContainerBorderColor;

#pragma mark - Camera View Controller

-(UIColor *)titleLabelColor;
-(UIColor *)subTitleLabelColor;
-(UIFont *)titleLabelFont;
-(UIFont *)subTitleLabelFont;

-(UIColor *)cancelButtonBackgroundColor;
-(UIColor *)useButtonBackgroundColor;
-(UIColor *)retakeButtonBackgroundColor;
-(UIColor *)cameraButtonBackgroundColor;

#pragma mark - CarouselViewController

-(CGFloat)carouselPunchCardCornerRadius;
-(CGColorRef)carouselPunchCardContainerBorderColor;
-(CGFloat)carouselPunchCardContainerBorderWidth;
-(UIColor *)pageControlSelectedDotColor;
-(UIColor *)pageControlUnselectedDotColor;
-(UIColor *)pageControlBackgroundColor;


#pragma mark - PunchCardController

-(UIColor *)createPunchCardButtonBackgroundColor;
-(UIFont *)createPunchCardButtonFont;
-(UIColor *)createPunchCardButtonTitleColor;
-(CGFloat)createPunchCardCornerRadius;
-(CGFloat)createPunchCardBorderWidth;
-(CGColorRef)createPunchCardBorderColor;

-(UIColor *)clockInPunchCardButtonBackgroundColor;
-(UIFont *)clockInPunchCardButtonFont;
-(UIColor *)clockInPunchCardButtonTitleColor;
-(CGFloat)clockInPunchCardCornerRadius;
-(CGFloat)clockInPunchCardBorderWidth;
-(CGColorRef)clockInPunchCardBorderColor;

-(UIFont *)selectionCellValueFont;
-(UIFont *)selectionCellFont;
-(UIColor *)selectionCellNameFontColor;
-(UIColor *)selectionCellValueFontColor;
-(UIColor *)selectionCellValueDisabledFontColor;
-(UIColor *)transparentBackgroundColor;

#pragma mark - SelectionController

-(UIFont *)cellFont;

#pragma mark - ProjectPunchController

-(UIFont *)punchAttributeRegularFont;
-(UIFont *)punchAttributeLightFont;
-(UIColor *)punchAttributeLabelColor;
-(UIFont *)addressSmallSizedLabelFont;
-(UIFont *)punchedSinceSmallSizedLabelFont;

#pragma mark - ProjectPunchBreakController

- (UIColor *)timesheetWorkHoursNewBigFontColor;
-(UIFont *)breakLabelFont;
-(UIColor *)breakLabelColor;
-(UIColor *)onBreakAddressLabelContainerBackgroundColor;

#pragma mark - PunchAttributeController

-(UIFont *)attributeTitleLabelFont;
-(UIColor *)attributeTitleLabelColor;

-(UIFont *)attributeValueLabelFont;
-(UIColor *)attributeValueLabelColor;
-(UIColor *)attributeDisabledValueLabelColor;


#pragma mark - AllPunchCardController

-(UIFont *)allPunchCardTitleLabelFont;
-(UIFont *)allPunchCardDescriptionLabelFont;
-(UIColor *)allPunchCardDescriptionLabelFontColor;
-(UIColor *)punchButtonColor;
-(UIColor *)punchButtonTitleColor;
-(CGFloat )punchStateButtonCornerRadius;
-(UIColor *)allPunchCardTitleLabelFontColor;
-(UIColor *)transferCardListContainerButtonColor;

#pragma mark - TransferPunchCardController

-(UIFont *)transferPunchButtonTitleLabelFont;
-(CGFloat)transferPunchButtonCornerRadius;
-(CGColorRef)transferPunchButtonBorderColor;
-(CGFloat)transferPunchButtonBorderWidth;
-(UIColor *)transferPunchButtonTitleColor;
-(UIColor *)transferPunchButtonButtonColor;

-(UIFont *)transferCardSelectionCellNameFont;
-(UIFont *)transferCardSelectionCellValueFont;
-(UIColor *)transferCardSelectionCellValueFontColor;
-(UIColor *)transferCardSelectionCellNameFontColor;
-(UIColor *)transferCardSelectionCellValueDisabledFontColor;

#pragma mark - WelcomeView
- (UIFont *)SignInButtonTitleLabelFont;
- (UIColor *)signInButtonTitleColor;
- (UIColor *)welcomeViewSlideTitleColor;
- (UIColor *)welcomeViewSlideDetailColor;
- (UIFont *)welcomeViewSlideDetailFont;
- (UIFont *)welcomeViewSlideTitleFont;
- (UIColor *)welcomepageCurrentPageTintColor;
- (UIColor *)welcomepageCurrentPageControlColor;
- (UIColor *)welcomeViewBGColor;
- (CGFloat)signInButtonCornerRadius;

#pragma mark - Punch Presenter

- (UIFont *)descriptionLabelBoldFont;
- (UIFont *)descriptionLabelLighterFont;

#pragma mark - OEF Card View

- (UIColor *)oefCardPunchOutButtonBorderColor;
- (UIColor *)oefCardCancelButtonTitleColor;
- (UIColor *)oefCardCancelButtonBackgroundColor;
- (UIColor *)oefCardWindowBackgroundColor;
- (UIColor *)oefCardParentViewBackgroundColor;
- (UIColor *)oefCardScrollViewBackgroundColor;
- (UIColor *)oefCardContainerViewBackgroundColor;
- (CGFloat)oefPunchCardCornerRadius;
- (CGColorRef)oefPunchCardContainerBorderColor;
- (CGFloat)oefPunchCardContainerBorderWidth;
-(UIColor *)transferOEFCardButtonBackgroundColor;
-(UIFont *)transferOEFCardButtonFont;
-(UIColor *)transferOEFCardButtonTitleColor;
-(CGFloat)transferOEFCardCornerRadius;
-(CGFloat)transferOEFCardBorderWidth;
-(UIColor *)transferOEFCardBorderColor;
-(UIColor *)oefCardResumeWorkButtonBackgroundColor;
-(UIFont *)oefCardResumeWorkButtonFont;
-(UIColor *)oefCardResumeWorkButtonTitleColor;
-(CGFloat)oefCardResumeWorkButtonCornerRadius;
-(CGFloat)oefCardResumeWorkButtonBorderWidth;
-(UIColor *)oefCardResumeWorkButtonBorderColor;
- (UIColor *)oefCardTableCellBackgroundColor;
- (UIColor *)oefCardBackGroundViewColor;
#pragma mark - Punch Card View

-(UIColor *)punchCardTableViewParentViewBackgroundColor;
-(UIColor *)punchCardTableViewCellBackgroundColor;
-(CGFloat)punchCardTableViewCellCornerRadius;
-(CGFloat)punchCardTableViewCellBorderWidth;
-(UIColor *)punchCardTableViewCellBorderColor;
-(UIColor *)punchCardTableViewBackgroundColor;
-(UIColor *)punchCardTableHeaderViewBackgroundColor;
-(UIFont *)punchCardTableHeaderViewLabelFont;

#pragma mark - Bookmarks View
- (UIColor *)noBookmarksLabelTitleTextColor;
- (UIColor *)noBookmarksLabelDescriptionTextColor;
- (UIFont *)noBookmarksLabelTitleTextFont;
- (UIFont *)noBookmarksLabelDescriptionFont;
- (UIColor *)plusSignColor;


#pragma mark - Timesheet Status Colors

-(UIColor *)approvedColor;
-(UIColor *)rejectedColor;
-(UIColor *)waitingForApprovalColor;
-(UIColor *)notSubmittedColor;

-(UIColor *)approvedButtonBorderColor;
-(UIColor *)rejectedButtonBorderColor;
-(UIColor *)waitingForApprovalButtonBorderColor;
-(UIColor *)notSubmittedButtonBorderColor;


-(UIColor *)issuesButtonDefaultTitleOrBorderColor;
-(UIColor *)timesheetStatusButtonDefaultTitleOrBorderColor;
-(UIColor *)issuesCountColor;
-(UIColor *)issuesButtonWhenFoundTitleOrBorderColor;

#pragma mark - Timesheet Status Font
- (UIFont *)timesheetIssuesCountLabelFont;
- (UIFont *)timesheetViolationsLabelFont;
- (UIFont *)timesheetStatusLabelFont;


#pragma mark - Timesheet Duration
- (UIFont *)timeDurationNameLabelFont;
- (UIFont *)timeDurationValueLabelFont;
- (UIColor *)breakTimeDurationColor;
- (UIColor *)timeOffTimeDurationColor;
- (UIColor *)workTimeDurationColor;

#pragma mark - Punch empty State

- (UIFont *)punchEmptyStateFirstLineFont;
- (UIFont *)punchEmptyStateSecondLineFont;
- (UIColor *)punchEmptyStateFirstLineColor;
- (UIColor *)punchEmptyStateSecondLineColor;


@end
