
import XCTest

class PunchOutTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }
    
    
    func tapOnClockOutButton() {
        let punchOutElement = XCUIApplication().buttons["punch_out_btn"]
        waitForElementToAppear(punchOutElement)
        waitForHittable(punchOutElement, waitSeconds: 120)
        punchOutElement.tap()
    }


    func tapOnStartBreakButton() {
        let startBreakElement = XCUIApplication().buttons["start_break_btn"]
        waitForElementToAppear(startBreakElement)
        waitForHittable(startBreakElement, waitSeconds: 120)
        startBreakElement.tap()
    }
    
    func verifySelectedBreakType(_ breakType:String) {
        let punchBreakLabelElement = XCUIApplication().staticTexts["punch_break_lbl"]
        waitForElementToAppear(punchBreakLabelElement)
        let breakTypeString : String = punchBreakLabelElement.label
        assertEqualStrings(breakTypeString, value2: breakType)
    }

}
