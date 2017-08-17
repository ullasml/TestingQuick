
import Foundation

class ApprovalInfo {
    var status:String?
    var comments:String?
    var amount:String?

    init(status : String, comments: String) {
        self.status = status
        self.comments = comments
    }
}