
import XCTest
import Foundation

class TimesheetDayEntriesTestStep: BaseTestStep {

    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    func tapOnAddTimeEntryRowForTimesheet()
    {
        let plusButton = XCUIApplication().buttons[Constants.navigationbarPlusButton]
        let addButon = XCUIApplication().buttons[Constants.navigationbarAddButton]
        let timeentryAddButton = XCUIApplication().buttons["time_dist_add_btn"]
        if(plusButton.exists){
            waitForElementToAppear(plusButton)
            plusButton.tap()
        }
        else if(addButon.exists){
            waitForElementToAppear(addButon)
            addButon.tap()
        }
        else if(timeentryAddButton.exists){
            waitForElementToAppear(timeentryAddButton)
            timeentryAddButton.tap()
        }
    }

    func tapOnAddTimeoffEntryForTimesheet()
    {
        let timeoffAddButton = XCUIApplication().buttons["uia_timeoff_button_identifier"]
        waitForElementToAppear(timeoffAddButton)
        timeoffAddButton.tap()
    }

    func tapOnAddTimeEntryRowForTimesheetForEmptyTimeEntry()
    {
        var barButonAdd = XCUIApplication().buttons[Constants.barButtonAddId]
        if(!barButonAdd.exists){
            barButonAdd = XCUIApplication().buttons["time_dist_add_btn"]
        }
        waitForElementToAppear(barButonAdd)
        barButonAdd.tap()
        
        let timeEntryRowTableElement = XCUIApplication().tables["time_entry_tbl_view"]
        waitForElementToAppear(timeEntryRowTableElement)
        
        let firstCell = timeEntryRowTableElement.cells.element(boundBy: 1)
        waitForElementToAppear(firstCell)
        firstCell.tap()
    }

    func addTimeEntryRowForTimesheet(_ standardTimesheetRowAttributes :TimesheetRowAttributes? ) {

        let timeEntryRowTableElement = XCUIApplication().tables["uia_time_entry_table_identifier"]
        waitForElementToAppear(timeEntryRowTableElement)

        let firstCell = timeEntryRowTableElement.cells.element(boundBy: 0)
        waitForElementToAppear(firstCell)
        waitForHittable(firstCell)
        firstCell.tap()
        
        let clientSegment = XCUIApplication().segmentedControls["segment_clients_projects"].buttons.element(boundBy: 1)
        waitForHittable(clientSegment)
        clientSegment.tap()

        let clientSelectionTableElement = XCUIApplication().tables["select_client_tbl_view"]
        waitForElementToAppear(clientSelectionTableElement)

        let firstClientSelectionCell = clientSelectionTableElement.cells.element(boundBy: 0)
        waitForElementToAppear(firstClientSelectionCell.staticTexts[(standardTimesheetRowAttributes?.client)!])
        firstClientSelectionCell.tap()

        let projectSelectionTableElement = XCUIApplication().tables["select_task_tbl_view"]
        waitForElementToAppear(projectSelectionTableElement)

        let firstProjectSelectionCell = projectSelectionTableElement.cells.element(boundBy: 0)
        waitForElementToAppear(firstProjectSelectionCell.staticTexts[(standardTimesheetRowAttributes?.project)!])
        waitForHittable(firstProjectSelectionCell)
        firstProjectSelectionCell.tap()


        if(standardTimesheetRowAttributes!.taskAllowed)
        {
            let taskSelectionTableElement = XCUIApplication().tables["select_task_tbl_view"]
            waitForElementToAppear(taskSelectionTableElement)

            let firstTaskSelectionCell = taskSelectionTableElement.cells.element(boundBy: 0)
            waitForElementToAppear(firstTaskSelectionCell.staticTexts[(standardTimesheetRowAttributes?.task)!])
            waitForHittable(firstTaskSelectionCell)
            firstTaskSelectionCell.tap()
        }
    }

