
import Foundation

class StandardTimesheetRowAttributes{

    var client:String?
    var project:String?
    var task:String?
    var taskAllowed:Bool


    init(client : String , project : String, task : String, taskAllowed : Bool) {
        self.client = client
        self.project = project
        self.task = task
        self.taskAllowed = taskAllowed
    }
    
}