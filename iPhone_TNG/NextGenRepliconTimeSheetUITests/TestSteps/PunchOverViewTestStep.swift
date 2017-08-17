
import XCTest



class PunchOverViewTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }
    
    func editPunchTime(_ dateString:String) {
        let punchDetailsTableElement = XCUIApplication().tables["punch_details_table_view"]
        waitForElementToAppear(punchDetailsTableElement)
        
        let dateAndTimeCell = punchDetailsTableElement.cells.element(boundBy: 1)
        waitForElementToAppear(dateAndTimeCell)
        dateAndTimeCell.tap()
        
        let hString =  getHourString(dateString) as String
        let mString =  getMinuteString(dateString) as String
        let punchDetailsDatePicker = XCUIApplication().datePickers["punch_details_date_picker"]
        punchDetailsDatePicker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: hString)
        punchDetailsDatePicker.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: mString)
        
        let toolBarDoneButton = XCUIApplication().toolbars.buttons["punch_details_toolbar_done_btn"]
        toolBarDoneButton.tap()
    }
    
    func savePunch() {
        let saveBarButton = XCUIApplication().buttons["punch_details_save_btn"]
        waitForElementToAppear(saveBarButton)
        saveBarButton.tap()
    }

    func deletePunch() {
        let deleteButton = XCUIApplication().buttons["punch_delete_btn"]
        waitForElementToAppear(deleteButton)
        waitForHittable(deleteButton, waitSeconds: 120)
        deleteButton.tap()
        
        let deletePunchSheetElement = XCUIApplication().sheets["Are you sure you want to delete this punch?"]
        waitForElementToAppear(deletePunchSheetElement)
        waitForHittable(deletePunchSheetElement, waitSeconds: 120)
        let deletePunchButton = deletePunchSheetElement.buttons[Constants.delete_button_identifier];    waitForElementToAppear(deletePunchButton)
        waitForHittable(deletePunchButton, waitSeconds: 120)
        deletePunchButton.tap()

    }
}

