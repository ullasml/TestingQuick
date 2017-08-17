//
//  TimeOffDeserializer.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 04/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit

@objc enum TimeOffModelType: Int {
    case unKnown
    case timeOff
    case pendingApproval
    case previousApproval
    
    var description: String {
        switch self {
        case .timeOff:
            return "TIMEOFF_MODULE"
        case .pendingApproval:
            return APPROVALS_PENDING_TIMEOFF_MODULE
        case .previousApproval:
            return APPROVALS_PREVIOUS_TIMEOFF_MODULE
        default:
            return "UNKNOWN_TIMEOFF_MODULE"
        }
    }
}

@objc protocol TimeOffDeserializerProtocol {
    func setTimeOffModelType(type:TimeOffModelType)
    func getAllTimeOffType() -> [TimeOffTypeDetails]
    func getDefaultTimeOffType() -> TimeOffTypeDetails?
    func getBalanceInfo(_ balanceInfo:[String:Any]?) -> TimeOffBalance?
    func getTimeOffUDFsFromDB(forUri timeOffUri:String?) -> [TimeOffUDF]
    func deserializeTimeOffDetails(timeOffUri: String) -> TimeOff?
    func deserializeDurationOptionsAndSchedules(from response:[String:Any]?) -> [String:Any]
}

class TimeOffDeserializer: NSObject {
    
    fileprivate let timeoffModel:TimeoffModel
    fileprivate let loginModel:LoginModel
    fileprivate let approvalsModel: ApprovalsModel
    private let defaultDuration = String(format: Precision.twoDecimal, 0)
    
    fileprivate var timeOffModelType: TimeOffModelType = .unKnown
    
    init(timeoffModel: TimeoffModel,
           loginModel: LoginModel,
       approvalsModel: ApprovalsModel) {
        
        self.timeoffModel = timeoffModel
        self.loginModel = loginModel
        self.approvalsModel = approvalsModel
        super.init()
    }
    
    private func getTimeOffDuration(_ bookingDuration:[String:Any])-> TimeOffDuration?{
        let title = bookingDuration["displayText"] as? String
        var durationstr = ""
        if let duration = bookingDuration["duration"] as? Double {
           durationstr = String(format:Precision.twoDecimal, duration)
        }
        let uri = bookingDuration["uri"] as? String
        return TimeOffDuration(withUri: uri, title: title, duration: durationstr)
    }
    
    private func getDurationOptions(_ durationOptions:[String:Any]) -> TimeOffDurationOptions?{
        var timeOffDuration:[TimeOffDuration] = []
        let scheduleDuration = durationOptions["scheduleDuration"] as? Double ?? 0
        if let bookingDurations = durationOptions["bookingOptions"] as? [[String:Any]]{
            for bookingDuration in bookingDurations{
                if let toffDuration = getTimeOffDuration(bookingDuration){
                    timeOffDuration.append(toffDuration)
                }
            }
        }
        return TimeOffDurationOptions(withScheduleDuration: String(format:Precision.twoDecimal, scheduleDuration), durationOptions: timeOffDuration)
    }
    
    fileprivate func getDurationOptionsByScheduleDuration(_ bookingOptionsByScheduleDuration:[[String:Any]]?) -> [TimeOffDurationOptions]{
        
        var allDurationOptions:[TimeOffDurationOptions] = []
        
        guard let bookingOptions = bookingOptionsByScheduleDuration
            else { return [] }
        for option in bookingOptions
        {
            if let toffDurationOptions = getDurationOptions(option){
                allDurationOptions.append(toffDurationOptions)
            }
        }
        return allDurationOptions
    }
    
    private func  getDurationDetails(forSchedule scheduleDuration:String, durationUri:String, allOptions:[TimeOffDurationOptions]) -> TimeOffDuration?{
        guard let filteredValue = (allOptions.filter {$0.scheduleDuration == scheduleDuration}.map {$0.durationOptions}).first, let options = (filteredValue?.filter{$0.uri == durationUri})?.first else {
            return nil
        }
        
        return options.copy()
    }
    
    private func getDate(fromComponentDictionary dateDictionary:Dictionary<String, Any>) -> Date?
    {
        guard let year = dateDictionary["year"] as? Int, let month = dateDictionary["month"] as? Int, let day = dateDictionary["day"] as? Int else
        {
            return nil
        }
        let dateComponents = DateComponents(year: year, month: month, day: day)
        var gregorian = Calendar(identifier:Calendar.Identifier.gregorian)
        gregorian.timeZone = TimeZone(identifier: "UTC")!
        return gregorian.date(from: dateComponents)
    }
    
