#import <CoreGraphics/CoreGraphics.h>
#import "DefaultTheme.h"
#import "Util.h"


static NSString *const RepliconLightFontName = @"OpenSans-Light";
static NSString *const RepliconRegularFontName = @"OpenSans";
static NSString *const RepliconBoldFontName = @"OpenSans-Semibold";

@implementation DefaultTheme

#pragma mark - <Theme>

- (UIColor *)punchInColor
{
    return [self mountainMeadowColor];
}

- (CGColorRef)punchInButtonBorderColor
{
    return [[self salemColor] CGColor];
}

- (CGFloat)punchInButtonBorderWidth
{
    return 1.0f;
}

- (UIFont *)punchInButtonTitleFont
{
    return [self repliconBoldFontOfSize:20.0f];
}

- (UIColor *)punchInButtonTitleColor
{
    return [self lightTextOnDarkBackgroundColor];
}

- (UIColor *)takeBreakButtonTitleColor
{
    return [self carrotOrangeColor];
}

- (UIColor *)takeBreakButtonBorderColor
{
    return [UIColor clearColor];
}

- (UIColor *)punchOutAddressLabelContainerBackgroundColor
{
    return [self shadyMountainMeadowColor];
}

- (UIFont *)addressLabelFont
{
    return [self repliconRegularFontOfSize:12.0f];
}

- (UIColor *)addressLabelTextColor
{
    return [self lightTextOnDarkBackgroundColor];
}

- (UIFont *)punchedSinceLabelFont
{
    return [self repliconBoldFontOfSize:28.0f];
}

- (UIColor *)punchedSinceLabelTextColor
{
    return [self lightTextOnDarkBackgroundColor];
}

- (UIColor *)onBreakBackgroundColor
{
    return [self carrotOrangeColor];
}

- (UIColor *)onBreakClockOutButtonTitleColor
{
    return [self persimmonColor];
}

- (UIColor *)onBreakClockOutButtonBackgroundColor
{
    return [self lightButtonBackgroundColor];
}

- (UIColor *)timesheetBreakHoursNewBigFontColor
{
    return [self geebungColor];
}

- (UIColor *)resumeWorkButtonTitleColor
{
    return [self mountainMeadowColor];
}

- (UIColor *)resumeWorkButtonBackgroundColor
{
    return [self lightButtonBackgroundColor];
}

- (UIColor *)punchOutButtonBackgroundColor
{
    return [self lightButtonBackgroundColor];
}

- (UIColor *)punchOutButtonBorderColor
{
    return [UIColor clearColor];
}

- (UIColor *)takeBreakButtonBackgroundColor
{
    return [self lightButtonBackgroundColor];
}

- (UIColor *)supervisorDashboardBackgroundColor
{
    return [self galleryColor];
}

- (UIColor *)supervisorTimesheetDetailsControllerBackGroundColor
{
    return [self galleryColor];
}
- (UIColor *)supervisorTimesheetDetailsControllerSummaryCardBackGroundColor
{
    return [self whiteColor];
}

- (UIColor *)transparentColor
{
    return [UIColor clearColor];
}

- (UIColor *)transferButtonTitleColor
{
    return [self mountainMeadowColor];
}

- (UIColor *)transferButtonBackgroundColor
{
    return [self lightButtonBackgroundColor];
}

- (UIColor *)defaultleftBarButtonColor
{
    return [self repliconBlueColor];
}

#pragma mark - Supervisor Team Timesheets

- (UIColor *)timesheetUsersTableViewHeaderColor
{
    return [self galleryColor];
}

- (UIFont *)timesheetUsersTableViewHeaderFont
{
    return [self repliconLightFontOfSize:12.0f];
}

- (UIFont *)timesheetUserNameFont
{
    return [self repliconRegularFontOfSize:12.0f];
}

- (UIFont *)timesheetUserWorkHoursFont
{
    return [self repliconRegularFontOfSize:14.0f];
}

- (UIFont *)timesheetUserBreakHoursFont
{
    return [self repliconRegularFontOfSize:10.0f];
}

- (UIColor *)timesheetUserBreakHoursColor
{
    return [self dustyGrayColor];
}

- (UIColor *)timesheetUserOvertimeAndViolationsColor
{
    return [self persimmonColor];
}

- (UIFont *)supervisorTeamTimesheetsSectionHeaderFont
{
    return [self repliconLightFontOfSize:10.0f];
}

- (UIColor *)supervisorTeamTimesheetsSectionFontColor
{
    return [self doveGrayColor];
}


#pragma mark - Time Summary

- (UIColor *)childControllerDefaultBackgroundColor
{
    return [self alabasterColor];
}

- (UIFont *)timeCardSummaryDateTextFont
{
    return [self repliconRegularFontOfSize:17.0f];
}

-(UIColor *)timeCardSummaryBackgroundColor
{
    return [self transparentColor];
}

-(UIColor *)timeCardSummaryDateTextColor
{
    return [self blackColor];
}

- (UIColor *)timeCardSummaryRegularTimeTextColor
{
    return [self mountainMeadowColor];
}

- (UIColor *)timeCardSummaryOverTimeTextColor
{
    return [self silverColor];
}

- (UIFont *)timeCardSummaryRegularTimeTextFont
{
    return [self repliconRegularFontOfSize:22.0f];
}

- (UIColor *)timeCardSummaryTimeDescriptionTextColor
{
    return [self blackColor];
}

- (UIFont *)timeCardSummaryTimeDescriptionTextFont
{
    return [self repliconRegularFontOfSize:11.0f];
}

- (UIColor *)timeCardSummaryOnBreakTimeTextColor
{
    return [self carrotOrangeColor];
}

#pragma mark - Timesheet Breakdown

- (UIColor *)timesheetBreakdownBackgroundColor
{
    return [self alabasterColor];
}

- (UIColor *)timesheetBreakdownRegularTimeTextColor
{
    return [self primaryGrayColor];
}

- (UIColor *)timesheetBreakdownBreakTimeTextColor
{
    return [self primaryGrayColor];
}

- (UIFont *)timesheetBreakdownTimeFont
{
    return [self repliconRegularFontOfSize:12];
}

- (UIFont *)timesheetRegularTimeFont
{
    return [self repliconRegularFontOfSize:22.0f];
}

