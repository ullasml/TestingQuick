

import UIKit

// MARK: <WidgetTimesheetRepositoryInterface>

@objc protocol WidgetTimesheetRepositoryInterface : class {
    
    /**
     Fetches the widget timesheet for a date
     - Parameter date: a date within the timesheet period
     - Returns: a promise for a request
     */
    func fetchWidgetTimesheetForDate(_ date:Date) -> KSPromise<AnyObject>
    
    /**
     Fetches the widget timesheet for a uri
     - Parameter uri: a timesheet uri
     - Returns: a promise for a request
     */
    func fetchWidgetTimesheetForTimesheetWithUri(_ timesheetUri:String!) -> KSPromise<AnyObject>
}

/// Repository to fetch an Widget Timesheet.
/**
 **Responsibilty**
 - Fetches the widget timesheet for a uri
 - Fetches the widget timesheet for a date
 */


class WidgetTimesheetRepository: NSObject,WidgetTimesheetRepositoryInterface {

    var timesheetWidgetsDeserializer:WidgetTimesheetDeserializer!
    var timesheetRequestProvider:TimesheetRequestProvider!
    var client: RequestPromiseClient!
    weak var injector : BSInjector!
    
    // MARK: - NSObject
    init(timesheetWidgetsDeserializer:WidgetTimesheetDeserializer!,
         timesheetRequestProvider:TimesheetRequestProvider!,
         client: RequestPromiseClient!) {
        super.init()
        self.timesheetWidgetsDeserializer = timesheetWidgetsDeserializer
        self.timesheetRequestProvider = timesheetRequestProvider
        self.client = client
    }
    
    deinit{
        print("Deallocated: \(String(describing:self))")   
    }

    func fetchWidgetTimesheetForDate(_ date:Date) -> KSPromise<AnyObject> {
        let timesheetDeferred = KSDeferred<AnyObject>()
        let request = self.timesheetRequestProvider.requestForFetchingTimesheetWidgets(for: date)!
        let timesheetPromise = self.client.promise(with: request)!
        timesheetPromise.then({ (response) -> AnyObject? in
            let widgetTimesheetDeserializer = self.timesheetWidgetsDeserializer as WidgetTimesheetDeserializerInterface
            let widgetTimesheet = widgetTimesheetDeserializer.deserialize(response as! NSDictionary)
            timesheetDeferred.resolve(withValue: widgetTimesheet as AnyObject)
            return nil
        }) { (error) -> AnyObject? in
            timesheetDeferred.rejectWithError(error)
            return nil
        }
        return timesheetDeferred.promise
    }
    
    func fetchWidgetTimesheetForTimesheetWithUri(_ timesheetUri:String!) -> KSPromise<AnyObject> {
        let timesheetDeferred = KSDeferred<AnyObject>()
        let request = self.timesheetRequestProvider.requestForFetchingTimesheetWidgets(forTimesheetUri: timesheetUri)!
        let timesheetPromise = self.client.promise(with: request)!
        timesheetPromise.then({ (response) -> AnyObject? in
            let widgetTimesheetDeserializer = self.timesheetWidgetsDeserializer as WidgetTimesheetDeserializerInterface
            let widgetTimesheet = widgetTimesheetDeserializer.deserialize(response as! NSDictionary)
            timesheetDeferred.resolve(withValue: widgetTimesheet as AnyObject)
            return nil
        }) { (error) -> AnyObject? in
            timesheetDeferred.rejectWithError(error)
            return nil
        }
        return timesheetDeferred.promise
    }
}
