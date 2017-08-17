import XCTest

class ManualPunchTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }
    

    func addClockInMissingPunch() {
        let clockInSegmentButton = XCUIApplication().segmentedControls["punch_type_segment_control"].buttons.element(boundBy: 0)
        waitForElementToAppear(clockInSegmentButton)
        waitForHittable(clockInSegmentButton)
        clockInSegmentButton.tap()
    }
    
    func addBreakMissingPunch() {
        let breakSegmentButton = XCUIApplication().segmentedControls["punch_type_segment_control"].buttons.element(boundBy: 1)
        waitForElementToAppear(breakSegmentButton)
        waitForHittable(breakSegmentButton)
        breakSegmentButton.tap()
    }

    func addClockOutMissingPunch() {
        let clockOutSegmentButton = XCUIApplication().segmentedControls["punch_type_segment_control"].buttons.element(boundBy: 2)
        waitForElementToAppear(clockOutSegmentButton)
        waitForHittable(clockOutSegmentButton)
        clockOutSegmentButton.tap()
    }

    func selectTimeToAddPunch(_ dateString:String) {
        let manualPunchTableElement = XCUIApplication().tables["manual_punch_table_view"]
        waitForElementToAppear(manualPunchTableElement)
        
        let dateAndTimeCell = manualPunchTableElement.cells.element(boundBy: 1)
        waitForElementToAppear(dateAndTimeCell)
        dateAndTimeCell.tap()
        
        let hString =  getHourString(dateString) as String
        let mString =  getMinuteString(dateString) as String
        let manualPunchDatePicker = XCUIApplication().datePickers["manual_punch_date_picker"]
        manualPunchDatePicker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: hString)
        manualPunchDatePicker.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: mString)
        
        let toolBarDoneButton = XCUIApplication().toolbars.buttons["manual_punch_toolbar_done_btn"]
        toolBarDoneButton.tap()
    }

    func saveManualPunch() {
        let saveBarButton = XCUIApplication().buttons["missing_punch_save_btn"]
        waitForElementToAppear(saveBarButton)
        saveBarButton.tap()
    }


    func tapOnBreakCell() {
        let manualPunchTableElement = XCUIApplication().tables["manual_punch_table_view"]
        waitForElementToAppear(manualPunchTableElement)

        let breakTypeCell = manualPunchTableElement.cells.element(boundBy: 0)
        waitForElementToAppear(breakTypeCell)
        breakTypeCell.tap()
    }
}
