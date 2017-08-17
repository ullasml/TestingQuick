

import Foundation

class Waiver{

    var title           : String = ""
    var acceptTitle     : String = ""
    var rejectTitle     : String = ""

    init(title : String , acceptTitle : String, rejectTitle: String) {
        self.title = title
        self.acceptTitle = acceptTitle
        self.rejectTitle = rejectTitle

    }
    
}