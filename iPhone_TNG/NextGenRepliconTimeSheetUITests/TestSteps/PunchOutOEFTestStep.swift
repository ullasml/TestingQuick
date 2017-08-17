
import XCTest

class PunchOutOEFTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }
    
    func verifyPunchStateDetails(_ entryOef : [OefType], punchAction: String) {
        let punchStateLabelElement = XCUIApplication().staticTexts["uia_punch_in_details_label_identifier"]
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
    
    func tapOnTakeABreakButton() {
        let breakElement = XCUIApplication().buttons["uia_break_punch_button_identifier"]
        waitForElementToAppear(breakElement)
        breakElement.tap()
    }

    func tapOnClockOutButton() {
        self.scrollViewDownAction(withName: Constants.punch_flow_scroll_view_identifier)

        let clockOutElement = XCUIApplication().buttons["uia_punch_out_button_identifier"]
        waitForElementToAppear(clockOutElement)
        waitForHittable(clockOutElement)
        clockOutElement.tap()
    }
}
