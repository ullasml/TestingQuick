
import XCTest

class DailyWidgetEntryDetailsUITest: XCTestCase {
    let app = XCUIApplication()
    let config = OEFConfig()
    

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func setUpDailyWidgetEntryDetailsUI() {
        let tablesQuery = app.tables["daily_widget_details_tableview"]
        waitForElementToAppear(tablesQuery)
        if(tablesQuery.exists){
            let textOEFCell = tablesQuery.cells.elementBoundByIndex(0)
            
            // Wait for table to display data
            waitForElementToAppear(textOEFCell)
            
            textOEFCell.tap()
            
            let descriptionTextView = app.textViews["description_text_view"]
            waitForElementToAppear(descriptionTextView)
            
            descriptionTextView.tap()
            descriptionTextView.clearAndEnterText(config.oef.text)
            
            let doneButton = app.navigationBars.buttons["description_done_btn"]
            doneButton.tap()
            
            let numericTextField = tablesQuery.textFields["daily_widget_numeric_fld"]
            
            // Wait for table to display data
            waitForElementToAppear(numericTextField)
            
            numericTextField.tap()
            numericTextField.clearAndEnterText(config.oef.numeric)
            
            let keyBoardDoneButton = app.windows.containingType(.Button, identifier:".").childrenMatchingType(.Button).elementBoundByIndex(1)
            waitForElementToAppear(keyBoardDoneButton)
            keyBoardDoneButton.tap()
            
            let dropDownOEFCell = tablesQuery.cells.elementBoundByIndex(2)
            
            // Wait for table to display data
            waitForElementToAppear(dropDownOEFCell)
            
            dropDownOEFCell.tap()
            
            let dropDownTable = app.tables["drop_down_oef_table"]
            let dropDownOEFTableCell = dropDownTable.cells.elementBoundByIndex(1)
            
            // Wait for table to display data
            waitForElementToAppear(dropDownOEFTableCell)
            
            dropDownOEFTableCell.tap()
            
            let saveButton = app.navigationBars.buttons["dailly_widget_save_btn"]
            waitForElementToAppear(saveButton)
            saveButton.tap()
            checkDataSavedCorrectlyForDailyWidget()
        }
        let logoutUITest = LogoutUITest()
        logoutUITest.setUpLogOut(true, index: 0)
    }
    
    
    func checkDataSavedCorrectlyForDailyWidget(){
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
        }
        let detailsTable = app.tables["daily_widget_details_tableview"]
        waitForElementToAppear(detailsTable)
        if(detailsTable.exists){
            let staticTextOfFirstCell = detailsTable.cells.elementBoundByIndex(0)
                .staticTexts["desc_lbl"]
            let staticTextOfThirdCell = detailsTable.cells.elementBoundByIndex(2)
                .staticTexts["desc_lbl"]
            
            let textOEFValue  = staticTextOfFirstCell.value
            let dropDownOEFValue = staticTextOfThirdCell.value
            let numericTextField  = detailsTable.textFields["daily_widget_numeric_fld"]
            
            
            
            XCTAssertEqual(textOEFValue as? String, config.oef.text)
            XCTAssertEqual(numericTextField.value as? String, config.oef.numeric)
            XCTAssertEqual(dropDownOEFValue as? String, config.oef.dropDown)
        }
    }

}
