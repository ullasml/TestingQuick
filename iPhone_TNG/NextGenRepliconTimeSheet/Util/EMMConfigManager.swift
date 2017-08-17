//
//  EMMConfigManager.swift
//  NextGenRepliconTimeSheet
//

import Foundation

/**
 * EMMConfigManager
 * Replicon app configuration dictionary pushed down from an MDM server are stored in the key com.apple.configuration.managed.
 * companyname and username are passed through keys com.replicon.companyname & com.replicon.username respectively from Appconfig.
 * EMMConfigManger is used to read this values stored in com.apple.configuration.managed.
 */

enum EMMConfigurationKeys {
    static let mdmConfigurationKey = "com.apple.configuration.managed"
    static let companyName = "com.replicon.companyname"
    static let userName = "com.replicon.username"
}

@objc class EMMConfigManager : NSObject {
    
    private let defaults:UserDefaults?

    var companyName: String? {
        get {
            let emmDataDictionary = self.readEMMConfigCredentials()
            return emmDataDictionary?["companyName"];
        }
    }
    
    var userName: String? {
        get {
            let emmDataDictionary = self.readEMMConfigCredentials()
            return emmDataDictionary?["userName"];
        }
    }
    
    init(withUserDefaults defaults:UserDefaults) {
        self.defaults = defaults
        super.init()
    }
    
    //// The values are stored in UserDefaults when pushed from MDM
    //// Commenting the observer, since no values are updated, we can directly read the values from the defaults
    //// uncomment this and add the update code
    /*
     func addEMMConfigObserver() {
     let center = NotificationCenter.default
     let mainQueue = OperationQueue.main
     center.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: mainQueue) { (note) in
     //update code
     }
     }*/
    
     fileprivate func readEMMConfigCredentials() -> [String:String]? {
        guard let emmDataDictionary = self.defaults?.object(forKey: EMMConfigurationKeys.mdmConfigurationKey) as? [String:Any] else {
            return nil
        }
        var dataDictionary = [String:String]()
        if let companyName = emmDataDictionary[EMMConfigurationKeys.companyName] as? String {
            dataDictionary["companyName"] = companyName
        }
        if let userName = emmDataDictionary[EMMConfigurationKeys.userName] as? String {
            dataDictionary["userName"] = userName
        }
        return dataDictionary
    }
    
    func isEMMValuesStored () -> Bool {
        if let emmDataDictionary = self.readEMMConfigCredentials() {
            return ((emmDataDictionary["companyName"] != nil) || (emmDataDictionary["userName"] != nil))
        }
        return false
    }
}
