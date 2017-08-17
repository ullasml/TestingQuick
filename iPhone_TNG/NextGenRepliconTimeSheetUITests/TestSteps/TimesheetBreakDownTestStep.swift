import Foundation

import XCTest

class TimesheetBreakDownTestStep: BaseTestStep {


    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    func tapTimesheetDayCellOnIndex(_ index:UInt) {
        let timesheetBreakdownTableElement = XCUIApplication().tables["uia_timesheet_breakdown_table_identifier"]
        let timesheetCell = timesheetBreakdownTableElement.cells.element(boundBy: index)
        waitForElementToAppear(timesheetCell)
        waitForHittable(timesheetCell)
        timesheetCell.tap()
    }

    func scrollToCellOnIndex(_ index:UInt) {
        let timesheetBreakdownTableElement = XCUIApplication().tables["uia_timesheet_breakdown_table_identifier"]
        let timesheetCell = timesheetBreakdownTableElement.cells.element(boundBy: index)
        waitForElementToAppear(timesheetCell)
        waitForHittable(timesheetCell)
        timesheetBreakdownTableElement.scrollToElement(timesheetCell)
    }

    func scrollUpToTheTop() {
        
        XCUIApplication().scrollViews["uia_timesheet_breakdown_scrollview_identifier"].swipeDown()
    }


    func verifyTimesheetDays(_ timesheetDays: Array<TimesheetDay>) {

        let dateLabelIdentifier = "uia_timesheet_day_label_identifier"
        //let workHoursLabelIdentifier = "uia_timesheet_day_work_hours_value_label_identifier"
        //let breakHoursLabelIdentifier = "uia_timesheet_day_break_hours_value_label_identifier"

        let timesheetBreakdownTableElement = XCUIApplication().tables["uia_timesheet_breakdown_table_identifier"]
        waitForElementToAppear(timesheetBreakdownTableElement)

        let count = timesheetDays.count
        for i in 0...count-1 {
            let timesheetDay = timesheetDays[i]
            let dayTotalCell = timesheetBreakdownTableElement.cells.element(boundBy: UInt(i))

            let date : String = dayTotalCell.staticTexts[dateLabelIdentifier].label
            //let workHours : String = dayTotalCell.staticTexts[workHoursLabelIdentifier].label
            //let breakHours : String = dayTotalCell.staticTexts[breakHoursLabelIdentifier].label

            assertEqualStrings(date, value2: timesheetDay.date!)
            //assertEqualStrings(workHours, value2: timesheetDay.workHours!)
            //assertEqualStrings(breakHours, value2: timesheetDay.breakHours!)
        }
        
    }

    func tapOnBackButton() {
        let backButtonElement = XCUIApplication().navigationBars.buttons["My Timesheet"];
        waitForElementToAppear(backButtonElement)
        waitForHittable(backButtonElement);
        backButtonElement.tap();
    }

    func verifyWhetherTimesheetBreakdownDataReceived() {
        let timesheetBreakdownTableElement = XCUIApplication().tables["uia_timesheet_breakdown_table_identifier"]
        waitForElementToAppear(timesheetBreakdownTableElement)
    }

    func verifyTimesheetDaySummary(_ timesheetDay: TimesheetDay, index : UInt) {

        let dateLabelIdentifier = "uia_timesheet_day_label_identifier"
        let workHoursLabelIdentifier = "uia_timesheet_day_work_hours_value_label_identifier"
        let breakHoursLabelIdentifier = "uia_timesheet_day_break_hours_value_label_identifier"

        let timesheetBreakdownTableElement = XCUIApplication().tables["uia_timesheet_breakdown_table_identifier"]
        waitForElementToAppear(timesheetBreakdownTableElement)

        let dayTotalCell = timesheetBreakdownTableElement.cells.element(boundBy: UInt(index))

        let date : String = dayTotalCell.staticTexts[dateLabelIdentifier].label
        let workHours : String = dayTotalCell.staticTexts[workHoursLabelIdentifier].label
        let breakHours : String = dayTotalCell.staticTexts[breakHoursLabelIdentifier].label

        assertEqualStrings(date, value2: timesheetDay.date!)
        assertEqualStrings(workHours, value2: timesheetDay.workHours!)
        assertEqualStrings(breakHours, value2: timesheetDay.breakHours!)

    }

    
}
