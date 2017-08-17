
import XCTest

class TimeLineTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }
    
    func tapOnTimelinePunchWithIndex(_ index:UInt) {
        let timeLineTableElement = XCUIApplication().tables["timeline_entry_tableview"]
        waitForElementToAppear(timeLineTableElement)
        
        let timeLineCellElement = timeLineTableElement.cells.element(boundBy: index);
        waitForElementToAppear(timeLineCellElement)
        timeLineCellElement.tap()
    }


    func tapToAddManualPunch(_ index:UInt) {
        let timeLineTableElement = XCUIApplication().tables["timeline_entry_tableview"]
        waitForElementToAppear(timeLineTableElement)
        
        let timeLineCellElement = timeLineTableElement.cells.element(boundBy: index);
        waitForElementToAppear(timeLineCellElement)
        timeLineCellElement.tap()
    }

    func verifyPunchTime(_ timeString:String,index:UInt) {
        let timeLineTableElement = XCUIApplication().tables["timeline_entry_tableview"]
        waitForElementToAppear(timeLineTableElement)
        
        let timeLineCellElement = timeLineTableElement.cells.element(boundBy: index);
        waitForElementToAppear(timeLineCellElement)
        
        let timeLineEntryLabelElement = timeLineCellElement.staticTexts["timeline_time_entry_lbl"]
        waitForElementToAppear(timeLineEntryLabelElement)
        let labelText : String = timeLineEntryLabelElement.label
        assertEqualStrings(labelText, value2: timeString)
    }
    
    func verifyTimeLinePunchEntry(_ punchEntry:String,index:UInt) {
        let timeLineTableElement = XCUIApplication().tables["timeline_entry_tableview"]
        waitForElementToAppear(timeLineTableElement)
        
        let timeLineCellElement = timeLineTableElement.cells.element(boundBy: index);
        waitForElementToAppear(timeLineCellElement)
        
        let timeLineEntryLabelElement = timeLineCellElement.staticTexts["timeline_punch_entry_lbl"]
        waitForElementToAppear(timeLineEntryLabelElement)
        let labelText : String = timeLineEntryLabelElement.label
        assertEqualStrings(labelText, value2: punchEntry)
    }

    func scrollToCellOnIndex(_ index:UInt) {
        let timesheetBreakdownTableElement = XCUIApplication().tables["timeline_entry_tableview"]
        let timesheetCell = timesheetBreakdownTableElement.cells.element(boundBy: index)
        waitForElementToAppear(timesheetCell)
        waitForHittable(timesheetCell)
        timesheetBreakdownTableElement.scrollToElement(timesheetCell)
    }
    
    func verifyTimeLinePunchEntrySubStrings(_ entryOef : [OefType], punchAction: String,index:UInt) {
        let timeLineTableElement = XCUIApplication().tables["timeline_entry_tableview"]
        waitForElementToAppear(timeLineTableElement)
        
        let timeLineCellElement = timeLineTableElement.cells.element(boundBy: index);
        waitForElementToAppear(timeLineCellElement)
        
        let timeLineEntryLabelElement = timeLineCellElement.staticTexts["timeline_punch_entry_lbl"]
        waitForElementToAppear(timeLineEntryLabelElement)
        let labelText : String = timeLineEntryLabelElement.label
        let oefTypesArray = entryOef
        for oef: OefType in oefTypesArray {
            let oefValue = oef.oefValue
            let isContainsString =  String(labelText).isContainsSubString(oefValue)
            XCTAssertTrue(isContainsString)
        }
        
        let isContainsString =  String(labelText).isContainsSubString(punchAction)
        XCTAssertTrue(isContainsString)
    }
}
