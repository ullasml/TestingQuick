//
//  ShiftDetailsPresenter.swift
//  NextGenRepliconTimeSheet
//
//  Created by Someshubhra Karmakar on 31/07/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import Foundation

class ShiftDetailsPresenter : NSObject {
    
    let theme: Theme
    let presenterHelper: ShiftPresenterHelper
    weak var injector:BSInjector!
    
    init(theme: Theme, presenterHelper: ShiftPresenterHelper){
        self.theme = theme
        self.presenterHelper = presenterHelper
        super.init()
    }
    
    func shiftSectionItemPresenters(forShiftDetailsList shiftDetailsList: [Any]) -> [ShiftItemsSectionPresenter] {
        var presenters = [ShiftItemsSectionPresenter]()
        
        for shiftDetail in shiftDetailsList {
            let sectionPresenter = createShiftItemsSectionPresenter(shiftData: shiftDetail)
            presenters.append(sectionPresenter)
        }
        
        return presenters
    }
    
    private func createShiftItemsSectionPresenter(shiftData:Any) -> ShiftItemsSectionPresenter {
        var shiftItemPresenters = [ShiftItemPresenter]()
        
        if let _  = shiftData as? String { // No shifts assigned
            let shiftItemPresenter = injector.getInstance(ShiftItemPresenter.self) as! ShiftItemPresenter
            shiftItemPresenter.setup(cellType:.noShifts,
                                     shiftDescriptionText: ConstStrings.noShiftsAssigned,
                                     shiftDetailsDescriptionText : nil,
                                     notes: nil,
                                     shiftColorHex: nil,
                                     udfName: nil,
                                     udfValue: nil,
                                     timeOffDescText: nil,
                                     timeOffStatus: nil,
                                     holidayDescriptionText: nil)
            
            shiftItemPresenters.append(shiftItemPresenter)
            
            
        }
        else if let element = shiftData as? [String:Any] { // Single shift data
            if let elementType = element["type"] as? String {
                if elementType == TIME_OFF_ENTRY {
                    let timeOffItemPresenter = presenterHelper.createTimeOffItemPresenter(dataDict: element, timeOffNameKey: "TimeOffName", approvalStatusKey: "approvalStatus")
                    shiftItemPresenters.append(timeOffItemPresenter)
                    
                }
                else if elementType == HOLIDAY_ENTRY {
                    let holidayItemPresenter = presenterHelper.createHolidayItemPresenter(dataDict: element)
                    shiftItemPresenters.append(holidayItemPresenter)
                    
                }
            }
        }
        else if let entryDetails = shiftData as? [[String:Any]] , entryDetails.count > 0 {// Shift Info
            let models = createShiftDetailsItemPresenter(shiftData: entryDetails)
            shiftItemPresenters.append(models.shiftItemPresenter)
            
            
            shiftItemPresenters.append(contentsOf: models.udfItemPresenters)
            
            if let shiftNotesItemPresenter = models.noteItemPresenter {
                shiftItemPresenters.append(shiftNotesItemPresenter)
            }
        }
        
        // Create the section presenter
        let sectionPresenter = injector.getInstance(ShiftItemsSectionPresenter.self) as! ShiftItemsSectionPresenter
        sectionPresenter.setup(shiftDayText: nil,
                               subText: nil,
                               shiftItemPresenters:shiftItemPresenters)
        
        if let shiftItemPresenter = sectionPresenter.shiftItemPresenters.last {
            shiftItemPresenter.bottomSeparator = .none
        }
        if let shiftItemPresenter = sectionPresenter.shiftItemPresenters.first {
            shiftItemPresenter.topSeparator = .none
        }
        
        return sectionPresenter
    }
    
