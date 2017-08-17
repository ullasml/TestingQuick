
import XCTest

class SupervisorDashBoardUITest: XCTestCase {
    let app = XCUIApplication()
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    override func tearDown() {
        super.tearDown()
    }

    func setUpSupervisorDashboard(index: Int)
    {
        let tabBarItemsQuery = app.tabBars.buttons["dashboard_tabbar_item"];
        waitForElementToAppear(tabBarItemsQuery)
        if tabBarItemsQuery.exists
        {
            tabBarItemsQuery.tap()
            
            let tablesQuery = app.tables["supervisor_inbox_table_view"]
            waitForElementToAppear(tablesQuery)
            if tablesQuery.exists
            {
                let timesheetCell = tablesQuery.cells.elementBoundByIndex(0)
                // Wait for table to display data
                waitForElementToAppear(timesheetCell)
                
                timesheetCell.tap()
                
                let approvalTimesheetListUITest = ApprovalTimesheetListUITest()
                approvalTimesheetListUITest.setUpApprovalTimesheetListUI(index)
            }
        }
    }

    
    
    
}
