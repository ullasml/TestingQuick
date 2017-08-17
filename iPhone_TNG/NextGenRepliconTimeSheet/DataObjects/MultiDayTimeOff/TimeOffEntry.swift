//
//  TimeOffEntry.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 03/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit

enum TimeOffDurationType : String{
    case fullDay = "urn:replicon:time-off-relative-duration:full-day"
    case quarterDay = "urn:replicon:time-off-relative-duration:quarter-day"
    case halfDay = "urn:replicon:time-off-relative-duration:half-day"
    case threeQuarterDay = "urn:replicon:time-off-relative-duration:three-quarter-day"
    case partialDay = "urn:replicon:time-off-relative-duration:partial-day"
    case none = "urn:replicon:time-off-relative-duration:none"
    case unknown = "unknown"
}

@objc class TimeOffEntry: NSObject {
    let date : Date?
    let scheduleDuration:String
    var bookingDurationDetails:TimeOffDuration?
    var timeEnded : String?
    var timeStarted : String?
    var durationType : TimeOffDurationType {
        return getDurationType()
    }
    
    init?(withDate date:Date?, scheduleDuration:String, bookingDurationObj:TimeOffDuration?, timeStarted:String = "", timeEnded:String = ""){
        
        guard let timeOffDate = date else {
            return nil
        }

        self.date = timeOffDate
        self.scheduleDuration = scheduleDuration
        self.timeEnded = timeEnded
        self.timeStarted = timeStarted
        self.bookingDurationDetails = bookingDurationObj
        super.init()
    }
    
    private func getDurationType() -> TimeOffDurationType {
        guard let type = TimeOffDurationType(rawValue: self.bookingDurationDetails?.uri ?? "") else {
            return TimeOffDurationType.unknown
        }
        return type
    }
    
    override var description: String {
        var description = "<\(String(describing: TimeOffEntry.self))>"
        description += "\r\t date                    : \(String(describing: self.date))"
        description += "\r\t scheduleDuration  : \(String(describing: self.scheduleDuration))"
        description += "\r\t durationType                    : \(String(describing: self.durationType))"
        description += "\r\t durationDetails  : \(String(describing: self.bookingDurationDetails))"
        description += "\r\t timeEnded : \(String(describing: self.timeEnded))"
        description += "\r\t timeStarted : \(String(describing: self.timeStarted))"
        return description
    }
    
    func copy(with zone: NSZone? = nil) -> TimeOffEntry? {
        let copy = TimeOffEntry(withDate: date, scheduleDuration: scheduleDuration, bookingDurationObj: bookingDurationDetails, timeStarted: timeStarted ?? "", timeEnded: timeEnded ?? "")
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TimeOffEntry else {
            return false
        }
        let lhs = self
        
        guard let lhsDate = lhs.date, let rhsDate = rhs.date else {
            return false
        }
        
        return lhsDate.equalsIgnoreTime(rhsDate) &&
            lhs.scheduleDuration == rhs.scheduleDuration &&
            lhs.timeEnded == rhs.timeEnded &&
            lhs.timeStarted == rhs.timeStarted &&
            lhs.bookingDurationDetails == rhs.bookingDurationDetails
    }
}
