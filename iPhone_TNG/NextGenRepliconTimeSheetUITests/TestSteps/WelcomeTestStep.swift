

import XCTest

class WelcomeTestStep: BaseTestStep {
    

    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    func tapSignInButton() {
        let notoficationOkButton = XCUIApplication().alerts.collectionViews.buttons["OK"]
        if(notoficationOkButton.exists)
        {
            notoficationOkButton.tap()
        }

        let signInButton = XCUIApplication().buttons["uia_welcome_sign_in_button_identifier"]
        waitForElementToAppear(signInButton)
        signInButton.tap()
    }

}
