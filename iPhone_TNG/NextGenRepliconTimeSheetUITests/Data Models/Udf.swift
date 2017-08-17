import Foundation

class Udf{
    var udfValue:String = ""
    var udfTitle:String?
    var udfType:String?
    var defaultValue:String?

    init(udfValue : String, udfTitle: String , udfType: String) {
        self.udfValue = udfValue
        self.udfTitle = udfTitle
        self.udfType = udfType

        if (udfType == UdfType.DropDownUdf.rawValue){
            self.defaultValue = "Select"
        }
        else if(udfType == UdfType.DateUdf.rawValue){
            self.defaultValue = "Select"
        }
        else if(udfType == UdfType.TextUdf.rawValue){
            self.defaultValue = "Add"
        }
        else if(udfType == UdfType.NumericUdf.rawValue){
            self.defaultValue = "Add"
        }

    }
}