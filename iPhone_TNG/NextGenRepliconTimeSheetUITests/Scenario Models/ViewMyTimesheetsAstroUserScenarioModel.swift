

import Foundation

class ViewMyTimesheetsAstroUserScenarioModel{
    var company:String?
    var companyLoginField:String?
    var user:User?
    var currentTimesheet : Timesheet?
    var previousTimesheet : Timesheet?
    var breakTypeArray = [String]()

    init(data:Data){
        let json = JSON(data: data)
        let password = "Password123"
        let companyKey = json["tenant"]["companyKey"].stringValue
        let userLoginName = json["user"]["loginName"].stringValue
        let loginCompanyName = json["endpoint"]["mobileLogin"].stringValue
        let breakTypeArray = json["breaks"].array
        let count = breakTypeArray?.count
        for i in 0...count!-1 {
            let breakTypeText = String(breakTypeArray![i]["displayText"].stringValue)
            self.breakTypeArray.append(breakTypeText!)
        }
        self.companyLoginField = loginCompanyName
        self.company = companyKey
        self.user = User(username: userLoginName, password: password)
        self.currentTimesheet = getCurrentTimesheet(json)
        self.previousTimesheet = getPreviousTimesheet(json)

    }


    func getCurrentTimesheet(_ json : JSON) -> Timesheet {
        return getTimesheet(json,isCurrentTimesheet:true)
    }

    func getPreviousTimesheet(_ json : JSON) -> Timesheet {
        return getTimesheet(json,isCurrentTimesheet:false)
    }

