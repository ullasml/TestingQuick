

import Foundation

class TimeDistributionWidgetScenarioModel {
    var company:String?
    var companyLoginField:String?

    var user:User?
    var supervisor:User?
    var standardTimesheetRowAttributes:TimesheetRowAttributes?
    var timesheetDays = [StandardTimesheetDayEntry]()
    var timesheetTotalHours : String?

    init(data:Data){
        let json = JSON(data: data)

        let password            = "Password123"
        let companyKey          = json["tenant"]["companyKey"].stringValue
        let userLoginName       = json["user"]["loginName"].stringValue
        let supervisorLoginName = json["supervisor"]["loginName"].stringValue
        let clientName          = json["client"]["name"].stringValue
        let projectName         = json["project"]["name"].stringValue
        let taskName            = json["tasks"][0]["name"].stringValue
        let loginCompanyName    = json["endpoint"]["mobileLogin"].stringValue

        self.companyLoginField = loginCompanyName
        self.company = companyKey
        self.user = User(username: userLoginName, password: password)
        self.supervisor = User(username: supervisorLoginName, password: password)
        self.standardTimesheetRowAttributes = TimesheetRowAttributes(client: clientName,project: projectName,task: taskName,activity:"", breaks : [],taskAllowed: false)

        let timesheetDateRange = json["timesheet"]["details"]["dateRange"].dictionary
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

        var roundedDifference : Double = 0
        for i in 0...difference {
            let todayDate = RDate.addDaysToDate(i, date: startDate)
            let dateInString = RDate.getStringFromDate(todayDate,format: "EEEE, dd MMM yyyy")

            let timeentryHours = "8.00"
            roundedDifference = Double(timeentryHours)! + roundedDifference

            var entries = [TimeEntry]()
            let timeEntry = TimeEntry(value: timeentryHours, type: EntryType.Time.rawValue)
            entries.append(timeEntry)
            let standardTimesheetDayEntry = StandardTimesheetDayEntry(date: todayDate, entryDay: dateInString , entries: entries)
            self.timesheetDays.append(standardTimesheetDayEntry)

        }
        self.timesheetTotalHours = String(format: "%.2f", roundedDifference)
        
    }
}
