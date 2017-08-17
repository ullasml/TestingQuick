import XCTest

class SheetLevelUDFTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    let udfViewIdentifier = "uia_udf_view_identifier"
    let timeEntryTableIdentifier = "uia_timesheet_day_entry_view_details_table_identifier"
    let timeEntrytitleLabelIdentifier = "uia_timesheet_level_udf_title_identifier"
    let timeEntryValueLabelIdentifier = "uia_timesheet_level_udf_value_identifier"
    let timeEntryValueNumericTextfieldIdentifier = "uia_timesheet_level_numeric_udf_value_identifier"
    let dropdownIdentifier = "uia_dropdown_table_identifier"
    let textviewIdentifier = "uia_description_text_view_identifier"
    let descriptionDonebuttonIdentifier = "uia_description_done_button_identifier"
    let toolbarIdentifier = "uia_current_timesheet_toolbar_identifier"
    let doneButtonIdentifier = "uia_timesheet_level_date_picker_done_btn_identifier"
    let datePickerIdentifier = "uia_timesheet_level_date_udf_picker_identifier"
    

    func verifyTitlesOfUdfAndItsDefaultValues(_ sheetLevelUDFsArray : [Udf]) {

        let udfViewElement = XCUIApplication().descendants(matching: .other).matching(identifier: udfViewIdentifier)
        for i in 0...sheetLevelUDFsArray.count-1 {
            let udfObject : Udf = sheetLevelUDFsArray[i]
            let udfIndex = UInt(i)
            let udfTitleElement = udfViewElement.element(boundBy: udfIndex).staticTexts[timeEntrytitleLabelIdentifier]
            waitForElementToAppear(udfTitleElement)
            assertEqualStrings(udfTitleElement.label, value2: udfObject.udfTitle!)

            if(udfObject.udfType == UdfType.NumericUdf.rawValue)
            {
                let udfValueElement = udfViewElement.element(boundBy: udfIndex).textFields[timeEntryValueNumericTextfieldIdentifier]
                waitForElementToAppear(udfValueElement)
                assertEqualStrings(udfValueElement.value as! String, value2: udfObject.defaultValue!)

            }
            else
            {
                let udfValueElement = udfViewElement.element(boundBy: udfIndex).staticTexts[timeEntryValueLabelIdentifier]
                waitForElementToAppear(udfValueElement)
                assertEqualStrings(udfValueElement.label, value2: udfObject.defaultValue!)
            }
        }
        
    }

    func verifyTitlesOfUdfAndItsUserValuesEntered(_ sheetLevelUDFsArray : [Udf]) {

        let udfViewElement = XCUIApplication().descendants(matching: .other).matching(identifier: udfViewIdentifier)
        for i in 0...sheetLevelUDFsArray.count-1 {
            let udfObject : Udf = sheetLevelUDFsArray[i]
            let udfIndex = UInt(i)
            let udfTitleElement = udfViewElement.element(boundBy: udfIndex).staticTexts[timeEntrytitleLabelIdentifier]
            waitForElementToAppear(udfTitleElement)
            assertEqualStrings(udfTitleElement.label, value2: udfObject.udfTitle!)

            if(udfObject.udfType == UdfType.NumericUdf.rawValue)
            {
                let udfValueElement = udfViewElement.element(boundBy: udfIndex).textFields[timeEntryValueNumericTextfieldIdentifier]
                waitForElementToAppear(udfValueElement)
                assertEqualStrings(udfValueElement.value as! String, value2: udfObject.udfValue)

            }
            else
            {
                let udfValueElement = udfViewElement.element(boundBy: udfIndex).staticTexts[timeEntryValueLabelIdentifier]
                waitForElementToAppear(udfValueElement)
                assertEqualStrings(udfValueElement.label, value2: udfObject.udfValue)
            }
        }
        
    }

    func fillAllUdfWithValues(_ sheetLevelUDFsArray : [Udf]) {

        let udfViewElement = XCUIApplication().descendants(matching: .other).matching(identifier: udfViewIdentifier)
        for i in 0...sheetLevelUDFsArray.count-1 {
            let udfObject : Udf = sheetLevelUDFsArray[i]
            let udfIndex = UInt(i)
            if (udfObject.udfType == UdfType.DropDownUdf.rawValue)
            {
                let udfElement = udfViewElement.element(boundBy: udfIndex).staticTexts[timeEntryValueLabelIdentifier]
                waitForElementToAppear(udfElement)
                udfElement.tap()

                let dropdownTableElement = XCUIApplication().tables[dropdownIdentifier]
                waitForElementToAppear(dropdownTableElement)
                let dropdownOptionValueElement = dropdownTableElement.staticTexts[udfObject.udfValue]
                waitForElementToAppear(dropdownOptionValueElement)
                dropdownOptionValueElement.tap()

            }
            else if(udfObject.udfType == UdfType.DateUdf.rawValue)
            {
                let udfElement = udfViewElement.element(boundBy: udfIndex).staticTexts[timeEntryValueLabelIdentifier]
                waitForElementToAppear(udfElement)
                udfElement.tap()

                let datePicker = XCUIApplication().datePickers[datePickerIdentifier]

                let udfDate = RDate.parse(udfObject.udfValue,format: "MMMM d, yyyy")
                let year = RDate.yearFromDate(udfDate)
                let day = RDate.dayFromDate(udfDate)
                let month = RDate.getMonthFromDate(udfDate)

                datePicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: month)
                datePicker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "\(day!)")
                datePicker.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "\(year!)")

                let toolBarElement = XCUIApplication().toolbars[toolbarIdentifier]
                waitForElementToAppear(toolBarElement)
                let doneButtonPicker = toolBarElement.buttons[doneButtonIdentifier]
                waitForElementToAppear(doneButtonPicker)
                doneButtonPicker.tap()
            }
            else if(udfObject.udfType == UdfType.TextUdf.rawValue)
            {
                let udfElement = udfViewElement.element(boundBy: udfIndex).staticTexts[timeEntryValueLabelIdentifier]
                waitForElementToAppear(udfElement)
                udfElement.tap()

                let secriptionTextViewElement = XCUIApplication().textViews[textviewIdentifier]
                waitForElementToAppear(secriptionTextViewElement)
                secriptionTextViewElement.clearAndEnterText(udfObject.udfValue);
                waitForElementToAppear(XCUIApplication().textViews[udfObject.udfValue])

                let saveButtonElement = XCUIApplication().navigationBars.buttons[descriptionDonebuttonIdentifier];
                waitForElementToAppear(saveButtonElement)
                saveButtonElement.tap()
            }
            else if(udfObject.udfType == UdfType.NumericUdf.rawValue)
            {
                let udfElement = udfViewElement.element(boundBy: udfIndex).textFields[timeEntryValueNumericTextfieldIdentifier]
                waitForElementToAppear(udfElement)
                udfElement.clearAndEnterText(udfObject.udfValue);
            }
        }
    }
    

}
