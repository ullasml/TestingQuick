
import XCTest

class BreakOEFTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }
    
    func verifyPunchStateDetails(_ entryOef : [OefType], punchAction: String) {
        let punchStateLabelElement = XCUIApplication().staticTexts["uia_break_details_label_identifier"]
        waitForElementToAppear(punchStateLabelElement)
        let punchState : String = punchStateLabelElement.label
        let oefTypesArray = entryOef
        for oef: OefType in oefTypesArray {
            let oefValue = oef.oefValue
            let isContainsString =  String(punchState).isContainsSubString(oefValue)
            XCTAssertTrue(isContainsString)
        }
        
        let isContainsString =  String(punchState).isContainsSubString(punchAction)
        XCTAssertTrue(isContainsString)
    }

    func tapOnResumeButton() {
        let resumeElement = XCUIApplication().buttons["uia_resume_punch_button_identifier"]
        waitForElementToAppear(resumeElement)
        resumeElement.tap()
    }
    
    func tapOnClockOutButton() {
        let clockOutElement = XCUIApplication().buttons["uia_punch_out_button_identifier"]
        scrollUpUntilElementAppears(clockOutElement)
        waitForVisible(clockOutElement)
        waitForElementToAppear(clockOutElement)
        waitForHittable(clockOutElement)
        clockOutElement.tap()
    }
}
