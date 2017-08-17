import XCTest

class ExtendedInOutTimesheetWithUDFScenario: BaseScenario {

    var scenarioModel:ExtendedInOutTimesheetWithUDFScenarioModel?

    override func setUp() {
        super.setUp()

        scenarioModel = ExtendedInOutTimesheetWithUDFScenarioService().setup();

        XCUIApplication().launch()
    }

    override func tearDown() {
        super.tearDown()
        tabBarTestStep.tapOnSettings()
        logoutTestStep.logout()
        ExtendedInOutTimesheetWithUDFScenarioService().tearDown((scenarioModel?.company)!)
    }

    func testExtendedInOutTimesheetWithUDFScenario() {

        let company = scenarioModel!.companyLoginField!;
        let user = scenarioModel!.user!;
        let supervisor = scenarioModel!.supervisor!;
        let timesheetRowAttributes = scenarioModel!.timesheetRowAttributes!;
        let timesheetDays = scenarioModel!.timesheetDays;
        let sheetLevelUDFsArray = scenarioModel!.sheetLevelUDFsArray
        let totalTimesheetHours = scenarioModel!.totalTimesheetHours

        /*All this steps belong to the user context*/

        welcomeTestStep.tapSignInButton()
        loginTestStep.loginWithNormalUser(user,company: company)
        progressIndicatorTestStep.waitForIndicatorViewToDisappearIfExists()
        timesheetListTestStep.tapOnTimesheetListScreenToSeeTimesheetDetails()
        timesheetDetailsTestStep.verifyTimesheetDaysBreakdown(timesheetDays)
        timesheetDetailsTestStep.tapOnTimesheetDetailsToSeeTimesheetEntryDetails()
        timesheetDayEntriesTestStep.tapOnAddTimeEntryRowForTimesheet()
        progressIndicatorTestStep.waitForIndicatorViewToDisappearIfExists()
        timesheetDayEntriesTestStep.addTimeEntryRowForTimesheet(timesheetRowAttributes);
        timesheetDayEntriesTestStep.saveTimesheetEntry()
        timesheetDayEntriesTestStep.tapOnAddTimeEntryRowForTimesheet()
        progressIndicatorTestStep.waitForIndicatorViewToDisappearIfExists()
        timesheetDayEntriesTestStep.addBreakEntryRowForTimesheet(timesheetRowAttributes)
        timesheetDayEntriesTestStep.saveTimesheetEntry()


        for i in 0...timesheetDays.count-1 {
            let timesheetDay = timesheetDays[i]
            if i != 0 {
                let day = RDate.dayFromDate(timesheetDay.date!)
                timesheetDayEntriesTestStep.tapOnDay("\(day!)")
                timesheetDayEntriesTestStep.tapOnSuggestionView("\(timesheetRowAttributes.project!) for \(timesheetRowAttributes.client!)")
                let breakEntry = timesheetRowAttributes.breaks![0]
                timesheetDayEntriesTestStep.tapOnSuggestionView("\(breakEntry)")
            }
            timesheetDayEntriesTestStep.enterHoursForADayOnExtendedInoutTimesheet(timesheetDay.entries)
        }

        timesheetDayEntriesTestStep.saveTimesheet()
        timesheetDetailsTestStep.tapOnBackButton()
        timesheetListTestStep.tapOnTimesheetListScreenToSeeTimesheetDetails()
        timesheetDetailsTestStep.verifyExtendedInOutTimesheetDaysTimeEntryValues(timesheetDays)
        sheetLevelUDFTestStep.verifyTitlesOfUdfAndItsDefaultValues(sheetLevelUDFsArray)
        baseTestStep.tableScrollViewUpAction(withName: Constants.timesheet_day_view_details_identifier)
        sheetLevelUDFTestStep.fillAllUdfWithValues(sheetLevelUDFsArray)
        sheetLevelUDFTestStep.verifyTitlesOfUdfAndItsUserValuesEntered(sheetLevelUDFsArray)
        timesheetDetailsTestStep.submitTimesheet();
        timesheetListTestStep.verifyTimesheetHours(0,hours: totalTimesheetHours!)
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
        timesheetDetailsTestStep.verifyExtendedInOutTimesheetDaysTimeEntryValues(timesheetDays)
        baseTestStep.tableScrollViewUpAction(withName: Constants.timesheet_day_view_details_identifier)
        sheetLevelUDFTestStep.verifyTitlesOfUdfAndItsUserValuesEntered(sheetLevelUDFsArray)
        timesheetDetailsTestStep.tapOnBackButton()
        approveTimesheetsTestStep.selectATimesheetToApproveOrReject()
        approveTimesheetsTestStep.tapToApproveTimesheets()
        approveTimesheetsTestStep.verifyForAllTimesheetsApproved()
    }
    
}

