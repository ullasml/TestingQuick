


import XCTest

class StandardTimesheetWithUDFUserScenario: BaseScenario {
    
    var scenarioModel:StandardTimesheetWithUDFUserScenarioModel?
    
    override func setUp() {
        super.setUp()
        scenarioModel = StandardTimesheetWithUDFUserScenarioService().setup();
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
        tabBarTestStep.tapOnSettings()
        logoutTestStep.logout()
        StandardTimesheetWithUDFUserScenarioService().tearDown((scenarioModel?.company)!)
    }
    
    func testStandardTimesheetWithUDFUserScenario() {

        let company = scenarioModel!.companyLoginField!;
        let user = scenarioModel!.user!;
        let supervisor = scenarioModel!.supervisor!;
        let standardTimesheetRowAttributes = scenarioModel!.standardTimesheetRowAttributes!;
        let sheetLevelUDFsArray = scenarioModel!.sheetLevelUDFsArray
        let rowLevelUDFsArray = scenarioModel!.rowLevelUDFsArray
        let timesheetDays = scenarioModel!.timesheetDays;
        let rowlLevelUdfStartingIndex :UInt = 3;
        let totalTimesheetHours = scenarioModel!.timesheetTotalHours;

        /*All this steps belong to the user context*/
        
        welcomeTestStep.tapSignInButton()
        loginTestStep.loginWithNormalUser(user,company: company)
        progressIndicatorTestStep.waitForIndicatorViewToDisappearIfExists()
        timesheetListTestStep.tapOnTimesheetListScreenToSeeTimesheetDetails()
        timesheetDetailsTestStep.tapOnTimesheetDetailsToSeeTimesheetEntryDetails()
        timesheetDayEntriesTestStep.tapOnAddTimeEntryRowForTimesheet()
        progressIndicatorTestStep.waitForIndicatorViewToDisappearIfExists()
        timesheetDayEntriesTestStep.addTimeEntryRowForTimesheet(standardTimesheetRowAttributes);
        rowLevelUDFTestStep.verifyTitlesOfUdfAndItsDefaultValues(rowLevelUDFsArray,index:rowlLevelUdfStartingIndex )
        rowLevelUDFTestStep.fillAllUdfWithValues(rowLevelUDFsArray,index:rowlLevelUdfStartingIndex)
        timesheetDayEntriesTestStep.saveTimesheetEntry()

        for i in 0...timesheetDays.count-1 {
            let timesheetDay = timesheetDays[i]
            if i != 0 {
                let day = RDate.dayFromDate(timesheetDay.date!)
                timesheetDayEntriesTestStep.tapOnDay("\(day!)")
            }
            timesheetDayEntriesTestStep.enterHoursForADayOnStandardTimesheet(timesheetDay.entries)
        }

        timesheetDayEntriesTestStep.tapOnFirstEntryOfTimesheet()
        timesheetDayEntryDetailsTestStep.saveTimesheetEditedEntry()
        timesheetDayEntriesTestStep.saveTimesheet()
        timesheetDetailsTestStep.tapOnBackButton()
        timesheetListTestStep.tapOnTimesheetListScreenToSeeTimesheetDetails()
        timesheetDetailsTestStep.verifyStandardTimesheetDaysTimeEntryValues(timesheetDays)
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
        timesheetDetailsTestStep.verifyStandardTimesheetDaysTimeEntryValues(timesheetDays)
        sheetLevelUDFTestStep.verifyTitlesOfUdfAndItsUserValuesEntered(sheetLevelUDFsArray)
        timesheetDetailsTestStep.tapOnTimesheetDetailsToSeeTimesheetEntryDetails()
        for i in 0...timesheetDays.count-1 {
            let timesheetDay = timesheetDays[i]
            if i != 0 {
                let day = RDate.dayFromDate(timesheetDay.date!)
                timesheetDayEntriesTestStep.tapOnDay("\(day!)")
            }
            timesheetDayEntriesTestStep.verifyHoursForADayOnStandardTimesheet(timesheetDay.entries)
            timesheetDayEntriesTestStep.tapOnFirstEntryOfTimesheet()
            timesheetDayEntryDetailsTestStep.tapOnTimeEntryRowForEditing()
            rowLevelUDFTestStep.verifyTitlesOfUdfAndItsUserValuesEntered(rowLevelUDFsArray,index:rowlLevelUdfStartingIndex)
            timesheetDayEntriesTestStep.tapOnBackButton()
            timesheetDayEntryDetailsTestStep.tapOnBackButton()
        }

        timesheetDetailsTestStep.tapOnBackButton()
        timesheetDetailsTestStep.tapOnBackButton()
        approveTimesheetsTestStep.selectATimesheetToApproveOrReject()
        approveTimesheetsTestStep.tapToApproveTimesheets()
        approveTimesheetsTestStep.verifyForAllTimesheetsApproved()
    }
    
}
