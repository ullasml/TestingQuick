
import XCTest

class WorkAndBreakHoursTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    func verifyWorkHours(_ workHours:String,onIndex: UInt) {
        verifyHours(workHours,index:onIndex)
    }

    func verifyBreakHours(_ breakHours:String,onIndex: UInt) {
        verifyHours(breakHours,index:onIndex)
    }

    func verifyHours(_ hours : String , index : UInt) {
        let hoursSummaryCollectionViewElement = XCUIApplication().collectionViews["uia_work_break_overtime_hours_collectionview_identifier"]
        waitForElementToAppear(hoursSummaryCollectionViewElement)
        waitForHittable(hoursSummaryCollectionViewElement, waitSeconds: 120)

        let hoursLabelElement = hoursSummaryCollectionViewElement.children(matching: .cell).element(boundBy: index).staticTexts[hours]
        waitForElementToAppear(hoursLabelElement)
        let hoursText : String = hoursLabelElement.label
        assertEqualStrings(hoursText, value2: hours)
    }
    
    fileprivate func getMinuteStringFromFormattedTime(_ text: String) -> String {
        let hourAndMinuteArray = text.components(separatedBy: ":")
        var minuteString: String = hourAndMinuteArray[1]
        minuteString = minuteString.replacingOccurrences(of: "m", with: "", options: NSString.CompareOptions.literal, range: nil)
        return minuteString
    }
}
