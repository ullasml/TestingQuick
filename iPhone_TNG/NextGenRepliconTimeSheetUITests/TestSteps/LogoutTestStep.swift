
import XCTest

class LogoutTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    func logout() {

        let logOutButtonElement = XCUIApplication().buttons["logout_button"];
        waitForElementToAppear(logOutButtonElement)
        waitForHittable(logOutButtonElement);
        logOutButtonElement.tap();

        let cancelButtonElement = XCUIApplication().navigationBars.buttons["Cancel"];
        waitForElementToAppear(cancelButtonElement)
        waitForHittable(cancelButtonElement);
        cancelButtonElement.tap();
    }
}