    fileprivate func getTimeOffEntriesFromDB(_ timeOffEntries:[[String:Any]]?, allOptions:[TimeOffDurationOptions]) -> [TimeOffEntry]{
        
        guard let allEntries = timeOffEntries else {
            return []
        }
        
        var entries : [TimeOffEntry] = []
        for timeOffEntry in allEntries{
            guard let dateInterval = timeOffEntry["date"] as? TimeInterval else {
                continue
            }
            
            let entryDate = DateHelper.getDateFrom(timeInterval: dateInterval)
            let schedule = timeOffEntry["scheduledDuration"] as? String ?? defaultDuration
            let scheduleDuration = String(format: Precision.twoDecimal, Double(schedule) ?? 0)

            let durationUri:String = timeOffEntry["relativeDurationUri"] as? String ?? ""
            let timeEnded = timeOffEntry["timeEnded"] as? String ?? ""
            let timeStarted = timeOffEntry["timeStarted"] as? String ?? ""
            let durationObj = getDurationDetails(forSchedule: scheduleDuration, durationUri: durationUri, allOptions: allOptions)
            let specificDuration = timeOffEntry["specificDuration"] as? String ?? defaultDuration
            durationObj?.duration = String(format: Precision.twoDecimal, Double(specificDuration) ?? 0)
            if let timeOffEntryObj = TimeOffEntry(withDate: entryDate, scheduleDuration: scheduleDuration, bookingDurationObj: durationObj, timeStarted: timeStarted, timeEnded: timeEnded){
                entries.append(timeOffEntryObj)
                print(timeOffEntryObj.description)
            }
        }
        return entries
    }

    fileprivate func getDurationOptionsByScheduleDurationDB(_ bookingOptionsByScheduleDuration:[[String:Any]]?) -> [TimeOffDurationOptions]{
        
        guard let bookingOptions = bookingOptionsByScheduleDuration
            else { return [] }
        
        var allDurationOptions:[TimeOffDurationOptions] = []
        for option in bookingOptions
        {
            guard let schedule = option["scheduledDuration"] as? String, let durationOption = getTimeOffDurationDB(option) else {
                continue
            }

            let scheduleDuration = String(format: Precision.twoDecimal, Double(schedule) ?? 0)
            if let thisSchedule = (allDurationOptions.filter {$0.scheduleDuration == scheduleDuration}).first {
                thisSchedule.durationOptions?.append(durationOption)
            }else{
                allDurationOptions.append(TimeOffDurationOptions(withScheduleDuration: scheduleDuration, durationOptions: [durationOption]))
            }
            
        }
        return allDurationOptions
    }

    private func getTimeOffDurationDB(_ bookingDuration:[String:Any])-> TimeOffDuration?{
        let title = bookingDuration["displayText"] as? String
        //let duration = bookingDuration["duration"] as? String ?? defaultDuration
        let uri = bookingDuration["uri"] as? String
        
        let duration = bookingDuration["duration"] is NSNull ? "" : bookingDuration["duration"] as? String ?? ""
        let bookingDuration = duration.characters.count > 0 ? String(format: Precision.twoDecimal, Double(duration) ?? 0) : duration
        return TimeOffDuration(withUri: uri, title: title, duration: bookingDuration)
    }

    
    fileprivate func getApprovalStatusDB(_ timeOffObjet: [String:Any]?) -> TimeOffStatusDetails?{
        guard let status = timeOffObjet, let uri = status["approvalStatusUri"] as? String, let title = status["approvalStatus"] as? String else {
            return nil
        }
        
        return TimeOffStatusDetails(withUri: uri, title: title)
    }
    
    fileprivate func getTimeOffType(_ timeOffUri:String?, timeOffName:String?, timeOffMeasurementUri:String?) -> TimeOffTypeDetails?{
        guard let uri = timeOffUri, let name = timeOffName, let measurementUri = timeOffMeasurementUri else {
            return nil
        }
        return TimeOffTypeDetails(withUri: uri, title: name, measurementUri: measurementUri)
    }
    
