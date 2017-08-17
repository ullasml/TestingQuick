
import XCTest

class ListOfTimesheetUITest: XCTestCase {
    let app = XCUIApplication()
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func setUpListOfTimeSheet(index: Int) {
        let tablesQuery = app.tables["list_of_timesheet_table"]
        waitForElementToAppear(tablesQuery)
        if(tablesQuery.exists){
            let firstCell = tablesQuery.cells.elementBoundByIndex(0)
            
            // Wait for table to display data
            waitForElementToAppear(firstCell)

            firstCell.tap()
        }
        let timesheetEntryUITest = TimesheetEntryUITest()
        timesheetEntryUITest.setUpTimesheetEntryUI(index)
    }
}
