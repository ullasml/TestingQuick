

import UIKit

func ==?<T : Equatable>(lhs: T?, rhs: T?) -> Bool{
    if lhs == nil && rhs == nil {
        return true
    }
    else if ((lhs == nil && rhs != nil)||(lhs != nil && rhs == nil)) {
        return false 
    }
    else if lhs != nil && rhs != nil {
        
        if let rhsValue = rhs as? Date, let lhsValue = lhs as? Date{
            let areDatesEqual = (rhsValue.compare(lhsValue) == .orderedSame)
            return areDatesEqual 
        }
        return (lhs! == rhs!) 
    }
    return false
}

infix operator ==? : CustomEqualityPrecedence
precedencegroup CustomEqualityPrecedence {
    associativity: left
    higherThan: AdditionPrecedence
}


 enum SummaryStatus : String{
    case OutOfDate  = "urn:replicon:mobile:timesheet:widget:summary:status:out-of-date"
    case Current    = "urn:replicon:mobile:timesheet:widget:summary:status:current"
    case Unknown
}

class WidgetTimesheet: NSObject {
    
    var uri: String!
    var period: TimesheetPeriod!
    var widgetsMetaData: [WidgetData]?
    var approvalTimePunchCapabilities: TimesheetApprovalTimePunchCapabilities?
    var summary:Summary?
    var canAutoSubmitOnDueDate:Bool
    var displayPayAmount:Bool 
    var canOwnerViewPayrollSummary:Bool
    var displayPayTotals:Bool
    var attestationStatus:AttestationStatus


    init(uri: String!,
         period: TimesheetPeriod!,
         summary:Summary?,
         widgetsMetaData: [WidgetData]?,
         approvalTimePunchCapabilities:TimesheetApprovalTimePunchCapabilities?,
         canAutoSubmitOnDueDate:Bool = false,
         displayPayAmount:Bool = false,
         canOwnerViewPayrollSummary:Bool = false,
         displayPayTotals:Bool = false,
         attestationStatus:AttestationStatus) {
        self.uri = uri
        self.summary = summary
        self.period = period
        self.widgetsMetaData = widgetsMetaData
        self.approvalTimePunchCapabilities = approvalTimePunchCapabilities
        self.canAutoSubmitOnDueDate = canAutoSubmitOnDueDate
        self.displayPayAmount = displayPayAmount
        self.canOwnerViewPayrollSummary = canOwnerViewPayrollSummary
        self.displayPayTotals = displayPayTotals
        self.attestationStatus = attestationStatus
        super.init()
    }
    
    override var description: String {
        var description = "<\(NSStringFromClass(WidgetTimesheet.self))>"
        description += "\r\t period                         : \(self.period)"
        description += "\r\t uri                            : \(self.uri)"
        description += "\r\t summary                        : \(String(describing: self.summary))"
        description += "\r\t widgetsMetaData                : \(String(describing: self.widgetsMetaData))"
        description += "\r\t approvalTimePunchCapabilities  : \(String(describing: self.approvalTimePunchCapabilities))"
        description += "\r\t canAutoSubmitOnDueDate         : \(String(describing: self.canAutoSubmitOnDueDate))"
        description += "\r\t displayPayAmount               : \(String(describing: self.displayPayAmount))"
        description += "\r\t canOwnerViewPayrollSummary     : \(String(describing: self.canOwnerViewPayrollSummary))"
        description += "\r\t displayPayTotals               : \(String(describing: self.displayPayTotals))"
        description += "\r\t attestationStatus               : \(String(describing: self.attestationStatus))"
        return description
    }
    
    // MARK: - <NSCopying>
    
