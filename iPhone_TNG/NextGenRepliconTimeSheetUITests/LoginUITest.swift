
import XCTest

class LoginUITest: XCTestCase {
    
    var app = XCUIApplication()
    let config = Config()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    func setUpLoginUI(isAdminUser: Bool, index: Int)
    {
        let companyName:String;
        let userName:String;
        let password:String;
        
        if isAdminUser
        {
            companyName = config.admin[index].company
            userName = config.admin[index].name
            password = config.admin[index].password
        }
        else
        {
            companyName = config.users[index].company
            userName = config.users[index].name
            password = config.users[index].password
        }
        fillLoginDetails(companyName, userName: userName, password: password, isAdmin: isAdminUser, index: index)
    }
    
    func fillLoginDetails(companyName: String, userName:String, password:String, isAdmin: Bool, index: Int)
    {
        let tablesQuery = app.tables
        let companyTextField = tablesQuery.textFields["company_fld"]
        
        if(companyTextField.exists){
            waitForElementToAppear(companyTextField)
            companyTextField.tap()
            companyTextField.clearAndEnterText(companyName)
            
            let userNameTextField = tablesQuery.textFields["user_name_fld"]
            waitForElementToAppear(userNameTextField)
            userNameTextField.tap()
            userNameTextField.clearAndEnterText(userName)
            
            let signInButton = app.buttons["sign_in_btn"]
            waitForElementToAppear(signInButton)
            signInButton.tap()
            
            // Wait for next textfield to appear to enter password
            let passwordSecureTextField = tablesQuery.secureTextFields["password_fld"]
            waitForElementToAppear(passwordSecureTextField)
            
            passwordSecureTextField.tap()
            passwordSecureTextField.clearAndEnterText(password)
            
            let goButton = app.buttons["Go"]
            waitForElementToAppear(goButton)
            goButton.tap()
        }
        
        if isAdmin
        {
            let supervisorDashBoardUITest = SupervisorDashBoardUITest()
            supervisorDashBoardUITest.setUpSupervisorDashboard(index)
        }
        else
        {
            let listOfTimesheetUITest = ListOfTimesheetUITest()
            listOfTimesheetUITest.setUpListOfTimeSheet(index)
        }
    }
}
