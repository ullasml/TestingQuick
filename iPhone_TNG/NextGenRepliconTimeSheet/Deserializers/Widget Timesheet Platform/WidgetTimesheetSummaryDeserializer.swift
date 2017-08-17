
import UIKit

/**
 Deserialize the widget timesheet summary for a service response
 - Parameter response: a response dictionary
 - Returns: a WidgetTimesheetSummary
 */
// MARK:- <WidgetTimesheetDeserializerInterface>

@objc protocol WidgetTimesheetSummaryDeserializerInterface : class {
    func deserialize(_ response:AnyObject?,isAutoSubmitEnabled:Bool) -> Summary?
}

///Deserializer for Widget Timesheet Summary
class WidgetTimesheetSummaryDeserializer: NSObject,WidgetTimesheetSummaryDeserializerInterface {

    var violationsForTimesheetPeriodDeserializer:ViolationsForTimesheetPeriodDeserializer!
    var timeSheetPermittedActionsDeserializer:TimeSheetPermittedActionsDeserializer!
    var currencyValueDeserializer:CurrencyValueDeserializer!
    var grossHoursDeserializer:GrossHoursDeserializer!
    var actualsByPayCodeDeserializer:ActualsByPayCodeDeserializer!
    var payCodeHoursDeserializer:PayCodeHoursDeserializer!
    var dateFormatterShortDate : DateFormatter
    var dateFormatterShortTime : DateFormatter
    var calendar : NSCalendar!


    init(violationsForTimesheetPeriodDeserializer:ViolationsForTimesheetPeriodDeserializer!,
         timeSheetPermittedActionsDeserializer:TimeSheetPermittedActionsDeserializer,
         currencyValueDeserializer:CurrencyValueDeserializer!,
         grossHoursDeserializer:GrossHoursDeserializer!,
         actualsByPayCodeDeserializer:ActualsByPayCodeDeserializer!,
         payCodeHoursDeserializer:PayCodeHoursDeserializer,
         dateFormatterShortDate:DateFormatter,
         dateFormatterShortTime:DateFormatter,
         calendar: NSCalendar!) {
        self.violationsForTimesheetPeriodDeserializer = violationsForTimesheetPeriodDeserializer
        self.timeSheetPermittedActionsDeserializer = timeSheetPermittedActionsDeserializer
        self.currencyValueDeserializer = currencyValueDeserializer
        self.grossHoursDeserializer = grossHoursDeserializer
        self.actualsByPayCodeDeserializer = actualsByPayCodeDeserializer
        self.payCodeHoursDeserializer = payCodeHoursDeserializer
        self.dateFormatterShortDate = dateFormatterShortDate
        self.dateFormatterShortTime = dateFormatterShortTime
        self.calendar = calendar
        super.init()
    }
    
    func deserialize(_ response:AnyObject?,isAutoSubmitEnabled:Bool) -> Summary? {
        
        if JSONHelper.isValidJSON(response){
            var responseDictionary = response as! [AnyHashable : Any]
            if let json = JSONHelper.getJSON(responseDictionary as AnyObject){
                var timeSheetApprovalStatus: TimeSheetApprovalStatus?
                if let approvalStatusValue = json["timesheetStatus"].dictionary {
                    let uri = approvalStatusValue["uri"]?.stringValue
                    let text = approvalStatusValue["displayText"]?.stringValue
                    timeSheetApprovalStatus = TimeSheetApprovalStatus(approvalStatusUri: uri, approvalStatus: text)
                }
                
                let timesheetDuration = self.deserializeTimesheetDuration(json)
                let violationsAndWaivers : AllViolationSections? = self.violationsForTimesheetPeriodDeserializer.deserialize(responseDictionary["timesheetPeriodViolations"] as! [AnyHashable : Any], timesheetType: TimesheetType.WidgetTimesheetType) 
                
                let timeSheetPermittedActions = self.timeSheetPermittedActionsDeserializer.deserialize(forWidgetTimesheet: responseDictionary,isAutoSubmitEnabled:isAutoSubmitEnabled)
                let lastUpdatedDate = self.deserializeScriptCalculationStatus(json)
                var totalIssuesCount = 0
                if let timesheetPeriodViolationsValue = json["timesheetPeriodViolations"].dictionary {
                    if let totalIssuesCountValue = timesheetPeriodViolationsValue["totalTimesheetPeriodViolationMessagesCount"]?.int{
                        totalIssuesCount = totalIssuesCountValue
                    }
                }
                
                var lastSuccessfulScriptCalculationDate : NSDate? = nil
                var status = SummaryStatus.Unknown.rawValue
                if let scriptCalculationStatus = json["scriptCalculationStatus"].dictionary {
                    if let statusValue = scriptCalculationStatus["status"]?.string{
                        status = statusValue
                    }
                    
                    if let lastSuccessfulAttempt = scriptCalculationStatus["lastSuccessfulAttempt"]?.dictionary{
                        if let valueInUtc = lastSuccessfulAttempt["valueInUtc"]?.dictionary {
                            let hour = valueInUtc["hour"]?.intValue
                            let minute = valueInUtc["minute"]?.intValue
                            let second = valueInUtc["second"]?.intValue
                            let day = valueInUtc["day"]?.intValue
                            let month = valueInUtc["month"]?.intValue
                            let year = valueInUtc["year"]?.intValue
                            let dateComponents = DateComponents(year: year, month: month, day: day,hour: hour, minute: minute, second: second)
                            lastSuccessfulScriptCalculationDate = self.calendar.date(from: dateComponents)! as NSDate
                        }
                    }
                }
                
                let payWidgetData = self.deserializePayWidgetData(json)

                return Summary(timesheetStatus: timeSheetApprovalStatus, 
                               workBreakAndTimeoffDuration: timesheetDuration, 
                               violationsAndWaivers: violationsAndWaivers,
                               issuesCount:totalIssuesCount, 
                               timeSheetPermittedActions: timeSheetPermittedActions,
                               lastUpdatedDateString:lastUpdatedDate,
                               status:status,
                               lastSuccessfulScriptCalculationDate:lastSuccessfulScriptCalculationDate as Date?,
                               payWidgetData:payWidgetData)
            }
        }
        return nil
    }
    