    fileprivate func getBalanceInfoFromDB(_ balanceDict:[String:Any]?) -> TimeOffBalance?{
        guard let balanceInfo = balanceDict, let displayFormatUri = balanceInfo["timeOffDisplayFormatUri"] as? String else {
            return nil
        }
        
        var balance:String? = nil
        var requested:String? = nil
        switch displayFormatUri {
        case TimeOffConstants.MeasurementUnit.days:
            balance = balanceInfo["balanceRemainingDays"] as? String
            requested = balanceInfo["requestedDays"] as? String
        case TimeOffConstants.MeasurementUnit.hours:
            balance = balanceInfo["balanceRemainingHours"] as? String
            requested = balanceInfo["requestedHours"] as? String
        default:
            print("Unexpected Measurement Uri")
        }
        
        if let timeRemaining = balance?.replaceCommaWithDot(), let doubleVal = Double(timeRemaining) {
            balance = String(format:Precision.twoDecimal, doubleVal)
        }
        
        if let timeTaken = requested?.replaceCommaWithDot(), let doubleVal = Double(timeTaken) {
            requested = String(format:Precision.twoDecimal, doubleVal)
        }
        
        return TimeOffBalance(timeRemaining: balance, timeTaken: requested)
    }
    
    fileprivate func getTimeOffDetailsFromDb(withUri uri:String, comments:String?, canEdit:Bool?, canDelete:Bool?) -> TimeOffDetails?{
        return TimeOffDetails(withUri: uri, comments: comments ?? "", resubmitComments:"", edit: canEdit ?? false, delete: canDelete ?? false)
    }
    
    fileprivate func getTimeOffEntriesFromSchedules(_ scheduleInfoByDate:[[String:Any]]?, allOptions:[TimeOffDurationOptions]) -> [TimeOffEntry]{
        
        guard let schedules = scheduleInfoByDate
            else { return [] }
        
        var entries : [TimeOffEntry] = []
        
        for schedule in schedules{
            guard let date = schedule["date"] as? [String:Any] else {
                continue
            }
            let entryDate = getDate(fromComponentDictionary:date)
            let scheduleDuration = schedule["scheduleDuration"] as? Double ?? 0
            let durationUri = scheduleDuration == 0 ? TimeOffDurationType.none.rawValue : TimeOffDurationType.fullDay.rawValue
            let durationObj = getDurationDetails(forSchedule: String(format:Precision.twoDecimal, scheduleDuration), durationUri: durationUri, allOptions: allOptions)
            if let timeOffEntryObj = TimeOffEntry(withDate: entryDate, scheduleDuration: String(format:Precision.twoDecimal, scheduleDuration), bookingDurationObj: durationObj){
                entries.append(timeOffEntryObj)
            }
        }
        return entries
    }
    
    //MARK: Decide Model 
    
    fileprivate func getTimeOffInfoForSheetIdentity(timeoffUri: String) -> [[String: Any]]? {
        switch timeOffModelType {
        case .timeOff :
            return self.timeoffModel.getTimeoffInfoSheetIdentity(timeoffUri) as? [[String : Any]]
        case .pendingApproval:
            return self.approvalsModel.getAllPendingTimeoffFromDB(forTimeoff: timeoffUri) as? [[String : Any]]
        case .previousApproval:
            return self.approvalsModel.getAllPreviousTimeoffFromDB(forTimeoff: timeoffUri) as? [[String : Any]]
        default:
            return self.timeoffModel.getTimeoffInfoSheetIdentity(timeoffUri) as? [[String : Any]]
        }
    }
    
    fileprivate func fetchAllTimeOffs() -> [[String:Any]]? {
        switch timeOffModelType {
        case .timeOff :
            return self.timeoffModel.getAllTimeOffTypesFromDB() as? [[String : Any]]
        case .pendingApproval:
            return self.approvalsModel.getAllPendingTimeOffsOfApprovalFromDB() as? [[String : Any]]
        case .previousApproval:
            return self.approvalsModel.getAllPreviousTimeOffsOfApprovalFromDB() as? [[String : Any]]
        default:
            return self.timeoffModel.getAllTimeOffTypesFromDB() as? [[String : Any]]
        }
    }

