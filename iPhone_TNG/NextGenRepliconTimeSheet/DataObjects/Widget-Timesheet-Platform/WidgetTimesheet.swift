

import UIKit

class WidgetTimesheet: NSObject {
    
    var uri: String!
    var period: TimesheetPeriod!
    var approvalStatus : TimeSheetApprovalStatus!
    var widgetsMetaData: [WidgetMetaData]?
    var workBreakAndTimeoffDuration: TimesheetDuration?
    var issuesCount: Int
    var timeSheetPermittedActions:TimeSheetPermittedActions!

    
    init(uri: String!,
         period: TimesheetPeriod!,
         approvalStatus:TimeSheetApprovalStatus!,
         widgetsMetaData: [WidgetMetaData]?,
         workBreakAndTimeoffDuration:TimesheetDuration?,
         issuesCount:Int = 0,
         timeSheetPermittedActions:TimeSheetPermittedActions) {
        self.uri = uri
        self.approvalStatus = approvalStatus
        self.period = period
        self.widgetsMetaData = widgetsMetaData
        self.workBreakAndTimeoffDuration = workBreakAndTimeoffDuration
        self.issuesCount = issuesCount
        self.timeSheetPermittedActions = timeSheetPermittedActions
        super.init()
    }
    
    override var description: String {
        var description = "<\(NSStringFromClass(WidgetTimesheet.self))>"
        description += "\r\t approvalStatus                 : \(self.approvalStatus)"
        description += "\r\t period                         : \(self.period)"
        description += "\r\t uri                            : \(self.uri)"
        description += "\r\t widgetsMetaData                : \(String(describing: self.widgetsMetaData))"
        description += "\r\t workBreakAndTimeoffDuration    : \(String(describing: self.workBreakAndTimeoffDuration))"
        description += "\r\t issuesCount                    : \(self.issuesCount)"
        description += "\r\t workBreakAndTimeoffDuration    : \(String(describing: self.timeSheetPermittedActions))"
        return description
    }
    
    // MARK: - <NSCopying>
    
    override func copy() -> Any {
        return self.copyWithZone(nil)
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject {
        return WidgetTimesheet(uri: self.uri,
                               period: self.period,
                               approvalStatus:self.approvalStatus,
                               widgetsMetaData:self.widgetsMetaData,
                               workBreakAndTimeoffDuration:self.workBreakAndTimeoffDuration,
                               issuesCount:self.issuesCount,
                               timeSheetPermittedActions:self.timeSheetPermittedActions)
    }
    
}

class TimesheetDuration: NSObject {
    
    var regularHours: DateComponents
    var breakHours: DateComponents
    var timeOffHours: DateComponents
    
    init(regularHours: DateComponents,breakHours: DateComponents,timeOffHours:DateComponents) {
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
        
        return lhs.regularHours == rhs.regularHours && lhs.breakHours == rhs.breakHours && lhs.timeOffHours == rhs.timeOffHours
    }
    
}

class PunchWidgetMetaData: NSObject {
    
    var titleText: String!
    var descriptionText: String!
    
    
    init(title: String!,description: String!) {
        self.titleText = title
        self.descriptionText = description
        super.init()
    }
    
    override var description: String {
        var description = "<\(NSStringFromClass(PunchWidgetMetaData.self))>"
        description += "\r\t title                 : \(self.titleText)"
        description += "\r\t description            : \(self.descriptionText)"
        return description
    }
    // MARK: - <NSCopying>
    
    override func copy() -> Any {
        return self.copyWithZone(nil)
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject {
        return PunchWidgetMetaData(title: self.titleText,description:self.descriptionText)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? PunchWidgetMetaData else {
            return false
        }
        let lhs = self
        
        return lhs.titleText == rhs.titleText && lhs.descriptionText == rhs.descriptionText
    }
    
}

class PayWidgetMetaData: NSObject {
    
    var titleText: String!
    var descriptionText: String!
    
    
    init(title: String!,description: String!) {
        self.titleText = title
        self.descriptionText = description
        super.init()
    }
    
    override var description: String {
        var description = "<\(NSStringFromClass(PayWidgetMetaData.self))>"
        description += "\r\t title                 : \(self.titleText)"
        description += "\r\t description            : \(self.descriptionText)"
        return description
    }
    // MARK: - <NSCopying>
    
    override func copy() -> Any {
        return self.copyWithZone(nil)
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject {
        return PayWidgetMetaData(title: self.titleText,description:self.descriptionText)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? PayWidgetMetaData else {
            return false
        }
        let lhs = self
        
        return lhs.titleText == rhs.titleText && lhs.descriptionText == rhs.descriptionText
    }
    
}

class AttestationWidgetMetaData: NSObject {
    
    var titleText: String!
    var descriptionText: String!
    
    
    init(title: String!,description: String!) {
        self.titleText = title
        self.descriptionText = description
        super.init()
    }
    
    override var description: String {
        var description = "<\(NSStringFromClass(AttestationWidgetMetaData.self))>"
        description += "\r\t title                 : \(self.titleText)"
        description += "\r\t description            : \(self.descriptionText)"
        return description
    }
    // MARK: - <NSCopying>
    
    override func copy() -> Any {
        return self.copyWithZone(nil)
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject {
        return AttestationWidgetMetaData(title: self.titleText,description:self.descriptionText)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? AttestationWidgetMetaData else {
            return false
        }
        let lhs = self
        
        return lhs.titleText == rhs.titleText && lhs.descriptionText == rhs.descriptionText
    }
    
}

class NoticeWidgetMetaData: NSObject {
    
    var titleText: String!
    var descriptionText: String!
    
    
    init(title: String!,description: String!) {
        self.titleText = title
        self.descriptionText = description
        super.init()
    }
    
    override var description: String {
        var description = "<\(NSStringFromClass(NoticeWidgetMetaData.self))>"
        description += "\r\t title                 : \(self.titleText)"
        description += "\r\t description            : \(self.descriptionText)"
        return description
    }
    // MARK: - <NSCopying>
    
    override func copy() -> Any {
        return self.copyWithZone(nil)
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject {
        return NoticeWidgetMetaData(title: self.titleText,description:self.descriptionText)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? NoticeWidgetMetaData else {
            return false
        }
        let lhs = self
        
        return lhs.titleText == rhs.titleText && lhs.descriptionText == rhs.descriptionText
    }
    
}

class WidgetMetaData: NSObject {
    
    var timesheetWidgetTypeUri: String!
    var timesheetWidgetMetaData: AnyObject?
    
    init(timesheetWidgetMetaData: AnyObject?,timesheetWidgetTypeUri: String!) {
        self.timesheetWidgetTypeUri = timesheetWidgetTypeUri
        self.timesheetWidgetMetaData = timesheetWidgetMetaData
        super.init()
    }
    
    override var description: String {
        var description = "<\(NSStringFromClass(WidgetMetaData.self))>"
        description += "\r\t timesheetWidgetMetaData    : \(String(describing: self.timesheetWidgetMetaData))"
        description += "\r\t timesheetWidgetType        : \(String(describing: self.timesheetWidgetTypeUri))"
        return description
    }
    // MARK: - <NSCopying>
    
    override func copy() -> Any {
        return self.copyWithZone(nil)
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject {
        return WidgetMetaData(timesheetWidgetMetaData: self.timesheetWidgetMetaData,
                              timesheetWidgetTypeUri:self.timesheetWidgetTypeUri)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? WidgetMetaData else {
            return false
        }
        let lhs = self
        
        return lhs.timesheetWidgetTypeUri == rhs.timesheetWidgetTypeUri
    }
    
}
