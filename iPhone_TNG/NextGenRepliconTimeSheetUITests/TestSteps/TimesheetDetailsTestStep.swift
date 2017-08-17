

import XCTest

class TimesheetDetailsTestStep: BaseTestStep {

    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    let dayViewTableIdentifier = "uia_timesheet_day_view_details_table_identifier"

    func tapOnTimesheetDetailsToSeeTimesheetEntryDetails() {

        let dayViewTableElement = XCUIApplication().tables[dayViewTableIdentifier]
        waitForElementToAppear(dayViewTableElement)
        let firstCell = dayViewTableElement.cells.element(boundBy: 1)
        waitForElementToAppear(firstCell)
        firstCell.tap()
        
    }

    func verifyTimesheetDaysBreakdown(_ timesheetDays : [InoutTimesheetDayEntry]) {

        let dayViewTableElement = XCUIApplication().tables[dayViewTableIdentifier]
        waitForElementToAppear(dayViewTableElement)
        for k in 0...timesheetDays.count-1 {
            let timesheetDay = timesheetDays[k]
            let firstCell = dayViewTableElement.cells.element(boundBy: UInt(k) + 1)
            firstCell.staticTexts[timesheetDay.entryDay!]
            waitForElementToAppear(firstCell)
        }
    }

    func verifyExtendedInOutTimesheetDaysTimeEntryValues(_ timesheetDays : [InoutTimesheetDayEntry]) {

        let dayViewTableElement = XCUIApplication().tables[dayViewTableIdentifier]
        waitForElementToAppear(dayViewTableElement)
        for k in 0...timesheetDays.count-1 {
            let timesheetDay = timesheetDays[k]
            let firstCell = dayViewTableElement.cells.element(boundBy: UInt(k) + 1)
            waitForElementToAppear(firstCell)
            let timesheetDayEntryLabelElement = firstCell.staticTexts[timesheetDay.totalHoursForDay]
            waitForElementToAppear(timesheetDayEntryLabelElement)
        }
    }

    func verifyStandardTimesheetDaysTimeEntryValues(_ timesheetDays : [StandardTimesheetDayEntry]) {

        let dayViewTableElement = XCUIApplication().tables[dayViewTableIdentifier]
        waitForElementToAppear(dayViewTableElement)
        for k in 0...timesheetDays.count-1 {
            let timesheetDay = timesheetDays[k]
            let firstCell = dayViewTableElement.cells.element(boundBy: UInt(k) + 1)
            waitForElementToAppear(firstCell)
            let timesheetDayEntryLabelElement = firstCell.staticTexts[timesheetDay.totalHoursForDay]
            waitForElementToAppear(timesheetDayEntryLabelElement)
        }
    }

    func submitTimesheet() {

        let dayViewTableElement = XCUIApplication().tables[dayViewTableIdentifier]
        waitForElementToAppear(dayViewTableElement)

        let firstCell = dayViewTableElement.cells.element(boundBy: 1)
        waitForHittable(firstCell, waitSeconds: 120);

        let submitTimesheetElement = dayViewTableElement.buttons["uia_description_done_button_identifier"]
        waitForElementToAppear(submitTimesheetElement)
        waitForHittable(submitTimesheetElement, waitSeconds: 120)
        submitTimesheetElement.tap()
    }

    func tapOnBackButton() {
        let backButtonElement = XCUIApplication().navigationBars.buttons["Back"];
        waitForElementToAppear(backButtonElement)
        waitForHittable(backButtonElement);
        backButtonElement.tap();
    }

    func verifyTimesheetHours(_ hours:String) {

        let timesheetTotalHoursLabelElement = XCUIApplication().staticTexts["timesheet_total_value_label"];
        waitForElementToAppear(timesheetTotalHoursLabelElement)

        let totalTimesheetHours : String = XCUIApplication().staticTexts["timesheet_total_value_label"].value as! String
        assertEqualStrings(totalTimesheetHours, value2: hours)

    }
}
