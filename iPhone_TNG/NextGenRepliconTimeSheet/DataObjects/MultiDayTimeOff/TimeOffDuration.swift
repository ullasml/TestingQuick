//
//  TimeOffDuration.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 03/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit

@objc class TimeOffDuration: NSObject {
    let title : String?
    var duration : String
    let uri : String?
    
    init?(withUri uri:String?, title:String?, duration:String) {
        guard let durationUri = uri, durationUri.characters.count > 0, let durationTitle = title, durationTitle.characters.count > 0 else {
            return nil
        }
        self.uri = durationUri
        self.title = durationTitle
        self.duration = duration
    }
    
    override var description: String {
        var description = "<\(String(describing: TimeOffDuration.self))>"
        description += "\r\t title                    : \(String(describing: self.title))"
        description += "\r\t duration  : \(String(describing: self.duration))"
        description += "\r\t uri : \(String(describing: self.uri))"
        return description
    }
    
    func copy(with zone: NSZone? = nil) -> TimeOffDuration? {
        let copy = TimeOffDuration(withUri: uri, title: title, duration: duration)
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TimeOffDuration else {
            return false
        }
        let lhs = self
        
        return lhs.uri == rhs.uri &&
            lhs.title == rhs.title &&
            lhs.duration == rhs.duration
    }
}
