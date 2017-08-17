//
//  DateHelper.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 13/04/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import Foundation

@objc class DateHelper : NSObject {
    /// Get Date from ComponentDictionary containing year, month and day
    class func getDate(fromComponentDictionary dateDictionary:Dictionary<String, Any>) -> Date?
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
    
    /// Convert array of TimeIntervals to array of Dates
    class func getDatesFrom(timeIntervals:[Any]) -> [Date]?{
        guard let timeIntervalDates = timeIntervals as? [TimeInterval] else {
            return nil
        }
        let dates = timeIntervalDates.map({Date(timeIntervalSince1970: ($0))})
        return dates
    }
    
    class func listOfDates(_ dates:[Date], contains date:Date) -> Bool{
        return dates.contains { $0.equalsIgnoreTime(date) }
    }
    
    class func getStringFromDate(date:Date, withFormat format:String, andTimeZoneAbbr zoneAbbr:String? = nil) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let zone = zoneAbbr, zone.characters.count > 0 {
            let timezone = TimeZone(abbreviation: zone)
            dateFormatter.timeZone = timezone
        }
        return dateFormatter.string(from: date)
    }
    
    class func getDateFrom(dateString:String, withFormat format:String) -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateString)
    }
    
    class func getDateFrom(timeInterval:Any) -> Date?{
        guard timeInterval is TimeInterval else {
            return nil
        }
        let date = Date(timeIntervalSince1970:timeInterval as! TimeInterval)
        return date
    }
    
    class func convertDateString(dateString dateStr:String, from fromFormat:String, to toFormat:String) -> String?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        if let date = dateFormatter.date(from: dateStr){
            dateFormatter.dateFormat = toFormat
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    class func convertDateToDict(date: Date) -> [String: Any]{
        var calendar = NSCalendar.current
        let unitFlags = Set<Calendar.Component>([.day, .month, .year])
        calendar.timeZone = TimeZone(identifier: "UTC")! //TimeZone(secondsFromGMT:0)!
        let components = calendar.dateComponents(unitFlags, from: date as Date)
        print("All Components : \(components)")
        
        // *** Get Individual components from date ***
        let day = calendar.component(.day, from: date as Date)
        let month = calendar.component(.month, from: date as Date)
        let year = calendar.component(.year, from: date as Date)
        return ["day":day, "month":month, "year":year]
        
    }
    
    class func getUTCDate(from date: Date) -> Date{
        var calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let finalDate = calendar.date(from: components)!
        return finalDate
    }

}
