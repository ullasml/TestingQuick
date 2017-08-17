
import XCTest

class ApprovalDailyWidgetTimesheetEntryDetailsUITest: XCTestCase {
    let app = XCUIApplication()
    let config = OEFConfig()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func setUpApprovalDailyWidgetTimesheetEntryDetailsUI() {
        let tablesQuery = app.tables["daily_widget_details_tableview"]
        waitForElementToAppear(tablesQuery)
        if tablesQuery.exists {
            checkShowingDataCorrectlyOrNot()
        }
    }
    
    func checkShowingDataCorrectlyOrNot(){
        let detailsTable = app.tables["daily_widget_details_tableview"]
        waitForElementToAppear(detailsTable)
        if(detailsTable.exists){
            let staticTextOfFirstCell = detailsTable.cells.elementBoundByIndex(0)
                .staticTexts["desc_lbl"]
            let staticTextOfSecondCell = detailsTable.cells.elementBoundByIndex(1)
                .staticTexts["desc_lbl"]
            let staticTextOfThirdCell = detailsTable.cells.elementBoundByIndex(2)
                .staticTexts["desc_lbl"]
            
            let textOEFValue  = staticTextOfFirstCell.value
            let numericOEFValue  = staticTextOfSecondCell.value
            let dropDownOEFValue = staticTextOfThirdCell.value
            
            XCTAssertEqual(textOEFValue as? String, config.oef.text)
            XCTAssertEqual(numericOEFValue as? String, config.oef.numeric)
            XCTAssertEqual(dropDownOEFValue as? String, config.oef.dropDown)
        }
        let logoutUITest = LogoutUITest()
        logoutUITest.setUpLogOut(false, index: 1)
    }
}
