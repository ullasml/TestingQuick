
import Foundation
class InOutTime{

    var inTime   : String?
    var outTime  : String?
    var decimalDifference  : String?
    var type  : String?


    init(inTime : String , outTime: String,decimalDifference : String,type: String) {
        self.inTime = inTime
        self.outTime = outTime
        self.decimalDifference = decimalDifference
        self.type = type
    }
    
}
