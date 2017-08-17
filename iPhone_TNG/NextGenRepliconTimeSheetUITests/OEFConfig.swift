import Foundation

class OEFConfig {
    
    let oef: OEFData
    
    init(){
        let currentBundle = NSBundle(forClass: self.dynamicType)
        let filePath = currentBundle.pathForResource("oefconfig.json", ofType: nil)
        let jsonFileData = NSData(contentsOfFile: filePath!)
        let json = JSON(data: jsonFileData!)
        
        // read OEF element
        oef = OEFData(text: json["oef"]["text"].stringValue,
            numeric: json["oef"]["numeric"].stringValue,
            dropDown: json["oef"]["dropDown"].stringValue)
    }
}

struct OEFData {
    let text: String
    let numeric: String
    let dropDown: String
}
