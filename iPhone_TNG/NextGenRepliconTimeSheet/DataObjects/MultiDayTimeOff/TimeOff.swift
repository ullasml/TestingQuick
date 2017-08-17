//
//  TimeOff.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 04/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit

class TimeOff: NSObject {
    var startDayEntry:TimeOffEntry?
    var endDayEntry:TimeOffEntry?
    var middleDayEntries:[TimeOffEntry]
    var allDurationOptions:[TimeOffDurationOptions]
    var allUDFs:[TimeOffUDF]
    var approvalStatus:TimeOffStatusDetails?
    var balanceInfo:TimeOffBalance?
    var type:TimeOffTypeDetails?
    var details:TimeOffDetails?
    
    init(withStartDayEntry startDayEntry:TimeOffEntry?, endDayEntry:TimeOffEntry?, middleDayEntries:[TimeOffEntry], allDurationOptions:[TimeOffDurationOptions], allUDFs:[TimeOffUDF], approvalStatus:TimeOffStatusDetails?, balanceInfo:TimeOffBalance?, type:TimeOffTypeDetails?, details:TimeOffDetails?){
        self.startDayEntry = startDayEntry
        self.endDayEntry = endDayEntry
        self.middleDayEntries = middleDayEntries
        self.allDurationOptions = allDurationOptions
        self.allUDFs = allUDFs
        self.approvalStatus = approvalStatus
        self.balanceInfo = balanceInfo
        self.type = type
        self.details = details
        super.init()
    }
    
    override var description: String {
        var description = "<\(String(describing: TimeOff.self))>"
        description += "\r\t startDayEntry                    : \(String(describing: self.startDayEntry))"
        description += "\r\t endDayEntry  : \(String(describing: self.endDayEntry))"
        description += "\r\t middleDayEntries                    : \(String(describing: self.middleDayEntries))"
        description += "\r\t allDurationOptions  : \(String(describing: self.allDurationOptions))"
        description += "\r\t allUDFs  : \(String(describing: self.allUDFs))"
        description += "\r\t approvalStatus  : \(String(describing: self.approvalStatus))"
        description += "\r\t balanceInfo  : \(String(describing: self.balanceInfo))"
        description += "\r\t type  : \(String(describing: self.type))"
        description += "\r\t details  : \(String(describing: self.details))"
        return description
    }
    
    func copy(with zone: NSZone? = nil) -> TimeOff {
        let copy = TimeOff(withStartDayEntry: startDayEntry, endDayEntry: endDayEntry, middleDayEntries: middleDayEntries, allDurationOptions: allDurationOptions, allUDFs: allUDFs, approvalStatus: approvalStatus, balanceInfo: balanceInfo, type: type, details: details)
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TimeOff else {
            return false
        }
        let lhs = self
        
        return lhs.startDayEntry == rhs.startDayEntry &&
            lhs.endDayEntry == rhs.endDayEntry &&
            lhs.middleDayEntries == rhs.middleDayEntries &&
            lhs.allDurationOptions == rhs.allDurationOptions &&
            lhs.allUDFs == rhs.allUDFs &&
            lhs.approvalStatus == rhs.approvalStatus &&
            lhs.balanceInfo == rhs.balanceInfo &&
            lhs.type == rhs.type &&
            lhs.details == rhs.details
    }
    
}
