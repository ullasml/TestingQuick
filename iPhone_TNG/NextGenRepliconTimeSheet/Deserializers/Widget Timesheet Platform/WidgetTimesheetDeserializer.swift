
import UIKit

enum TimesheetWidgetType : String{
    case PayWidget = "urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
    case PunchWidget = "urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
    case AttestationWidget = "urn:replicon:policy:timesheet:widget-timesheet:attestation"
    case NoticeWidget = "urn:replicon:policy:timesheet:widget-timesheet:notice"
    case TimeoffInLieuWidget = "TimeoffInLieuWidget"
    case TimeDistributionWidget = "TimedistributionWidget"
    case DailyFieldWidget = "DailyfieldWidget"
    case UnknownWidget
    
}

private enum AttestationStatusType : String{
    case Attested = "urn:replicon:attestation-status:attested"
    case Unattested = "urn:replicon:attestation-status:unattested"
}


/**
 Deserialize the widget timesheet for a service response
 - Parameter response: a response dictionary
 - Returns: a WidgetTimesheet
 */
// MARK:- <WidgetTimesheetDeserializerInterface>

@objc protocol WidgetTimesheetDeserializerInterface : class {
    func deserialize(_ response:AnyObject?) -> WidgetTimesheet?
}


// MARK:- WidgetTimesheetDeserializer

class WidgetTimesheetDeserializer: NSObject,WidgetTimesheetDeserializerInterface {
    
    var widgetTimesheetSummaryDeserializer:WidgetTimesheetSummaryDeserializer!
    var calendar : NSCalendar!
    
    init(widgetTimesheetSummaryDeserializer:WidgetTimesheetSummaryDeserializer!,
         calendar: NSCalendar!) {
        self.calendar = calendar
        self.widgetTimesheetSummaryDeserializer = widgetTimesheetSummaryDeserializer
        super.init()
    }
    
    func deserialize(_ response:AnyObject?) -> WidgetTimesheet? {
        
        if JSONHelper.isValidJSON(response){
            if let json = JSONHelper.getJSON(response){
                return self.deserializeFromJSON(json, response:response)
            }
        }
        return nil
    }
    
    // MARK: - Private
    
    fileprivate func deserializeFromJSON(_ json: JSON,response:AnyObject?) -> WidgetTimesheet{
        
        let responseDictionary = response as! [AnyHashable : Any]
        var timesheetPeriod : TimesheetPeriod?
        let timesheetUri = json["timesheetUri"].stringValue
        var attestationStatusType:AttestationStatusType = .Unattested

        if let timesheetInfo = json["timesheet"].dictionary{
            
            if let timesheetPeriodValue = timesheetInfo["timesheetPeriod"]?.dictionary {
                if let timesheetPeriodRangeInfo = timesheetPeriodValue["dateRangeValue"]?.dictionary{
                    let endDateValue = timesheetPeriodRangeInfo["endDate"]?.dictionaryObject
                    let startDateValue = timesheetPeriodRangeInfo["startDate"]?.dictionaryObject
                    let dateTimeComponentDeserializer = DateTimeComponentDeserializer()
                    let endDateComponents = dateTimeComponentDeserializer.deserializeDateTime(endDateValue)
                    let startDateComponents = dateTimeComponentDeserializer.deserializeDateTime(startDateValue)
                    let endDate = self.calendar.date(from: endDateComponents!)
                    let startDate = self.calendar.date(from: startDateComponents!)
                    timesheetPeriod = TimesheetPeriod(start: startDate, end: endDate)
                }
            }
            if let noticeWidgetValue = timesheetInfo["attestation"]?.dictionary {
                if let statusValue = noticeWidgetValue["status"]?.stringValue,statusValue.characters.count > 0{
                    attestationStatusType = AttestationStatusType(rawValue: statusValue)!
                }
            }
        }
        var isAutoSubmitEnabled = false
        var canOwnerViewPayrollSummary = false
        var displayPayAmount = false
        var displayPayTotals = false
        if let permittedActions = json["permittedActions"].dictionary {
            if let canAutoSubmitOnDueDate = permittedActions["canAutoSubmitOnDueDate"]?.bool{
                isAutoSubmitEnabled =  canAutoSubmitOnDueDate
            }
            if let displayPayAmountBoolValue = permittedActions["displayPayAmount"]?.bool{
                displayPayAmount =  displayPayAmountBoolValue
            }
            if let canOwnerViewPayrollSummaryBoolValue = permittedActions["canOwnerViewPayrollSummary"]?.bool{
                canOwnerViewPayrollSummary =  canOwnerViewPayrollSummaryBoolValue
            }
            if let displayPayTotalsBoolValue = permittedActions["displayPayTotals"]?.bool{
                displayPayTotals =  displayPayTotalsBoolValue
            }
        }
        
        let timePunchCapabilities = self.deserializeTimePunchCapabilities(json)
        let widgetTimesheetSummaryDeserializerInterface = self.widgetTimesheetSummaryDeserializer as WidgetTimesheetSummaryDeserializerInterface
        let timesheetSummary = widgetTimesheetSummaryDeserializerInterface.deserialize(responseDictionary["summary"] as AnyObject, isAutoSubmitEnabled: isAutoSubmitEnabled)        
        let widgetsMetaData = self.deserializeWidgetsMetaData(json,summary:timesheetSummary)
        
        let attestationStatus:AttestationStatus = (attestationStatusType == .Unattested) ? .Unattested : .Attested
        let widgetTimesheet = WidgetTimesheet(uri: timesheetUri,
                                              period: timesheetPeriod,
                                              summary:timesheetSummary,
                                              widgetsMetaData:widgetsMetaData,
                                              approvalTimePunchCapabilities:timePunchCapabilities,
                                              displayPayAmount:displayPayAmount,
                                              canOwnerViewPayrollSummary:canOwnerViewPayrollSummary,
                                              displayPayTotals:displayPayTotals, 
                                              attestationStatus:attestationStatus)
        return widgetTimesheet
    }
    
