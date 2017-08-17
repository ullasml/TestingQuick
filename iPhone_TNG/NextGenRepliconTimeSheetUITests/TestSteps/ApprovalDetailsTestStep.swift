
import Foundation
import XCTest

class ApprovalDetailsTestStep: BaseTestStep {

    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    func verifyApprovalDetails(_ approvalSummary:[ApprovalInfo]) {

        for i in 0...approvalSummary.count - 1 {
            let status = approvalSummary[i].status
            let listOfTimesheetTableElement = XCUIApplication().tables["uia_approvers_table_identifier"]
            waitForElementToAppear(listOfTimesheetTableElement)

            let firstCell = listOfTimesheetTableElement.cells.element(boundBy: UInt(i*2))
            waitForElementToAppear(firstCell.staticTexts[status!])
        }

    }
}
