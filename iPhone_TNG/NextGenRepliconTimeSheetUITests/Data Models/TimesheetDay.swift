
import Foundation

class TimesheetDay{

    var date :String?
    var workHours :String?
    var breakHours :String?
    var punches :Array<Punch>?



    init(date : String , workHours : String , breakHours : String , punches:Array<Punch>?) {
        self.date = date
        self.workHours = workHours
        self.breakHours = breakHours
        self.punches = punches

    }
    
}