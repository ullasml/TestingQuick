import XCTest

class DailyWidgetEntryUITest: XCTestCase {
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
    
    func setUpDailyWidgetEntryUI() {
        let tablesQuery = app.tables["widget_ts_entry_tableview"]
        waitForElementToAppear(tablesQuery)
        if(tablesQuery.exists){
            let historyText = String.localize("Approval History", comment: "Approval History")
            let historyLbl = tablesQuery.staticTexts[historyText]
            var index  = config.widgetTimesheet
            if historyLbl.exists
            {
                index+=1
            }
            
            let firstCell = tablesQuery.cells.elementBoundByIndex(index)
            
            // Wait for table to display data
            waitForElementToAppear(firstCell)
            
            firstCell.tap()
        }
        let dailyWidgetEntryDetailsUITest = DailyWidgetEntryDetailsUITest()
        dailyWidgetEntryDetailsUITest.setUpDailyWidgetEntryDetailsUI()
    }
}