    //MARK:  Shift details section creation
    private func createShiftDetailsItemPresenter(shiftData:[[String:Any]]) -> (shiftItemPresenter:ShiftItemPresenter, udfItemPresenters:[ShiftItemPresenter], noteItemPresenter:ShiftItemPresenter?) {
        
        var shiftDescText = ""
        var shiftDetailsDescriptionText = ""
        var shiftColorHex:String?
        
        var udfItemPresenters = [ShiftItemPresenter]()
        
        var workEntryTotalHours:Int = 0
        var breakEntryHours:Int = 0
        
        
        // First element of the array will be the shift name and duration. From second element onwards we kave the break, notes and UDF info.
        let shiftInfo = shiftData[0]
        
        if let shiftColorCode = shiftInfo["colorCode"] as? String {
            shiftColorHex = String(format: "#%@", shiftColorCode)
        }
        
        if let shiftName = shiftInfo["shiftName"] as? String {
            shiftDescText = shiftName
        }
        
        if let startTime = shiftInfo["in_time"] as? String, startTime != NULL_STRING, !startTime.isEmpty,
            let endTime = shiftInfo["out_time"] as? String, endTime != NULL_STRING, !endTime.isEmpty{
            
            shiftDescText = String(format:"%@ - %@ %@ %@",shiftDescText,startTime,ConstStrings.to,endTime)
            
            if let inTimeStamp = shiftInfo["in_time_stamp"] as? Int,
                let outTimeStamp = shiftInfo["out_time_stamp"] as? Int {
                workEntryTotalHours = workEntryTotalHours + outTimeStamp - inTimeStamp
            }
        }
        
        // iterate the rest array for Breaks and UDFs
        if shiftData.count > 1 { // Check this to avoid crash in next line if count is only 1
            for index in 1...(shiftData.count - 1){
                let element = shiftData[index]
                if let type = element["type"] as? String, type == "UDF" {// User defined types
                    let udfItemPresenter = injector.getInstance(ShiftItemPresenter.self) as! ShiftItemPresenter
                    udfItemPresenter.setup(cellType:.udf,
                                           shiftColorHex: shiftColorHex,
                                           udfName: element["udf_name"] as? String,
                                           udfValue: element["udfValue"] as? String)
                    
                    udfItemPresenters.append(udfItemPresenter)
                    
                }
                else {// check for break types
                    var breakDescriptionText = ""
                    if let breakDuration = element["shiftDuration"] as? String {
                        breakDescriptionText.append(breakDuration.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                    
                    if let breakType = element["breakType"] as? String {
                        breakDescriptionText.append(String(format:" - %@",breakType))
                    }
                    
                    if let startTimeStamp = element["in_time_stamp"] as? Int,
                        let endTimeStamp = element["out_time_stamp"] as? Int{
                        breakEntryHours = breakEntryHours + endTimeStamp - startTimeStamp
                    }
                    if !shiftDetailsDescriptionText.isEmpty {// Already there are characters in string so add a new line character
                        shiftDetailsDescriptionText = shiftDetailsDescriptionText + "\n"
                    }
                    shiftDetailsDescriptionText = shiftDetailsDescriptionText + breakDescriptionText
                }
            }
        }
        
        let totaltimeDiffBetweenWorkAndBreakHours = workEntryTotalHours - breakEntryHours;
        
        
        let workMinutes = (totaltimeDiffBetweenWorkAndBreakHours / 60) % 60;
        let workHours = (totaltimeDiffBetweenWorkAndBreakHours / 3600);
        
        let breakMinutes = (breakEntryHours / 60) % 60;
        let breakHours = (breakEntryHours / 3600);
        
        let totalMinutes = (workEntryTotalHours / 60) % 60;
        let totalHours = (workEntryTotalHours / 3600);
        
        if !shiftDetailsDescriptionText.isEmpty {// Already there are characters in string so add a new line character
            shiftDetailsDescriptionText = shiftDetailsDescriptionText + "\n"
        }
        // Total work
        shiftDetailsDescriptionText = shiftDetailsDescriptionText + String(format:"%@: %02li:%02li", ConstStrings.totalHours, totalHours, totalMinutes)
        
        // Work Sumary including breaks
        shiftDetailsDescriptionText = shiftDetailsDescriptionText + "\n"
        shiftDetailsDescriptionText = shiftDetailsDescriptionText + String(format:"%@: %02li:%02li + %@: %02li:%02li", ConstStrings.work, workHours, workMinutes, ConstStrings.breakInShift ,breakHours, breakMinutes)
        
        var shiftDetailsDescription:String?
        if shiftDetailsDescriptionText.isEmpty {
            shiftDetailsDescription = nil
        }
        else {
            shiftDetailsDescription = shiftDetailsDescriptionText
        }
        
        
        let shiftItemPresenter = injector.getInstance(ShiftItemPresenter.self) as! ShiftItemPresenter
        shiftItemPresenter.setup(cellType:.shiftDetail,
                                 shiftDescriptionText: shiftDescText,
                                 shiftDetailsDescriptionText : shiftDetailsDescription,
                                 shiftColorHex: shiftColorHex)
        
        
        
        // add a notes presenter as well
        // Iterate through the notes seperately as notes can be inserted in any type of shift data(shifts, break, udf etc)
        var notes:String?
        for shiftInfo in shiftData {
            if let notesObject = shiftInfo["note"] as? String , !notesObject.isEmpty , notesObject != NULL_STRING{ // Notes
                notes = notesObject
            }
        }
       
        var notesPresenter:ShiftItemPresenter?
        if let _ = notes {
            notesPresenter = injector.getInstance(ShiftItemPresenter.self) as? ShiftItemPresenter
            notesPresenter?.setup(cellType:.notes,
                                  notes: notes,
                                  shiftColorHex: shiftColorHex)
        }
        
        
        return (shiftItemPresenter,udfItemPresenters,notesPresenter)
    }
    
}
