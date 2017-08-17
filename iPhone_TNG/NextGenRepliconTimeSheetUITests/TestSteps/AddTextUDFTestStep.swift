
import XCTest

class AddTextUDFTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }
    
    func addTextForUdf(_ text:String) {
        let descriptionTextViewElement = XCUIApplication().textViews["description_text_view"]
        waitForElementToAppear(descriptionTextViewElement)
        
        descriptionTextViewElement.tap()
        descriptionTextViewElement.clearAndEnterText(text)
        
        let doneBarButton = XCUIApplication().buttons["description_done_btn"]
        waitForElementToAppear(doneBarButton)
        doneBarButton.tap()
    }
}
