//
//  TimeOffStatusDetails.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 13/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import Foundation

class TimeOffStatusDetails: NSObject {
    var title : String
    var uri : String
    
    init(withUri uri:String, title:String) {
        self.uri = uri
        self.title = title
    }
    
    override var description: String {
        var description = "<\(String(describing: TimeOffStatusDetails.self))>"
        description += "\r\t title                    : \(String(describing: self.title))"
        description += "\r\t uri : \(String(describing: self.uri))"
        return description
    }
    
    func copy(with zone: NSZone? = nil) -> TimeOffStatusDetails {
        let copy = TimeOffStatusDetails(withUri: uri, title: title)
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TimeOffStatusDetails else {
            return false
        }
        let lhs = self
        
        return lhs.uri == rhs.uri && lhs.title == rhs.title
    }
}
