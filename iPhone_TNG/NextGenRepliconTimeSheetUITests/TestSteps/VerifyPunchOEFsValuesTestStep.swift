
import XCTest

class VerifyPunchOEFsValuesTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }
    
    let textAndNumericOefIdentifier = "uia_text_and_numeric_cell_view_identifier"
    let dropDownOefIdentifier = "uia_dropdown__cell_view_identifier"
    let oefCellTitleIdentifier = "uia_cell_title_view_identifier"
    
    
    func verifyAllOefsValuesWithPunchAction(_ oefArray: [OefType]) {
        
        let oefCount = oefArray.count
        for i in 0...oefCount-1 {
            let oefObject : OefType = oefArray[i]
            let oefType = oefObject.oefType
            let oefIndex = UInt(i)
            
            let oefTitleElement = XCUIApplication().staticTexts["\(oefCellTitleIdentifier)-\(oefIndex)"]
            waitForElementToAppear(oefTitleElement)
            let oefTitle : String = oefTitleElement.label
            assertEqualStrings(oefTitle, value2: oefObject.oefTitle!)
            
            if oefType == Constants.textOefUri ||  oefType == Constants.numericOefUri{
                let textViewValueElement = XCUIApplication().textViews["\(textAndNumericOefIdentifier)-\(oefIndex)"]
                waitForElementToAppear(textViewValueElement)
                assertEqualStrings(textViewValueElement.value as! String, value2: oefObject.oefValue)
            }
            else{
                let dropdownLabelValueElement = XCUIApplication().staticTexts[dropDownOefIdentifier]
                waitForElementToAppear(dropdownLabelValueElement)
                let oefDropDownValue : String = dropdownLabelValueElement.label
                assertEqualStrings(oefDropDownValue, value2: oefObject.oefValue)
            }
        }
    }

}
