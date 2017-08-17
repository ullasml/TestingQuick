

import UIKit

// MARK: <WidgetTimesheetRequestProviderInterface>

@objc protocol WidgetTimesheetRequestProviderInterface : class {
    
    /**
     Returns the request for widget timesheet summary service call
     - Parameter uri: a timesheet uri
     - Returns: a NSURLRequest
     */
    func requestForTimesheetSummary(_ timesheetUri:String!) -> URLRequest!
    
    /**
     Returns the request for punch widget summary service call
     - Parameter uri: a timesheet uri
     - Returns: a NSURLRequest
     */
    func requestForPunchWidgetSummary(_ timesheetUri:String!) -> URLRequest!

}
class WidgetTimesheetRequestProvider: NSObject,WidgetTimesheetRequestProviderInterface {

    let urlStringProvider:URLStringProvider
    var userDefaults: UserDefaults!
    var guidProvider: GUIDProvider
    init(urlStringProvider:URLStringProvider,
         userDefaults: UserDefaults,
         guidProvider: GUIDProvider){
        self.urlStringProvider = urlStringProvider
        self.userDefaults = userDefaults
        self.guidProvider = guidProvider
    }
    
    func requestForTimesheetSummary(_ timesheetUri:String!) -> URLRequest!{
        let urlString = self.urlStringProvider.urlString(withEndpointName: "WidgetTimesheetSummary") as String
        let paramDict = ["URLString": urlString as String] as [String: Any]
        let request = RequestBuilder.buildGETRequestWithParamDict(toHandleCookies: paramDict)!
        request.addValue(timesheetUri, forHTTPHeaderField: "X-Timesheet-Uri")
        return request as URLRequest! 
    }
    
    func requestForPunchWidgetSummary(_ timesheetUri:String!) -> URLRequest!{
        let urlString = self.urlStringProvider.urlString(withEndpointName: "PunchWidget") as String
        let paramDict = ["URLString": urlString as String] as [String: Any]
        let request = RequestBuilder.buildGETRequestWithParamDict(toHandleCookies: paramDict)!
        request.addValue(timesheetUri, forHTTPHeaderField: "X-Timesheet-Uri")
        return request as URLRequest! 
    }
}
