

import UIKit

// MARK: <UserActionForTimesheetRequestProviderInterface>

@objc protocol UserActionForTimesheetRequestProviderInterface : class {
    
    /**
     Returns the request for a user action (submit/resubmit/reopen) for timesheet service call
     - Parameter uri: a timesheet uri
     - Returns: a NSURLRequest
     */
    func requestForUserTimesheetAction(_ action:RightBarButtonActionType, timesheetUri:String!, comments:String!) -> URLRequest!
}

/// This controller provides a request for submit,resubmit and reopen user timesheet action
class UserActionForTimesheetRequestProvider: NSObject,UserActionForTimesheetRequestProviderInterface {
    
    let urlStringProvider:URLStringProvider
    init(urlStringProvider:URLStringProvider){
        self.urlStringProvider = urlStringProvider
    }
    
    func requestForUserTimesheetAction(_ action:RightBarButtonActionType, timesheetUri:String!, comments:String!) -> URLRequest!{
        var urlString = ""
        if action == RightBarButtonActionTypeSubmit ||  action == RightBarButtonActionTypeReSubmit{
            urlString = self.urlStringProvider.urlString(withEndpointName: "WidgetTimesheetSubmit") as String
        }
        else{
            urlString = self.urlStringProvider.urlString(withEndpointName: "WidgetTimesheetReopen") as String
        }
        
        do {
            let requestBody = (comments != nil && !comments.isEmpty) ? ["comments" : comments] : NSDictionary() 
            let data: NSData = try JSONSerialization.data(withJSONObject: requestBody, options: []) as NSData
            let requestBodyString = NSString(data:data as Data, encoding:String.Encoding.utf8.rawValue)
            let paramDict = ["URLString": urlString as String,"PayLoadStr": requestBodyString!] as [String: Any]
            let request = RequestBuilder.buildPOSTRequest(withParamDict: paramDict)!
            request.addValue(timesheetUri, forHTTPHeaderField: "X-Timesheet-Uri")
            return request as URLRequest! 
        }
        catch {
            return nil
        }
    }
}
