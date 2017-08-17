import Foundation

class OefType{
    var oefValue:String = ""
    var oefTitle:String?
    var oefType:String?
    var defaultValue:String?
    var oefUri:String?
    
    init(oefValue : String, oefTitle: String , oefType: String, oefUri: String) {
        self.oefValue = oefValue
        self.oefTitle = oefTitle
        self.oefType = oefType
        self.defaultValue = "Select"
        self.oefUri = oefUri
    }
}