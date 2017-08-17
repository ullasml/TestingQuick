

import XCTest

class PreviousOrNextTimesheetNavigationTestStep: BaseTestStep {


    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    func tapToViewPreviousTimesheet() {
        let uiaPreviousTimesheetNavigationButtonIdentifierButton = XCUIApplication().scrollViews["uia_timesheet_breakdown_scrollview_identifier"].otherElements.buttons["uia_previous_timesheet_navigation_button_identifier"]
        uiaPreviousTimesheetNavigationButtonIdentifierButton.tap()
    }

    func tapToViewNextTimesheet() {
        let nextButton = XCUIApplication().buttons["uia_next_timesheet_navigation_button_identifier"]
        waitForElementToAppear(nextButton)
        waitForHittable(nextButton)
        nextButton.tap()
    }
    
    
    
}