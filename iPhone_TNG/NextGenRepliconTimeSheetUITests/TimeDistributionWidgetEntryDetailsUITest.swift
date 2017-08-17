
import XCTest

class TimeDistributionWidgetEntryDetailsUITest: XCTestCase {
    let app = XCUIApplication()
    let config = TimeDistConfig()
    let timesheetType = TimesheetTypeList()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func setUpTimeDistributionWidgetEntryDetailsUI() {
        let addTimeEntryButton = app.navigationBars.buttons["time_dist_add_btn"]
        if(addTimeEntryButton.exists){
            addTimeEntryButton.tap()
            let tablesQuery = app.tables["time_entry_tbl_view"]
            waitForElementToAppear(tablesQuery)
            if(tablesQuery.exists){
                let firstCell = tablesQuery.cells.elementBoundByIndex(0)
                // Wait for table to display data
                waitForElementToAppear(firstCell)
                firstCell.tap()
                
                let clientAndProjectTable = app.tables["select_client_tbl_view"]
                waitForElementToAppear(clientAndProjectTable)
                
                let clientCell = clientAndProjectTable.cells.elementBoundByIndex(1)
                // Wait for table to display data
                waitForElementToAppear(clientCell)
                clientCell.tap()
                
                let taskTable = app.tables["select_task_tbl_view"]
                waitForElementToAppear(taskTable)
                
                let taskCell = taskTable.cells.elementBoundByIndex(1)
                // Wait for table to display data
                waitForElementToAppear(taskCell)
                taskCell.tap()
                
                let saveTimeEntryButton = app.navigationBars.buttons["time_entry_save_btn"]
                waitForElementToAppear(saveTimeEntryButton)
                saveTimeEntryButton.tap()
                
                let entryTableViewQuery = app.tables["row_entry_tbl_view"]
                waitForElementToAppear(entryTableViewQuery)
                
                let timeTextField = entryTableViewQuery.textFields["day_time_text_fld"]
                // Wait for table to display data
                waitForElementToAppear(timeTextField)
                timeTextField.tap()
                timeTextField.clearAndEnterText(config.entryData.time)
                
                let saveEntryButton = app.navigationBars.buttons["save_time_dist_btn"]
                waitForElementToAppear(saveEntryButton)
                saveEntryButton.tap()
                
                checkDataSavedCorrectlyForTimeDistWidget()
                
                app.navigationBars.buttons.matchingIdentifier("Back").elementBoundByIndex(0).tap()
                
                let submitButton = app.buttons["submit_btn"]
                waitForElementToAppear(submitButton)
                submitButton.tap()
            }
        }
    }
    
    func checkDataSavedCorrectlyForTimeDistWidget(){
        // verify data saved successfully
        let tablesQuery = app.tables["widget_ts_entry_tableview"]
        waitForElementToAppear(tablesQuery)
        if(tablesQuery.exists){
            // Wait for table to display
            waitForElementToAppear(tablesQuery)
            
            let firstCell = tablesQuery.cells.elementBoundByIndex(1)
            
            // Wait for table to display data
            waitForElementToAppear(firstCell)
            
            firstCell.tap()
            
            let detailsTable = app.tables["row_entry_tbl_view"]
            waitForElementToAppear(detailsTable)
            if(detailsTable.exists){
                let clientAndProjectLbl = detailsTable.cells.elementBoundByIndex(0)
                    .staticTexts["client_project_lbl"]
                let taskLbl = detailsTable.cells.elementBoundByIndex(0)
                    .staticTexts["task_lbl"]
                let activityLbl = detailsTable.cells.elementBoundByIndex(0)
                    .staticTexts["activity_lbl"]
                let timeValue = detailsTable.cells.elementBoundByIndex(0)
                    .textFields["day_time_text_fld"].value
                
                let clientAndProjectValue  = clientAndProjectLbl.value
                let taskValue = taskLbl.value
                let activityValue  = activityLbl.value

                
                XCTAssertEqual(timeValue as? String, config.entryData.time)
                XCTAssertEqual(clientAndProjectValue as? String, config.entryData.client)
                XCTAssertEqual(taskValue as? String, config.entryData.task)
                XCTAssertEqual(activityValue as? String, config.entryData.activity)
            }
        }
    }

}

