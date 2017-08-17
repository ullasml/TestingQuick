import XCTest

class SelectDropDownEntryTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }
    
    func selectDropDownEntry() {
        let listOfDropDownEntriesTableElement = XCUIApplication().tables["drop_down_oef_table"]
        waitForElementToAppear(listOfDropDownEntriesTableElement)
        
        let firstCell = listOfDropDownEntriesTableElement.cells.element(boundBy: 1)
        waitForElementToAppear(firstCell)
        waitForHittable(firstCell)
        firstCell.tap()
    }
    
    
}
