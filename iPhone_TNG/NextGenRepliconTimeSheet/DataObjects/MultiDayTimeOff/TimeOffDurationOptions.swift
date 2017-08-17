//
//  TimeOffDurationOptions.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 03/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit

@objc class TimeOffDurationOptions: NSObject {
    let scheduleDuration:String
    var durationOptions:[TimeOffDuration]?
    
    init(withScheduleDuration scheduleDuration:String, durationOptions:[TimeOffDuration]?) {
        self.scheduleDuration = scheduleDuration
        self.durationOptions = durationOptions
        super.init()
    }
    
    override var description: String {
        var description = "<\(String(describing: TimeOffDurationOptions.self))>"
        description += "\r\t scheduleDuration                    : \(String(describing: self.scheduleDuration))"
        description += "\r\t durationOptions  : \(String(describing: self.durationOptions))"
        return description
    }
    
    func copy(with zone: NSZone? = nil) -> TimeOffDurationOptions {
        let copy = TimeOffDurationOptions(withScheduleDuration: scheduleDuration, durationOptions: durationOptions)
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TimeOffDurationOptions, let lhsOptions = self.durationOptions, let rhsOptions = rhs.durationOptions else {
            return false
        }
        let lhs = self
        
        return lhs.scheduleDuration == rhs.scheduleDuration && lhsOptions == rhsOptions
    }
    
}




