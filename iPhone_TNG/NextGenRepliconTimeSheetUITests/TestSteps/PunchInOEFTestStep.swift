
import XCTest

class PunchInOEFTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    let textAndNumericOefIdentifier = "uia_text_and_numeric_cell_view_identifier"
    let oefTableIdentifier = "uia_punch_card_entry_table_identifier"
    
    func tapOnOefCellAndFillValues(_ oefArray: [OefType]) {
        
        let oefCount = oefArray.count
        for i in 0...oefCount-1 {
            let oefObject : OefType = oefArray[i]
            let oefType = oefObject.oefType
            
            let oefTableElement = XCUIApplication().tables[oefTableIdentifier]
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
    
    func tapOnClockInButton() {
        let clockInElement = XCUIApplication().buttons["uia_punch_in_action_identifier"]
        waitForElementToAppear(clockInElement)
        clockInElement.tap()
    }
}
