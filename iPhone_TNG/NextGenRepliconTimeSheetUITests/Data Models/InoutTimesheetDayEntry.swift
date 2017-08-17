
import Foundation

class InoutTimesheetDayEntry{

    var date :Date?
    var entryDay :String!
    var entries = [InOutTime]()
    var totalHoursForDay : String!



    init(date : Date  , entryDay : String , entries : [InOutTime]) {
        self.date = date
        self.entryDay = entryDay
        self.entries = entries;

        var timesheetTotal : Double = 0
        for i in 0...entries.count-1 {
            let inOutTime = entries[i]
            let myDouble = Double(inOutTime.decimalDifference!)
            timesheetTotal = myDouble! + timesheetTotal

        }

        let roundedDifference = Double(timesheetTotal).roundToPlaces(2)
        self.totalHoursForDay = "\(roundedDifference)"

    }
    
}
