
import XCTest

class ApprovalTimeDistributionWidgetTimesheetEntryDetailsUITest: XCTestCase {
    
    let app = XCUIApplication()
    let config = TimeDistConfig()
    let timesheetType = TimesheetTypeList()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func setUpApprovalDailyWidgetTimesheetEntryDetailsUI() {
        let tablesQuery = app.tables["row_entry_tbl_view"]
        waitForElementToAppear(tablesQuery)
        if tablesQuery.exists {
            checkDataSavedCorrectlyForTimeDistWidget()
        }
    }
    
    func checkDataSavedCorrectlyForTimeDistWidget(){
        // verify data saved successfully
        let detailsTable = app.tables["row_entry_tbl_view"]
        waitForElementToAppear(detailsTable)
        if(detailsTable.exists){
            let clientAndProjectValue = detailsTable.cells.elementBoundByIndex(0)
                .staticTexts["client_project_lbl"].value
            let taskValue = detailsTable.cells.elementBoundByIndex(0)
                .staticTexts["task_lbl"].value
            let activityValue = detailsTable.cells.elementBoundByIndex(0)
                .staticTexts["activity_lbl"].value
            let timeValue = detailsTable.cells.elementBoundByIndex(0)
                .staticTexts["day_time_text_fld"].value
            XCTAssertEqual(timeValue as? String, config.entryData.time)
        }
    }
}
