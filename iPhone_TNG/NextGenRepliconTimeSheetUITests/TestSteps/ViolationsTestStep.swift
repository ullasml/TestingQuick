
import Foundation
import XCTest

class ViolationsTestStep: BaseTestStep {

    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    func verifyCorrectnessOfViolationsCount(_ violations : Int) {
        let violationsButtonElement = ViolationsButtonElement()
        waitForElementToAppear(violationsButtonElement)
        waitForHittable(violationsButtonElement);
        let violationsText : String = violationsButtonElement.label
        let violationString = violations > 1 ? "Violations" : "Violation"
        let serializedviolationString = "\(violations) \(violationString)"
        assertEqualStrings(violationsText, value2:serializedviolationString )
    }

    func tapToViewViolations() {
        let violationsButtonElement = ViolationsButtonElement()
        scrollDownUntilElementAppears(violationsButtonElement)
        waitForElementToAppear(violationsButtonElement)
        waitForHittable(violationsButtonElement);
        violationsButtonElement.tap()
    }

    func verifyViolations(_ allViolations: Array<Violation>) {
        let violationsTableElement = ViolationsTableElement()
        waitForElementToAppear(violationsTableElement)
        let cellsCount = violationsTableElement.cells.count;
        for i in 0...cellsCount-1 {
            let violationCell = violationsTableElement.cells.element(boundBy: i)
            let violationTitleLabelElement = violationCell.staticTexts["uia_violation_title_label"]
            waitForElementToAppear(violationTitleLabelElement)
            let violation : Violation = allViolations[toInt(i)]
            let labelText : String = violationTitleLabelElement.label
            assertEqualStrings(labelText, value2: violation.title)

            let violationStatusLabelElement = violationCell.staticTexts["uia_violation_status_label"]
            waitForElementToAppear(violationStatusLabelElement)
            let statusLabelText : String = violationStatusLabelElement.label
            assertEqualStrings(statusLabelText, value2: violation.defaultStatus)

        }

    }

    func verifyViolationOnIndexAfterAccepting(_ allViolations: Array<Violation>,index : UInt) -> () {
        let violationsTableElement = ViolationsTableElement()
        waitForElementToAppear(violationsTableElement)

        let violationCell = violationsTableElement.cells.element(boundBy: index)
        let violationTitleLabelElement = violationCell.staticTexts["uia_violation_title_label"]
        waitForElementToAppear(violationTitleLabelElement)
        let violation : Violation = allViolations[toInt(index)]
        let labelText : String = violationTitleLabelElement.label
        assertEqualStrings(labelText, value2: violation.title)

        let violationStatusLabelElement = violationCell.staticTexts[(violation.waiver?.acceptTitle)!]
        waitForElementToAppear(violationStatusLabelElement)
    }

    func acceptViolationOnIndex(_ allViolations: Array<Violation>,index : UInt) {
        let violationsTableElement = ViolationsTableElement()
        let violationCell = violationsTableElement.cells.element(boundBy: index)
        waitForElementToAppear(violationCell)
        waitForHittable(violationCell);
        violationCell.tap()

        let violationsButtonElement = XCUIApplication().buttons["uia_violation_waiver_response_button_identifier"];
        waitForElementToAppear(violationsButtonElement)
        waitForHittable(violationsButtonElement);
        violationsButtonElement.tap()

        let breakTypeElement = XCUIApplication().sheets["Change Waiver Response"]
        waitForElementToAppear(breakTypeElement)
        waitForHittable(breakTypeElement, waitSeconds: 120)
        let violation : Violation = allViolations[toInt(index)]
        let breakEntry = breakTypeElement.buttons[(violation.waiver?.acceptTitle)!]
        waitForElementToAppear(breakEntry)
        breakEntry.tap()

    }


    fileprivate func ViolationsTableElement() -> XCUIElement{

        let violationsButtonElement = XCUIApplication().tables["uia_violations_table_identifier"];
        waitForElementToAppear(violationsButtonElement)
        waitForHittable(violationsButtonElement);
        return violationsButtonElement;
    }

    fileprivate func ViolationsButtonElement() -> XCUIElement{
        let violationsButtonElement = XCUIApplication().buttons["uia_violations_button_identifier"];
        waitForElementToAppear(violationsButtonElement)
        waitForHittable(violationsButtonElement);
        return violationsButtonElement;
    }

    fileprivate func scrollToCellOnIndex(_ index:UInt) {
        let violationsTableElement = ViolationsTableElement()
        let timesheetCell = violationsTableElement.cells.element(boundBy: index)
        waitForElementToAppear(timesheetCell)
        waitForHittable(timesheetCell)
        violationsTableElement.scrollToElement(timesheetCell)
    }

}
