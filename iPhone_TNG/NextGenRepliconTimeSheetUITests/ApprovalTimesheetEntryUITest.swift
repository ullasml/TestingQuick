
import XCTest

class ApprovalTimesheetEntryUITest: XCTestCase {
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

    func setUpApprovalTimesheetEntryUI(index: Int) {
        if(index == 0){
            let approvalDailyWidgetTimesheetEntryUITest = ApprovalDailyWidgetTimesheetEntryUITest()
            approvalDailyWidgetTimesheetEntryUITest.setUpApprovalDailyWidgetTimesheetEntryUI()
        }
        else if(index == 1)
        {
            let approvalTimeDistributionWidgetTimesheetEntryUITest = ApprovalTimeDistributionWidgetTimesheetEntryUITest()
            approvalTimeDistributionWidgetTimesheetEntryUITest.setUpApprovalTimeDistributionWidgetTimesheetEntryUI()
        }
        else
        {
            
        }
    }
}
