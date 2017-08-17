

import UIKit

class JSONHelper: NSObject {

    class func getJSON(_ response:AnyObject?) -> JSON? {
        
        guard let responseValue = response else {
            return nil
        }
        do {
            
            if JSONSerialization.isValidJSONObject(responseValue) {
                let data: NSData = try JSONSerialization.data(withJSONObject: responseValue, options: []) as NSData
                let json = try JSON(data: data as Data)
                return json
            }
            else{
                return nil
            }
            
        }
        catch {
            return nil
        }
    }
    
    class func isValidJSON(_ response:AnyObject?) -> Bool {
        
        guard let responseValue = response else {
            return false
        }
        return JSONSerialization.isValidJSONObject(responseValue)
    }
}