- (UIFont *)timesheetBreakdownDateFont
{
    return [self repliconBoldFontOfSize:15.0f];
}

- (UIColor *)timesheetBreakdownSeparatorColor
{
    return [self silverColor];
}

- (UIColor *)timesheetWorkHoursNewBigFontColor
{
    return [UIColor colorWithRed:42/215.0 green:172/215.0 blue:93/215.0 alpha:1.0];
}

- (UIFont *)timesheetBreakdownViolationCountFont
{
    return [self repliconBoldFontOfSize:11.0f];
}

- (UIColor *)timesheetBreakdownViolationCountColor
{
    return [self whiteColor];
}

- (UIFont *)timesheetWidgetTitleFont
{
    return [self repliconBoldFontOfSize:18.0f];
}

- (UIFont *)timesheetNoticeWidgetDescriptionFont
{
    return [self repliconRegularFontOfSize:15.0f];
}

- (UIColor *)timesheetWidgetTitleTextColor
{
    return [self primaryGrayColor];
}

- (UIColor *)attestationSwitchColor
{
    return [self mountainMeadowColor];
}

#pragma mark - UISegmentedControl
- (UIColor *)segmentedControlTintColor
{
    return [self lochmaraColor];
}

- (UIColor *)segmentedControlTextColor
{
    return [self lochmaraColor];
}

- (UIFont *)segmentedControlFont
{
    return [self repliconRegularFontOfSize:12.0f];
}

#pragma mark - UIButtons

- (UIColor *)regularButtonTitleColor
{
    return [self denimColor];
}

- (UIColor *)regularButtonBackgroundColor
{
    return [self lightButtonBackgroundColor];
}

- (UIColor *)regularButtonBorderColor
{
    return [self silverColor];
}

- (UIFont *)regularButtonFont
{
    return [self repliconBoldFontOfSize:16.0f];
}

- (UIColor *)destructiveButtonTitleColor
{
    return [self persimmonColor];
}

#pragma mark - Card Container

- (CGColorRef)cardContainerBorderColor
{
    return [[self mercuryColor] CGColor];
}

- (CGFloat)cardContainerBorderWidth
{
    return 0.5f;
}

- (UIFont *)cardContainerHeaderFont
{
    return [self repliconRegularFontOfSize:14];
}

- (UIColor *)cardContainerHeaderColor
{
    return [self blackColor];
}

- (UIColor *)cardContainerSeparatorColor
{
    return [self silverColor];
}

- (UIColor *)cardContainerBackgroundColor
{
    return [self whiteColor];
}

#pragma mark - Supervisor Inbox

- (UIFont *)inboxRowFont {
    return [self repliconRegularFontOfSize:12];
}

#pragma mark - Employee Status

- (UIFont *)teamStatusTitleFont
{
    return [self repliconRegularFontOfSize:12];
}

- (UIColor *)teamStatusTitleColor
{
    return [self blackColor];
}

- (UIFont *)teamStatusValueFont
{
    return [self repliconRegularFontOfSize:16];
}

- (UIColor *)teamStatusInColor
{
    return [self mountainMeadowColor];
}

- (UIColor *)teamStatusOutColor
{
    return [self silverColor];
}

- (UIColor *)teamStatusBreakColor
{
    return [self buttercupColor];
}

- (UIColor *)userSummaryCellBackgroundColor
{
    return [self whiteColor];
}

- (UIFont *)userSummaryCellNameFont
{
    return [self repliconRegularFontOfSize:12];
}

- (UIColor *)userSummaryCellNameColor
{
    return [self mineShaftColor];
}

- (UIFont *)userSummaryCellDetailsFont
{
    return [self repliconRegularFontOfSize:10];
}

- (UIColor *)userSummaryCellDetailsColor
{
    return [self dustyGrayColor];
}

- (UIFont *)userSummaryCellHoursFont
{
    return [self repliconRegularFontOfSize:14];
}

- (UIColor *)userSummaryCellHoursColor
{
    return [self mineShaftColor];
}

- (UIColor *)userSummaryCellHoursInactiveColor
{
    return [self dustyGrayColor];
}

#pragma - Violations

- (UIFont *)violationsCellTitleFont
{
    return [self repliconBoldFontOfSize:12];
}

- (UIColor *)violationsCellTitleTextColor
{
    return [self mineShaftColor];
}

- (UIFont *)violationsCellTimeAndStatusFont
{
    return [self repliconRegularFontOfSize:10];
}

- (UIColor *)violationsCellTimeAndStatusTextColor
{
    return [self dustyGrayColor];
}

- (UIColor *)violationsButtonTitleColor
{
    return [UIColor whiteColor];
}

- (UIColor *)violationsButtonBackgroundColor
{
    return [self persimmonColor];
}

- (UIColor *)violationsButtonBorderColor
{
    return [self mandyColor];
}

#pragma mark - Delete Punch

- (UIColor *)deletePunchButtonBackgroundColor
{
    return [self whiteColor];
}

- (UIColor *)deletePunchButtonBorderColor
{
    return [self silverColor];
}

- (UIColor *)deletePunchButtonTitleColor
{
    return [self persimmonColor];
}

#pragma mark - Team Status

- (UIFont *)teamStatusCellNoUsersFont
{
    return [self repliconRegularFontOfSize:12];
}

- (UIColor *)teamStatusCellNoUsersColor
{
    return [self mineShaftColor];
}

- (UIFont *)teamTableViewSectionHeaderFont
{
    return [self repliconRegularFontOfSize:14];
}

- (UIColor *)teamTableViewSectionHeaderTextColor
{
    return  [self dustyGrayColor];
}

- (UIColor *)teamTableViewSectionHeaderBackgroundColor
{
    return [self galleryColor];
}

- (UIColor *)teamStatusTableFooterBackgroundColor
{
    return [self galleryColor];
}

#pragma mark - Timeline

- (UIFont *)timeLineCellTimeLabelFont
{
    return [self repliconRegularFontOfSize:15.0f];
}

- (UIFont *)timeLineCellDescriptionLabelFont
{
    return [self repliconRegularFontOfSize:15.0f];
}

- (UIColor *)timeLineCellTimeLabelTextColor
{
    return [self darkTextOnLightBackgroundColor];
}

- (UIColor *)newTimeLineCellTimeLabelTextColor
{
    return [self lightTimeLineTimeColor];
}