    override func copy() -> Any {
        return self.copyWithZone(nil)
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject {
        return WidgetTimesheet(uri: self.uri,
                               period: self.period,
                               summary:self.summary,
                               widgetsMetaData:self.widgetsMetaData,
                               approvalTimePunchCapabilities:self.approvalTimePunchCapabilities,
                               canAutoSubmitOnDueDate:self.canAutoSubmitOnDueDate,
                               displayPayAmount:self.displayPayAmount,
                               canOwnerViewPayrollSummary:self.canOwnerViewPayrollSummary,
                               displayPayTotals:self.displayPayTotals,
                               attestationStatus:self.attestationStatus)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? WidgetTimesheet else {
            return false
        }
        let lhs = self
        
        let uriEqual                = (lhs.uri ==? rhs.uri)
        let summaryEqual            = (lhs.summary ==? rhs.summary)
        let periodEqual             = (lhs.period ==? rhs.period)
        let capabilitiesEqual       = (lhs.approvalTimePunchCapabilities ==? rhs.approvalTimePunchCapabilities) 
        let canAutoSubmitEqual      = (lhs.canAutoSubmitOnDueDate ==? rhs.canAutoSubmitOnDueDate)
        let viewPayrollSummaryEqual = (lhs.canOwnerViewPayrollSummary ==? rhs.canOwnerViewPayrollSummary)
        let displayPayAmountEqual   = (lhs.displayPayAmount ==? rhs.displayPayAmount)
        let displayPayTotalsEqual   = (lhs.displayPayTotals ==? rhs.displayPayTotals)
        let attestationStatusEqual  = (lhs.attestationStatus ==? rhs.attestationStatus)

        let allEqual = uriEqual && summaryEqual && periodEqual && capabilitiesEqual && canAutoSubmitEqual && viewPayrollSummaryEqual && displayPayAmountEqual && displayPayTotalsEqual && attestationStatusEqual
        return  allEqual
    }
    
}

class Summary: NSObject {
    
    var timesheetStatus : TimeSheetApprovalStatus!
    var workBreakAndTimeoffDuration: TimesheetDuration?
    var violationsAndWaivers:AllViolationSections?
    var issuesCount: Int
    var timeSheetPermittedActions:TimeSheetPermittedActions!
    var lastUpdatedDateString:String?
    var status: String!
    var lastSuccessfulScriptCalculationDate : Date?
    var payWidgetData:PayWidgetData!

    
    init(timesheetStatus:TimeSheetApprovalStatus!,
         workBreakAndTimeoffDuration:TimesheetDuration?,
         violationsAndWaivers:AllViolationSections?,
         issuesCount:Int = 0,
         timeSheetPermittedActions:TimeSheetPermittedActions!,
         lastUpdatedDateString:String? = nil,
         status:String! = SummaryStatus.Unknown.rawValue,
         lastSuccessfulScriptCalculationDate : Date? = nil,
         payWidgetData:PayWidgetData!) {
        self.timesheetStatus = timesheetStatus
        self.workBreakAndTimeoffDuration = workBreakAndTimeoffDuration
        self.violationsAndWaivers = violationsAndWaivers
        self.issuesCount = issuesCount
        self.timeSheetPermittedActions = timeSheetPermittedActions
        self.lastUpdatedDateString = lastUpdatedDateString
        self.status = status
        self.lastSuccessfulScriptCalculationDate = lastSuccessfulScriptCalculationDate
        self.payWidgetData = payWidgetData
        super.init()
    }
    
    override var description: String {
        var description = "<\(NSStringFromClass(WidgetTimesheet.self))>"
        description += "\r\t timesheetStatus                : \(self.timesheetStatus)"
        description += "\r\t workBreakAndTimeoffDuration    : \(String(describing: self.workBreakAndTimeoffDuration))"
        description += "\r\t violationsAndWaivers           : \(String(describing: self.violationsAndWaivers))"
        description += "\r\t issuesCount                    : \(String(describing: self.issuesCount))"
        description += "\r\t violationsAndWaivers           : \(String(describing: self.timeSheetPermittedActions))"
        description += "\r\t lastUpdatedDateString          : \(String(describing: self.lastUpdatedDateString))"
        description += "\r\t status                         : \(String(describing: self.status))"
        description += "\r\t lastSuccessfulCalculationDate  : \(String(describing: self.lastSuccessfulScriptCalculationDate))"
        description += "\r\t payWidgetData                  : \(String(describing: self.payWidgetData))"

        return description
    }
    
    // MARK: - <NSCopying>
    
