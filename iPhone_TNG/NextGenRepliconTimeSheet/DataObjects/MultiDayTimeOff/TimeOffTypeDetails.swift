//
//  TimeOffTypeDetails.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 13/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import Foundation

class TimeOffTypeDetails: NSObject {
    let title : String
    let uri : String
    var measurementUri : String
    
    init(withUri uri:String, title:String, measurementUri:String) {
        self.uri = uri
        self.title = title
        self.measurementUri = measurementUri
    }
    
    override var description: String {
        var description = "<\(String(describing: TimeOffTypeDetails.self))>"
        description += "\r\t title                    : \(String(describing: self.title))"
        description += "\r\t uri : \(String(describing: self.uri))"
        description += "\r\t measurementUri : \(String(describing: self.measurementUri))"
        return description
    }
    
    func copy(with zone: NSZone? = nil) -> TimeOffTypeDetails {
        let copy = TimeOffTypeDetails(withUri: uri, title: title, measurementUri: measurementUri)
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TimeOffTypeDetails else {
            return false
        }
        let lhs = self
        
        return lhs.uri == rhs.uri &&
            lhs.title == rhs.title &&
            lhs.measurementUri == rhs.measurementUri
    }
}