    func addTimeEntryRowForTimesheet(_ standardTimesheetRowAttributes :StandardTimesheetRowAttributes? ) {
        
        let timeEntryRowTableElement = XCUIApplication().tables["uia_time_entry_table_identifier"]
        waitForElementToAppear(timeEntryRowTableElement)
        
        let firstCell = timeEntryRowTableElement.cells.element(boundBy: 0)
        waitForElementToAppear(firstCell)
        waitForHittable(firstCell)
        firstCell.tap()
        
        let clientSegment = XCUIApplication().segmentedControls["segment_clients_projects"].buttons.element(boundBy: 1)
        waitForElementToAppear(clientSegment)
        waitForHittable(clientSegment)
        clientSegment.tap()
        
        let clientSelectionTableElement = XCUIApplication().tables["select_client_tbl_view"]
        waitForElementToAppear(clientSelectionTableElement)
        
        let firstClientSelectionCell = clientSelectionTableElement.cells.element(boundBy: 0)
        waitForElementToAppear(firstClientSelectionCell.staticTexts[(standardTimesheetRowAttributes?.client)!])
        firstClientSelectionCell.tap()
        
        //Use this if you imitate user search for projects
        let projectSelectionTableElement = XCUIApplication().tables["select_task_tbl_view"]
        waitForElementToAppear(projectSelectionTableElement)
        
        let firstProjectSelectionCell = projectSelectionTableElement.cells.element(boundBy: 0)
        waitForElementToAppear(firstProjectSelectionCell.staticTexts[(standardTimesheetRowAttributes?.project)!])
        waitForHittable(firstProjectSelectionCell)
        firstProjectSelectionCell.tap()
        
        
        //Use this if you imitate user search for tasks
        //waitForElementToAppear(XCUIApplication().navigationBars.staticTexts["Select a Task"])
        
        if(standardTimesheetRowAttributes!.taskAllowed)
        {
            let taskSelectionTableElement = XCUIApplication().tables["select_task_tbl_view"]
            waitForElementToAppear(taskSelectionTableElement)
            
            let firstTaskSelectionCell = taskSelectionTableElement.cells.element(boundBy: 0)
            waitForElementToAppear(firstTaskSelectionCell.staticTexts[(standardTimesheetRowAttributes?.task)!])
            waitForHittable(firstTaskSelectionCell)
            firstTaskSelectionCell.tap()
        }
        
        let saveBarButton = XCUIApplication().buttons["time_entry_save_btn"]
        waitForElementToAppear(saveBarButton)
        waitForHittable(saveBarButton)
        saveBarButton.tap()
    }
    
    func addBreakEntryRowForTimesheet(_ standardTimesheetRowAttributes :TimesheetRowAttributes? ) {

        let breakSegment = XCUIApplication().segmentedControls["uia_time_entry_segment_control_identifier"].buttons["Add Break"]
        waitForHittable(breakSegment)
        breakSegment.tap()

        let timeEntryRowTableElement = XCUIApplication().tables["uia_time_entry_table_identifier"]
        waitForElementToAppear(timeEntryRowTableElement)

        let breakEntry = standardTimesheetRowAttributes!.breaks![0]
        let firstCell = timeEntryRowTableElement.cells.staticTexts[breakEntry]
        waitForElementToAppear(firstCell)
        waitForHittable(firstCell)
        firstCell.tap()
    }

    func tapOnDay(_ day : String) -> () {
        let dayButtonElement = XCUIApplication().buttons[day]
        waitForElementToAppear(dayButtonElement)
        waitForHittable(dayButtonElement)
        dayButtonElement.tap()
    }

    func tapOnSuggestionView(_ suggestion : String) -> () {
        print(XCUIApplication().debugDescription)
        let timeEntryRowsTableElement = XCUIApplication().tables["uia_inout_timesheet_entry_table_identifier"]

        let suggestionElement = timeEntryRowsTableElement.staticTexts[suggestion]
        waitForHittable(suggestionElement)
        suggestionElement.tap()
    }


    func enterHoursForADayOnStandardTimesheet(_ timeEntries:[TimeEntry]) {

        let timeEntryRowsTableElement = XCUIApplication().tables["uia_standard_timesheet_entry_table_identifier"]
        waitForElementToAppear(timeEntryRowsTableElement)

        let count = timeEntries.count
        for i in 0...count-1 {
            let hours = timeEntries[i]

            if hours.type == EntryType.Time.rawValue {
                let timeEntryTextField = timeEntryRowsTableElement.textFields["uia_standard_timesheet_time_entry_textfield_identifier"]
                waitForElementToAppear(timeEntryTextField)
                timeEntryTextField.tap()
                timeEntryTextField.clearAndEnterText(hours.value)

                let toolbarElement = XCUIApplication().toolbars["standard_timesheet_toolbar_label"]
                let toolbarDoneButtonElement = toolbarElement.buttons["standard_timesheet_done_button_label"]
                waitForElementToAppear(toolbarDoneButtonElement)
                toolbarDoneButtonElement.tap()
            }

        }
    }