    override func copy() -> Any {
        return self.copyWithZone(nil)
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject {
        return Summary(timesheetStatus:self.timesheetStatus,
                       workBreakAndTimeoffDuration:self.workBreakAndTimeoffDuration,
                       violationsAndWaivers:self.violationsAndWaivers,
                       issuesCount:self.issuesCount,
                       timeSheetPermittedActions:self.timeSheetPermittedActions,
                       lastUpdatedDateString:self.lastUpdatedDateString,
                       status:self.status,
                       lastSuccessfulScriptCalculationDate:self.lastSuccessfulScriptCalculationDate,
                       payWidgetData:self.payWidgetData)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Summary else {
            return false
        }
        let lhs = self
        let statusEqual         = (lhs.timesheetStatus ==? rhs.timesheetStatus) 
        let actionsEqual        = (lhs.timeSheetPermittedActions ==? rhs.timeSheetPermittedActions) 
        let issuesEqual         = (lhs.issuesCount ==? rhs.issuesCount)
        let durationEqual       = (lhs.workBreakAndTimeoffDuration ==? rhs.workBreakAndTimeoffDuration) 
        let dateStringEqual     = (lhs.lastUpdatedDateString ==? rhs.lastUpdatedDateString) 
        let waiversEqual        = (lhs.violationsAndWaivers ==? rhs.violationsAndWaivers) 
        let summaryStatusEqual  = (lhs.status ==? rhs.status)          
        let payWidgetDataEqual  = (lhs.payWidgetData ==? rhs.payWidgetData) 
        let dateEqual           = (lhs.lastSuccessfulScriptCalculationDate ==? rhs.lastSuccessfulScriptCalculationDate) 
        
        let allEqual = statusEqual && actionsEqual && waiversEqual && issuesEqual && durationEqual && dateStringEqual && summaryStatusEqual && payWidgetDataEqual && dateEqual
        return  allEqual
    }
}

class TimesheetDuration: NSObject {
    
    var regularHours: DateComponents?
    var breakHours: DateComponents?
    var timeOffHours: DateComponents?
    
    init(regularHours: DateComponents?,breakHours: DateComponents?,timeOffHours:DateComponents?) {
        self.regularHours = regularHours
        self.breakHours = breakHours
        self.timeOffHours = timeOffHours
        super.init()
    }
    
    override var description: String {
        var description = "<\(NSStringFromClass(TimesheetDuration.self))>"
        description += "\r\t timeOffHours          : \(String(describing: self.timeOffHours))"
        description += "\r\t breakHours            : \(String(describing: self.breakHours))"
        description += "\r\t regularHours          : \(String(describing: self.regularHours))"
        return description
    }
    // MARK: - <NSCopying>
    
    override func copy() -> Any {
        return self.copyWithZone(nil)
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject {
        return TimesheetDuration(regularHours: self.regularHours,
                                 breakHours: self.breakHours,
                                 timeOffHours:self.timeOffHours)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TimesheetDuration else {
            return false
        }
        let lhs = self
        
        let  regularHoursEqual = (lhs.regularHours ==? rhs.regularHours) 
        let  breakHoursEqual =  (lhs.breakHours ==? rhs.breakHours) 
        let  timeOffHoursEqual = (lhs.timeOffHours ==? rhs.timeOffHours) 
        return regularHoursEqual && breakHoursEqual && timeOffHoursEqual
    }
    
}

class PunchWidgetData: NSObject {
    
    var daySummaries: [TimesheetDaySummary]!
    var widgetLevelDuration: TimesheetDuration!
    
    init(daySummaries: [TimesheetDaySummary]!,widgetLevelDuration: TimesheetDuration!) {
        self.daySummaries = daySummaries
        self.widgetLevelDuration = widgetLevelDuration
        super.init()
    }
    
    override var description: String {
        var description = "<\(NSStringFromClass(PunchWidgetData.self))>"
        description += "\r\t widgetLevelDuration     : \(self.widgetLevelDuration)"
        description += "\r\t daySummaries            : \(self.daySummaries)"
        return description
    }
    // MARK: - <NSCopying>
    
    override func copy() -> Any {
        return self.copyWithZone(nil)
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject {
        return PunchWidgetData(daySummaries: self.daySummaries,widgetLevelDuration:self.widgetLevelDuration)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? PunchWidgetData else {
            return false
        }
        let lhs = self
        let daySummariesEqual         = (lhs.daySummaries == rhs.daySummaries) 
        let widgetDurationEqual       = (lhs.widgetLevelDuration ==? rhs.widgetLevelDuration)
        return daySummariesEqual && widgetDurationEqual
    }
}

class PayWidgetData: NSObject {
    
    var grossHours: GrossHours?
    var grossPay: CurrencyValue?
    var actualsByPaycode: [Paycode]?
    var actualsByDuration: [Paycode]?

    
    init(grossHours: GrossHours?,grossPay: CurrencyValue?,actualsByPaycode:[Paycode]?,actualsByDuration: [Paycode]?) {
        self.grossHours = grossHours
        self.grossPay = grossPay
        self.actualsByPaycode = actualsByPaycode
        self.actualsByDuration = actualsByDuration
        super.init()
    }
    
