

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


class StandardTimesheetWithUDFUserScenarioModel{
    var company:String?
    var companyLoginField:String?
    
    var user:User?
    var supervisor:User?
    var entries = [String]()
    var standardTimesheetRowAttributes:TimesheetRowAttributes?
    var sheetLevelUDFsArray: [Udf] = []
    var cellLevelUDFsArray : [Udf] = []
    var rowLevelUDFsArray : [Udf] = []
    var udfTypeArray = [UdfType]()
    var timesheetDays = [StandardTimesheetDayEntry]()
    var timesheetTotalHours : String?



    init(data:Data){
        let json = JSON(data: data)
        let password = "Password123"
        let companyKey = json["tenant"]["companyKey"].stringValue
        let userLoginName = json["user"]["loginName"].stringValue
        let supervisorLoginName = json["supervisor"]["loginName"].stringValue
        let clientName = json["client"]["name"].stringValue
        let projectName = json["project"]["name"].stringValue
        let taskName = json["tasks"][0]["name"].stringValue
        let loginCompanyName = json["endpoint"]["mobileLogin"].stringValue
        
        let timesheetLevelUdfs = json["timesheetLevelUdfs"].array
        let timesheetRowUdfs = json["timesheetRowUdfs"].array
        let timesheetEntryUdfs = json["timesheetEntryUdfs"].array

        self.udfTypeArray = [UdfType.DropDownUdf, UdfType.NumericUdf, UdfType.DateUdf, UdfType.TextUdf]
        
        self.sheetLevelUDFsArray = serializedUdfsForUdfObjects(timesheetLevelUdfs!)
        self.rowLevelUDFsArray = serializedUdfsForUdfObjects(timesheetRowUdfs!)
        self.cellLevelUDFsArray = serializedUdfsForUdfObjects(timesheetEntryUdfs!)

        self.companyLoginField = loginCompanyName
        self.company = companyKey
        self.user = User(username: userLoginName, password: password)
        self.supervisor = User(username: supervisorLoginName, password: password)
        self.standardTimesheetRowAttributes = TimesheetRowAttributes(client: clientName,project: projectName,task: taskName,activity:"", breaks : [], taskAllowed: false)
        
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


    fileprivate func serializedUdfsForUdfObjects(_ entryUdfs : [JSON]) -> [Udf] {

        var allUdfArray = [Udf]()
        if entryUdfs.count > 0 {
            for i in 1...entryUdfs.count {
                let index = i-1
                var allDropdownValues = [String]()
                let udfType = String(describing: entryUdfs[index]["type"]["displayText"])
                var udfValue = ""
                if udfType == UdfType.DropDownUdf.rawValue {

                    let dropdownValues = entryUdfs[index]["dropdownValues"].array
                    for i in 0...(dropdownValues?.count)!-1 {
                        let dropDownUdfEntryValue = String(describing: dropdownValues![i]["name"])
                        allDropdownValues.append(dropDownUdfEntryValue)
                    }
                    udfValue =  allDropdownValues[0]

                }
                else if udfType == UdfType.NumericUdf.rawValue{
                    udfValue =  "12"
                }
                else if udfType == UdfType.DateUdf.rawValue{
                    let dateInString = RDate.getStringFromDate(Date(),format: "MMMM d, yyyy")
                    udfValue =  dateInString
                }
                else if udfType == UdfType.TextUdf.rawValue{
                    udfValue =  "My UIAutomation test comments"
                }
                let udfTitle = String(describing: entryUdfs[index]["displayText"])
                let udfObject = Udf(udfValue : udfValue, udfTitle: udfTitle , udfType: udfType)
                allUdfArray.append(udfObject)
            }
        }

        return allUdfArray.sorted(by: { $0.udfTitle < $1.udfTitle })
    }
    
}
