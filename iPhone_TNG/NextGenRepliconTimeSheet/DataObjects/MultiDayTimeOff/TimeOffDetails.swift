//
//  TimeOffDetails.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 15/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import Foundation

class TimeOffDetails: NSObject {
    let uri : String
    var userComments : String
    var resubmitComments : String
    let canEdit : Bool
    let canDelete : Bool

    
    init(withUri uri:String, comments:String, resubmitComments: String, edit:Bool = false, delete:Bool = false) {
        self.uri = uri
        self.userComments = comments
        self.resubmitComments = resubmitComments
        self.canEdit = edit
        self.canDelete = delete
    }
    
    override var description: String {
        var description = "<\(String(describing: TimeOffDetails.self))>"
        description += "\r\t uri                    : \(String(describing: self.uri))"
        description += "\r\t userComments                    : \(String(describing: self.userComments))"
        description += "\r\t resubmitComments : \(String(describing: self.resubmitComments))"
        description += "\r\t canEdit                    : \(String(describing: self.canEdit))"
        description += "\r\t canDelete : \(String(describing: self.canDelete))"
        return description
    }
    
    func copy(with zone: NSZone? = nil) -> TimeOffDetails {
        let copy = TimeOffDetails(withUri: uri, comments: userComments, resubmitComments: resubmitComments, edit: canEdit, delete: canDelete)
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TimeOffDetails else {
            return false
        }
        let lhs = self
        
        return lhs.uri == rhs.uri &&
            lhs.userComments == rhs.userComments &&
            lhs.resubmitComments == rhs.resubmitComments &&
            lhs.canEdit == rhs.canEdit &&
            lhs.canDelete == rhs.canDelete
    }
}