    // MARK:- Private
    
    fileprivate func deserializePayWidgetData(_ summary: JSON) -> PayWidgetData?{
        var actualByPayCodes  = [Paycode]()
        var actualByPayDurations = [Paycode]()
        if let actualsByPaycode = summary["actualsByPaycode"].array, actualsByPaycode.count > 0 {
            for actualByPaycode in actualsByPaycode {
                let payCode = self.actualsByPayCodeDeserializer.deserialize(forPayCodeDictionary: actualByPaycode.dictionaryObject)
                let payCodeDuration = self.payCodeHoursDeserializer.deserialize(forHoursDictionary: actualByPaycode.dictionaryObject)
                actualByPayCodes.append(payCode!)
                actualByPayDurations.append(payCodeDuration!)
            }
        }
        
        let actualsByPayCodeInfo : [Paycode]? = actualByPayCodes.count > 0 ? actualByPayCodes : nil
        let actualsByPayDurationsInfo : [Paycode]? = actualByPayDurations.count > 0 ? actualByPayDurations : nil
        let grossHours = self.grossHoursDeserializer.deserialize(forHoursDictionary: summary["totalPayableTimeDuration"].dictionaryObject)
        let grossPay = self.currencyValueDeserializer.deserialize(forCurrencyValue: summary["totalPayablePay"].dictionaryObject)
        let payWidgetData = PayWidgetData(grossHours: grossHours, grossPay: grossPay, actualsByPaycode: actualsByPayCodeInfo, actualsByDuration: actualsByPayDurationsInfo)
        return payWidgetData
    }


    fileprivate func deserializeTimesheetDuration(_ json: JSON) -> TimesheetDuration {
        let regularHoursComponents = self.dateComponentsFromDictionary(json["totalWorkDuration"])
        let breakHoursComponents = self.dateComponentsFromDictionary(json["totalBreakDuration"])
        let timeOffHoursComponents = self.dateComponentsFromDictionary(json["totalTimeOffDuration"])
        let timesheetDuration = TimesheetDuration(regularHours: regularHoursComponents,
                                                  breakHours: breakHoursComponents,
                                                  timeOffHours: timeOffHoursComponents)
        return timesheetDuration
    }
    
    fileprivate func dateComponentsFromDictionary(_ entity:JSON) -> DateComponents{
        
        var dateComponents = DateComponents(hour: 0, minute: 0, second: 0)
        if let dictionary = entity.dictionary {
            let hour = dictionary["hours"]?.intValue
            let minute = dictionary["minutes"]?.intValue
            let second = dictionary["seconds"]?.intValue
            dateComponents = DateComponents(hour: hour, minute: minute, second: second)
        }
        return dateComponents
    }
    
    fileprivate func deserializeScriptCalculationStatus(_ json: JSON) -> String?{
        
        if let scriptCalculationStatus = json["scriptCalculationStatus"]["lastSuccessfulAttempt"].dictionary {
            let utcValue = scriptCalculationStatus["valueInUtc"]
            guard let valueInUtc = utcValue else {
                return nil;
            }
            let day = valueInUtc["day"].int
            let month = valueInUtc["month"].int
            let year = valueInUtc["year"].int
            let hour = valueInUtc["hour"].int
            let minute = valueInUtc["minute"].int
            let second = valueInUtc["second"].int
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour!
            dateComponents.minute = minute
            dateComponents.second = second
            dateComponents.day = day
            dateComponents.month = month
            dateComponents.year = year
            
            let dateInLocalTimeZone = self.calendar.date(from: dateComponents)
            let dateWithWeekday = self.dateFormatterShortDate.string(from: dateInLocalTimeZone!)
            let timeInAMPM = self.dateFormatterShortTime.string(from: dateInLocalTimeZone!)
            return "\(dateWithWeekday) \(timeInAMPM)"
            
        }
        
        return nil;
    }
    

}
