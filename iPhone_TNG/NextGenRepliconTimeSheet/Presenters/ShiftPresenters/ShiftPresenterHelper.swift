//
//  ShiftPresenterHelper.swift
//  NextGenRepliconTimeSheet
//
//  Created by Someshubhra Karmakar on 31/07/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import Foundation

class ShiftPresenterHelper : NSObject {
    
    let theme: Theme
    weak var injector:BSInjector!
    
    init(theme: Theme){
        self.theme = theme
        super.init()
    }
    
    //MARK: Time off cell model creation
    func createTimeOffItemPresenter(dataDict:[String:Any], timeOffNameKey:String, approvalStatusKey:String)->ShiftItemPresenter {
        var time = ""
        if let timeOffDisplayFormatUri = dataDict["timeOffDisplayFormatUri"] as? String {
            if timeOffDisplayFormatUri == TIME_Off_DISPLAY_WORK_DAYS_FORMAT_URI {
                if let timeOffDayDuration = dataDict["timeOffDayDuration"] as? String {
                    if timeOffDayDuration == "All Day" {
                        time =  ConstStrings.allDay
                    }
                    else {
                        let timeOffDayDurationNSString = timeOffDayDuration as NSString
                        if let timeOffDayRoudedText = Util.getRoundedValue(fromDecimalPlaces: timeOffDayDurationNSString.newDoubleValue(), withDecimalPlaces: 2){
                            
                            if fabs(timeOffDayDurationNSString.newDoubleValue()) != 1.00 {
                                time = String(format: "%@ %@", timeOffDayRoudedText, ConstStrings.days)
                            }
                            else {
                                time = String(format: "%@ %@", timeOffDayRoudedText, ConstStrings.day)
                            }
                        }
                    }
                    
                }
            }
            else if timeOffDisplayFormatUri == TIME_Off_DISPLAY_HOURS_FORMAT_URI {
                if let timeOffHourDuration = dataDict["timeOffHourDuration"] as? String {
                    if let timeOffDayDuration = dataDict["timeOffDayDuration"] as? String, timeOffDayDuration == "All Day" {
                        time =  ConstStrings.allDay
                        
                    }
                    else {
                        let timeOffHourDurationNSString = timeOffHourDuration as NSString
                        if let timeOffHourRoudedText = Util.getRoundedValue(fromDecimalPlaces: timeOffHourDurationNSString.newDoubleValue(), withDecimalPlaces: 2){
                            
                            if fabs(timeOffHourDurationNSString.newDoubleValue()) != 1.00 {
                                time = String(format: "%@ %@", timeOffHourRoudedText,ConstStrings.hours)
                            }
                            else {
                                time = String(format: "%@ %@", timeOffHourRoudedText, ConstStrings.hour)
                            }
                        }
                    }
                }
            }
        }
        // End of time variable population
        
        if time.isEmpty,  let timeOffDayDuration = dataDict["timeOffDayDuration"] as? String, timeOffDayDuration == "All Day" {
            time = ConstStrings.allDay
        }
        
        var timeOffDescText:String?
        var timeOffStatus:String?
        
        if let timeOffName = dataDict[timeOffNameKey] as? String {
            timeOffDescText = String(format: "%@ : %@", timeOffName,time)
        }
        
        if let status = dataDict[approvalStatusKey] as? String {
            timeOffStatus = status
        }
        
        let shiftItemPresenter = injector!.getInstance(ShiftItemPresenter.self) as! ShiftItemPresenter
        shiftItemPresenter.setup(cellType:.timeOff,
                                 timeOffDescText: timeOffDescText,
                                 timeOffStatus: timeOffStatus)
        
        return shiftItemPresenter
        
    }
    
    
    //MARK: Holiday cell model creation
    func createHolidayItemPresenter(dataDict:[String:Any])->ShiftItemPresenter {
        var holidayText:String?
        
        if let holiday = dataDict["type"] as? String, holiday == HOLIDAY_ENTRY  {
            holidayText = dataDict["holiday"] as? String
        }
        
        let shiftItemPresenter = injector!.getInstance(ShiftItemPresenter.self) as! ShiftItemPresenter
        shiftItemPresenter.setup(cellType:.holiday,
                                 holidayDescriptionText: holidayText)
        return shiftItemPresenter
    }
    
    
}
