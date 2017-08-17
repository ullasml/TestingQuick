
import Foundation
import XCTest

class ApproveTimesheetsTestStep: BaseTestStep {

    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    func tapOnFirstTimesheetWaitingForApproval() {

        let dashboardsTableElement = XCUIApplication().tables["approval_ts_list_tbl_view"];
        waitForElementToAppear(dashboardsTableElement)

        let pendingTimesheetsCell = dashboardsTableElement.cells.element(boundBy: 0)
        waitForElementToAppear(pendingTimesheetsCell)
        pendingTimesheetsCell.tap()
    }

    func selectATimesheetToApproveOrReject() {

        let dashboardsTableElement = XCUIApplication().tables["approval_ts_list_tbl_view"];
        waitForElementToAppear(dashboardsTableElement)

        let pendingTimesheetsCell = dashboardsTableElement.cells.element(boundBy: 0)
        let radioButton = pendingTimesheetsCell.buttons["approval_radio_btn_label"]
        waitForElementToAppear(radioButton)
        radioButton.tap()
    }

    func verifyForAllTimesheetsApproved() {

        let dashboardsTableElement = XCUIApplication().staticTexts["no_timesheets_pending_for_approval_label"];
        waitForElementToAppear(dashboardsTableElement)

    }

    func tapToApproveTimesheets() {

        let approveButtonElement = XCUIApplication().buttons["approve_button_label"];
        waitForElementToAppear(approveButtonElement)
        waitForHittable(approveButtonElement)
        approveButtonElement.forceTapElement()
    }

    func tapToRejectTimesheets() {

        let approveButtonElement = XCUIApplication().buttons["reject_button_label"];
        waitForElementToAppear(approveButtonElement)
        approveButtonElement.tap()
    }
    
    func tapOnBackButton() {
        let backButtonElement = XCUIApplication().navigationBars.buttons["Back"];
        waitForElementToAppear(backButtonElement)
        waitForHittable(backButtonElement);
        backButtonElement.tap();
        
    }

}
