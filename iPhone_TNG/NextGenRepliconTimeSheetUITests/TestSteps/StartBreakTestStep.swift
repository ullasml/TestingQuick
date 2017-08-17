
import XCTest

class StartBreakTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }


    func tapOnClockOutButton() {
        let punchOutElement = XCUIApplication().buttons["punch_out_btn"]
        waitForElementToAppear(punchOutElement)
        waitForHittable(punchOutElement, waitSeconds: 120)
        punchOutElement.tap()
    }

}