    func enterHoursForADay(_ hours:String) {
        
        let timeEntryRowsTableElement = XCUIApplication().tables["uia_standard_timesheet_entry_table_identifier"]
        waitForElementToAppear(timeEntryRowsTableElement)
        
        let timeEntryTextField = timeEntryRowsTableElement.textFields["uia_standard_timesheet_time_entry_textfield_identifier"]
        waitForElementToAppear(timeEntryTextField)
        timeEntryTextField.tap()
        timeEntryTextField.clearAndEnterText(hours)
        
        let toolbarElement = XCUIApplication().toolbars["standard_timesheet_toolbar_label"]
        let toolbarDoneButtonElement = toolbarElement.buttons["standard_timesheet_done_button_label"]
        waitForElementToAppear(toolbarDoneButtonElement)
        toolbarDoneButtonElement.tap()
        
        
        
    }
    
    func enterHoursForADayOnExtendedInoutTimesheet(_ timeEntries:[InOutTime]) {

        let timeEntryRowsTableElement = XCUIApplication().tables["uia_inout_timesheet_entry_table_identifier"]
        waitForElementToAppear(timeEntryRowsTableElement)

        let count = timeEntries.count
        for i in 0...count-1 {
            let inOutTime = timeEntries[i]
            let index : UInt = UInt(i*2 + 1)
            let cell = timeEntryRowsTableElement.cells.element(boundBy: index)
            let intimeEntryTextField = cell.textFields["uia_inout_timesheet_in_time_value_textfield_identifier"]
            waitForElementToAppear(intimeEntryTextField)
            intimeEntryTextField.tap()
            intimeEntryTextField.clearAndEnterText(inOutTime.inTime!)

            let outtimeEntryTextField = cell.textFields["uia_inout_timesheet_out_time_value_textfield_identifier"]
            waitForElementToAppear(outtimeEntryTextField)
            outtimeEntryTextField.tap()
            outtimeEntryTextField.clearAndEnterText(inOutTime.outTime!)
        }

        let resignButtonElement = XCUIApplication().buttons["uia_keyboard_resign_button_identifier"]
        resignButtonElement.tap()
    }

    func saveTimesheet() {
        let saveTimesheetButton = XCUIApplication().navigationBars.buttons["save_time_dist_btn"]
        waitForElementToAppear(saveTimesheetButton)
        waitForHittable(saveTimesheetButton)
        saveTimesheetButton.tap()
    }
        
    func saveTimesheetEntry() {
        let saveBarButton = XCUIApplication().buttons["time_entry_save_btn"]
        waitForElementToAppear(saveBarButton)
        waitForHittable(saveBarButton)
        saveBarButton.tap()
    }

    func tapOnFirstEntryOfTimesheet() {
        let timeEntryRowsTableElement = XCUIApplication().tables["uia_standard_timesheet_entry_table_identifier"]
        waitForElementToAppear(timeEntryRowsTableElement)
        
        let firstCell = timeEntryRowsTableElement.cells.element(boundBy: 0)
        waitForElementToAppear(firstCell)
        firstCell.tap()
    }

    func tapOnBackButton() {
        let backButtonElement = XCUIApplication().navigationBars.buttons["Back"];
        waitForElementToAppear(backButtonElement)
        waitForHittable(backButtonElement);
        backButtonElement.tap();
    }

    func selectRowToCheckNegativeTime() {
    
        let listOfTimesheetTableElement = XCUIApplication().tables["uia_standard_timesheet_entry_table_identifier"]
        let firstCell = listOfTimesheetTableElement.cells.element(boundBy: 1)
        waitForElementToAppear(firstCell)
        waitForHittable(firstCell)
        firstCell.tap()
    }
    
    func verifyHoursForADayOnStandardTimesheet(_ timeEntries:[TimeEntry]) {
        
        let timeEntryRowsTableElement = XCUIApplication().tables["uia_standard_timesheet_entry_table_identifier"]
        waitForElementToAppear(timeEntryRowsTableElement)
        
        let count = timeEntries.count
        for i in 0...count-1 {
            let hours = timeEntries[i]
            let cell = timeEntryRowsTableElement.cells.element(boundBy: UInt(i))
            let timeEntryTextField = cell.staticTexts["uia_standard_timesheet_time_entry_textfield_identifier"]
            waitForElementToAppear(timeEntryTextField)
            let hoursValue :String =  timeEntryTextField.label
            
            assertEqualStrings(hours.value, value2: hoursValue)
        }
    }

}
