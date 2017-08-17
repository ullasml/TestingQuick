
import XCTest

class PunchInTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }
    
    func tapOnClockInButton() {
        let clockInElement = XCUIApplication().buttons["punch_in_btn"]
        waitForElementToAppear(clockInElement)
        clockInElement.tap()
    }
    
    func verifyPunchStateDetails(_ punchStateText:String) {
        let punchStateLabelElement = XCUIApplication().staticTexts["punch_state_lbl"]
        waitForElementToAppear(punchStateLabelElement)
        let punchState : String = punchStateLabelElement.label
        assertEqualStrings(punchState, value2: punchStateText)
    }
    
}
