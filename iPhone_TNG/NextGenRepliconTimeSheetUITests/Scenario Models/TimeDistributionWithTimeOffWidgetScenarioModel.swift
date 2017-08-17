
import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class TimeDistributionWithTimeOffWidgetScenarioModel {
    var company:String?
    var companyLoginField:String?
    var user:User?
    var supervisor:User?
    var standardTimesheetRowAttributes:TimesheetRowAttributes?
    var timesheetDays = [StandardTimesheetDayEntry]()
    var timesheetTotalHours : String?
    var timeoffTotalHours : String?
    var totalHours : String?
    var timeoffTypes = [String]()
    var timeoffStartDate:Date?
    var timeoffEndDate:Date?
    var paycodeSummary = [PayCodeInfo]()
    var totalAmount : String?

    init(data:Data){
        let json = JSON(data: data)

        self.timeoffStartDate = RDate.from(2016, month: 6, day: 15)
        self.timeoffEndDate = RDate.from(2016, month: 6, day: 18)

        let password            = "Password123"
        let companyKey          = json["tenant"]["companyKey"].stringValue
        let userLoginName       = json["user"]["loginName"].stringValue
        let supervisorLoginName = json["supervisor"]["loginName"].stringValue
        let clientName          = json["client"]["name"].stringValue
        let projectName         = json["project"]["name"].stringValue
        let taskName            = json["tasks"][0]["name"].stringValue
        let loginCompanyName    = json["endpoint"]["mobileLogin"].stringValue
        let paycodes            = json["paycodes"].array
        let hourlyPayrollForUser = json["hourlyPayrollForUser"]["hourlyRate"].dictionary

        let hourlyPayAmount = hourlyPayrollForUser! ["amount"]!.floatValue
        let payCurrencyType = hourlyPayrollForUser! ["currency"]!["displayText"].stringValue

        self.companyLoginField = loginCompanyName
        self.company = companyKey
        self.user = User(username: userLoginName, password: password)
        self.supervisor = User(username: supervisorLoginName, password: password)
        self.standardTimesheetRowAttributes = TimesheetRowAttributes(client: clientName,project: projectName,task: taskName,activity:"", breaks : [],taskAllowed: false)

        let timesheetDateRange = json["timesheet"]["dateRange"].dictionary
        let timesheetStartDate = timesheetDateRange!["startDate"]!.dictionary
        let timesheetEndDate = timesheetDateRange!["endDate"]!.dictionary

        let endDay = timesheetEndDate!["day"]!.intValue
        let endMonth = timesheetEndDate!["month"]!.intValue
        let endYear = timesheetEndDate!["year"]!.intValue

        let startDay = timesheetStartDate!["day"]!.intValue
        let startMonth = timesheetStartDate!["month"]!.intValue
        let startYear = timesheetStartDate!["year"]!.intValue

        let endDate = RDate.from(endYear, month: endMonth, day: endDay)
        let startDate = RDate.from(startYear, month: startMonth, day: startDay)
        let difference = RDate.differenceBetweenDates(startDate,end:endDate);

        self.timeoffStartDate = startDate
        self.timeoffEndDate = RDate.addDaysToDate(3, date: startDate)

        var roundedTimeoffDifference : Double = 0

        var roundedDifference : Double = 0
        for i in 0...difference {
            let todayDate = RDate.addDaysToDate(i, date: startDate)
            var entries = [TimeEntry]()

            let isBetween : Bool = RDate.isBetweeen(todayDate, date1: self.timeoffStartDate!, andDate: self.timeoffEndDate!)
            if isBetween {

                print(todayDate)
                let weekDay = RDate.getWeekDayOfDate(todayDate)
                let weekDayString = serializedWeekDay(UInt(weekDay))
                print(weekDay)
                var hours = "8.00"
                if weekDayString == "Sun" || weekDayString == "Sat" {
                    hours = "0.00"
                }
                let timeoffEntry = TimeEntry(value: hours, type: EntryType.Timeoff.rawValue)
                let timeEntry = TimeEntry(value: "0.00", type: EntryType.Time.rawValue)
                entries.append(timeoffEntry)
                entries.append(timeEntry)
                roundedTimeoffDifference = Double(hours)! + roundedTimeoffDifference

            }
            else{
                let timeoffEntry = TimeEntry(value: "0.00", type: EntryType.Timeoff.rawValue)
                let timeEntry = TimeEntry(value: "8.00", type: EntryType.Time.rawValue)
                entries.append(timeoffEntry)
                entries.append(timeEntry)
                roundedDifference = Double("8.00")! + roundedDifference

            }



            let dateInString = RDate.getStringFromDate(todayDate,format: "EEEE, dd MMM yyyy")

            let standardTimesheetDayEntry = StandardTimesheetDayEntry(date: todayDate, entryDay: dateInString , entries: entries)
            self.timesheetDays.append(standardTimesheetDayEntry)

        }
        self.timesheetTotalHours = String(format: "%.2f", roundedDifference)
        self.timeoffTotalHours = String(format: "%.2f", roundedTimeoffDifference)
        self.totalHours = String(format: "%.2f", roundedTimeoffDifference+roundedDifference)
        let totalPayAmount = hourlyPayAmount * (self.totalHours! as NSString).floatValue
        let roundedTotalPayAmountAmount = String(format: "%.2f", totalPayAmount)
        self.totalAmount = "\(payCurrencyType) \(roundedTotalPayAmountAmount)"

        let breakType = json["timeofftypes"].array
        let count = breakType?.count
        for i in 0...count!-1 {
            let breakTypeText = String(describing: breakType![i]["displayText"])
            self.timeoffTypes.append(breakTypeText)
        }


        let paycodecount = paycodes?.count
        for i in 0...paycodecount!-1 {
            let paycode = paycodes![i].dictionary
            let paycodeUri = paycode!["payCodeTypeUri"]
            if (paycodeUri == "urn:replicon:pay-code-type:time-off") {
                let paycodename = paycode!["name"]?.stringValue
                let payAmount = hourlyPayAmount * (self.timeoffTotalHours! as NSString).floatValue
                let roundedPayAmount = String(format: "%.2f", payAmount)
                let payCodeInfo = PayCodeInfo(name: paycodename!, hours: "\(self.timeoffTotalHours!) hrs", amount: "\(payCurrencyType) \(roundedPayAmount)")
                self.paycodeSummary.append(payCodeInfo)
            }
            else if (paycodeUri == "urn:replicon:pay-code-type:regular-time") {
                let paycodename = paycode!["name"]?.stringValue
                let payAmount = hourlyPayAmount * (self.timesheetTotalHours! as NSString).floatValue
                let roundedPayAmount = String(format: "%.2f", payAmount)
                let payCodeInfo = PayCodeInfo(name: paycodename!, hours: "\(self.timesheetTotalHours!) hrs", amount: "\(payCurrencyType) \(roundedPayAmount)")
                self.paycodeSummary.append(payCodeInfo)
            }
        }

        self.paycodeSummary.sort(by: { $0.name < $1.name })
        self.timeoffTypes = self.timeoffTypes.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }

    }

    fileprivate func timeoffDate(_ day:Int , month: Int , year : Int) -> String{
        let startDate = RDate.from(day, month: month, day: day)
        let dateInString = RDate.getStringFromDate(startDate,format: "EEEE, dd MMM yyyy")
        return dateInString
    }

    fileprivate func serializedWeekDay(_ weekDay :UInt) -> String{
        switch weekDay {
        case 1:
            return "Sun"
        case 2:
            return "Mon"
        case 3:
            return "Tue"
        case 4:
            return "Wed"
        case 5:
            return "Thu"
        case 6:
            return "Fri"
        case 7:
            return "Sat"
        default:
            print("Error fetching days")
            return "Day"
        }
    }
}
