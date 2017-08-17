import XCTest

class RowLevelUDFTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }
    
    let timeEntryTableIdentifier = "uia_time_entry_table_identifier"
    let timeEntrytitleLabelIdentifier = "uia_timesheet_day_label_identifier"
    let timeEntryValueLabelIdentifier = "uia_row_level_udf_value_identifier"
    let dropdownIdentifier = "uia_dropdown_table_identifier"
    let datePickerIdentifier = "uia_row_level_date_udf_picker_identifier"
    let toolbarIdentifier = "uia_row_level_toolbar_identifier"
    let doneButtonIdentifier = "uia_row_level_date_picker_done_btn_identifier"
    let textviewIdentifier = "uia_description_text_view_identifier"
    let descriptionDonebuttonIdentifier = "uia_description_done_button_identifier"
    let timeEntryValueNumericTextfieldIdentifier = "uia_row_level_numeric_udf_value_identifier"


    func verifyTitlesOfUdfAndItsDefaultValues(_ sheetLevelUDFsArray : [Udf], index : UInt) {

        for i in 0...sheetLevelUDFsArray.count-1 {
            let udfObject : Udf = sheetLevelUDFsArray[i]
            let udfIndex = UInt(i)
            let timeEntryRowTableElement = XCUIApplication().tables[timeEntryTableIdentifier]
            waitForElementToAppear(timeEntryRowTableElement)
            let cell = timeEntryRowTableElement.cells.element(boundBy: udfIndex+index)
            waitForElementToAppear(cell)
            let udfTitleElement = cell.staticTexts[timeEntrytitleLabelIdentifier]
            waitForElementToAppear(udfTitleElement)
            assertEqualStrings(udfTitleElement.label, value2: udfObject.udfTitle!)

            if(udfObject.udfType == UdfType.NumericUdf.rawValue)
            {
                let udfValueElement = cell.textFields[timeEntryValueNumericTextfieldIdentifier]
                waitForElementToAppear(udfValueElement)
                assertEqualStrings(udfValueElement.value as! String, value2: udfObject.defaultValue!)

            }
            else
            {
                let udfValueElement = cell.staticTexts[timeEntryValueLabelIdentifier]
                waitForElementToAppear(udfValueElement)
                assertEqualStrings(udfValueElement.label, value2: udfObject.defaultValue!)
            }
        }

    }

    func verifyTitlesOfUdfAndItsUserValuesEntered(_ sheetLevelUDFsArray : [Udf] , index : UInt) {

        for i in 0...sheetLevelUDFsArray.count-1 {
            let udfObject : Udf = sheetLevelUDFsArray[i]
            let udfIndex = UInt(i)

            let timeEntryRowTableElement = XCUIApplication().tables[timeEntryTableIdentifier]
            waitForElementToAppear(timeEntryRowTableElement)
            let cell = timeEntryRowTableElement.cells.element(boundBy: udfIndex+index)
            waitForElementToAppear(cell)
            let udfTitleElement = cell.staticTexts[timeEntrytitleLabelIdentifier]
            waitForElementToAppear(udfTitleElement)
            assertEqualStrings(udfTitleElement.label, value2: udfObject.udfTitle!)

            if(udfObject.udfType == UdfType.NumericUdf.rawValue)
            {
                let udfValueElement = cell.textFields[timeEntryValueNumericTextfieldIdentifier]
                waitForElementToAppear(udfValueElement)
                assertEqualStrings(udfValueElement.value as! String, value2: udfObject.udfValue)

            }
            else
            {
                if(udfObject.udfType != UdfType.DateUdf.rawValue){

                    let udfValueElement = cell.staticTexts[timeEntryValueLabelIdentifier]
                    waitForElementToAppear(udfValueElement)
                    assertEqualStrings(udfValueElement.label, value2: udfObject.udfValue)
                }


            }
        }

    }

    func fillAllUdfWithValues(_ sheetLevelUDFsArray : [Udf] , index : UInt) {

        for i in 0...sheetLevelUDFsArray.count-1 {
            let udfObject : Udf = sheetLevelUDFsArray[i]
            let udfIndex = UInt(i)

            let timeEntryRowTableElement = XCUIApplication().tables[timeEntryTableIdentifier]
            waitForElementToAppear(timeEntryRowTableElement)
            let cell = timeEntryRowTableElement.cells.element(boundBy: udfIndex+index)
            waitForElementToAppear(cell)
            cell.tap()

            if (udfObject.udfType == UdfType.DropDownUdf.rawValue)
            {
                let dropdownTableElement = XCUIApplication().tables[dropdownIdentifier]
                waitForElementToAppear(dropdownTableElement)
                let dropdownOptionValueElement = dropdownTableElement.staticTexts[udfObject.udfValue]
                waitForElementToAppear(dropdownOptionValueElement)
                dropdownOptionValueElement.tap()

            }
            else if(udfObject.udfType == UdfType.DateUdf.rawValue)
            {

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
                let secriptionTextViewElement = XCUIApplication().textViews[textviewIdentifier]
                waitForElementToAppear(secriptionTextViewElement)
                secriptionTextViewElement.clearAndEnterText(udfObject.udfValue);

                let saveButtonElement = XCUIApplication().navigationBars.buttons[descriptionDonebuttonIdentifier];
                waitForElementToAppear(saveButtonElement)
                saveButtonElement.tap()
            }
            else if(udfObject.udfType == UdfType.NumericUdf.rawValue)
            {
                let udfElement = cell.textFields[timeEntryValueNumericTextfieldIdentifier]
                waitForElementToAppear(udfElement)
                udfElement.clearAndEnterText(udfObject.udfValue);
            }
        }
    }


}

