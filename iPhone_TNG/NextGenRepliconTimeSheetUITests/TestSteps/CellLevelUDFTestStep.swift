import XCTest

class CellLevelUDFTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }
    
    
    let timeEntryTableIdentifier = "uia_timesheet_day_entry_view_details_table_identifier"
    let timeEntrytitleLabelIdentifier = "uia_cell_level_udf_title_identifier"
    let timeEntryValueLabelIdentifier = "uia_cell_level_udf_value_identifier"
    
    
    func tapOnCellLevelTextUdf(_ index:UInt) {
        let timeEntryRowTableElement = XCUIApplication().tables[timeEntryTableIdentifier]
        waitForElementToAppear(timeEntryRowTableElement)
        
        let cell = timeEntryRowTableElement.cells.element(boundBy: index)
        waitForElementToAppear(cell)
        cell.tap()
    }
    
    func tapOnCellLevelDateUdf(_ index:UInt) {
        let timeEntryRowTableElement = XCUIApplication().tables[timeEntryTableIdentifier]
        waitForElementToAppear(timeEntryRowTableElement)
        
        let cell = timeEntryRowTableElement.cells.element(boundBy: index)
        waitForElementToAppear(cell)
        cell.tap()
        
        let toolBarDoneButton = XCUIApplication().toolbars.buttons["uia_cell_level_date_picker_done_btn_identifier"]
        waitForElementToAppear(toolBarDoneButton)
        toolBarDoneButton.tap()
    }
    
    func tapOnCellLevelDropDownUdf(_ index:UInt) {
        let timeEntryRowTableElement = XCUIApplication().tables[timeEntryTableIdentifier]
        waitForElementToAppear(timeEntryRowTableElement)
        
        let cell = timeEntryRowTableElement.cells.element(boundBy: index)
        waitForElementToAppear(cell)
        cell.tap()
    }
    
    func tapOnCellLevelNumericUdf(_ index:UInt, numericValue:String) {
        let timeEntryRowTableElement = XCUIApplication().tables[timeEntryTableIdentifier]
        waitForElementToAppear(timeEntryRowTableElement)
        
        let cell = timeEntryRowTableElement.cells.element(boundBy: index)
        waitForElementToAppear(cell)
        cell.tap()
        
        let numericUdfElement = XCUIApplication().textFields["uia_cell_level_numeric_udf_value_identifier"]
        waitForElementToAppear(numericUdfElement)
        
        numericUdfElement.tap()
        numericUdfElement.clearAndEnterText(numericValue)
        
        let doneButton = XCUIApplication().buttons["uia_number_keypad_done_btn_identifier"]
        waitForElementToAppear(doneButton)
        doneButton.tap()
    }
    
    func verifyCellLevelNumericUdfValue(_ index:UInt, udfObject:Udf) {
        let timeEntryRowTableElement = XCUIApplication().tables[timeEntryTableIdentifier]
        waitForElementToAppear(timeEntryRowTableElement)
        
        let cell = timeEntryRowTableElement.cells.element(boundBy: index)
        waitForElementToAppear(cell)
        
        let cellUdfTitleLabelElement = cell.staticTexts[timeEntrytitleLabelIdentifier]
        waitForElementToAppear(cellUdfTitleLabelElement)
        let title : String = cellUdfTitleLabelElement.label
        assertEqualStrings(title, value2: udfObject.udfTitle!)
        
        let cellUdfValueLabelElement = XCUIApplication().textFields["uia_cell_level_numeric_udf_value_identifier"]
        waitForElementToAppear(cellUdfValueLabelElement)
        let value  = cellUdfValueLabelElement.value as! String
        let udfValue = udfObject.udfValue
        XCTAssertEqual(value, udfValue)
    }
    
    func verifyCellLevelDropDownUdfValue(_ index:UInt, udfObject:Udf) {
        let timeEntryRowTableElement = XCUIApplication().tables[timeEntryTableIdentifier]
        waitForElementToAppear(timeEntryRowTableElement)
        
        let cell = timeEntryRowTableElement.cells.element(boundBy: index)
        waitForElementToAppear(cell)
        
        let cellUdfTitleLabelElement = cell.staticTexts[timeEntrytitleLabelIdentifier]
        waitForElementToAppear(cellUdfTitleLabelElement)
        let title : String = cellUdfTitleLabelElement.label
        assertEqualStrings(title, value2: udfObject.udfTitle!)
        
        let cellUdfValueLabelElement = cell.staticTexts[timeEntryValueLabelIdentifier]
        waitForElementToAppear(cellUdfValueLabelElement)
        let value : String = cellUdfValueLabelElement.label
        assertEqualStrings(value, value2: udfObject.udfValue)
    }
    
    func verifyCellLevelDateUdfValue(_ index:UInt, udfObject:Udf) {
        let timeEntryRowTableElement = XCUIApplication().tables[timeEntryTableIdentifier]
        waitForElementToAppear(timeEntryRowTableElement)
        
        let cell = timeEntryRowTableElement.cells.element(boundBy: index)
        waitForElementToAppear(cell)
        
        let cellUdfTitleLabelElement = cell.staticTexts[timeEntrytitleLabelIdentifier]
        waitForElementToAppear(cellUdfTitleLabelElement)
        let title : String = cellUdfTitleLabelElement.label
        assertEqualStrings(title, value2: udfObject.udfTitle!)
        
        let cellUdfValueLabelElement = cell.staticTexts[timeEntryValueLabelIdentifier]
        waitForElementToAppear(cellUdfValueLabelElement)
        let value : String = cellUdfValueLabelElement.label
        assertEqualStrings(value, value2: udfObject.udfValue)
    }
    
    func verifyCellLevelTextUdfValue(_ index:UInt, udfObject:Udf) {
        let timeEntryRowTableElement = XCUIApplication().tables[timeEntryTableIdentifier]
        waitForElementToAppear(timeEntryRowTableElement)
        
        let cell = timeEntryRowTableElement.cells.element(boundBy: index)
        waitForElementToAppear(cell)
        
        let cellUdfTitleLabelElement = cell.staticTexts[timeEntrytitleLabelIdentifier]
        waitForElementToAppear(cellUdfTitleLabelElement)
        let title : String = cellUdfTitleLabelElement.label
        assertEqualStrings(title, value2: udfObject.udfTitle!)
        
        let cellUdfValueLabelElement = cell.staticTexts[timeEntryValueLabelIdentifier]
        waitForElementToAppear(cellUdfValueLabelElement)
        let value : String = cellUdfValueLabelElement.label
        assertEqualStrings(value, value2: udfObject.udfValue)
    }
}

