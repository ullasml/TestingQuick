
import XCTest

class LogoutUITest: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func setUpLogOut(isAdminUser: Bool, index: Int)
    {
        let tabBarItemsQuery = app.tabBars.buttons["settings_tabbar_item"];
        
        waitForElementToAppear(tabBarItemsQuery)
        if(tabBarItemsQuery.exists)
        {
            tabBarItemsQuery.tap();
            let logOutButtonQuery = app.buttons["logout_button"];
            if(logOutButtonQuery.exists)
            {
                logOutButtonQuery.tap();
                //setup Login UI
                loginUser(isAdminUser, index: index)
            }
        }
    }
    
    private func loginUser(isAdminUser: Bool, index: Int){
        //setup Login UI
        let loginUITest = LoginUITest()
        loginUITest.setUpLoginUI(isAdminUser, index: index)
    }
}
