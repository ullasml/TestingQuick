
import Foundation
import UIKit

@objc protocol TimeOffRequestProviderProtocol  {
    func setUpWithUserUri(userUri:String)
    func requestForBookingParams(timeOffTypeUri:String,
                                 startDate:Date,
                                 endDate:Date) -> URLRequest?
    func requestForMultiDayTimeoffSubmit(timeOff:TimeOff, isNewBooking: Bool) -> URLRequest?
    func getTimeOffBalance(timeOff:TimeOff) -> URLRequest?
    func deleteTimeOff(timeOff: TimeOff) -> URLRequest?
}

class TimeOffRequestProvider: NSObject,TimeOffRequestProviderProtocol {
    let urlStringProvider:URLStringProvider
    var userUri:String!
    var userDefaults: UserDefaults!
    var guidProvider: GUIDProvider
    
    func setUpWithUserUri(userUri:String){
        self.userUri = userUri
    }
    
    init(urlStringProvider:URLStringProvider,
              userDefaults: UserDefaults,
              guidProvider: GUIDProvider){
        self.urlStringProvider = urlStringProvider
        self.userDefaults = userDefaults
        self.guidProvider = guidProvider
    }
    
    func requestForBookingParams(timeOffTypeUri:String,
                                      startDate:Date,
                                        endDate:Date) -> URLRequest?{
        do{
            let startDateDict = DateHelper.convertDateToDict(date: startDate)
            let endDateDict = DateHelper.convertDateToDict(date: endDate)
            
            let requestBody = ["userUri":self.userUri, "timeOffTypeUri":timeOffTypeUri, "startDate": startDateDict, "endDate":endDateDict] as [String : Any]
            let data: NSData = try JSONSerialization.data(withJSONObject: requestBody, options: []) as NSData
            let urlString = self.urlStringProvider.urlString(withEndpointName: "BookingParams") as String
            let requestBodyString = NSString(data:data as Data, encoding:String.Encoding.utf8.rawValue)
            let paramDict = ["URLString": urlString as Any, "PayLoadStr": requestBodyString!] as [String:Any]
            let request = RequestBuilder.buildPOSTRequest(withParamDict: paramDict)
            return request as URLRequest?
        }
        catch{
            return nil
        }
    }
    
