
import Foundation

class Timesheet{

    var currentTimesheetPeriodDateRange :String?
    var grossPay :String?
    var timesheetDays :Array<TimesheetDay>?
    var totalWorkHours :String?
    var totalOtHours :String?
    var totalBreakHours :String?
    var violations :Array<Violation>?
    var violationsCount : Int?

    init(currentTimesheetPeriodDateRange : String ,
         grossPay : String ,
         timesheetDays :Array<TimesheetDay>,
         totalWorkHours : String,
         totalOtHours : String,
         totalBreakHours : String,
         violations : Array<Violation>?,
         violationsCount : Int) {
        self.currentTimesheetPeriodDateRange = currentTimesheetPeriodDateRange
        self.timesheetDays = timesheetDays
        self.grossPay = grossPay
        self.totalWorkHours = totalWorkHours
        self.totalOtHours = totalOtHours
        self.totalBreakHours = totalBreakHours
        self.violations = violations
        self.violationsCount = violationsCount

    }
    
}