

import Foundation

import XCTest

class TimeDistributionWithApprovalHistoryScenario: BaseScenario {

    var scenarioModel:TimeDistributionWithApprovalHistoryScenarioModel?

    override func setUp() {
        super.setUp()

        scenarioModel = TimeDistributionWithApprovalHistoryScenarioService().setup()

        XCUIApplication().launch()
    }

    override func tearDown() {
        super.tearDown()
        tabBarTestStep.tapOnSettings()
        logoutTestStep.logout()
        

        TimeDistributionWithApprovalHistoryScenarioService().tearDown((scenarioModel?.company)!)
    }

    func testTimeDistributionWithApprovalHistoryScenario() {

        let company = scenarioModel!.companyLoginField!;
        let user = scenarioModel!.user!;
        let supervisor = scenarioModel!.supervisor!;
        let standardTimesheetRowAttributes = scenarioModel!.standardTimesheetRowAttributes!;
        let timesheetDays = scenarioModel!.timesheetDays;
        let totalTimesheetHours = scenarioModel!.timesheetTotalHours;
        let approvalSummaryBeforeApproval = scenarioModel!.approvalSummaryBeforeApproval;

        /*All this steps belong to the user context*/

        welcomeTestStep.tapSignInButton()
        loginTestStep.loginWithNormalUser(user,company: company)
        timesheetListTestStep.tapOnTimesheetListScreenToSeeTimesheetDetails()
        widgetTimesheetDetailsTestStep.tapOnWidgetTimeDistributionToSeeTimesheetEntryDetails()
        timesheetDayEntriesTestStep.tapOnAddTimeEntryRowForTimesheet()
        progressIndicatorTestStep.waitForIndicatorViewToDisappearIfExists()
        timesheetDayEntriesTestStep.addTimeEntryRowForTimesheet(standardTimesheetRowAttributes);
        timesheetDayEntriesTestStep.saveTimesheetEntry()

        for i in 0...timesheetDays.count-1 {
            let timesheetDay = timesheetDays[i]
            if i != 0 {
                let day = RDate.dayFromDate(timesheetDay.date!)
                timesheetDayEntriesTestStep.tapOnDay("\(day!)")
            }
            timesheetDayEntriesTestStep.enterHoursForADayOnStandardTimesheet(timesheetDay.entries)
        }
        timesheetDayEntriesTestStep.saveTimesheet()
        progressIndicatorTestStep.waitForIndicatorViewToAppearAndDisappear()
        widgetTimesheetDetailsTestStep.verifyTimesheetHoursOnTimeDistributionWidgetOnIndex(totalTimesheetHours!,index:1)
        widgetTimesheetDetailsTestStep.submitTimesheet();
        timesheetListTestStep.verifyTimesheetHours(0,hours: totalTimesheetHours!)
        timesheetListTestStep.verifyApprovalsStatusOnTimesheetCellWithIndex(0,status: "Waiting for Approval")
        timesheetListTestStep.tapOnTimesheetListScreenToSeeTimesheetDetails()
        progressIndicatorTestStep.waitForIndicatorViewToDisappearIfExists()
        widgetTimesheetDetailsTestStep.tapOnApprovalsWidgetToSeeApprovalDetails()
        approvalDetailsTestStep.verifyApprovalDetails(approvalSummaryBeforeApproval)
        tabBarTestStep.tapOnSettings()
        logoutTestStep.logout()


        /*All this steps belong to the supervisor context*/

        welcomeTestStep.tapSignInButton()
        loginTestStep.loginWithNormalUser(supervisor,company: company)
        progressIndicatorTestStep.waitForIndicatorViewToDisappearIfExists()
        tabBarTestStep.tapOnDashboards()
        dashboardTestStep.verifyForCorrectItemsWaitingForApproval(1)
        dashboardTestStep.tapOnPendingTimesheetsWaitingForApproval()
        approveTimesheetsTestStep.tapOnFirstTimesheetWaitingForApproval()
        progressIndicatorTestStep.waitForIndicatorViewToDisappearIfExists()
        widgetTimesheetDetailsTestStep.tapOnWidgetTimeDistributionToSeeTimesheetEntryDetails()
        for i in 0...timesheetDays.count-1 {
            let timesheetDay = timesheetDays[i]
            if i != 0 {
                let day = RDate.dayFromDate(timesheetDay.date!)
                timesheetDayEntriesTestStep.tapOnDay("\(day!)")
            }
            timesheetDayEntriesTestStep.verifyHoursForADayOnStandardTimesheet(timesheetDay.entries)
        }
        widgetTimesheetDetailsTestStep.tapOnBackButton()
        widgetTimesheetDetailsTestStep.tapOnApprovalsWidgetToSeeApprovalDetails()
        approvalDetailsTestStep.verifyApprovalDetails(approvalSummaryBeforeApproval)
        timesheetDetailsTestStep.tapOnBackButton()
        timesheetDetailsTestStep.tapOnBackButton()
        approveTimesheetsTestStep.selectATimesheetToApproveOrReject()
        approveTimesheetsTestStep.tapToApproveTimesheets()
        approveTimesheetsTestStep.verifyForAllTimesheetsApproved()
    }
}
