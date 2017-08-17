
import XCTest

class TimesheetEntryUITest: XCTestCase {
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

    func setUpTimesheetEntryUI(index: Int) {
        if(index == 0){
            let dailyWidgetEntryUITest = DailyWidgetEntryUITest()
            dailyWidgetEntryUITest.setUpDailyWidgetEntryUI()
        }
        else if(index == 1)
        {
            let timeDistributionWidgetEntryUITest = TimeDistributionWidgetEntryUITest()
            timeDistributionWidgetEntryUITest.setUpTimeDistributionWidgetEntryUI()
        }
        else
        {
            
        }
    }
}
