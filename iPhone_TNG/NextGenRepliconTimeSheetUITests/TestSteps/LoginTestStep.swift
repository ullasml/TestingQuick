
import XCTest

class LoginTestStep: BaseTestStep {

    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    func loginWithNormalUser(_ user: User,company: String) {
        let tablesQuery = XCUIApplication().tables
        let companyTextField = tablesQuery.textFields["uia_company_textfield_identifier"]
        let userNameTextField = tablesQuery.textFields["uia_username_textfield_identifier"]
        let signInButton = XCUIApplication().buttons["uia_login_button_identifier"]

        XCTAssertNotNil(user);

        waitForElementToAppear(companyTextField)
        companyTextField.tap()
        companyTextField.clearAndEnterText(company)

        waitForElementToAppear(userNameTextField)
        let nextToolbarButton = XCUIApplication().segmentedControls["uia_login_screen_toolbar_identifier"]
        nextToolbarButton.buttons.element(boundBy: 1).tap()
        userNameTextField.clearAndEnterText(user.username)

        waitForElementToAppear(signInButton)
        signInButton.tap()

        let passwordSecureTextField = tablesQuery.secureTextFields["uia_password_button_identifier"]
        waitForElementToAppear(passwordSecureTextField)
        passwordSecureTextField.tap()
        passwordSecureTextField.clearAndEnterText(user.password)

        let goButton = XCUIApplication().buttons["Go"]
        waitForElementToAppear(goButton)
        goButton.tap()

    }

}
