import XCTest
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



class ViewMyTimesheetsAstroUserScenario: BaseScenario {

    var scenarioModel:ViewMyTimesheetsAstroUserScenarioModel?

    override func setUp() {
        super.setUp()
        scenarioModel = ViewMyTimesheetsAstroUserScenarioService().setup();
        XCUIApplication().launch()

    }

    override func tearDown() {
        super.tearDown()
        ViewMyTimesheetsAstroUserScenarioService().tearDown((scenarioModel?.company)!)

    }

    func testViewMyTimesheetsAstroUserScenario() {

        let company = scenarioModel!.companyLoginField!;
        let user = scenarioModel!.user!;

        welcomeTestStep.tapSignInButton()
        loginTestStep.loginWithNormalUser(user,company: company)
        baseTestStep.allowAppToUseLocation();
        workAndBreakHoursTestStep.verifyBreakHours("2h:0m",onIndex:1)
        workAndBreakHoursTestStep.verifyWorkHours("2h:0m",onIndex:0)
        viewMyTimesheetsTestStep.tapViewMyTimesheetsButton()
        verifyFlowWithTimesheet(scenarioModel!.currentTimesheet!)
        timesheetBreakDownTestStep.scrollToCellOnIndex(0) 
        baseTestStep.scrollViewDownAction(withName: Constants.punch_flow_timesheet_breakdown_scrollview_identifier)
        baseTestStep.scrollViewDownAction(withName: Constants.punch_flow_timesheet_breakdown_scrollview_identifier)
        previousOrNextTimesheetNavigationTestStep.tapToViewPreviousTimesheet()
        verifyFlowWithTimesheet(scenarioModel!.previousTimesheet!)
        tabBarTestStep.tapOnSettings()
        logoutTestStep.logout()
    }

    fileprivate func verifyFlowWithTimesheet(_ timesheet : Timesheet) {

        let timesheetPeriodDateRange = timesheet.currentTimesheetPeriodDateRange!
        let timesheetDays: Array<TimesheetDay> = timesheet.timesheetDays!
        let grossPay = timesheet.grossPay!
        let totalBreakHours = timesheet.totalBreakHours!
        let totalWorkHours = timesheet.totalWorkHours!
        let timesheetViolationsCount = timesheet.violationsCount!
        let indexOfViolationToAccept : UInt = 0

        timesheetBreakDownTestStep.verifyWhetherTimesheetBreakdownDataReceived()
        viewMyTimesheetsTestStep.checkForCorrectViewControllerTitle()
        viewMyTimesheetsTestStep.verifyCurrentTimesheetPeriodDateRangeWithValue(timesheetPeriodDateRange)
        viewMyTimesheetsTestStep.verifyGrossPayWithValue(grossPay)
        workAndBreakHoursTestStep.verifyBreakHours(totalBreakHours,onIndex:1)
        workAndBreakHoursTestStep.verifyWorkHours(totalWorkHours,onIndex:0)
        violationsTestStep.verifyCorrectnessOfViolationsCount(timesheetViolationsCount)
        violationsTestStep.tapToViewViolations()
        violationsTestStep.verifyViolations(scenarioModel!.currentTimesheet!.violations!)
        violationsTestStep.acceptViolationOnIndex(scenarioModel!.currentTimesheet!.violations!,index:indexOfViolationToAccept)
        violationsTestStep.verifyViolationOnIndexAfterAccepting(scenarioModel!.currentTimesheet!.violations!,index:indexOfViolationToAccept)
        timesheetBreakDownTestStep.tapOnBackButton()
        baseTestStep.scrollViewUpAction(withName: Constants.punch_flow_timesheet_breakdown_scrollview_identifier)

        let count = timesheetDays.count
        for i in 0...count-1 {
            let timesheetDay = timesheetDays[i]
            timesheetBreakDownTestStep.verifyTimesheetDaySummary(timesheetDay,index: UInt(i))
            timesheetBreakDownTestStep.tapTimesheetDayCellOnIndex(UInt(i))

            let punchesCount = timesheetDay.punches?.count
            if punchesCount > 0 {
                for k in 0...punchesCount!-1 {
                    let punch = timesheetDay.punches![k]
                    if punch.actionType == "TakeBreak" {
                        timeLineTestStep.verifyTimeLinePunchEntry(punch.breakValue!, index:UInt(k));
                    }
                    else{
                        timeLineTestStep.verifyTimeLinePunchEntry(punch.actionType!, index:UInt(k));
                    }
                }
            }

            timesheetBreakDownTestStep.tapOnBackButton()
            if i != count-1 {
                timesheetBreakDownTestStep.scrollToCellOnIndex(UInt(i+1))
            }
        }

    }


}

