
import Foundation

class Violation{

    var title   : String = ""
    var waiver  : Waiver?
    var type    : String = ""
    var defaultStatus : String = "No Response"

    init(title : String , waiver : Waiver, type: String) {
        self.waiver = waiver
        self.title = title
        self.type = type

    }
    
}