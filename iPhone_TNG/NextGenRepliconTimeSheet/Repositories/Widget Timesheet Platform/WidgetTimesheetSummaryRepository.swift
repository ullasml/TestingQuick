
import UIKit





// MARK: <WidgetTimesheetSummaryRepositoryInterface>

@objc protocol WidgetTimesheetSummaryRepositoryInterface : class {
    
    /**
     Fetches the widget timesheet summary for a timesheet
     - Parameter uri: a timesheet uri
     - Returns: a promise for a request
     */
    func fetchSummaryForTimesheet(_ timesheet:WidgetTimesheet!) -> KSPromise<AnyObject>!
    
    /**
     Add the caller as the observer to receive updates when timesheet summary for a timesheet is fetched
     - Parameter observer: a WidgetTimesheetSummaryRepositoryObserver
     */
    func addListener(_ observer:WidgetTimesheetSummaryRepositoryObserver!)
    
    /**
     Remove the caller as the observer to stop receiving updates when timesheet summary for a timesheet is fetched
     - Parameter observer: a WidgetTimesheetSummaryRepositoryObserver
     */
    func removeListener(_ observer:WidgetTimesheetSummaryRepositoryObserver!)
    
    /**
     Remove all the callers as the observer to stop receiving updates when timesheet summary for a timesheet is fetched
     */
    func removeAllListeners()
}

// MARK: <WidgetTimesheetSummaryRepositoryObserver>

@objc protocol WidgetTimesheetSummaryRepositoryObserver : class {
    
    /**
     Fetches the widget timesheet summary for a timesheet
     - Parameter uri: a timesheet uri
     - Returns: a promise for a request
     */
    func widgetTimesheetSummaryRepository(_ repository:WidgetTimesheetSummaryRepository!, fetchedNewSummary:Summary)
}

class WidgetTimesheetSummaryRepository: NSObject,WidgetTimesheetSummaryRepositoryInterface {
    

    
    var client: RequestPromiseClient!
    var widgetTimesheetRequestProvider : WidgetTimesheetRequestProvider!
    var widgetTimesheetSummaryDeserializer : WidgetTimesheetSummaryDeserializer!
    weak var injector : BSInjector!
    var observers = NSHashTable<WidgetTimesheetSummaryRepositoryObserver>.weakObjects()
    
    // MARK: - NSObject
    init(widgetTimesheetSummaryDeserializer:WidgetTimesheetSummaryDeserializer!,
         widgetTimesheetRequestProvider:WidgetTimesheetRequestProvider!,
         client: RequestPromiseClient!) {
        super.init()
        self.widgetTimesheetSummaryDeserializer = widgetTimesheetSummaryDeserializer;
        self.widgetTimesheetRequestProvider = widgetTimesheetRequestProvider
        self.client = client
    }
    
    deinit{
        print("Deallocated: \(String(describing:self))")   
    }
    
    /**
     Add the caller as the observer to receive updates when timesheet summary for a timesheet is fetched
     - Parameter observer: a WidgetTimesheetSummaryRepositoryObserver
     */
    func addListener(_ observer: WidgetTimesheetSummaryRepositoryObserver!) {
        self.observers.add(observer)
    }
    
    /**
     Remove the caller as the observer to stop receiving updates when timesheet summary for a timesheet is fetched
     - Parameter observer: a WidgetTimesheetSummaryRepositoryObserver
     */
    func removeListener(_ observer:WidgetTimesheetSummaryRepositoryObserver!){
        self.observers.remove(observer)
    }
    
    /**
     Remove all the callers as the observer to stop receiving updates when timesheet summary for a timesheet is fetched
     */
    func removeAllListeners(){
        self.observers.removeAllObjects()
    }

    
    func fetchSummaryForTimesheet(_ timesheet:WidgetTimesheet!) -> KSPromise<AnyObject>!{
        let deferred = KSDeferred<AnyObject>()
        let requestProvider = self.widgetTimesheetRequestProvider as WidgetTimesheetRequestProviderInterface
        let request = requestProvider.requestForTimesheetSummary(timesheet.uri)
        let timesheetPromise = self.client.promise(with: request)!
        timesheetPromise.then({ (response) -> AnyObject? in
            let widgetTimesheetSummaryDeserializer = self.widgetTimesheetSummaryDeserializer as WidgetTimesheetSummaryDeserializerInterface
            let widgetTimesheetSummary = widgetTimesheetSummaryDeserializer.deserialize(response,isAutoSubmitEnabled:timesheet.canAutoSubmitOnDueDate)
            for observer in self.observers.allObjects {
                observer.widgetTimesheetSummaryRepository(self, fetchedNewSummary: widgetTimesheetSummary!)
            }
            deferred.resolve(withValue: widgetTimesheetSummary)
            return nil
        }) { (error) -> AnyObject? in
            deferred.rejectWithError(error)
            return nil
        }
        return deferred.promise
    }

}
