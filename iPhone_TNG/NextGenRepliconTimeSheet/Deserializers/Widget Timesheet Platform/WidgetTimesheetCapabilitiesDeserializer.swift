
import UIKit

class WidgetTimesheetCapabilitiesDeserializer: NSObject {
    
    func getUserConfiguredSupportedWidgetUris(_ widgetTimesheetCapabilities : [[String:AnyObject]]) -> [String] {
        var configuredUris : [String] = []
        
        for widgetCapability in widgetTimesheetCapabilities{
            let policyValue = widgetCapability["policyValue"]!
            let isEnabled = policyValue["bool"] as? Bool ?? false
            if isEnabled {
                let policyKeyUri = widgetCapability["policyKeyUri"]!
                configuredUris.append(policyKeyUri as! String)
            }
        }
        return configuredUris
    }
}
