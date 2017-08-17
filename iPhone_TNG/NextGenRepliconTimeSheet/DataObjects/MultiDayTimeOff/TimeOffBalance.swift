//
//  TimeOffBalance.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 10/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit

class TimeOffBalance: NSObject {
    let timeRemaining : String?
    let timeTaken : String?
    
    init(timeRemaining:String? = nil, timeTaken:String? = nil) {
        self.timeRemaining = timeRemaining
        self.timeTaken = timeTaken
    }
    
    override var description: String {
        var description = "<\(String(describing: TimeOffBalance.self))>"
        description += "\r\t timeRemaining                    : \(String(describing: self.timeRemaining))"
        description += "\r\t timeTaken : \(String(describing: self.timeTaken))"
        return description
    }
    
    func copy(with zone: NSZone? = nil) -> TimeOffBalance {
        let copy = TimeOffBalance(timeRemaining: timeRemaining, timeTaken: timeTaken)
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TimeOffBalance else {
            return false
        }
        let lhs = self
        
        return lhs.timeRemaining == rhs.timeRemaining &&
            lhs.timeTaken == rhs.timeTaken
    }
}
