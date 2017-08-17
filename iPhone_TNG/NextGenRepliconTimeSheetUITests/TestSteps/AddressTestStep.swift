
import XCTest

class AddressTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }
    
    func verifyAddress() {        
        let punchAddressLabelElement = XCUIApplication().staticTexts["punch_address_lbl"]
        waitForElementToAppear(punchAddressLabelElement)
        let address : String = punchAddressLabelElement.label
        assertEqualStrings(address, value2: "Dheeraj Enclave, Wadala West, Wadala, Mumbai, Maharashtra 400031, India")
    }
}
