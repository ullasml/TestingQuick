
import Foundation

class TimesheetRowAttributes{

    var client:String?
    var project:String?
    var task:String?
    var taskAllowed:Bool
    var activity:String?
    var breaks:Array<String>?


    init(client : String , project : String, task : String, activity : String,breaks: Array<String> ,taskAllowed : Bool) {
        self.client = client
        self.project = project
        self.task = task
        self.taskAllowed = taskAllowed
        self.activity = activity
        self.breaks = breaks
    }
    
}