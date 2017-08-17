
import XCTest

class ApprovalTimesheetListUITest: XCTestCase {
    let app = XCUIApplication()
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func setUpApprovalTimesheetListUI(index: Int) {
        let tablesQuery = app.tables["approval_ts_list_tbl_view"]
        waitForElementToAppear(tablesQuery)
        if tablesQuery.exists
        {
            let firstCell = tablesQuery.cells.elementBoundByIndex(0)
            // Wait for table to display data
            waitForElementToAppear(firstCell)
            
            firstCell.tap()
            
            let approvalTimesheetEntryUITest = ApprovalTimesheetEntryUITest()
            approvalTimesheetEntryUITest.setUpApprovalTimesheetEntryUI(index)
        }
    }
}