- (UIColor *)timeLineCellDescriptionLabelTextColor
{
    return [self darkTextOnLightBackgroundColor];
}

- (UIColor *)timeLineCellVerticalLineColor
{
    return [self silverColor];
}

- (UIColor *)addPunchButtonBackgroundColor
{
    return [self lochmaraColor];
}

- (UIColor *)addPunchButtonTitleColor
{
    return [self whiteColor];
}

- (UIColor *)addPunchButtonBorderColor
{
    return [UIColor clearColor];
}

- (UIFont *)actualPunchTimeFont
{
    return [self repliconBoldFontOfSize:14];
}

- (UIFont *)timeLineMetaDataBolderFont
{
    return [self repliconBoldFontOfSize:17];
}

- (UIFont *)punchDurationFont
{
    return [self repliconLightFontOfSize:17];
}

- (UIFont *)punchDataFont
{
    return [self repliconLightFontOfSize:12];
}

- (UIFont *)violationCountFont
{
    return [self repliconBoldFontOfSize:13];
}

- (UIFont *)timeLinePunchTypeTexFont
{
    return [self repliconBoldFontOfSize:17];
}


- (UIColor *)actualPunchTimeTextColor
{
    return [self primaryGrayColor];
}

- (UIColor *)timeLinePunchTypeTextColor
{
    return [self primaryGrayColor];
}

- (UIColor *)punchDurationTextColor
{
    return [self primaryGrayColor];
}

- (UIColor *)punchDataTextColor
{
    return [self primaryGrayColor];
}

- (UIColor *)violationCountHighlightedTextColor
{
    return [UIColor whiteColor];
}

- (UIFont *)timeLineMetadataFont
{
    return [self repliconLightFontOfSize:12];
}
- (UIColor *)timeLineMetadataTextColor
{
    return [self primaryGrayColor];
}

- (UIColor *)timelineSelectedCellColor
{
    return  [Util colorWithHex:@"#F2F2F2" alpha:1.0f];
}

#pragma mark - Timesheet Button Controller

- (UIColor *)viewTimesheetButtonBorderColor
{
    return [self silverColor];
}

- (UIColor *)viewTimesheetButtonTitleColor
{
    return [self denimColor];
}

- (UIColor *)viewTimesheetButtonBackgroundColor
{
    return [self lightButtonBackgroundColor];
}



#pragma mark - Timesheet Details

- (UIFont *)timesheetDetailDateRangeFont
{
    return [self repliconBoldFontOfSize:18];
}

- (UIFont *)timesheetDetailCurrentPeriodFont
{
    return [self repliconLightFontOfSize:15];
}

- (UIColor *)timesheetDetailsBackgroundColor
{
    return [self galleryColor];
}

- (UIColor *)timesheetDetailsBorderColor
{
    return [self silverColor];
}

- (UIColor *)timesheetDetailCurrentPeriodTextColor
{
    return [self primaryGrayColor];
}

- (UIColor *)timesheetDetailDateRangeTextColor
{
    return [self primaryGrayColor];
}

#pragma mark - Duration Label

- (UIColor *)durationLabelTextColor
{
    return [self lightTextOnDarkBackgroundColor];
}

- (UIFont *)durationLabelBigNumberFont
{
    return [UIFont fontWithName:RepliconLightFontName size:30.0f];
}

- (UIFont *)durationLabelLittleNumberFont
{
    return [UIFont fontWithName:RepliconBoldFontName size:30.0f];
}

- (UIFont *)clientLabelLittleNumberFont
{
    return [UIFont fontWithName:RepliconBoldFontName size:15.0f];
}

- (UIFont *)durationLabelBigTimeUnitFont
{
    return [UIFont fontWithName:RepliconLightFontName size:30.0f];
}

- (UIFont *)durationLabelLittleTimeUnitFont
{
    return [UIFont fontWithName:RepliconBoldFontName size:30.0f];
}
- (UIFont *)durationLabelLittleTimeUnitBigFont
{
    return [UIFont fontWithName:RepliconBoldFontName size:36.0f];
}
#pragma mark - Navigation Bar

- (UIColor *)navigationBarBackgroundColor
{
    return [self wildSandColor];
}

- (UIColor *)navigationBarTintColor
{
    return [self lochmaraColor];
}

- (UIFont *)navigationBarTitleFont
{
    return [self repliconRegularFontOfSize:17];
}

#pragma mark - UITableViews

- (UIFont *)defaultTableViewCellFont
{
    return [self repliconRegularFontOfSize:14];
}

- (UIColor *)defaultTableViewSecondRowTextColor
{
    return [self dustyGrayColor];
}

- (UIColor *)defaultTableViewHeaderBackgroundColor
{
    return [self silverColor];
}

- (UIFont *)defaultTableViewHeaderButtonFont
{
    return [self repliconRegularFontOfSize:15.0f];
}

- (UIColor *)defaultTableViewSeparatorColor
{
    return [self altoColor];
}

#pragma mark - Search TextFields

- (UIFont *)searchTextFieldFont
{
    return [self repliconLightFontOfSize:16];
}

- (UIColor *)searchTextFieldBackgroundColor
{
    return [self whiteColor];
}

#pragma mark - DayController

- (UIColor *)dayControllerBackgroundColor
{

    return [self whiteColor];
}

- (UIColor *)dayControllerBorderColor
{
    return [self silverColor];
}

#pragma mark - AddPunchController

- (UIColor *)separatorViewBackgroundColor
{
    return [self silverColor];
}

- (UIColor *)datePickerBackgroundColor
{
    return [self whiteColor];
}

#pragma mark - PunchOverViewController

- (UIColor *)punchOverviewBackgroundColor
{
    return [self galleryColor];
}

#pragma mark - PunchDetailsController

- (UIColor *)punchDetailsBorderLineColor
{
    return [self silverColor];
}

- (UIColor *)punchDetailsContentViewBackgroundColor
{
    return [self whiteColor];
}

- (UIFont *)punchDetailsAddressLabelFont
{
    return [self repliconRegularFontOfSize:12.0f];
}

- (UIColor *)punchDetailsAddressLabelTextColor
{
    return [self mineShaftColor];
}

#pragma mark - ApprovalStatus labels

- (UIColor *)approvalStatusNotSubmittedColor
{
    return [self grayColor];
}

