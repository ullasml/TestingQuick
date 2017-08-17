

import Foundation
import XCTest

class TimeDistributionWithTimeOffWidgetScenario: BaseScenario {

    var scenarioModel:TimeDistributionWithTimeOffWidgetScenarioModel?

    override func setUp() {
        super.setUp()
        scenarioModel = TimeDistributionWithTimeOffWidgetScenarioService().setup()
        XCUIApplication().launch()
    }

    override func tearDown() {
        super.tearDown()
        tabBarTestStep.tapOnSettings()
        logoutTestStep.logout()
        

        TimeDistributionWithTimeOffWidgetScenarioService().tearDown((scenarioModel?.company)!)
    }

    func testTimeDistributionWidgetTimesheetScenario() {

        let company = scenarioModel!.companyLoginField!;
        let user = scenarioModel!.user!;
        let supervisor = scenarioModel!.supervisor!;
        let standardTimesheetRowAttributes = scenarioModel!.standardTimesheetRowAttributes!;
        let timesheetDays = scenarioModel!.timesheetDays;
        let totalTimesheetHours = scenarioModel!.timesheetTotalHours;
        let totalHours = scenarioModel!.totalHours;
        let timeoffTotalHours = scenarioModel!.timeoffTotalHours;
        let paycodeSummary = scenarioModel!.paycodeSummary;
        let totalAmount = scenarioModel!.totalAmount


        let timeoffTypes = scenarioModel!.timeoffTypes
        let timeoffStartDate = scenarioModel!.timeoffStartDate
        let startDay = RDate.dayFromDate(timeoffStartDate!)
        let startMonth = RDate.monthFromDate(timeoffStartDate!)
        let startYear = RDate.yearFromDate(timeoffStartDate!)

        let timeoffEndDate = scenarioModel!.timeoffEndDate
        let endDay = RDate.dayFromDate(timeoffEndDate!)
        let endMonth = RDate.monthFromDate(timeoffEndDate!)
        let endYear = RDate.yearFromDate(timeoffEndDate!)

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
        widgetTimesheetDetailsTestStep.tapOnWidgetTimeDistributionToSeeTimesheetEntryDetails()
        timesheetDayEntriesTestStep.tapOnAddTimeoffEntryForTimesheet()
        progressIndicatorTestStep.waitForIndicatorViewToDisappearIfExists()
        timeoffTestStep.tapOnCellOnIndex(0)
        timeoffTestStep.selectTimeoffWithValue(timeoffTypes[0])
        timeoffTestStep.tapOnCellToSelectDate(1)
        progressIndicatorTestStep.waitForIndicatorViewToDisappearIfExists()
        timeoffTestStep.selectDate(UInt(startDay!),month:UInt(startMonth!),year:UInt(startYear!))
        timeoffTestStep.tapOnCellToSelectDate(2)
        progressIndicatorTestStep.waitForIndicatorViewToDisappearIfExists()
        timeoffTestStep.selectDate(UInt(endDay!),month:UInt(endMonth!),year:UInt(endYear!))
        timeoffTestStep.submitTimeoff()
        timesheetDayEntriesTestStep.saveTimesheet()
        progressIndicatorTestStep.waitForIndicatorViewToDisappearIfExists()
        widgetTimesheetDetailsTestStep.verifyTimesheetHoursOnTimeDistributionWidgetOnIndex(totalTimesheetHours!,index:1)
        widgetTimesheetDetailsTestStep.verifyTimeoffHoursOnTimeDistributionWidgetOnIndex(timeoffTotalHours!,index:1)

        widgetTimesheetDetailsTestStep.verifyHoursOnPayrollSummaryWidgetOnIndex(paycodeSummary,totalHours:"\(totalHours!) hrs", totalAmount:totalAmount!, index:2)
        widgetTimesheetDetailsTestStep.submitTimesheet();
        timesheetListTestStep.verifyTimesheetHours(0,hours: totalHours!)
        timesheetListTestStep.verifyApprovalsStatusOnTimesheetCellWithIndex(0,status: "Waiting for Approval")
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
        timesheetDetailsTestStep.tapOnBackButton()
        approveTimesheetsTestStep.selectATimesheetToApproveOrReject()
        approveTimesheetsTestStep.tapToApproveTimesheets()
        approveTimesheetsTestStep.verifyForAllTimesheetsApproved()
    }
}
