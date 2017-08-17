
import Foundation


import XCTest

class DashboardTestStep: BaseTestStep {

    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    func tapOnPendingTimesheetsWaitingForApproval() {

        let dashboardsTableElement = XCUIApplication().tables["supervisor_inbox_table_view"];
        waitForElementToAppear(dashboardsTableElement)

        let pendingTimesheetsCell = dashboardsTableElement.cells.element(boundBy: 0)
        waitForElementToAppear(pendingTimesheetsCell)
        pendingTimesheetsCell.tap()
    }

    func verifyForNoPendingItems() {

        let dashboardsTableElement = XCUIApplication().tables["supervisor_inbox_table_view"];
        waitForElementToAppear(dashboardsTableElement)

        let pendingTimesheetsCell = dashboardsTableElement.cells.element(boundBy: 0)
        waitForElementToAppear(pendingTimesheetsCell.staticTexts["No pending items"])

    }

    func verifyForCorrectItemsWaitingForApproval(_ itemsWaitingForApproval: UInt) {

        let dashboardsTableElement = XCUIApplication().tables["supervisor_inbox_table_view"];
        waitForElementToAppear(dashboardsTableElement)

        let pendingTimesheetsCell = dashboardsTableElement.cells.element(boundBy: 0)
        waitForElementToAppear(pendingTimesheetsCell.staticTexts["\(itemsWaitingForApproval) Timesheet for Approval"])
        
    }
    
    func tapViewMyTimesheetsButton() {
        let viewMyTimesheetsButton = XCUIApplication().buttons["uia_view_my_timesheets_button_identifier"]
        scrollDownUntilElementAppears(viewMyTimesheetsButton)
        waitForVisible(viewMyTimesheetsButton)
        waitForElementToAppear(viewMyTimesheetsButton)
        waitForHittable(viewMyTimesheetsButton)
        viewMyTimesheetsButton.tap()
    }
}
