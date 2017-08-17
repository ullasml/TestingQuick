
import Foundation

import XCTest

class TimeoffTestStep: BaseTestStep {


    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    func tapOnCellOnIndex(_ index : UInt) {

        let timeLineTableElement = XCUIApplication().tables["uia_timeoff_table_identifier"]
        waitForElementToAppear(timeLineTableElement)

        let timeLineCellElement = timeLineTableElement.cells.element(boundBy: index);
        waitForElementToAppear(timeLineCellElement)
        waitForHittable(timeLineCellElement)
        timeLineCellElement.tap()
    }

    func tapOnCellToSelectDate(_ index : UInt) {
        
        let timeLineTableElement = XCUIApplication().tables["uia_timeoff_table_identifier"]
        waitForElementToAppear(timeLineTableElement)
        
        let timeLineCellElement = timeLineTableElement.cells.element(boundBy: index);
        let dateSelectionElement = timeLineCellElement.staticTexts["uia_timeoff_date_selection_identifier"];
        waitForElementToAppear(dateSelectionElement)
        waitForHittable(dateSelectionElement)
        dateSelectionElement.tap()
    }
    
    func selectTimeoffWithValue(_ timeoff : String) {

        XCUIApplication().pickerWheels[timeoff];

        let toolBar = XCUIApplication().toolbars["uia_timeoff_toobar_identifier"]
        waitForElementToAppear(toolBar)

        let doneButton = toolBar.buttons["uia_timeoff_done_button_identifier"]
        waitForElementToAppear(doneButton)
        doneButton.tap()
    }

    func selectDate(_ day :UInt , month: UInt , year: UInt) {
        let gridViewIdentifier = "uia_timeoff_date_selection_grid_identifier"
        let gridViewElement = XCUIApplication().descendants(matching: .other).matching(identifier: gridViewIdentifier)
        waitForElementToAppear(gridViewElement.element)

        let identifier = "uia_tile_view_identifier_\(day)-\(month)-\(year)"
        let tileViewElement = gridViewElement.descendants(matching: .other).matching(identifier: identifier)
        waitForElementToAppear(tileViewElement.element)
        tileViewElement.element.tap()

        let saveButtonElement = XCUIApplication().navigationBars.buttons["uia_timeoff_done_button_identifier"];
        waitForElementToAppear(saveButtonElement)
        saveButtonElement.tap()

    }

    func submitTimeoff(){
        let submitButtonElement = XCUIApplication().buttons["uia_timeoff_submit_button_identifier"];
        waitForElementToAppear(submitButtonElement)
        waitForHittable(submitButtonElement)
        submitButtonElement.tap()
        
    }



}