- (UIColor *)approvalStatusWaitingForApprovalColor
{
    return [self buttercupColor];
}

- (UIColor *)approvalStatusRejectedColor
{
    return [self persimmonColor];
}

- (UIColor *)approvalStatusTimesheetNotApprovedColor
{
    return [self grayColor];
}

- (UIColor *)approvalStatusDefaultColor
{
    return [self mountainMeadowColor];
}

#pragma mark - MultiDayTimeOff Status

- (UIColor *)timeOffStatusWaitingForApprovalColor {
    return [Util colorWithHex:@"#FCC58D" alpha:1.0f];
}

- (UIColor *)timeOffStatusApprovedColor {
    return [Util colorWithHex:@"#86BC3B" alpha:1.0f];
}

- (UIColor *)timeOffStatusRejectedColor {
    return [Util colorWithHex:@"#F4694B" alpha:1.0f];
}


#pragma mark - Waivers

- (UIColor *)waiverBackgroundColor
{
    return [self galleryColor];
}

- (UIColor *)waiverSectionTitleTextColor
{
    return [self dustyGrayColor];
}

- (UIFont *)waiverSectionTitleFont
{
    return [self repliconRegularFontOfSize:14];
}

- (UIColor *)waiverSeparatorColor
{
    return [self silverColor];
}

- (UIColor *)waiverViolationTitleTextColor
{
    return [self blackColor];
}

- (UIFont *)waiverViolationTitleFont
{
    return [self repliconRegularFontOfSize:14];
}

- (UIColor *)waiverDisplayTextColor
{
    return [self dustyGrayColor];
}

- (UIFont *)waiverDisplayTextFont
{
    return [self repliconRegularFontOfSize:12];
}

- (UIColor *)waiverResponseButtonBackgroundColor
{
    return [self wildSandColor];
}

- (UIColor *)waiverResponseButtonBorderColor
{
    return [self silverColor];
}

- (UIColor *)waiverResponseButtonTextColor
{
    return [self grayColor];
}

- (UIFont *)waiverResponseButtonTitleFont
{
    return [self repliconRegularFontOfSize:13.0f];
}

#pragma mark - Expenses

- (UIColor *)expenseEntriesTableBackgroundColor
{
    return [self galleryColor];
}

#pragma mark - Shifts

- (UIColor *)shiftUnassignedTextColor
{
    return [self dustyGrayColor];
}

- (UIColor *)shiftWorkBreakHoursTextColor
{
    return [self dustyGrayColor];
}

- (UIColor *)shiftNotesFromManagerHeaderTextColor
{
    return [self dustyGrayColor];
}

- (UIColor *)shiftCellsTextColor
{
    return [Util colorWithHex:@"#3D4552" alpha:1.0];
}

- (UIColor *)shiftTimeOffNotSubmittedStatusColor
{
    return [self mineShaftColor];
}
- (UIFont *)shiftCellsBoldFont
{
    return [self repliconBoldFontOfSize:18];
}

- (UIFont *)shiftCellsLightFont
{
     return [self repliconLightFontOfSize:14];
}

- (UIFont *)shiftCellsBoldSmallFont
{
    return [self repliconBoldFontOfSize:14];
}

- (UIFont *)shiftCellsLightBigFont
{
    return [self repliconLightFontOfSize:18];
}

- (UIFont *)shiftCellStatusFont
{
    return [self repliconBoldFontOfSize:14];
}
#pragma mark - Tab Bar

- (UIColor *)tabBarTintColor
{
    return [Util colorWithHex:@"#007AC9" alpha:1.0];
}

#pragma mark - Offline Banner

- (UIColor *)offlineBannerBackgroundColor
{
    return [self tundoraColor];
}

- (UIColor *)offlineBannerTextColor
{
    return [self whiteColor];
}

- (UIFont *)offlineBannerFont
{
    return [self repliconBoldFontOfSize:10.0f];
}

#pragma mark - Error Banner

- (UIColor *)errorBannerBackgroundColor
{
    return [Util colorWithHex:@"#3e5f6d" alpha:1.0f];
}

- (UIColor *)errorBannerCountTextColor
{
    return [Util colorWithHex:@"#FFFFFF" alpha:1.0f];
}

- (UIFont *)errorBannerCountFont
{
    return [self repliconBoldFontOfSize:18.0f];
}

- (UIColor *)errorBannerDateTextColor
{
    return [Util colorWithHex:@"#FFFFFF" alpha:1.0f];
}

- (UIFont *)errorBannerDateFont
{
    return [self repliconRegularFontOfSize:12.0f];
}

#pragma mark - Error Details

- (UIColor *)errorDetailsBackgroundColor
{
   return [self mercuryColor];
}

- (UIColor *)errorDetailsTextColor
{
   return [Util colorWithHex:@"#A2A2A2" alpha:1.0f];
}

- (UIFont *)errorDetailsFont
{
   return [self repliconRegularFontOfSize:15.0f];
}

- (UIColor *)errorDetailsHeaderTextColor
{
   return [Util colorWithHex:@"#171616" alpha:1.0f];
}

- (UIFont *)errorDetailsHeaderFont
{
   return [self repliconBoldFontOfSize:17.0f];
}

- (UIColor *)errorDetailsCellShadowColor
{
    return [Util colorWithHex:@"#000000" alpha:0.08f];
}

#pragma mark - Timeoff

- (UIColor *)timeOffDayRangeColor
{
    return [self dustyGrayColor];
}

#pragma mark - GrossPayController

- (UIFont *)grossPayFont
{
    return [self repliconBoldFontOfSize:32.0f];
}

- (UIFont *)grossPayHeaderFont
{
    return [self repliconRegularFontOfSize:17.0f];
}

- (UIColor *)grossPayTextColor
{
    return [Util colorWithHex:@"#324d5b" alpha:1.0f];
}

- (UIColor *)grossPaySeparatorBackgroundColor
{
    return [self altoColor];
}

#pragma mark - Legends fonts

- (UIFont *)legendsGrossPayFont
{
    return [self repliconBoldFontOfSize:18.0f];
}

- (UIFont *)legendsGrossPayHeaderFont
{
    return [self repliconRegularFontOfSize:10.0f];
}

#pragma mark Last Update time for legends

- (UIFont *)lastUpdateTimeFont
{
    return [self repliconRegularFontOfSize:12.0f];
}

