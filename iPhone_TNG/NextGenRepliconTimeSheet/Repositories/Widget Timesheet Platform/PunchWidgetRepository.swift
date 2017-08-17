

import UIKit

// MARK: <PunchWidgetRepositoryInterface>

@objc protocol PunchWidgetRepositoryInterface : class {
    
    /**
     Fetches the info for a punch widget on a timesheet
     - Parameter uri: a timesheet uri
     - Returns: a promise for a request
     */
    func fetchPunchWidgetInfoForTimesheetWithUri(_ timesheetUri:String!) -> KSPromise<AnyObject>
    
    /**
     Fetches the summary for a punch widget on a timesheet
     - Parameter uri: a timesheet uri
     - Returns: a promise for a request
     */
    
    func fetchPunchWidgetSummaryForTimesheetWithUri(_ timesheetUri:String!) -> KSPromise<AnyObject>
}

/// Repository to fetch info for Punch Widget

class PunchWidgetRepository: NSObject,PunchWidgetRepositoryInterface {
    
    var widgetTimesheetRequestProvider:WidgetTimesheetRequestProvider!
    var timesheetInfoDeserializer:TimesheetInfoDeserializer!
    var client: RequestPromiseClient!
    weak var injector : BSInjector!
    
    // MARK: - NSObject
    init(widgetTimesheetRequestProvider:WidgetTimesheetRequestProvider!,
        timesheetInfoDeserializer:TimesheetInfoDeserializer!,
         client: RequestPromiseClient!) {
        super.init()
        self.widgetTimesheetRequestProvider = widgetTimesheetRequestProvider
        self.timesheetInfoDeserializer = timesheetInfoDeserializer
        self.client = client
    }
    
    deinit{
        print("Deallocated: \(String(describing:self))")   
    }
    
    func fetchPunchWidgetInfoForTimesheetWithUri(_ timesheetUri:String!) -> KSPromise<AnyObject> {
        let timesheetDeferred = KSDeferred<AnyObject>()
        let requestProvider = self.widgetTimesheetRequestProvider as WidgetTimesheetRequestProviderInterface
        let request = requestProvider.requestForPunchWidgetSummary(timesheetUri)
        let timesheetPromise = self.client.promise(with: request)!
        timesheetPromise.then({ (response) -> AnyObject? in
            let punchWidgetInfo = self.timesheetInfoDeserializer.deserializeTimesheetInfo(forWidget: response as! [AnyHashable : Any])
            timesheetDeferred.resolve(withValue: punchWidgetInfo as AnyObject)
            return nil
        }) { (error) -> AnyObject? in
            timesheetDeferred.rejectWithError(error)
            return nil
        }
        return timesheetDeferred.promise
    }
    
    func fetchPunchWidgetSummaryForTimesheetWithUri(_ timesheetUri:String!) -> KSPromise<AnyObject> {
        let timesheetDeferred = KSDeferred<AnyObject>()
        let requestProvider = self.widgetTimesheetRequestProvider as WidgetTimesheetRequestProviderInterface
        let request = requestProvider.requestForPunchWidgetSummary(timesheetUri)
        let timesheetPromise = self.client.promise(with: request)!
        timesheetPromise.then({ (response) -> AnyObject? in
            let punchWidgetInfo = self.timesheetInfoDeserializer.deserializeTimesheetInfo(forWidget: response as! [AnyHashable : Any])
            timesheetDeferred.resolve(withValue: punchWidgetInfo as AnyObject)
            return nil
        }) { (error) -> AnyObject? in
            timesheetDeferred.rejectWithError(error)
            return nil
        }
        return timesheetDeferred.promise
    }

}