    func requestForMultiDayTimeoffSubmit(timeOff:TimeOff, isNewBooking: Bool) -> URLRequest?
    {
        do{
            let guidString = self.guidProvider.guid() as String

            let owner:[String:Any] = ["uri":self.userUri , "loginName":NSNull(), "parameterCorrelationId":NSNull()]
            let timeOffType:[String:Any] = ["uri":timeOff.type?.uri ?? "", "name":NSNull()]
            
            let startDate = (timeOff.startDayEntry?.date)!
            let endDate = (timeOff.endDayEntry?.date)!
            
            let startDateDict = DateHelper.convertDateToDict(date: startDate)
            let endDateDict = DateHelper.convertDateToDict(date: endDate)
            
            let startDateDurationUri: Any
            let endDateDurationUri: Any

            if(isTimeOffPartialOrNone(timeOffEntry: timeOff.startDayEntry!)) {
                startDateDurationUri = NSNull()
            }
            else{
                startDateDurationUri = (timeOff.startDayEntry?.durationType.rawValue)! as String
            }
            
            if(isTimeOffPartialOrNone(timeOffEntry: timeOff.endDayEntry!)) {
                endDateDurationUri = NSNull()
            }
            else{
                endDateDurationUri = (timeOff.endDayEntry?.durationType.rawValue)! as String
            }
            
            let timeOffStart = ["date": startDateDict, "timeOfDay":NSNull(), "relativeDuration":startDateDurationUri, "specificDuration":NSNull()] as [String : Any]
            let timeOffEnd = ["date": endDateDict, "timeOfDay":NSNull(), "relativeDuration":endDateDurationUri, "specificDuration":NSNull()] as [String : Any]
            let customFieldsData: [[String: Any]] = self.getUDFFromTimeOff(timeOff: timeOff)!
            
            var userExplicitEntries:[Any]  = []
            if let startDateUserExplicitEntry = getTimeEntry(timeOffEntry: timeOff.startDayEntry!, isEndDayEntry: false){
                userExplicitEntries.append(startDateUserExplicitEntry)
            }
            for timeOffMiddleEntry in timeOff.middleDayEntries{
                if let userExplicitDict = getTimeEntry(timeOffEntry: timeOffMiddleEntry, isEndDayEntry: false){
                    userExplicitEntries.append(userExplicitDict)
                }
            }
            if(!(timeOff.startDayEntry?.date)!.equalsIgnoreTime((timeOff.endDayEntry?.date)!)){
                if let endDateUserExplicitEntry = getTimeEntry(timeOffEntry: timeOff.endDayEntry!, isEndDayEntry: true){
                    userExplicitEntries.append(endDateUserExplicitEntry)
                }
            }
            let multiDayUsingStartEndDate = ["timeOffStart":timeOffStart,"timeOffEnd":timeOffEnd]
            var urlString: String
            var target: Any
            if(isNewBooking){
                target = NSNull()
                urlString = self.urlStringProvider.urlString(withEndpointName: "MultiDayTimeoffSubmit") as String
            }
            else{
                urlString = self.urlStringProvider.urlString(withEndpointName: "MultiDayTimeoffReSubmit")
                target = ["uri":timeOff.details?.uri]
            }

            let timeOffDataRequest = ["target":target,
                                       "owner":owner,
                                 "timeOffType":timeOffType,
                 "entryConfigurationMethodUri":"urn:replicon:time-off-entry-configuration-method:populate-daily-entries-using-explicit-user-entries",
                   "multiDayUsingStartEndDate":multiDayUsingStartEndDate,
                         "userExplicitEntries":userExplicitEntries,
                                    "comments":timeOff.details?.userComments ?? "",
                           "customFieldValues":customFieldsData]
            
            let requestBody = ["data":timeOffDataRequest, "unitOfWorkId":guidString, "comments":(timeOff.details?.resubmitComments)!] as [String: Any]
            let data: NSData = try JSONSerialization.data(withJSONObject: requestBody, options: []) as NSData
            
            let requestBodyString = NSString(data:data as Data, encoding:String.Encoding.utf8.rawValue)
            let paramDict = ["URLString": urlString as String, "PayLoadStr": requestBodyString!] as [String: Any]
            let request = RequestBuilder.buildPOSTRequest(withParamDict: paramDict)
            return request as URLRequest?
        }
        catch{
            return nil
        }
    }
    
    
    func getTimeOffBalance(timeOff:TimeOff) -> URLRequest? {
        
        do
        {
            let calendar = Calendar.current
            let owner:[String:Any] = ["uri":self.userUri]
            let timeOffType:[String:Any] = ["uri":timeOff.type?.uri ?? ""]
            
            let startDate = (timeOff.startDayEntry?.date)!
            let endDate = (timeOff.endDayEntry?.date)!
            let startDateDict = ["day":calendar.component(.day, from: startDate), "month":calendar.component(.month, from: startDate), "year":calendar.component(.year, from: startDate)]
            let endDateDict = ["day":calendar.component(.day, from: endDate), "month":calendar.component(.month, from: endDate), "year":calendar.component(.year, from: endDate)]
            
            let timeOffStart = ["date": startDateDict] as [String : Any]
            let timeOffEnd = ["date": endDateDict] as [String : Any]
            let multiDayUsingStartEndDate = ["timeOffStart":timeOffStart,"timeOffEnd":timeOffEnd]
            var userExplicitEntries:[Any]  = []
            
            if let startDateUserExplicitEntry = getTimeEntryForBalance(timeOffEntry: timeOff.startDayEntry!){
                userExplicitEntries.append(startDateUserExplicitEntry)
            }
            for timeOffMiddleEntry in timeOff.middleDayEntries{
                if let userExplicitDict = getTimeEntryForBalance(timeOffEntry: timeOffMiddleEntry){
                    userExplicitEntries.append(userExplicitDict)
                }
            }
            if let endDateUserExplicitEntry = getTimeEntryForBalance(timeOffEntry: timeOff.endDayEntry!){
                userExplicitEntries.append(endDateUserExplicitEntry)
            }
            
            let balanceRequestBody = ["target":["uri": NSNull()],
                                      "owner":owner,
                                      "timeOffType":timeOffType,
                                      "entryConfigurationMethodUri":"urn:replicon:time-off-entry-configuration-method:populate-daily-entries-using-explicit-user-entries",
                                      "multiDayUsingStartEndDate":multiDayUsingStartEndDate,
                                      "userExplicitEntries":userExplicitEntries,
                                      "comments":"",
                                      "customFieldValues":[]] as [String : Any]
            
            let requestBody = ["timeOff":balanceRequestBody] as [String: Any]
            let data: NSData = try JSONSerialization.data(withJSONObject: requestBody, options: []) as NSData
            let urlString = self.urlStringProvider.urlString(withEndpointName: "TimeoffBalance") as String
            let requestBodyString = NSString(data:data as Data, encoding:String.Encoding.utf8.rawValue)
            let paramDict = ["URLString": urlString as String, "PayLoadStr": requestBodyString!] as [String: Any]
            let request = RequestBuilder.buildPOSTRequest(withParamDict: paramDict)
            return request as URLRequest?
        }
        catch{
            return nil
        }
    }
    
