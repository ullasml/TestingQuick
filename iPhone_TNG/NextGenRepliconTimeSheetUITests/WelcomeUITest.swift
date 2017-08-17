
import XCTest

class WelcomeUITest: XCTestCase {
    var app = XCUIApplication()
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func setUpWelcomeScreenUI() {
        let notoficationOkButton = app.alerts.collectionViews.buttons["OK"]
        if(notoficationOkButton.exists)
        {
            notoficationOkButton.tap()
        }
        
        let signInButton = app.buttons["welcome_sign_in_btn"]
        if(signInButton.exists)
        {
            signInButton.tap()
        }
        //setup Login UI
        let loginUITest = LoginUITest()
        loginUITest.setUpLoginUI(false, index: 0)
    }

}
