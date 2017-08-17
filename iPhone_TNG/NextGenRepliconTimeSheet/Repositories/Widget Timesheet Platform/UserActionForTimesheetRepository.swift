

import UIKit

// MARK: <UserActionForTimesheetRepositoryInterface>

@objc protocol UserActionForTimesheetRepositoryInterface : class {
    
    /**
     Submits/resubmit/reopens the widget timesheet based on the user action
     - Parameter date: a RightBarButtonActionType
     - Returns: a promise for a request
     */
    func userActionOnTimesheetWithType(_ action:RightBarButtonActionType, timesheetUri:String!, comments:String!) -> KSPromise<AnyObject>
}

/// This repository submits a Service Request for submit,resubmit and reopen user timesheet action for timesheet

class UserActionForTimesheetRepository: NSObject,UserActionForTimesheetRepositoryInterface {

    var userActionForTimesheetRequestProvider:UserActionForTimesheetRequestProvider!
    var client: RequestPromiseClient!
    weak var injector : BSInjector!
    
    // MARK: - NSObject
    init(userActionForTimesheetRequestProvider:UserActionForTimesheetRequestProvider!,
         client: RequestPromiseClient!) {
        super.init()
        self.userActionForTimesheetRequestProvider = userActionForTimesheetRequestProvider
        self.client = client
    }
    
    deinit{
        print("Deallocated: \(String(describing:self))")   
    }
    
    
    func userActionOnTimesheetWithType(_ action:RightBarButtonActionType, timesheetUri:String!, comments:String!) -> KSPromise<AnyObject>{
        let deferred = KSDeferred<AnyObject>()
        let requestProvider = self.userActionForTimesheetRequestProvider as UserActionForTimesheetRequestProviderInterface
        let request = requestProvider.requestForUserTimesheetAction(action, timesheetUri: timesheetUri, comments: comments)!
        let timesheetPromise = self.client.promise(with: request)!
        timesheetPromise.then({ (response) -> AnyObject? in
            deferred.resolve(withValue: response as AnyObject)
            return nil
        }) { (error) -> AnyObject? in
            deferred.rejectWithError(error)
            return nil
        }

        return deferred.promise
    }

    
}