    fileprivate func fetchTimeOffUdfForUri(uriValue: String, udfUri: String) -> [String:Any]? {
        switch timeOffModelType {
        case .timeOff :
            return self.timeoffModel.getTimeOffCustomFields(forSheetURI: uriValue, moduleName: ConstStrings.module, andUdfURI: udfUri)?.first as? [String : Any]
        case .pendingApproval:
            return self.approvalsModel.getPendingTimeOffCustomFields(forSheetURI: uriValue, moduleName: ConstStrings.module, andUdfURI: udfUri)?.first as? [String : Any]
        case .previousApproval:
            return self.approvalsModel.getPreviousTimeOffCustomFields(forSheetURI: uriValue, moduleName: ConstStrings.module, andUdfURI: udfUri)?.first as? [String : Any]
        default:
            return self.timeoffModel.getTimeOffCustomFields(forSheetURI: uriValue, moduleName: ConstStrings.module, andUdfURI: udfUri)?.first as? [String : Any]
        }
    }
}

// MARK: TimeOffDeserializerProtocol methods

extension TimeOffDeserializer: TimeOffDeserializerProtocol {
    
    func setTimeOffModelType(type:TimeOffModelType){
        self.timeOffModelType = type
    }
    
    /****************** Load TimeOffType From DB *********************/
    //MARK: Load TimeOffType From DB
    
    
    func getAllTimeOffType() -> [TimeOffTypeDetails] {
        var allTypes:[TimeOffTypeDetails] = []
        guard let allTypesFromDB = self.fetchAllTimeOffs() else {
            return []
        }
        
        for type in allTypesFromDB{
            if let title = type["timeoffTypeName"] as? String, let uri = type["timeoffTypeUri"] as? String, let measurementUri = type["timeOffDisplayFormatUri"] as? String {
                allTypes.append(TimeOffTypeDetails(withUri: uri, title: title, measurementUri: measurementUri))
            }
        }
        return allTypes
    }
    
    func getDefaultTimeOffType() -> TimeOffTypeDetails?{
        let defaultType = self.timeoffModel.getDefaultTimeoffType() as? [String:String]
        if let type = defaultType, let uri = type["uri"] {
            let allTypes = getAllTimeOffType()
            let matches = allTypes.filter() {$0.uri == uri}
            return matches.first
        }
        return nil
    }
    
    
    func getTimeOffUDFsFromDB(forUri timeOffUri:String?) -> [TimeOffUDF]{
        
        guard let allUDFs = self.loginModel.getEnabledOnlyUDFsforModuleName("TimeOff_UDF")   as? [[String: Any]] else {
            return []
        }
        var udfs : [TimeOffUDF] = []
        for timeOffUDF in allUDFs{
            guard let displayName = timeOffUDF["name"] as? String, let uri = timeOffUDF["uri"] as? String, let typeUri = timeOffUDF["udfType"] as? String else{
                continue
            }
            
            var value = ""
            var optionsUri:String?
            
            if let timeOffUriVal = timeOffUri, let udf = fetchTimeOffUdfForUri(uriValue: timeOffUriVal, udfUri: uri), let udfValue = udf["udfValue"] as? String, let udfTypeUri = udf["entry_type"] as? String {
                //During TimeOff Load
                if let type = TimeOffUDFType(rawValue: udfTypeUri){
                    switch type {
                    case .text, .numeric:
                        value = udfValue
                    case .dropdown:
                        value = udfValue
                        optionsUri = udf["dropDownOptionURI"] as? String
                    case .date:
                        if let date = DateHelper.convertDateString(dateString: udfValue, from: DateFormat.format2, to: DateFormat.format1){
                            value = date
                        }
                    default:
                        value = ""
                    }
                    
                }
                
            }else{
                //During New TimeOff Booking
                if let type = TimeOffUDFType(rawValue: typeUri){
                    switch type {
                    case .dropdown:
                        value = timeOffUDF["textDefaultValue"] as? String ?? ""
                        optionsUri = timeOffUDF["dropDownOptionDefaultURI"] as? String
                    case .text:
                        value = timeOffUDF["textDefaultValue"] as? String ?? ""
                    case .numeric:
                        value = timeOffUDF["numericDefaultValue"] as? String ?? ""
                    case .date:
                        if let interval = timeOffUDF["dateDefaultValue"] as? TimeInterval, let date = DateHelper.getDateFrom(timeInterval: interval){
                            value = DateHelper.getStringFromDate(date: date, withFormat: DateFormat.format1, andTimeZoneAbbr: "UTC")
                        }
                    default:
                        value = ""
                    }
                }
            }
            let decimalPlaces = timeOffUDF["numericDecimalPlaces"] as? Int ?? 0
            udfs.append(TimeOffUDF(name: displayName, value: value, uri: uri, typeUri: typeUri, timeOffUri: timeOffUri ?? "", decimalPlaces: decimalPlaces, optionsUri: optionsUri))
            
        }
        return udfs
    }
    