    func deleteTimeOff(timeOff: TimeOff) -> URLRequest? {
        do
        {
            let timeOffUri = timeOff.details?.uri
            let requestBody = ["timeOffUri" : timeOffUri]
            let data: NSData = try JSONSerialization.data(withJSONObject: requestBody, options: []) as NSData
            let urlString = self.urlStringProvider.urlString(withEndpointName: "DeleteTimeOffData") as String
            let requestBodyString = NSString(data:data as Data, encoding:String.Encoding.utf8.rawValue)
            let paramDict = ["URLString": urlString as String, "PayLoadStr": requestBodyString!] as [String: Any]
            let request = RequestBuilder.buildPOSTRequest(withParamDict: paramDict)
            return request as URLRequest?
        }
        catch{
            return nil
        }
    }

    private func getTimeEntry(timeOffEntry: TimeOffEntry, isEndDayEntry: Bool) -> [String: Any]?
    {
        let timeOffDate = timeOffEntry.date
        let timeOffDateDict = DateHelper.convertDateToDict(date: timeOffDate!)
        
        var specificDuration:Any = NSNull()
        var startTime:Any = NSNull()
        var endTime:Any = NSNull()
        var relativeDuration: Any = timeOffEntry.durationType.rawValue
        
        if(timeOffEntry.durationType != .none && timeOffEntry.durationType != .fullDay) {
            if(isEndDayEntry){
                if let endTimeValue = Util.getApiTimeDict(forTime: timeOffEntry.timeEnded) as? [String: Any] {
                endTime = endTimeValue
            }
        }
            else{
                if let startTimeValue  = Util.getApiTimeDict(forTime: timeOffEntry.timeStarted) as? [String: Any] {
                    startTime =  startTimeValue
                }
            }
        }
        
        if(timeOffEntry.durationType == .none){
            specificDuration = "0.00"
            relativeDuration = NSNull()
        }
        
        if(timeOffEntry.durationType == .partialDay){
            specificDuration = timeOffEntry.bookingDurationDetails?.duration ?? 0
            relativeDuration = NSNull()
        }
        
        let userExplicitDict = ["date":timeOffDateDict,
                                               "relativeDurationUri":relativeDuration,
                                               "specificDuration":specificDuration,
                                               "timeStarted":startTime,
                                               "timeEnded":endTime] as [String : Any]
        return userExplicitDict
    }
    