    fileprivate func deserializeTimePunchCapabilities(_ json: JSON) -> TimesheetApprovalTimePunchCapabilities?{
        
        if let timePunchCapabilities = json["timepunchCapabilities"].dictionary{
            let hasBreakAccess = timePunchCapabilities["hasBreakAccess"]?.bool ?? false
            let activitySelectionRequired = timePunchCapabilities["activitySelectionRequired"]?.bool ?? false
            let projectTaskSelectionRequired = timePunchCapabilities["projectTaskSelectionRequired"]?.bool ?? false
            let hasProjectAccess = timePunchCapabilities["hasProjectAccess"]?.bool ?? false
            let hasActivityAccess = timePunchCapabilities["hasActivityAccess"]?.bool ?? false
            let hasClientAccess = timePunchCapabilities["hasClientAccess"]?.bool ?? false
            return TimesheetApprovalTimePunchCapabilities(hasBreakAccess: hasBreakAccess, activitySelectionRequired: activitySelectionRequired, projectTaskSelectionRequired: projectTaskSelectionRequired, hasProjectAccess: hasProjectAccess, hasActivityAccess: hasActivityAccess, hasClientAccess: hasClientAccess)
            
        }
        return nil
    }
    
    fileprivate func deserializeWidgetsMetaData(_ json: JSON,summary:Summary!) -> [WidgetData]? {
        var supportedWidgets  = [TimesheetWidgetType]()
        var allTimesheetWidgets = [WidgetData]()
        for widgetUri in supportedWidgetUris {
            let timesheetWidgetType = TimesheetWidgetType(rawValue: widgetUri) ?? .UnknownWidget
            supportedWidgets.append(timesheetWidgetType)
        }

        if let timesheetWidgets = json["widgets"].array, timesheetWidgets.count > 0 {
            for widget in timesheetWidgets {
                let widgetTypeUri = widget.stringValue
                let timesheetWidgetType = TimesheetWidgetType(rawValue:widgetTypeUri ) ?? .UnknownWidget
                var timesheetWidgetMetaData : AnyObject? = nil
                if timesheetWidgetType == .PayWidget{
                    timesheetWidgetMetaData = summary.payWidgetData
                }
                else if timesheetWidgetType == .NoticeWidget{
                     timesheetWidgetMetaData = self.deserializeNoticeWidgetData(json)
                }
                else if timesheetWidgetType == .AttestationWidget{
                    timesheetWidgetMetaData = self.deserializeAttestationWidgetData(json)
                }
                if supportedWidgets.contains(timesheetWidgetType){
                    let widgetMetaData = WidgetData(timesheetWidgetMetaData: timesheetWidgetMetaData,
                                                    timesheetWidgetTypeUri: widgetTypeUri)
                    allTimesheetWidgets.append(widgetMetaData)
                }
            }
        }
        return allTimesheetWidgets;
    }
    
        
    fileprivate func deserializeNoticeWidgetData(_ widget: JSON) -> NoticeWidgetData{
        var title : String? = nil
        var description : String? = nil
        if let timesheetInfo = widget["timesheet"].dictionary{
            if let noticeWidgetValue = timesheetInfo["notice"]?.dictionary {
                if let titleValue = noticeWidgetValue["title"]?.stringValue,titleValue.characters.count > 0{
                    title = titleValue
                }
                if let text = noticeWidgetValue["text"]?.stringValue,text.characters.count > 0{
                    description = text;
                }
            }
        }
        let noticeMetaData = NoticeWidgetData(title: title,description:description)
        return noticeMetaData
    }
    
    fileprivate func deserializeAttestationWidgetData(_ widget: JSON) -> AttestationWidgetData{
        var title : String? = nil
        var description : String? = nil
        if let timesheetInfo = widget["timesheet"].dictionary{
            if let noticeWidgetValue = timesheetInfo["attestation"]?.dictionary {
                if let titleValue = noticeWidgetValue["title"]?.stringValue,titleValue.characters.count > 0{
                    title = titleValue
                }
                if let text = noticeWidgetValue["text"]?.stringValue,text.characters.count > 0{
                    description = text;
                }
            }
        }
        let attestationMetaData = AttestationWidgetData(title: title,description:description)
        return attestationMetaData
    }
    
}
