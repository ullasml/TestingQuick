

import Foundation
import XCTest

class WidgetTimesheetDetailsTestStep: BaseTestStep {

    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    func tapOnWidgetTimeDistributionToSeeTimesheetEntryDetails() {
        let dayViewTableElement = XCUIApplication().tables["widget_ts_entry_tableview"]
        waitForElementToAppear(dayViewTableElement)
        let firstCell = dayViewTableElement.cells.staticTexts["Time Distribution"]
        waitForElementToAppear(firstCell)
        waitForHittable(firstCell)
        firstCell.tap()
    }

    func tapOnApprovalsWidgetToSeeApprovalDetails() {
        let dayViewTableElement = XCUIApplication().tables["widget_ts_entry_tableview"]
        waitForElementToAppear(dayViewTableElement)
        let firstCell = dayViewTableElement.cells.staticTexts["Approval History"]
        waitForElementToAppear(firstCell)
        waitForHittable(firstCell)
        firstCell.tap()
    }

    func submitTimesheet() {

        let submitTimesheetElement = XCUIApplication().buttons["widget_timesheet_submit_btn"]
        waitForElementToAppear(submitTimesheetElement)
        waitForHittable(submitTimesheetElement, waitSeconds: 120)
        submitTimesheetElement.tap()

    }

    func tapOnBackButton() {

        let backButtonElement = XCUIApplication().navigationBars.buttons["Back"];
        waitForElementToAppear(backButtonElement)
        waitForHittable(backButtonElement);
        backButtonElement.tap();

    }

    func verifyTimesheetHoursOnTimeDistributionWidgetOnIndex(_ hours:String,index:UInt) {

        let dayViewTableElement = XCUIApplication().tables["widget_ts_entry_tableview"]
        waitForElementToAppear(dayViewTableElement)

        let widgetTimesheetTimeDistributionCellElement = dayViewTableElement.cells.element(boundBy: index);
        waitForElementToAppear(widgetTimesheetTimeDistributionCellElement)

        let widgetTimesheetTitleLabelElement = widgetTimesheetTimeDistributionCellElement.staticTexts["widget_title_label"]
        waitForElementToAppear(widgetTimesheetTitleLabelElement)
        let widgetTitle : String = widgetTimesheetTitleLabelElement.label
        assertEqualStrings(widgetTitle, value2: "Time Distribution")

        let widgetTimesheetHoursLabelElement = widgetTimesheetTimeDistributionCellElement.staticTexts[hours];
        waitForElementToAppear(widgetTimesheetHoursLabelElement)

    }

    func verifyTimeoffHoursOnTimeDistributionWidgetOnIndex(_ hours:String,index:UInt) {

        let dayViewTableElement = XCUIApplication().tables["widget_ts_entry_tableview"]
        waitForElementToAppear(dayViewTableElement)

        let widgetTimesheetTimeDistributionCellElement = dayViewTableElement.cells.element(boundBy: index);
        waitForElementToAppear(widgetTimesheetTimeDistributionCellElement)

        let widgetTimesheetTitleLabelElement = widgetTimesheetTimeDistributionCellElement.staticTexts["widget_title_label"]
        waitForElementToAppear(widgetTimesheetTitleLabelElement)
        let widgetTitle : String = widgetTimesheetTitleLabelElement.label
        assertEqualStrings(widgetTitle, value2: "Time Distribution")

        let widgetTimesheetHoursLabelElement = widgetTimesheetTimeDistributionCellElement.staticTexts[hours];
        waitForElementToAppear(widgetTimesheetHoursLabelElement)
        let totalTimesheetHours : String = widgetTimesheetHoursLabelElement.label
        assertEqualStrings(totalTimesheetHours, value2: hours)
        
    }

    func verifyHoursOnPayrollSummaryWidgetOnIndex(_ paysummary:[PayCodeInfo],totalHours: String , totalAmount : String ,index:UInt) {

        let dayViewTableElement = XCUIApplication().tables["widget_ts_entry_tableview"]
        waitForElementToAppear(dayViewTableElement)

        let widgetTimesheetTimeDistributionCellElement = dayViewTableElement.cells.element(boundBy: index);
        waitForElementToAppear(widgetTimesheetTimeDistributionCellElement)

        let widgetTimesheetTitleLabelElement = widgetTimesheetTimeDistributionCellElement.staticTexts["uia_payroll_summary_widget_title_label"]
        waitForElementToAppear(widgetTimesheetTitleLabelElement)
        let widgetTitle : String = widgetTimesheetTitleLabelElement.label
        assertEqualStrings(widgetTitle, value2: "Payroll Summary")

        let paycodeNameLabelsElement = widgetTimesheetTimeDistributionCellElement.descendants(matching: .staticText).matching(identifier: "uia_pay_code_name_label_identifier")

        let paycodeHourLabelsElement = widgetTimesheetTimeDistributionCellElement.descendants(matching: .staticText).matching(identifier: "uia_pay_code_hours_label_identifier")

        let paycodeAmountLabelsElement = widgetTimesheetTimeDistributionCellElement.descendants(matching: .staticText).matching(identifier: "uia_pay_code_amount_label_identifier")

        for i in 0...paysummary.count-1 {
            let paycode = paysummary[i]
            let hours = paycode.hours
            let name = paycode.name
            let amount = paycode.amount

            let paycodeNameLabelElement = paycodeNameLabelsElement.element(boundBy: UInt(i))
            waitForElementToAppear(paycodeNameLabelElement)
            let labelName : String = paycodeNameLabelElement.label
            assertEqualStrings(labelName, value2: name!)

            let paycodeHoursLabelElement = paycodeHourLabelsElement.element(boundBy: UInt(i))
            waitForElementToAppear(paycodeHoursLabelElement)
            let labelHours : String = paycodeHoursLabelElement.label
            assertEqualStrings(labelHours, value2: hours!)

            let paycodeAmountLabelElement = paycodeAmountLabelsElement.element(boundBy: UInt(i))
            waitForElementToAppear(paycodeAmountLabelElement)
            let labelAmount : String = paycodeAmountLabelElement.label
            assertEqualStrings(labelAmount, value2: amount!)
        }

        let paywidgetAmountLabelElement = widgetTimesheetTimeDistributionCellElement.staticTexts["uia_payroll_summary_widget_amount_label_identifier"]
        waitForElementToAppear(paywidgetAmountLabelElement)
        let amountValue : String = paywidgetAmountLabelElement.label
        assertEqualStrings(amountValue, value2: totalAmount)

        let paywidgetHourLabelElement = widgetTimesheetTimeDistributionCellElement.staticTexts["uia_payroll_summary_widget_total_hours_label_identifier"]
        waitForElementToAppear(paywidgetHourLabelElement)
        let hourValue : String = paywidgetHourLabelElement.label
        assertEqualStrings(hourValue, value2: totalHours)
        
    }

}