    private func getTimeEntryForBalance(timeOffEntry: TimeOffEntry) -> [String: Any]?
    {
        let timeOffDate = timeOffEntry.date
        
        let timeOffDateDict = DateHelper.convertDateToDict(date: timeOffDate!)
        
        var specificDuration:Any
        var relativeDuration:Any
        
        if (timeOffEntry.durationType == .none){
            specificDuration = 0
            relativeDuration = NSNull()
        }
        else if(timeOffEntry.durationType == .partialDay){
            specificDuration = getDurationForPartialDay(duration: timeOffEntry.bookingDurationDetails?.duration)
            relativeDuration = NSNull()
        }
        else{
            relativeDuration = timeOffEntry.durationType.rawValue
            specificDuration = NSNull()
        }
        let userExplicitDict = ["date":timeOffDateDict,
                                "relativeDurationUri":relativeDuration,
                                "specificDuration":specificDuration,
                                "timeStarted":NSNull(),
                                "timeEnded":NSNull()] as [String : Any]
        return userExplicitDict

    }
    
    private func getDurationForPartialDay(duration:String?) -> Any{
        guard let specificDuration = duration else {
            return NSNull()
        }
        
        return specificDuration.characters.count > 0 ? specificDuration.replaceCommaWithDot() : String(format: Precision.twoDecimal, 0)
    }
    
    private func getUDFFromTimeOff(timeOff: TimeOff) ->[[String: Any]]? {
        var udfEntries:[[String:Any]] = []
        
        for timeOffUDFEntry in timeOff.allUDFs{
           var udfEntry = ["customField":["groupUri": NSNull(), "name":timeOffUDFEntry.name, "uri":timeOffUDFEntry.uri]] as [String : Any]
            
            switch timeOffUDFEntry.type {
            case .dropdown:
                udfEntry["date"] = NSNull()
                let optionsUri = timeOffUDFEntry.optionsUri ?? ""
                let dropDownOption = ["uri": optionsUri] as [String : Any]
                udfEntry["dropDownOption"] = optionsUri.characters.count > 0 ? dropDownOption : NSNull()
                udfEntry["number"] = NSNull()
                udfEntry["text"] = NSNull()
            case .numeric:
                udfEntry["date"] = NSNull()
                udfEntry["dropDownOption"] = NSNull()
                udfEntry["text"] = NSNull()
                if let numberValue = Double(timeOffUDFEntry.value) {
                    udfEntry["number"] = numberValue
                }else{
                    udfEntry["number"] = NSNull()
                }
            case .text:
                udfEntry["date"] = NSNull()
                udfEntry["dropDownOption"] = NSNull()
                if timeOffUDFEntry.value.characters.count > 0 {
                    udfEntry["text"] = timeOffUDFEntry.value
                }else{
                    udfEntry["text"] = NSNull()
                }
                udfEntry["number"] = NSNull()
            case .date:
                if let udfDate = DateHelper.getDateFrom(dateString: timeOffUDFEntry.value, withFormat: DateFormat.format1){
                    let calendar = Calendar.current
                    let timeOffDateDict = ["day":calendar.component(.day, from: udfDate),
                                           "month":calendar.component(.month, from: udfDate),
                                           "year":calendar.component(.year, from: udfDate)]
                    udfEntry["date"] = timeOffDateDict
                }else{
                    udfEntry["date"] = NSNull()
                }
                udfEntry["dropDownOption"] = NSNull()
                udfEntry["text"] = NSNull()
                udfEntry["number"] = NSNull()
            default:
                print("Unknown type")
            }
            
            udfEntries.append(udfEntry)
        }
        return udfEntries
    }
    
    fileprivate func isTimeOffPartialOrNone(timeOffEntry: TimeOffEntry) -> Bool {
        if(timeOffEntry.durationType == .none || timeOffEntry.durationType == .partialDay){
            return true
        }
        return false
    }
}