#pragma mark - Spinner

- (UIColor *)spinnerColor
{
    return [self mineShaftColor];
}

#pragma mark - Supervisor Clocked In Employee Chart

- (UIColor *)plotBarColor
{
    return [self mountainMeadowColor];
}

- (UIFont *)plotLabelFont
{
    return [self repliconRegularFontOfSize:7.5f];
}

- (UIColor *)plotLabelTextColor
{
    return [self dustyGrayColor];

}

- (UIColor *)plotHorizontalLineColor
{
    return [self mercuryColor];
}

- (UIFont *)plotNoCheckinsLabelFont;
{
    return [self repliconRegularFontOfSize:16.0];
}

#pragma mark - ApprovalsCommentsController

- (UIColor *)rejectButtonColor
{
    return [self scarletColor];
}

- (UIColor *)approvalPlaceholderTextColor
{
    return [self dustyGrayColor];
}

- (UIFont *)approvalPlaceholderTextFont
{
    return [self repliconLightFontOfSize:16];
}

#pragma mark - Audit Trail

- (UIFont *)auditTrailLogLabelFont
{
    return [self repliconRegularFontOfSize:12.0f];
}

- (UIColor *)auditTrailLogLabelTextColor
{
    return [self mineShaftColor];
}

- (UIFont *)auditTrailTitleLabelFont
{
    return [self repliconRegularFontOfSize:12.0f];
}

- (UIColor *)auditTrailTitleLabelTextColor
{
    return [self mineShaftColor];
}

#pragma mark - Attendance screens

- (UIColor *)punchConfirmationHeaderBackgroundColor
{
    return [self alabasterColor];
}

- (UIColor *)clockedInLabelColor
{
    return [self mountainMeadowColor];
}

- (UIColor *)clockedOutLabelColor
{
    return [self persimmonColor];
}

- (UIColor *)clockingInLabelColor
{
    return [self dustyGrayColor];
}

- (UIColor *)clockingOutLabelColor
{
    return [self dustyGrayColor];
}

- (UIColor *)punchConfirmationLightTextColor
{
    return [self dustyGrayColor];
}

- (UIColor *)punchConfirmationDarkTextColor
{
    return [self doveGrayColor];
}

#pragma mark - Approvals screens

- (UIColor *)approvalHeaderLightTextColor
{
    return [self dustyGrayColor];
}

- (UIColor *)approvalsRejectButtonColor
{
    return [self persimmonColor];
}

- (UIColor *)approvalsApproveButtonColor
{
    return [self curiousBlueColor];
}

- (UIColor *)standardButtonBorderColor
{
    return [self silverColor];
}

#pragma mark - Settings screen

- (UIColor *)logoutButtonTitleColor
{
    return [self persimmonColor];
}

- (UIColor *)sendFeedbackButtonTitleColor
{
    return [self grayColor];
}

- (UIFont *)debugLabelFont
{
    return [self repliconLightFontOfSize:16.0];
}

- (UIColor *)debugLabelColor
{
    return [self blackColor];
}

- (UIColor *)nodeJSTitleColor
{
    return [self grayColor];
}


#pragma mark - Previous Approvals Button Controller

- (UIColor *)viewPreviousApprovalsButtonBorderColor
{
    return [self silverColor];
}

- (UIColor *)viewPreviousApprovalsButtonTitleColor
{
    return [self denimColor];
}

- (UIColor *)viewPreviousApprovalsButtonBackgroundColor
{
    return [self lightButtonBackgroundColor];
}

#pragma mark - ForgotPasswordViewController

- (UIFont *)resetPasswordButtonTitleFont
{
    return [self repliconRegularFontOfSize:20.0f];
}
- (UIColor *)resetPasswordButtonTitleColor
{
    return [self whiteColor];
}

- (CGColorRef)forgotPasswordContainerBorderColor
{
    return [UIColor lightGrayColor].CGColor;
}

#pragma mark - Camera View Controller

-(UIColor *)titleLabelColor
{
    return [self whiteColor];
}
-(UIColor *)subTitleLabelColor
{
    return [self whiteColor];
}
-(UIFont *)titleLabelFont
{
    return [self repliconBoldFontOfSize:18.0];
}
-(UIFont *)subTitleLabelFont
{
    return [self repliconRegularFontOfSize:14.0];
}

-(UIColor *)cancelButtonBackgroundColor
{
    return [self transparentColor];
}
-(UIColor *)useButtonBackgroundColor
{
    return [self transparentColor];
}
-(UIColor *)retakeButtonBackgroundColor
{
    return [self transparentColor];
}
-(UIColor *)cameraButtonBackgroundColor
{
    return [self transparentColor];
}

#pragma mark - CarouselViewController

-(CGFloat)carouselPunchCardCornerRadius
{
    return 8.0f;
}

- (CGColorRef)carouselPunchCardContainerBorderColor
{
    return [[self mercuryColor] CGColor];
}

-(CGFloat)carouselPunchCardContainerBorderWidth
{
    return 1.0f;
}

-(UIColor *)pageControlSelectedDotColor
{
    return [self doveGrayColor];
}

-(UIColor *)pageControlUnselectedDotColor
{
    return [self dustyGrayColor];
}

-(UIColor *)pageControlBackgroundColor
{
    return [self childControllerDefaultBackgroundColor];
}



#pragma mark - PunchCardController

-(UIColor *)createPunchCardButtonBackgroundColor
{
    return [UIColor clearColor];
}

-(UIFont *)createPunchCardButtonFont
{
    return [self repliconBoldFontOfSize:17.0f];

}
-(UIColor *)createPunchCardButtonTitleColor
{
    return [self denimColor];
}
-(CGFloat)createPunchCardCornerRadius
{
    return 20.0;
}
-(CGFloat)createPunchCardBorderWidth
{
    return 1.0f;
}
-(CGColorRef)createPunchCardBorderColor
{
    return [self silverColor].CGColor;
}

-(UIColor *)clockInPunchCardButtonBackgroundColor
{
    return [self mountainMeadowColor];
}
-(UIFont *)clockInPunchCardButtonFont
{
    return [self repliconBoldFontOfSize:17.0f];
}
-(UIColor *)clockInPunchCardButtonTitleColor
{
    return [self whiteColor];
}
-(CGFloat)clockInPunchCardCornerRadius
{
    return 20.0;
}
-(CGFloat)clockInPunchCardBorderWidth
{
    return 1.0f;
}
-(CGColorRef)clockInPunchCardBorderColor
{
    return [self silverColor].CGColor;
}

