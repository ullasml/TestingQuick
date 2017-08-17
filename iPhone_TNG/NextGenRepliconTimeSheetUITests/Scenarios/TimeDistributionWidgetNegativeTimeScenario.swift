
import Foundation

import XCTest

class TimeDistributionWidgetNegativeTimeScenario: BaseScenario {
    
    var scenarioModel:TimeDistributionWidgetNegativeTimeEntryScenarioModel?
    
    override func setUp() {
        super.setUp()
        
        scenarioModel = TimeDistributionWidgetNegativeTimeScenarioService().setup()
        
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
        tabBarTestStep.tapOnSettings()
        logoutTestStep.logout()
        TimeDistributionWidgetNegativeTimeScenarioService().tearDown((scenarioModel?.company)!)
    }
    
    func testTimeDistributionWidgetTimesheetNegativeTimeScenario() {
        
        // call service setup user with time distribution widget timesheet template along with his supervisor
        // login as user
        // tap on timsheet list screen
        // tap on time distribution widget
        // Add the timesheet row
        // save the timesheet row
        // enter timesheet negative hours for a day
        // enter timesheet negative hours for next day
        // save timesheet
        // verify if timesheet hours saved correctly
        // submit timesheet
        // login as supervisor
        // verify the user submitted entry
        // Approve the timesheet
        
        
        let company = scenarioModel!.companyLoginField!;
        
        let user = scenarioModel!.user!;
        
        let hours = scenarioModel!.hours!;
        
        let supervisor = scenarioModel!.supervisor!;
        
        let standardTimesheetRowAttributes = scenarioModel!.standardTimesheetRowAttributes!;
        
        
        /*All this steps belong to the user context*/
        
        welcomeTestStep.tapSignInButton()
        loginTestStep.loginWithNormalUser(user,company: company)
        timesheetListTestStep.tapOnTimesheetListScreenToSeeTimesheetDetails()
        widgetTimesheetDetailsTestStep.tapOnWidgetTimeDistributionToSeeTimesheetEntryDetails()
        timesheetDayEntriesTestStep.tapOnAddTimeEntryRowForTimesheet()
        progressIndicatorTestStep.waitForIndicatorViewToDisappearIfExists()
        timesheetDayEntriesTestStep.addTimeEntryRowForTimesheet(standardTimesheetRowAttributes);
        timesheetDayEntriesTestStep.enterHoursForADay(hours)
        
        //Adding empty time entry
        timesheetDayEntriesTestStep.tapOnAddTimeEntryRowForTimesheet()
        progressIndicatorTestStep.waitForIndicatorViewToDisappearIfExists()
        timesheetDayEntriesTestStep.addTimeEntryRowForTimesheet(standardTimesheetRowAttributes);
        
        //Saving and checking back for the time entries
        timesheetDayEntriesTestStep.saveTimesheet()
        progressIndicatorTestStep.waitForIndicatorViewToAppearAndDisappear()
        widgetTimesheetDetailsTestStep.verifyTimesheetHoursOnTimeDistributionWidgetOnIndex(hours,index:1)
        widgetTimesheetDetailsTestStep.tapOnWidgetTimeDistributionToSeeTimesheetEntryDetails()
        
        //Going in details of the time entry
        timesheetDayEntriesTestStep.selectRowToCheckNegativeTime()
        timesheetDayEntryDetailsTestStep.tapOnBackButton()
        
        //submitting the timesheet
        timesheetDayEntriesTestStep.tapOnBackButton()
        widgetTimesheetDetailsTestStep.submitTimesheet();
        timesheetListTestStep.verifyTimesheetHours(0,hours: hours)
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
        widgetTimesheetDetailsTestStep.verifyTimesheetHoursOnTimeDistributionWidgetOnIndex(hours,index:2)
        widgetTimesheetDetailsTestStep.tapOnWidgetTimeDistributionToSeeTimesheetEntryDetails()
        timesheetDetailsTestStep.tapOnBackButton()
        timesheetDetailsTestStep.tapOnBackButton()
        approveTimesheetsTestStep.selectATimesheetToApproveOrReject()
        approveTimesheetsTestStep.tapToApproveTimesheets()
        approveTimesheetsTestStep.verifyForAllTimesheetsApproved()
        approveTimesheetsTestStep.tapOnBackButton()
        dashboardTestStep.tapViewMyTimesheetsButton()
        
        //to view user timesheet in Supervisor View team timesheets page
        viewMyTimesheetsTestStep.scrollDownScrollView()
        viewMyTimesheetsTestStep.tapOnTimesheetListScreenToSeeTimesheetDetails()
    }
}
