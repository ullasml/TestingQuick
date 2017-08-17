import XCTest

class SpinnerTestStep: BaseTestStep {

    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    func waitForSpinnerViewToDisappearIfExists(){
        let spinnerQuery = XCUIApplication().activityIndicators["uia_view_timesheet_spinner_identifier"]
        if(spinnerQuery.exists){
            waitForElementToDisappear(spinnerQuery)
        }
    }
}
