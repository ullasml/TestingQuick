import XCTest

class PunchAttributeValueTestStep: BaseTestStep {
    
    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }
    
    func serializedOefObjectForGettingPunchDetails(_ entryOef : [OefType], punchAction: String) -> String {
        var allStrings = [String]()
        allStrings.append(punchAction)
        let oefTypesArray = entryOef
        for oef: OefType in oefTypesArray {
            var oefValue = ""
            if (oef.oefType == Constants.numericOefUri) {
                oefValue = oef.oefValue
            }
            else if (oef.oefType == Constants.textOefUri) {
                oefValue = oef.oefValue
            }
            else {
                oefValue = oef.oefValue
            }
            
            if oefValue == "" {
                oefValue = NSLocalizedString("None", comment: "")
            }
            else {
                if oefValue.characters.count > 0 {
                    let oefString = "\(oef.oefTitle!) : \(oefValue)"
                    allStrings.append(oefString)
                }
            }
        }
        
        var completelyAppendedString = ""
        for k in 0..<allStrings.count {
        let constrainedString = allStrings[k]
        let isLastObject = (k != allStrings.count - 1)
            if isLastObject {
                completelyAppendedString = completelyAppendedString + "\(constrainedString) "
            }
            else {
                completelyAppendedString = completelyAppendedString + constrainedString
            }
        }
        return completelyAppendedString
    }

}
