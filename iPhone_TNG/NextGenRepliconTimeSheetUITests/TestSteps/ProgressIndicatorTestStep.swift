
import XCTest

class ProgressIndicatorTestStep: BaseTestStep {

    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    let indicatorIdentifier = "uia_global_indicator_view_label_identifier"

    func waitForIndicatorViewToAppearAndDisappear(){
        let globalIndicatorViewLabel = XCUIApplication().staticTexts[indicatorIdentifier]
        waitForElementToAppear(globalIndicatorViewLabel)
        waitForElementToDisappear(globalIndicatorViewLabel)
    }

    func waitForIndicatorViewToDisappearIfExists(){
        let globalIndicatorViewLabel = XCUIApplication().staticTexts[indicatorIdentifier]
        if(globalIndicatorViewLabel.exists){
            waitForElementToDisappear(globalIndicatorViewLabel)
        }
    }
}
