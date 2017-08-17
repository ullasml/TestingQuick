import XCTest

class DropDownOefSelectTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }
    
    func selectDropDownEntry() {
            let oefTableElement = XCUIApplication().tables[Constants.punch_flow_select_value_tableview_identifier]
            waitForElementToAppear(oefTableElement)
            
            let cell = oefTableElement.cells.element(boundBy: 1)
            waitForElementToAppear(cell)
            waitForHittable(cell)
            cell.tap()
    }

}