- (UIFont *)selectionCellValueFont
{
    return [UIFont fontWithName:RepliconLightFontName size:20.0f];
}

-(UIFont *)selectionCellFont
{
    return [self repliconRegularFontOfSize:14.0f];
}

-(UIColor *)selectionCellNameFontColor
{
    return [self dustyGrayColor];
}

-(UIColor *)selectionCellValueFontColor
{
    return [self denimColor];
}

-(UIColor *)selectionCellValueDisabledFontColor
{
    return [self silverColor];
}

-(UIColor *)transparentBackgroundColor
{
    return [self transparentColor];
}

#pragma mark - SelectionController

-(UIFont *)cellFont
{
    return [self repliconRegularFontOfSize:16.0f];
}

#pragma mark - ProjectPunchController

-(UIFont *)punchAttributeLightFont
{
    return [self repliconRegularFontOfSize:13.0f];
}
-(UIFont *)punchAttributeRegularFont
{
    return [self repliconBoldFontOfSize:24.0f];
}

-(UIColor *)punchAttributeLabelColor
{
    return [self lightTextOnDarkBackgroundColor];
}

- (UIFont *)addressSmallSizedLabelFont
{
    return [self repliconRegularFontOfSize:8.0f];
}
- (UIFont *)punchedSinceSmallSizedLabelFont
{
    return [self repliconBoldFontOfSize:12.0f];
}

#pragma mark - ProjectPunchBreakController

-(UIFont *)breakLabelFont
{
    return [self repliconBoldFontOfSize:28.0f];
}

-(UIColor *)breakLabelColor
{
    return [self lightTextOnDarkBackgroundColor];
}

-(UIColor *)onBreakAddressLabelContainerBackgroundColor
{
    return [self transparentBackgroundColor];
}

#pragma mark - PunchAttributeController

-(UIFont *)attributeTitleLabelFont
{
    return [self repliconRegularFontOfSize:13.0f];
}
-(UIColor *)attributeTitleLabelColor
{
    return [self doveGrayColor];
}
-(UIFont *)attributeValueLabelFont
{
    return [self repliconRegularFontOfSize:15.0f];
}
-(UIColor *)attributeValueLabelColor
{
    return [self blackColor];
}
-(UIColor *)attributeDisabledValueLabelColor
{
    return [self silverAltoColor];
}

#pragma mark - AllPunchCardController

-(UIFont *)allPunchCardTitleLabelFont
{
    return [self repliconBoldFontOfSize:17.0f];
}

-(UIFont *)allPunchCardDescriptionLabelFont
{
    return [self repliconRegularFontOfSize:13.0f];
}

-(UIColor *)allPunchCardTitleLabelFontColor
{
    return [self blackColor];
}

-(UIColor *)allPunchCardDescriptionLabelFontColor
{
    return [self dustyGrayColor];
}

- (UIColor *)punchButtonColor
{
    return [self mountainMeadowColor];
}

- (UIColor *)punchButtonTitleColor
{
    return [self lightTextOnDarkBackgroundColor];
}

- (CGFloat )punchStateButtonCornerRadius
{
    return 20.0f;
}

- (UIColor *)transferCardListContainerButtonColor
{
    return [UIColor clearColor];
}


#pragma mark - TransferPunchCardController

-(UIFont *)transferPunchButtonTitleLabelFont
{
    return [self repliconBoldFontOfSize:17.0f];
}

-(CGFloat)transferPunchButtonCornerRadius
{
    return 20.0;
}

- (CGColorRef)transferPunchButtonBorderColor
{
    return [self silverColor].CGColor;
}

- (CGFloat)transferPunchButtonBorderWidth
{
    return 1.0f;
}

- (UIColor *)transferPunchButtonTitleColor
{
    return [self whiteColor];
}

- (UIColor *)transferPunchButtonButtonColor
{
    return [self mountainMeadowColor];
}

- (UIFont *)transferCardSelectionCellNameFont
{
    return [UIFont fontWithName:RepliconLightFontName size:14.0f];
}

- (UIFont *)transferCardSelectionCellValueFont
{
    return [UIFont fontWithName:RepliconLightFontName size:20.0f];
}

-(UIColor *)transferCardSelectionCellValueFontColor
{
    return [self denimColor];
}

-(UIColor *)transferCardSelectionCellNameFontColor
{
    return [self dustyGrayColor];
}

-(UIColor *)transferCardSelectionCellValueDisabledFontColor
{
    return [self silverColor];
}

#pragma mark - WelcomeView

-(UIFont *)SignInButtonTitleLabelFont
{
    return [UIFont boldSystemFontOfSize:13.0f];
}

- (UIColor *)signInButtonTitleColor
{
    return [self lightTextOnDarkBackgroundColor];
}

- (UIFont *)welcomeViewSlideTitleFont
{
    return [UIFont fontWithName:RepliconLightFontName size:19.0f];
}

- (UIFont *)welcomeViewSlideDetailFont
{
    return [UIFont fontWithName:RepliconRegularFontName size:13.0f];
}

- (UIColor *)welcomeViewSlideTitleColor
{
    return [self tundoraColorText];
}

- (UIColor *)welcomeViewSlideDetailColor
{
    return [self tundoraColorWithLowAlpha];
}

- (UIColor *)welcomepageCurrentPageTintColor
{
    return [self OnahauColor];
}

- (UIColor *)welcomepageCurrentPageControlColor
{
    return [self CeruleanColor];
}

- (UIColor *)welcomeViewBGColor
{
    return [self lightTextOnDarkBackgroundColor];
}

-(CGFloat)signInButtonCornerRadius
{
    return 10.0;
}

#pragma mark - OEF Card View

- (UIColor *)oefCardPunchOutButtonBorderColor
{
    return [self dustyGrayColor];
}

- (UIColor *)oefCardCancelButtonTitleColor
{
    return [self pantoneCoatedBlackColor];
}

- (UIColor *)oefCardCancelButtonBackgroundColor
{
    return [UIColor clearColor];
}

- (UIColor *)oefCardWindowBackgroundColor
{
    return [UIColor whiteColor];
}

