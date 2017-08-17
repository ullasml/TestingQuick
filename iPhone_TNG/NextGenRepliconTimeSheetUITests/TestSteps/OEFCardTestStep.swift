import XCTest

class OEFCardTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }
    
    let textAndNumericOefIdentifier = "uia_text_and_numeric_cell_view_identifier"
    let punchButtonIdentifier = "uia_oef_card_punch_button_identifier"
    let oefCardTableIdentifier = "uia_oef_punch_card_entry_table_identifier"

    func tapOnBreakEntry() {
        let oefTableElement = XCUIApplication().tables[oefCardTableIdentifier]
        waitForElementToAppear(oefTableElement)
        let cell = oefTableElement.cells.element(boundBy: 0)
        waitForElementToAppear(cell)
        waitForHittable(cell)
        cell.tap()
    }
    
    func tapOnPunchActionButton() {
        let buttonElement = XCUIApplication().buttons[punchButtonIdentifier]
        waitForElementToAppear(buttonElement)
        buttonElement.tap()
    }

    func tapOnOefCellAndFillValues(_ oefArray: [OefType], isBreakEntry : Int) {
        let oefCount = oefArray.count
        for i in 0...oefCount-1 {
            let oefObject : OefType = oefArray[i]
            let oefType = oefObject.oefType
            
            let oefTableElement = XCUIApplication().tables[oefCardTableIdentifier]
            waitForElementToAppear(oefTableElement)
            
            let cell = oefTableElement.cells.staticTexts[oefObject.oefTitle!]
            waitForElementToAppear(cell)
            waitForHittable(cell)
            cell.tap()
            
            if oefType == Constants.textOefUri ||  oefType == Constants.numericOefUri{
                let textViewElement = XCUIApplication().textViews[oefObject.oefUri!]
                waitForElementToAppear(textViewElement)
                textViewElement.clearAndEnterText(oefObject.oefValue);
            }
            else{
                let dropdownTableElement = XCUIApplication().tables[Constants.punch_flow_select_value_tableview_identifier]
                waitForElementToAppear(dropdownTableElement)
                let dropdownOptionValueElement = dropdownTableElement.staticTexts[oefObject.oefValue]
                waitForElementToAppear(dropdownOptionValueElement)
                dropdownOptionValueElement.tap()
            }
        }
    }

}
