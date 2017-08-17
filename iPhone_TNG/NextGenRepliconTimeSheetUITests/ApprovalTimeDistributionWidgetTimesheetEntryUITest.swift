
import XCTest

class ApprovalTimeDistributionWidgetTimesheetEntryUITest: XCTestCase {
    let app = XCUIApplication()
    let config = TimesheetTypeList()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func setUpApprovalTimeDistributionWidgetTimesheetEntryUI() {
        let tablesQuery = app.tables["widget_ts_entry_tableview"]
        waitForElementToAppear(tablesQuery)
        if tablesQuery.exists
        {
            let historyText = String.localize("Approval History", comment: "Approval History")
            let historyLbl = tablesQuery.staticTexts[historyText]
            let index  = config.pendingDailyWidget;
            if historyLbl.exists
            {
                index + 1
            }
            
            let dailyWidgetCell = tablesQuery.cells.elementBoundByIndex(index)
            // Wait for table to display data
            waitForElementToAppear(dailyWidgetCell)
            
            dailyWidgetCell.tap()
            
            let approvalTimeDistributionWidgetTimesheetEntryDetailsUITest = ApprovalTimeDistributionWidgetTimesheetEntryDetailsUITest()
            approvalTimeDistributionWidgetTimesheetEntryDetailsUITest.setUpApprovalDailyWidgetTimesheetEntryDetailsUI()
        }
    }
}