    override var description: String {
        var description = "<\(NSStringFromClass(PayWidgetData.self))>"
        description += "\r\t grossHours                 : \(String(describing: self.grossHours))"
        description += "\r\t grossPay                   : \(String(describing: self.grossPay))"
        description += "\r\t actualsByPaycode           : \(String(describing: self.actualsByPaycode))"
        description += "\r\t actualsByDuration          : \(String(describing: self.actualsByDuration))"
        return description
    }
    // MARK: - <NSCopying>
    
    override func copy() -> Any {
        return self.copyWithZone(nil)
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject {
        return PayWidgetData(grossHours: self.grossHours, grossPay: self.grossPay, actualsByPaycode: self.actualsByPaycode, actualsByDuration: self.actualsByDuration)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? PayWidgetData else {
            return false
        }
        let lhs = self
        let grossPayEqual = (lhs.grossPay ==? rhs.grossPay) 
        let grossHoursEqual = (lhs.grossHours ==? rhs.grossHours) 
        return grossPayEqual && grossHoursEqual
    }
    
}

class AttestationWidgetData: NSObject {
    
    var titleText: String!
    var descriptionText: String!
    
    
    init(title: String!,description: String!) {
        self.titleText = title
        self.descriptionText = description
        super.init()
    }
    
    override var description: String {
        var description = "<\(NSStringFromClass(AttestationWidgetData.self))>"
        description += "\r\t title                 : \(self.titleText)"
        description += "\r\t description           : \(self.descriptionText)"
        return description
    }
    // MARK: - <NSCopying>
    
    override func copy() -> Any {
        return self.copyWithZone(nil)
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject {
        return AttestationWidgetData(title: self.titleText,description:self.descriptionText)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? AttestationWidgetData else {
            return false
        }
        let lhs = self
        let titleTextEqual         = (lhs.titleText ==? rhs.titleText) 
        let descriptionTextEqual   = (lhs.descriptionText ==? rhs.descriptionText)
        return titleTextEqual && descriptionTextEqual
    }
    
}

class NoticeWidgetData: NSObject {
    
    var titleText: String!
    var descriptionText: String!
    
    
    init(title: String!,description: String!) {
        self.titleText = title
        self.descriptionText = description
        super.init()
    }
    
    override var description: String {
        var description = "<\(NSStringFromClass(NoticeWidgetData.self))>"
        description += "\r\t title                 : \(self.titleText)"
        description += "\r\t description           : \(self.descriptionText)"
        return description
    }
    // MARK: - <NSCopying>
    
    override func copy() -> Any {
        return self.copyWithZone(nil)
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject {
        return NoticeWidgetData(title: self.titleText,description:self.descriptionText)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? NoticeWidgetData else {
            return false
        }
        let lhs = self
        let titleTextEqual         = (lhs.titleText ==? rhs.titleText) 
        let descriptionTextEqual   = (lhs.descriptionText ==? rhs.descriptionText)
        return titleTextEqual && descriptionTextEqual
    }
    
}

class WidgetData: NSObject {
    
    var timesheetWidgetTypeUri: String!
    var timesheetWidgetMetaData: AnyObject?
    
    init(timesheetWidgetMetaData: AnyObject?,timesheetWidgetTypeUri: String!) {
        self.timesheetWidgetTypeUri = timesheetWidgetTypeUri
        self.timesheetWidgetMetaData = timesheetWidgetMetaData
        super.init()
    }
    
    override var description: String {
        var description = "<\(NSStringFromClass(WidgetData.self))>"
        description += "\r\t timesheetWidgetMetaData    : \(String(describing: self.timesheetWidgetMetaData))"
        description += "\r\t timesheetWidgetType        : \(String(describing: self.timesheetWidgetTypeUri))"
        return description
    }
    // MARK: - <NSCopying>
    
    override func copy() -> Any {
        return self.copyWithZone(nil)
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject {
        return WidgetData(timesheetWidgetMetaData: self.timesheetWidgetMetaData,
                          timesheetWidgetTypeUri:self.timesheetWidgetTypeUri)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? WidgetData else {
            return false
        }
        let lhs = self
        
        return lhs.timesheetWidgetTypeUri ==? rhs.timesheetWidgetTypeUri
        let metaDataEqual  = true //(lhs.timesheetWidgetMetaData ==? rhs.timesheetWidgetMetaData) 
        let uriEqual       = (lhs.timesheetWidgetTypeUri ==? rhs.timesheetWidgetTypeUri)
        return metaDataEqual && uriEqual
    }
    
}
