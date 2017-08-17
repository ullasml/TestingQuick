
import XCTest

class TimesheetListTestStep: BaseTestStep {


    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }
    
    let listOfTimesheetTableId = "uia_list_of_timesheet_table_identifier"

    func tapOnTimesheetListScreenToSeeTimesheetDetails() {
        let listOfTimesheetTableElement = XCUIApplication().tables[listOfTimesheetTableId]
        waitForElementToAppear(listOfTimesheetTableElement)
        let firstCell = listOfTimesheetTableElement.cells.element(boundBy: 0)
        waitForElementToAppear(firstCell)
        waitForHittable(firstCell)
        firstCell.tap()
    }

    func verifyApprovalsStatusOnTimesheetCellWithIndex(_ index:UInt, status: String) {
        let listOfTimesheetTableElement = XCUIApplication().tables[listOfTimesheetTableId]
        waitForElementToAppear(listOfTimesheetTableElement)
        let firstCell = listOfTimesheetTableElement.cells.element(boundBy: 0)
        waitForElementToAppear(firstCell)
        waitForHittable(firstCell)
        waitForElementToAppear(firstCell.staticTexts[status])
    }

    func verifyTimesheetHours(_ index:UInt,hours:String) {
        let listOfTimesheetTableElement = XCUIApplication().tables[listOfTimesheetTableId];
        waitForElementToAppear(listOfTimesheetTableElement)
        let firstCell = listOfTimesheetTableElement.cells.element(boundBy: 0)
        waitForElementToAppear(firstCell)
        waitForElementToAppear(firstCell.staticTexts[hours])
    }
}
