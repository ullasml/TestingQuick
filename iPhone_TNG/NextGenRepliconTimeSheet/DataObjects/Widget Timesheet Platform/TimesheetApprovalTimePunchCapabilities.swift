
import UIKit

@objc class TimesheetApprovalTimePunchCapabilities: NSObject {
    
    
    var hasBreakAccess: Bool
    var activitySelectionRequired: Bool
    var projectTaskSelectionRequired : Bool
    var hasProjectAccess: Bool
    var hasActivityAccess: Bool
    var hasClientAccess: Bool

    
    init(hasBreakAccess: Bool,
         activitySelectionRequired: Bool,
         projectTaskSelectionRequired : Bool,
         hasProjectAccess: Bool,
         hasActivityAccess: Bool,
         hasClientAccess: Bool) {
        self.hasBreakAccess = hasBreakAccess
        self.activitySelectionRequired = activitySelectionRequired
        self.projectTaskSelectionRequired = projectTaskSelectionRequired
        self.hasProjectAccess = hasProjectAccess
        self.hasActivityAccess = hasActivityAccess
        self.hasClientAccess = hasClientAccess
         super.init()
    }
    
    override var description: String {
        var description = "<\(NSStringFromClass(TimesheetApprovalTimePunchCapabilities.self))>"
        description += "\r\t hasBreakAccess                 : \(self.hasBreakAccess)"
        description += "\r\t activitySelectionRequired      : \(self.activitySelectionRequired)"
        description += "\r\t projectTaskSelectionRequired   : \(self.projectTaskSelectionRequired)"
        description += "\r\t hasProjectAccess               : \(self.hasProjectAccess)"
        description += "\r\t hasActivityAccess              : \(self.hasActivityAccess)"
        description += "\r\t hasClientAccess                : \(self.hasClientAccess)"
        return description
    }
    
    // MARK: - <NSCopying>
    
    override func copy() -> Any {
        return self.copyWithZone(nil)
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject {
        return TimesheetApprovalTimePunchCapabilities(hasBreakAccess:self.hasBreakAccess,
                                                   activitySelectionRequired: self.activitySelectionRequired,projectTaskSelectionRequired:self.projectTaskSelectionRequired,
                                                                   hasProjectAccess:self.hasProjectAccess,
                                                                  hasActivityAccess:self.hasActivityAccess,
                                                                    hasClientAccess:self.hasClientAccess)
    }
    

    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TimesheetApprovalTimePunchCapabilities else {
            return false
        }
        let lhs = self
        
        return lhs.hasBreakAccess == rhs.hasBreakAccess &&
               lhs.activitySelectionRequired == rhs.activitySelectionRequired &&
               lhs.projectTaskSelectionRequired == rhs.projectTaskSelectionRequired &&
               lhs.hasProjectAccess == rhs.hasProjectAccess &&
               lhs.hasActivityAccess == rhs.hasActivityAccess &&
               lhs.hasClientAccess == rhs.hasClientAccess
    }
}
