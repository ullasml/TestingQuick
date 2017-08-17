import XCTest
import Foundation

class TimesheetDayEntryDetailsTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }
    
    func tapOnTimeEntryRowForEditing()
    {
        let timeEntryRowBtnElement = XCUIApplication().buttons["uia_timesheet_entry_details_cell_btn_identifier"]
        waitForElementToAppear(timeEntryRowBtnElement)
        timeEntryRowBtnElement.tap()
    }
    
    func saveTimesheetEditedEntry() {
        let saveBarButton = XCUIApplication().buttons["uia_day_entry_editview_save_btn_identifier"]
        waitForElementToAppear(saveBarButton)
        saveBarButton.tap()
    }
    
    func tapOnBackButton() {
        let cancelBarButton = XCUIApplication().buttons["uia_timesheet_day_entry_view_details_cancel_btn_identifier"]
        waitForElementToAppear(cancelBarButton)
        cancelBarButton.tap()
    }

}
