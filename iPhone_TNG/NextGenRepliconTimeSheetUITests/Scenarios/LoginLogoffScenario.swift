
import XCTest


class LoginLogoffScenario: BaseScenario {
    
    var scenarioModel:AstroUserScenarioModel?
    
    override func setUp() {
        super.setUp()
    
        scenarioModel = AstroUserScenarioService().setup();
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
            }
    
    func testAstroUserLoginLogoffScenario() {
        let company = scenarioModel!.companyLoginField!;
        let user = scenarioModel!.user!;
        welcomeTestStep.tapSignInButton()
        loginTestStep.loginWithNormalUser(user,company: company)
        baseTestStep.allowAppToUseLocation()
        tabBarTestStep.tapOnSettings()
        logoutTestStep.logout()
        AstroUserScenarioService().tearDown((scenarioModel?.company)!)
    }
}
