

import Foundation

import XCTest

class ViewMyTimesheetsTestStep: BaseTestStep {


    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    func tapViewMyTimesheetsButton() {
        let viewMyTimesheetsButton = XCUIApplication().buttons["uia_view_my_timesheets_button_identifier"]
        scrollDownUntilElementAppears(viewMyTimesheetsButton)
        waitForVisible(viewMyTimesheetsButton)
        waitForElementToAppear(viewMyTimesheetsButton)
        waitForHittable(viewMyTimesheetsButton)
        viewMyTimesheetsButton.tap()
    }

    func checkForCorrectViewControllerTitle() {
        let titleElement = XCUIApplication().navigationBars["My Timesheet"]
        waitForElementToAppear(titleElement)

    }

    func verifyCurrentTimesheetPeriodDateRangeWithValue(_ currentTimesheet: String) {

        let dateRangeLabelElement = XCUIApplication().staticTexts[currentTimesheet]
        waitForElementToAppear(dateRangeLabelElement)
        let labelText : String = dateRangeLabelElement.label
        assertEqualStrings(labelText, value2: currentTimesheet)
    }

    func verifyGrossPayWithValue(_ grossPay: String) {

        let grossPayValueLabelElement = XCUIApplication().staticTexts["uia_timesheet_gross_pay_value_label_identifier"]
        waitForElementToAppear(grossPayValueLabelElement)
        let labelText : String = grossPayValueLabelElement.label
        assertEqualStrings(labelText, value2: grossPay)
    }
    
    func scrollDownScrollView()
    {
        let goldenNonGoldenTableview = XCUIApplication().scrollViews["goldenNonGolden_tableview"]
        scrollDownUntilElementAppears(goldenNonGoldenTableview)
    }
    
    func tapOnTimesheetListScreenToSeeTimesheetDetails() {
        
        let listOfTimesheetTableElement = XCUIApplication().tables["goldenNonGolden_tableview"]
        waitForElementToAppear(listOfTimesheetTableElement)
        let firstCell = listOfTimesheetTableElement.cells.element(boundBy: 0)
        waitForElementToAppear(firstCell)
        waitForHittable(firstCell)
        firstCell.tap()
    }
}