    /****************** Load TimeOff From DB *********************/
    //MARK: Load TimeOff From DB
    
    func deserializeTimeOffDetails(timeOffUri: String) -> TimeOff? {
        
        let timeOffData = self.getTimeOffInfoForSheetIdentity(timeoffUri: timeOffUri)
        
        let timeOffDataDictionary = timeOffData?.first
        let tOffEntries =  self.timeoffModel.getTimeoffUserExplicitEntries(timeOffUri)  as? [[String : Any]]
        let timeoffBookingScheduledDurations = self.timeoffModel.getTimeoffScheduledDurations(timeOffUri) as? [[String: Any]]
        let allOptions = getDurationOptionsByScheduleDurationDB(timeoffBookingScheduledDurations)
        let timeoffEntries = getTimeOffEntriesFromDB(tOffEntries, allOptions: allOptions)
        let start = timeoffEntries.first
        let end = timeoffEntries.last
        let middle:[TimeOffEntry] = timeoffEntries.count > 2 ? Array(timeoffEntries[1..<(timeoffEntries.count-1)]) : []
        let approvalStatus = getApprovalStatusDB(timeOffDataDictionary)
        let timeOffUdfs = getTimeOffUDFsFromDB(forUri:timeOffUri)
        let timeOffTypeUri = timeOffDataDictionary?["timeoffTypeUri"] as? String
        let timeoffTypeName = timeOffDataDictionary?["timeoffTypeName"] as? String
        let measurementUri = timeOffDataDictionary?["timeOffDisplayFormatUri"] as? String
        
        let comments = timeOffDataDictionary?["comments"] as? String ?? ""
        let canDelete = timeOffDataDictionary?["hasTimeOffDeletetAcess"] as? Bool
        let canEdit = timeOffDataDictionary?["hasTimeOffEditAcess"] as? Bool
        
        let timeOffType = getTimeOffType(timeOffTypeUri, timeOffName: timeoffTypeName, timeOffMeasurementUri: measurementUri)
        let balanceDict = self.timeoffModel.getTimeoffBalance(forMultidayBooking: timeOffUri) as? [String:Any]
        let timeOffBalance = getBalanceInfoFromDB(balanceDict)
        let timeOffDetails = getTimeOffDetailsFromDb(withUri: timeOffUri, comments: comments, canEdit: canEdit, canDelete: canDelete)
        
        let timeOffObj = TimeOff(withStartDayEntry: start, endDayEntry: end, middleDayEntries: middle, allDurationOptions: allOptions, allUDFs: timeOffUdfs, approvalStatus: approvalStatus, balanceInfo: timeOffBalance, type: timeOffType, details: timeOffDetails)
        return timeOffObj
    }
    
    /****************** Load TimeOff From Response *********************/
    //MARK: Load TimeOff From Response
    
    func getBalanceInfo(_ balanceInfo:[String:Any]?) -> TimeOffBalance?{
        var timeRemaining:String? = nil, timeTaken:String? = nil
        
        if let remaining = balanceInfo?["timeRemaining"] as? Double{
            timeRemaining = String(format:Precision.twoDecimal, remaining)
        }
        
        if let taken = balanceInfo?["timeTaken"] as? Double{
            timeTaken = String(format:Precision.twoDecimal, taken)
        }
        if(timeTaken == nil && timeRemaining == nil){
            return nil
        }
        return TimeOffBalance(timeRemaining: timeRemaining, timeTaken: timeTaken)
    }
    
    
    /****************** Load DurationOptions and Schedules From Response *********************/
    //MARK: Load DurationOptions and Schedules From Response
    
    func deserializeDurationOptionsAndSchedules(from response:[String:Any]?) -> [String:Any]{
        guard let timeOffData = response else { return [:] }
        
        let root = timeOffData["d"] as? [String:Any]
        let bookingOptionsByScheduleDuration = root?["bookingOptionsByScheduleDuration"] as? [[String:Any]]
        let allOptions = getDurationOptionsByScheduleDuration(bookingOptionsByScheduleDuration)
        
        let scheduleInfoByDate = root?["scheduleInfoByDate"] as? [[String:Any]]
        let allEntries = getTimeOffEntriesFromSchedules(scheduleInfoByDate, allOptions: allOptions)
        return ["TimeOffDurationOptions":allOptions,"TimeOffEntry":allEntries]
    }
}