- (UIColor *)oefCardParentViewBackgroundColor
{
    return [UIColor whiteColor];
}

- (UIColor *)oefCardScrollViewBackgroundColor
{
    return [UIColor clearColor];
}

- (UIColor *)oefCardContainerViewBackgroundColor
{
    return [UIColor clearColor];
}

- (UIColor *)oefCardTableCellBackgroundColor
{
    return [UIColor clearColor];
}

- (UIColor *)oefCardBackGroundViewColor
{
    return [[UIColor blackColor] colorWithAlphaComponent:0.7f];;
}

-(CGFloat)oefPunchCardCornerRadius
{
    return 8.0f;
}

- (CGColorRef)oefPunchCardContainerBorderColor
{
    return [[UIColor clearColor] CGColor];
}

-(CGFloat)oefPunchCardContainerBorderWidth
{
    return 1.0f;
}

-(UIColor *)transferOEFCardButtonBackgroundColor
{
    return [self mountainMeadowColor];
}

-(UIFont *)transferOEFCardButtonFont
{
    return [self repliconBoldFontOfSize:17.0f];
}
-(UIColor *)transferOEFCardButtonTitleColor
{
    return [self whiteColor];
}
-(CGFloat)transferOEFCardCornerRadius
{
    return 20.0;
}
-(CGFloat)transferOEFCardBorderWidth
{
    return 1.0f;
}

-(UIColor *)transferOEFCardBorderColor
{
    return [self silverColor];
}

-(UIColor *)oefCardResumeWorkButtonBackgroundColor
{
    return [self mountainMeadowColor];
}

-(UIFont *)oefCardResumeWorkButtonFont
{
    return [self repliconBoldFontOfSize:17.0f];
}

-(UIColor *)oefCardResumeWorkButtonTitleColor
{
    return [self whiteColor];
}

-(CGFloat)oefCardResumeWorkButtonCornerRadius
{
    return 20.0;
}
-(CGFloat)oefCardResumeWorkButtonBorderWidth
{
    return 1.0f;
}

-(UIColor *)oefCardResumeWorkButtonBorderColor
{
    return [self silverColor];
}

#pragma mark - Punch Card View

-(UIColor *)punchCardTableViewParentViewBackgroundColor
{
    return [self alabasterColor];
}

-(UIColor *)punchCardTableViewBackgroundColor
{
    return [self transparentColor];
}

-(UIColor *)punchCardTableViewCellBackgroundColor
{
    return [self whiteColor];
}

-(CGFloat)punchCardTableViewCellCornerRadius
{
    return 5.0f;
}
-(CGFloat)punchCardTableViewCellBorderWidth
{
    return 0.5f;
}

-(UIColor *)punchCardTableViewCellBorderColor
{
    return [self complementaryColor];
}

-(UIColor *)punchCardTableHeaderViewBackgroundColor
{
    return [self transparentColor];
}

-(UIFont *)punchCardTableHeaderViewLabelFont
{
    return [self repliconBoldFontOfSize:14.0f];
}

#pragma mark - Bookmarks View
- (UIColor *)noBookmarksLabelTitleTextColor
{
    return [self blackColor];
}

- (UIColor *)noBookmarksLabelDescriptionTextColor
{
    return [self darkGrayishColor];
}

- (UIFont *)noBookmarksLabelTitleTextFont
{
    return  [self descriptionLabelBoldFont];
}

- (UIFont *)noBookmarksLabelDescriptionFont
{
    return  [self repliconRegularFontOfSize:12];
}

- (UIColor *)plusSignColor
{
    return [self brightBlueColor];
}


#pragma mark - Punch Presenter

- (UIFont *)descriptionLabelBoldFont
{
    return [UIFont fontWithName:RepliconBoldFontName size:15.0f];
}
- (UIFont *)descriptionLabelLighterFont
{
    return [UIFont fontWithName:RepliconLightFontName size:13.0f];
}

#pragma mark - Timesheet Status Colors

-(UIColor *)approvedColor
{
    return [Util colorWithHex:@"#22C064" alpha:1.0f];
}
-(UIColor *)rejectedColor
{
    return [Util colorWithHex:@"#E8421C" alpha:1.0f];
}
-(UIColor *)waitingForApprovalColor
{
    return [Util colorWithHex:@"#F7A72E" alpha:1.0f];
}
-(UIColor *)notSubmittedColor
{
    return [Util colorWithHex:@"#3D4552" alpha:1.0f];
}

-(UIColor *)approvedButtonBorderColor
{
    return [Util colorWithHex:@"#0F6B34" alpha:1.0f];
    
}
-(UIColor *)rejectedButtonBorderColor
{
    return [Util colorWithHex:@"#8C1B10" alpha:1.0f];
    
}
-(UIColor *)waitingForApprovalButtonBorderColor
{
    return [Util colorWithHex:@"#DB7F05" alpha:1.0f];
    
}
-(UIColor *)notSubmittedButtonBorderColor
{
    return [Util colorWithHex:@"#3D4552" alpha:1.0f];
    
}

-(UIColor *)issuesButtonDefaultTitleOrBorderColor
{
    return [Util colorWithHex:@"#E8421C" alpha:1.0f];
    
}

-(UIColor *)timesheetStatusButtonDefaultTitleOrBorderColor
{
    return [Util colorWithHex:@"#3D4552" alpha:1.0f];
    
}

-(UIColor *)issuesCountColor
{
    return [UIColor whiteColor];
    
}

-(UIColor *)issuesButtonWhenFoundTitleOrBorderColor
{
    return [Util colorWithHex:@"#E8421C" alpha:1.0f];
    
}

#pragma mark - Timesheet Status Font
- (UIFont *)timesheetIssuesCountLabelFont
{
    return [self repliconBoldFontOfSize:8];
}

- (UIFont *)timesheetViolationsLabelFont
{
    return [self repliconBoldFontOfSize:22];
}

- (UIFont *)timesheetStatusLabelFont
{
    return [self repliconBoldFontOfSize:13];
}

#pragma mark - Timesheet Duration
- (UIFont *)timeDurationNameLabelFont
{
    return [self repliconBoldFontOfSize:10];
}

- (UIFont *)timeDurationValueLabelFont
{
    return [self repliconBoldFontOfSize:17];
}

- (UIColor *)breakTimeDurationColor
{
    return [Util colorWithHex:@"#F7A72E" alpha:1.0f];
}

