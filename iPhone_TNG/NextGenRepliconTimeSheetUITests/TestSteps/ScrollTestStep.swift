
import Foundation
import XCTest

class ScrollTestStep: BaseTestStep {


    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    func swipeUpScrollView() {
        XCUIApplication().swipeUp()
    }

    func swipeDownScrollView() {
        XCUIApplication().swipeDown()
    }
    
}
