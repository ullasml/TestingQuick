
import Foundation
import UIKit

let plistFileName:String = "SupportedWidgets"
var widgetsDataDictionary: NSMutableDictionary?

struct Plist {
    enum PlistError: Error {
        case FileNotWritten
        case FileDoesNotExist
    }
    
    let name:String
    var sourcePath:String? {
        guard let path = Bundle.main.path(forResource: name, ofType: "plist") else { return .none }
        return path
    }
    
    init?(name:String) {
        self.name = name
        getPlistFileData()
    }
    
    fileprivate func getPlistFileData(){
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: sourcePath!) {
            guard let dict = NSMutableDictionary(contentsOfFile: sourcePath!) else { return  }
            widgetsDataDictionary = dict
        }
    }
}


@objc class WidgetsManager : NSObject {
    static let sharedInstance = WidgetsManager()
    private override init() {} //This prevents others from using the default '()' initializer for this class.
    
    func startPlistManager() {
        if let _ = Plist(name: plistFileName) {
            print("[SupportedWidgets] SupportedWidgets started")
        }
    }
    
    func isValueAvailable(key: String) -> Bool
    {
        let keys = Array(widgetsDataDictionary!.allValues) as! [String]
        if keys.count != 0 {
            if keys.contains(key){
                return true
            }
            else {
                return false
            }
        } else {
            return false
        }
    }
}