    func getTimesheet(_ json : JSON , isCurrentTimesheet : Bool) -> Timesheet {

        let timesheetKey = isCurrentTimesheet ? "currenttimesheet" : "previoustimesheet"
        let currentTimesheet = json[timesheetKey].dictionary
        let timesheetPeriodDateRange = currentTimesheet!["timesheetPeriodDateRange"]!.dictionary
        let startDate = timesheetPeriodDateRange!["startDate"]!.dictionary
        let endDate = timesheetPeriodDateRange!["endDate"]!.dictionary
        let dateFormatter = "EEE MMM dd";
        let startDateString = dateAsString(startDate!,dateformat: dateFormatter)
        let endDateString = dateAsString(endDate!,dateformat: dateFormatter)
        let periodString = "\(startDateString) - \(endDateString)"

        let violationsInfo = currentTimesheet!["violations"]!.dictionary
        let violationscount = violationsInfo!["totalTimesheetPeriodValidationMessagesCount"]!.intValue
        let violationsByDate = violationsInfo!["validationMessagesByDate"]!.array!

        var timesheetDayEntries = [TimesheetDay]()
        let timesheetDays = currentTimesheet!["timesheetDays"]!.array
        let count = timesheetDays!.count
        for i in 0...count-1 {

            let timesheetDay = timesheetDays![i]
            let workHours = timesheetDay["workHours"]
            let workHoursSerializedString = "\(workHours) Work"
            let breakHours = timesheetDay["breakHours"]
            let breakHoursString = "\(breakHours) Break"

            let punches = timesheetDay["punches"].array
            var punchesForTimesheetDay = [Punch]()
            let punchescount = punches!.count
            for j in 0...punchescount-1 {

                let punch = punches![j].dictionary
                let timePunch = punch!["timePunch"]!.dictionary
                let punchTime = timePunch!["punchTime"]!.dictionary
                let time = timeAsString(punchTime!, dateformat : "h:mm")
                let actionUri = timePunch!["actionUri"]!.stringValue

                if actionUri == "urn:replicon:time-punch-action:in" {
                    let serializedPunch = Punch(time: time, actionType: PunchType.ClockIn.rawValue, breakValue : "")
                    punchesForTimesheetDay.append(serializedPunch)
                }
                else if actionUri == "urn:replicon:time-punch-action:out" {
                    let serializedPunch = Punch(time: time, actionType: PunchType.ClockOut.rawValue, breakValue : "")
                    punchesForTimesheetDay.append(serializedPunch)

                }
                else if actionUri == "urn:replicon:time-punch-action:start-break" {
                    let breakType = self.breakTypeArray[0]
                    let serializedPunch = Punch(time: time, actionType: PunchType.TakeBreak.rawValue, breakValue : breakType)
                    punchesForTimesheetDay.append(serializedPunch)

                }

            }

            let date = timesheetDay["date"].dictionary
            let dateFormatter = "EEEE, MMM d";
            let dateString = dateAsString(date!,dateformat: dateFormatter)
            let timesheetDayEntry = TimesheetDay(date       : dateString,
                                                 workHours  : workHoursSerializedString,
                                                 breakHours : breakHoursString,
                                                 punches    : punchesForTimesheetDay)
            timesheetDayEntries.append(timesheetDayEntry)

        }

        var violationsForTimesheetDay = [Violation]()

        for i in 0..<(violationsByDate.count) {
            let violationInfo = violationsByDate[i].dictionary
            let validationMessages = violationInfo!["timePunchValidationMessages"]!.array!

            for k in 0..<(validationMessages.count) {

                let violationEntryInfo = validationMessages[k].dictionary
                let violationTitle = violationEntryInfo!["displayText"]!.stringValue
                let violationType = violationEntryInfo!["severity"]!.stringValue
                let waiverInfo = violationEntryInfo!["waiver"]!.dictionary

                let waiverTitle = waiverInfo!["displayText"]!.stringValue
                let waiverOptions = waiverInfo!["options"]!.array
                let waiverAcceptValue = waiverOptions![0].dictionary!["displayText"]!.stringValue
                let waiverRejectValue = waiverOptions![1].dictionary!["displayText"]!.stringValue

                let waiver = Waiver(title: waiverTitle, acceptTitle: waiverAcceptValue, rejectTitle: waiverRejectValue);

                if (violationType == "urn:replicon:severity:warning")  {
                    let violationTypeValue = ViolationType.Warning.rawValue
                    let violation = Violation(title:violationTitle,waiver:waiver ,type: violationTypeValue)
                    violationsForTimesheetDay.append(violation)
                }
                else if (violationType == "urn:replicon:severity:error"){
                    let violationTypeValue = ViolationType.Error.rawValue
                    let violation = Violation(title:violationTitle,waiver:waiver ,type: violationTypeValue)
                    violationsForTimesheetDay.append(violation)
                }
                else if (violationType == "urn:replicon:severity:information"){
                    let violationTypeValue = ViolationType.Information.rawValue
                    let violation = Violation(title:violationTitle,waiver:waiver ,type: violationTypeValue)
                    violationsForTimesheetDay.append(violation)
                }

            }


        }

        let currentTimesheetPeriodDateRange = periodString
        let grossPay        = currentTimesheet!["grossPay"]!.stringValue
        let totalWorkHours  = currentTimesheet!["totalWorkHours"]!.stringValue
        let totalOtHours    = currentTimesheet!["totalOtHours"]!.stringValue
        let totalBreakHours = currentTimesheet!["totalBreakHours"]!.stringValue

        return Timesheet(currentTimesheetPeriodDateRange: currentTimesheetPeriodDateRange ,
                         grossPay: grossPay,
                         timesheetDays:timesheetDayEntries,
                         totalWorkHours: totalWorkHours,
                         totalOtHours: totalOtHours,
                         totalBreakHours: totalBreakHours,
                         violations:violationsForTimesheetDay,
                         violationsCount:violationscount)
    }

    func dateAsString(_ dateInfo : Dictionary <String,JSON>,dateformat : String) -> String {

        let day = dateInfo["day"]!.intValue
        let month = dateInfo["month"]!.intValue
        let year = dateInfo["year"]!.intValue

        let calendar:Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = DateComponents();
        components.day = day;
        components.month = month;
        components.year = year;
        let date = calendar.date(from: components)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateformat
        return dateFormatter.string(from: date!)
    }

    func timeAsString(_ dateInfo : Dictionary <String,JSON>,dateformat : String) -> String {

        let day = dateInfo["hour"]!.intValue
        let month = dateInfo["minute"]!.intValue
        let year = dateInfo["second"]!.intValue

        let calendar:Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = DateComponents();
        components.hour = day;
        components.minute = month;
        components.second = year;
        let date = calendar.date(from: components)

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = dateformat
        return dateFormatter.string(from: date!)
    }
}
