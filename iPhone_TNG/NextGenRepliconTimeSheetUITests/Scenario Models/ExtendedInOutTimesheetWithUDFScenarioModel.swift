
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

class ExtendedInOutTimesheetWithUDFScenarioModel{
    var company:String?
    var companyLoginField:String?

    var user:User?
    var supervisor:User?
    var timesheetRowAttributes:TimesheetRowAttributes?
    var timesheetDays = [InoutTimesheetDayEntry]()
    var sheetLevelUDFsArray: [Udf] = []
    var totalTimesheetHours : String?
    fileprivate var timesheetTotal : Double = 0


    init(data:Data){
        let json = JSON(data: data)

        var sheetDropDownUDFValuesArray = [String] ()
        let password = "Password123"
        let companyKey = json["tenant"]["companyKey"].stringValue
        let userLoginName = json["user"]["loginName"].stringValue
        let supervisorLoginName = json["supervisor"]["loginName"].stringValue
        let clientName = json["client"]["name"].stringValue
        let projectName = json["project"]["name"].stringValue
        let activityName = json["activity"]["name"].stringValue
        let breaks = json["breaks"].array

        let timesheetLevelUdfs = json["timesheetLevelUdfs"].array
        let timesheetLevelDropDownUdfValuesArray = json["timesheetLevelUdfs"][0]["values"].array

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

        for i in 0...difference {
            let todayDate = RDate.addDaysToDate(i, date: startDate)
            let dateInString = RDate.getStringFromDate(todayDate,format: "EEEE, dd MMM yyyy")

            var entries = [InOutTime]()
            let inoutTimeEntry = serializeInOutTimeEntry(1205,outTime: 1255,type: EntryType.Time.rawValue)
            entries.append(inoutTimeEntry)
            let inoutBreakEntry = serializeInOutTimeEntry(0105,outTime: 0155,type: EntryType.Break.rawValue)
            entries.append(inoutBreakEntry)

            let inoutTimesheetDayEntry = InoutTimesheetDayEntry(date: todayDate, entryDay: dateInString , entries: entries)
            self.timesheetDays.append(inoutTimesheetDayEntry)
        }

        let roundedTimesheetHours = Double(timesheetTotal).roundToPlaces(2)
        self.totalTimesheetHours = "\(roundedTimesheetHours)"
        var breakTypes = [String]()

        let count = breaks?.count
        for i in 0...count!-1 {
            let breakTypeText = String(describing: breaks![i]["displayText"])
            breakTypes.append(breakTypeText)
        }

        let taskName = json["tasks"][0]["name"].stringValue
        let loginCompanyName = json["endpoint"]["mobileLogin"].stringValue

        self.companyLoginField = loginCompanyName
        self.company = companyKey
        self.user = User(username: userLoginName, password: password)
        self.supervisor = User(username: supervisorLoginName, password: password)
        self.timesheetRowAttributes = TimesheetRowAttributes(client: clientName,project: projectName,task: taskName,activity: activityName,breaks:breakTypes, taskAllowed: false)


        let timesheetLevelDropDownUdfValuesCount = timesheetLevelDropDownUdfValuesArray?.count
        for i in 0...timesheetLevelDropDownUdfValuesCount!-1 {
            let dropDownUdfEntryValue = String(describing: timesheetLevelDropDownUdfValuesArray![i]["name"])
            sheetDropDownUDFValuesArray.append(dropDownUdfEntryValue)
        }

        let timesheetLevelUdfsCount = timesheetLevelUdfs?.count
        for i in 0...timesheetLevelUdfsCount!-1 {
            let udfType = String(describing: timesheetLevelUdfs![i]["type"]["displayText"])
            var udfValue = ""
            if udfType == UdfType.DropDownUdf.rawValue {
                udfValue =  sheetDropDownUDFValuesArray[1]
            }
            else if udfType == UdfType.NumericUdf.rawValue{
                udfValue =  "12"
            }
            else if udfType == UdfType.DateUdf.rawValue{
                let dateInString = RDate.getStringFromDate(Date(),format: "MMMM d, yyyy")
                udfValue =  dateInString
            }
            else if udfType == UdfType.TextUdf.rawValue{
                udfValue =  "My UIAutomation test Comments"
            }
            let udfTitle = String(describing: timesheetLevelUdfs![i]["displayText"])
            let udfObject = Udf(udfValue : udfValue, udfTitle: udfTitle , udfType: udfType)
            self.sheetLevelUDFsArray.append(udfObject)
        }

        self.sheetLevelUDFsArray = self.sheetLevelUDFsArray.sorted(by: { $0.udfTitle < $1.udfTitle })
        
    }

    fileprivate func serializeInOutTimeEntry(_ inTime : Double, outTime : Double , type: String) -> InOutTime
    {

        let inTimeRounded = Double(inTime).roundDown(1)
        let intimeString = String(format: "%.0f", inTimeRounded)

        let outTimeRounded = Double(outTime).roundDown(1)
        let outtimeString = String(format: "%.0f", outTimeRounded)


        let timeDifference : Double = (outTime - inTime)/60
        self.timesheetTotal = timeDifference + self.timesheetTotal
        let inoutTimeEntry = InOutTime(inTime: intimeString, outTime: outtimeString, decimalDifference:"\(timeDifference)", type:type)
        return inoutTimeEntry
    }

}
