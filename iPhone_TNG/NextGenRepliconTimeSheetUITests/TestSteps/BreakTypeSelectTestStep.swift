
import Foundation
import XCTest


class BreakTypeSelectTestStep: BaseTestStep {

    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    func selectBreakTypeFromList(_ breakType:String) {
        let breakTypeElement = XCUIApplication().sheets["Select Break Type"]
        waitForElementToAppear(breakTypeElement)
        waitForHittable(breakTypeElement, waitSeconds: 120)
        let breakEntry = breakTypeElement.buttons[breakType]
        waitForElementToAppear(breakEntry)
        waitForHittable(breakEntry, waitSeconds: 120)
        breakEntry.tap()
    }
}