- (UIColor *)timeOffTimeDurationColor
{
    return [Util colorWithHex:@"#3D4552" alpha:1.0f];
}

- (UIColor *)workTimeDurationColor
{
    return [Util colorWithHex:@"#22C064" alpha:1.0f];
}

#pragma mark - Punch empty State

- (UIFont *)punchEmptyStateFirstLineFont
{
    return [UIFont fontWithName:RepliconBoldFontName size:22.0f];
}
- (UIFont *)punchEmptyStateSecondLineFont
{
    return [UIFont fontWithName:RepliconRegularFontName size:12.0f];
}

- (UIColor *)punchEmptyStateFirstLineColor
{
    return [self primaryGrayColor];
}

- (UIColor *)punchEmptyStateSecondLineColor
{
    return [self primaryGrayColor];
}

#pragma mark - Private

- (UIColor *)lightTextOnDarkBackgroundColor
{
    return [self whiteColor];
}
-(UIColor *)lightTimeLineTimeColor
{
    return [self lightColor];
}
- (UIColor *)darkTextOnLightBackgroundColor
{
    return [self blackColor];
}

- (UIColor *)lightButtonBackgroundColor
{
    return [self whiteColor];
}

#pragma mark - Replicon font definitions

- (UIFont *)repliconLightFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:RepliconLightFontName size:fontSize];
}

- (UIFont *)repliconRegularFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:RepliconRegularFontName size:fontSize];
}

- (UIFont *)repliconBoldFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:RepliconBoldFontName size:fontSize];
}

#pragma mark - Colors

// Color names are derived from http://chir.ag/projects/name-that-color/ where possible.

- (UIColor *)mountainMeadowColor
{
    return [Util colorWithHex:@"#22C064" alpha:1.0f];
}

- (UIColor *)shadyMountainMeadowColor
{
    return [Util colorWithHex:@"#1EAC59" alpha:1.0f];
}

- (UIColor *)salemColor
{
    return [Util colorWithHex:@"#15984C" alpha:1.0f];
}

- (UIColor *)persimmonColor
{
    return [Util colorWithHex:@"#FF654E" alpha:1.0f];
}

- (UIColor *)curiousBlueColor
{
    return [Util colorWithHex:@"#2885D4" alpha:1.0f];
}

- (UIColor *)denimColor
{
    return [Util colorWithHex:@"#1C6DCE" alpha:1.0f];
}

- (UIColor *)alabasterColor
{
    return [Util colorWithHex:@"#f8f8f8" alpha:1.0f];
}

- (UIColor *)blackColor
{
    return [UIColor blackColor];
}
- (UIColor *)lightColor
{
    return [Util colorWithHex:@"#656565" alpha:1.0];
}
- (UIColor *)carrotOrangeColor
{
    return [Util colorWithHex:@"#F0961C" alpha:1.0f];
}

- (UIColor *)geebungColor
{
    return [Util colorWithHex:@"#D2831A" alpha:1.0f];
}

- (UIColor *)galleryColor
{
    return [Util colorWithHex:@"#EEEEEE" alpha:1.0f];
}

- (UIColor *)mercuryColor
{
    return [Util colorWithHex:@"#E2E2E2" alpha:1.0f];
}

- (UIColor *)mineShaftColor
{
    return [Util colorWithHex:@"#333333" alpha:1.0f];
}

- (UIColor *)silverColor
{
    return [Util colorWithHex:@"#CCCCCC" alpha:1.0f];
}

- (UIColor *)silverAltoColor
{
    return [Util colorWithHex:@"#d4d4d4" alpha:1.0f];
}

- (UIColor *)buttercupColor
{
    return [Util colorWithHex:@"#F5A623" alpha:1.0f];
}

- (UIColor *)dustyGrayColor
{
    return [Util colorWithHex:@"#999999" alpha:1.0f];
}

- (UIColor *)doveGrayColor
{
    return [Util colorWithHex:@"#666666" alpha:1.0f];
}

- (UIColor *)whiteColor
{
    return [UIColor whiteColor];
}

- (UIColor *)redColor
{
    return [UIColor redColor];
}

- (UIColor *)wildSandColor
{
    return [Util colorWithHex:@"#F6F6F6" alpha:1.0f];
}

- (UIColor *)lochmaraColor
{
    return [Util colorWithHex:@"#007AC9" alpha:1.0f];
}

- (UIColor *)grayColor
{
    return [Util colorWithHex:@"#808080" alpha:1.0f];
}

- (UIColor *)tundoraColor
{
    return [Util colorWithHex:@"#4b4b4b" alpha:1.0f];
}

- (UIColor *)mandyColor
{
    return [Util colorWithHex:@"#E35B4B" alpha:1.0f];
}

- (UIColor *)altoColor
{
    return [Util colorWithHex:@"#D2D2D2" alpha:1.0f];
}

- (UIColor *)scarletColor
{
    return [Util colorWithHex:@"#FD2D10" alpha:1.0f];
}

- (UIColor *)tundoraColorText
{
    return [Util colorWithHex:@"#444343" alpha:1.0f];
}

- (UIColor *)tundoraColorWithLowAlpha
{
    return [Util colorWithHex:@"#444343" alpha:0.7f];
}

- (UIColor *)CeruleanColor
{
    return [Util colorWithHex:@"#00AEEF" alpha:1.0f];
}

- (UIColor *)OnahauColor
{
    return [Util colorWithHex:@"#c4e0ff" alpha:1.0f];
}

- (UIColor *)pantoneCoatedBlackColor
{
    return [Util colorWithHex:@"#2e2e2e" alpha:1.0f];
}

- (UIColor*)complementaryColor
{
    return [Util colorWithHex:@"#F1F1F1" alpha:1.0f];
}

- (UIColor*)darkGrayishColor
{
    return [Util colorWithHex:@"#545353" alpha:1.0f];
}

- (UIColor*)brightBlueColor
{
    return [Util colorWithHex:@"#3A81D9" alpha:1.0f];
}

- (UIColor *)repliconBlueColor {
    return [UIColor colorWithRed:0/255.0 green:122/255.0 blue:201/255.0 alpha:1.0];
}

- (UIColor*)primaryGrayColor
{
    return [Util colorWithHex:@"#3D4552" alpha:1.0f];
}

@end
