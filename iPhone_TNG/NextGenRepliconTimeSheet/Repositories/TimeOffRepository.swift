
import Foundation
import UIKit


@objc protocol TimeOffRepositoryProtocol {
    func getUserEntriesAndDurationOptions(timeOffTypeUri:String,
                                          startDate:Date,
                                          endDate:Date) -> KSPromise<AnyObject>
    func submitTimeOff(timeOffObject: TimeOff, isNewBooking: Bool) -> KSPromise<AnyObject>
    func getBalanceForTimeOff(timeOffObject: TimeOff) -> KSPromise<AnyObject>
    func deleteTimeOff(timeOffObject: TimeOff) -> KSPromise<AnyObject>
}

class TimeOffRepository: NSObject {
    
    var timeOffRequestProvider: TimeOffRequestProviderProtocol?
    var timeOffDeserializer: TimeOffDeserializer?
    var userSession: UserSession?
    var client:RequestPromiseClient?
    var timeOffModel: TimeoffModel?
    
    init(timeoffRequestProvider: TimeOffRequestProviderProtocol,
            timeOffDeserializer: TimeOffDeserializer,
                    userSession: UserSession,
                         client: RequestPromiseClient,
                     timeOffModel: TimeoffModel)
    {
        self.timeOffRequestProvider = timeoffRequestProvider
        self.timeOffDeserializer = timeOffDeserializer
        self.userSession = userSession
        self.client = client
        self.timeOffModel = timeOffModel
        super.init()
    }
}

// MARK: TimeOffRepositoryProtocol methods

extension TimeOffRepository: TimeOffRepositoryProtocol {
    
    func getUserEntriesAndDurationOptions(timeOffTypeUri:String,
                                          startDate:Date,
                                          endDate:Date) -> KSPromise<AnyObject>
    {
        let userUri = self.userSession?.currentUserURI!() ?? ""
        self.timeOffRequestProvider?.setUpWithUserUri(userUri: userUri)
        
        let timeOffBookingParamsDeferred = KSDeferred<AnyObject>()
        let urlRequest = self.timeOffRequestProvider?.requestForBookingParams(timeOffTypeUri: timeOffTypeUri, startDate: startDate, endDate: endDate)
        let jsonPromise = self.client?.promise(with: urlRequest as URLRequest!)
        jsonPromise?.then({ (jsonDictionary) -> Any? in
            let responseDataDictionary = jsonDictionary as? [String:Any]
            let result = self.timeOffDeserializer?.deserializeDurationOptionsAndSchedules(from: responseDataDictionary)
            
            timeOffBookingParamsDeferred.resolve(withValue: result as AnyObject)
            return nil
        }) { (error) -> AnyObject? in
            let error = NSError(domain: "Error Domain", code:0, userInfo: nil)
            timeOffBookingParamsDeferred.rejectWithError(error)
            return nil
        }
        return timeOffBookingParamsDeferred.promise
    }
    
    func submitTimeOff(timeOffObject: TimeOff, isNewBooking: Bool) -> KSPromise<AnyObject> {
        let userUri = self.userSession?.currentUserURI!()
        self.timeOffRequestProvider?.setUpWithUserUri(userUri: userUri!)
        let timeOffSubmitDeferred = KSDeferred<AnyObject>()
        let urlRequest = self.timeOffRequestProvider?.requestForMultiDayTimeoffSubmit(timeOff: timeOffObject, isNewBooking:isNewBooking)
        let jsonPromise = self.client?.promise(with: urlRequest as URLRequest!)
        jsonPromise?.then({ (jsonDictionary) -> Any? in
            if let responseDataDictionary = jsonDictionary?["d"] as! Dictionary<String, Any>?{
                let timeOffDataDictionary = NSMutableDictionary(dictionary: responseDataDictionary)
                self.timeOffModel?.saveTimeOffEntryDataFromApi(toDB: timeOffDataDictionary, andTimesheetUri: nil)
                timeOffSubmitDeferred.resolve(withValue: responseDataDictionary as AnyObject?)
            }
            return nil
        }) { (error) -> AnyObject? in
            let error = NSError(domain: "Error Domain", code:0, userInfo: nil)
            timeOffSubmitDeferred.rejectWithError(error)
            return nil
        }
        return timeOffSubmitDeferred.promise
    }
    
    func getBalanceForTimeOff(timeOffObject: TimeOff) -> KSPromise<AnyObject> {
        let userUri = self.userSession?.currentUserURI!()
        self.timeOffRequestProvider?.setUpWithUserUri(userUri: userUri!)
        let timeOffBalanceDeferred = KSDeferred<AnyObject>()
        let urlRequest = self.timeOffRequestProvider?.getTimeOffBalance(timeOff: timeOffObject)
        let jsonPromise = self.client?.promise(with: urlRequest as URLRequest!)
        jsonPromise?.then({ (jsonDictionary) -> Any? in
            let balanceDataDictionary = jsonDictionary?["d"] as? [String:Any]
            let result = self.timeOffDeserializer?.getBalanceInfo(balanceDataDictionary)
            timeOffBalanceDeferred.resolve(withValue: result)
            return nil
        }) { (error) -> AnyObject? in
            let error = NSError(domain: "Error Domain", code:0, userInfo: nil)
            timeOffBalanceDeferred.rejectWithError(error)
            return nil
        }
        
        return timeOffBalanceDeferred.promise
    }
    
    func deleteTimeOff(timeOffObject: TimeOff) -> KSPromise<AnyObject> {
        let userUri = self.userSession?.currentUserURI!()
        self.timeOffRequestProvider?.setUpWithUserUri(userUri: userUri!)
        
        let timeOffDeleteDeferred = KSDeferred<AnyObject>()
        let urlRequest = self.timeOffRequestProvider?.deleteTimeOff(timeOff: timeOffObject)
        let jsonPromise = self.client?.promise(with: urlRequest as URLRequest!)
        jsonPromise?.then({ (jsonDictionary) -> Any? in
            
            self.timeOffModel?.deleteTimeOffBalanceSummary(forMultiday: timeOffObject.details?.uri)
            self.timeOffModel?.deleteTimeOffFromDB(forSheetUri: timeOffObject.details?.uri)
            timeOffDeleteDeferred.resolve(withValue: jsonDictionary)
            return nil
            
        }) { (error) -> AnyObject? in
            let error = NSError(domain: "Error Domain", code:0, userInfo: nil)
            timeOffDeleteDeferred.rejectWithError(error)
            return nil
        }
        return timeOffDeleteDeferred.promise
    }
}


