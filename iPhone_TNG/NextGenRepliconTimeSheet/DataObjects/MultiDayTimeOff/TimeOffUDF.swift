//
//  TimeOffUDF.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 08/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit

enum TimeOffUDFType : String{
    case dropdown = "urn:replicon:custom-field-type:drop-down"
    case text = "urn:replicon:custom-field-type:text"
    case numeric = "urn:replicon:custom-field-type:numeric"
    case date = "urn:replicon:custom-field-type:date"
    case unknown = "unknown"
}

class TimeOffUDF: NSObject {
    let name:String
    var value:String
    let uri:String
    let typeUri:String
    let timeOffUri:String
    let decimalPlaces:Int
    var optionsUri:String?
    var type : TimeOffUDFType {
        return getUDFType()
    }
    
    init(name:String, value:String, uri:String, typeUri:String, timeOffUri:String, decimalPlaces:Int, optionsUri:String? = nil) {
        self.name = name
        self.value = value
        self.uri = uri
        self.typeUri = typeUri
        self.timeOffUri = timeOffUri
        self.decimalPlaces = decimalPlaces
        self.optionsUri = optionsUri
    }
    
    private func getUDFType() -> TimeOffUDFType {
        guard let type = TimeOffUDFType(rawValue: self.typeUri) else {
            return TimeOffUDFType.unknown
        }
        return type
    }

    override var description: String {
        var description = "<\(String(describing: TimeOffUDF.self))>"
        description += "\r\t name : \(String(describing: self.name))"
        description += "\r\t value : \(String(describing: self.value))"
        description += "\r\t uri : \(String(describing: self.uri))"
        description += "\r\t typeUri : \(String(describing: self.typeUri))"
        description += "\r\t timeOffUri : \(String(describing: self.timeOffUri))"
        description += "\r\t decimalPlaces : \(String(describing: self.decimalPlaces))"
        description += "\r\t optionsUri : \(String(describing: self.optionsUri))"

        return description
    }
    
    func copy(with zone: NSZone? = nil) -> TimeOffUDF {
        let copy = TimeOffUDF(name: name, value: value, uri: uri, typeUri: typeUri, timeOffUri: timeOffUri, decimalPlaces: decimalPlaces, optionsUri: optionsUri)
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TimeOffUDF else {
            return false
        }
        let lhs = self
        
        return lhs.name == rhs.name &&
            lhs.value == rhs.value &&
            lhs.uri == rhs.uri &&
            lhs.typeUri == rhs.typeUri &&
            lhs.timeOffUri == rhs.timeOffUri &&
            lhs.decimalPlaces == rhs.decimalPlaces &&
            lhs.optionsUri == rhs.optionsUri
    }
}
