
import Foundation

class StandardTimesheetDayEntry{

    var date :Date?
    var entryDay :String!
    var entries = [TimeEntry]()
    var totalHoursForDay : String!



    init(date : Date , entryDay : String , entries : [TimeEntry]) {
        self.date = date
        self.entryDay = entryDay
        self.entries = entries;

        var timesheetTotal : Double = 0
        for i in 0...entries.count-1 {
            let inOutTime = entries[i]
            let myDouble = Double(inOutTime.value)
            timesheetTotal = myDouble! + timesheetTotal
        }

        let roundedDifference = Double(timesheetTotal).roundToPlaces(2)
        self.totalHoursForDay = String(format: "%.2f", roundedDifference)
    }
    
}
