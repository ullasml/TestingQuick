import Foundation
class RDate {

    class func from(_ year:Int, month:Int, day:Int) -> Date {
        var c = DateComponents()
        c.year = year
        c.month = month
        c.day = day

        var gregorian = Calendar(identifier:Calendar.Identifier.gregorian)
        gregorian.timeZone = TimeZone(identifier: "UTC")!
        let date = gregorian.date(from: c)
        return date!
    }

    class func parse(_ dateStr:String, format:String="yyyy-MM-dd") -> Date {
        let dateFmt = DateFormatter()
        dateFmt.timeZone = TimeZone(identifier: "UTC")!
        dateFmt.dateFormat = format
        return dateFmt.date(from:dateStr)!
    }

    class func getStringFromDate(_ date:Date, format:String="yyyy-MM-dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")!
        dateFormatter.dateFormat = format
        let str = dateFormatter.string(from:date)
        return str;
    }

    class func differenceBetweenDates(_ start:Date, end:Date) -> Int {
        var gregorian = Calendar(identifier:Calendar.Identifier.gregorian)
        gregorian.timeZone = TimeZone(identifier: "UTC")!
        let flags = Calendar.Component.day
        let components = gregorian.dateComponents([flags], from: start, to: end)
        
        return components.day!
    }

    class func addDaysToDate(_ days:Int, date:Date) -> Date {
        var gregorian = Calendar(identifier:Calendar.Identifier.gregorian)
        gregorian.timeZone = TimeZone(identifier: "UTC")!
        let tomorrow = (gregorian as NSCalendar).date(
            byAdding: .day,
            value: days,
            to: date,
            options: NSCalendar.Options(rawValue: 0))
        return tomorrow!;
    }

    class func dayFromDate(_ date:Date) -> Int? {

        var gregorian = Calendar(identifier:Calendar.Identifier.gregorian)
        gregorian.timeZone = TimeZone(identifier: "UTC")!
        let comp: DateComponents = (gregorian as NSCalendar).components(.day, from: date)
        return comp.day

    }

    class func monthFromDate(_ date:Date) -> Int? {

        var gregorian = Calendar(identifier:Calendar.Identifier.gregorian)
        gregorian.timeZone = TimeZone(identifier: "UTC")!
        let comp: DateComponents = (gregorian as NSCalendar).components(.month, from: date)
        return comp.month
        
    }

    class func yearFromDate(_ date:Date) -> Int? {
        var gregorian = Calendar(identifier:Calendar.Identifier.gregorian)
        gregorian.timeZone = TimeZone(identifier: "UTC")!
        let comp: DateComponents = (gregorian as NSCalendar).components(.year, from: date)
        return comp.year
    }

    class func getMonthFromDate(_ date:Date, format:String="MMMM") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let str = dateFormatter.string(from: date)
        return str;
    }

    class func isBetweeen(_ date:Date , date1: Date, andDate date2: Date) -> Bool {
        let result1 = date1.compare(date) as ComparisonResult
        let result2 = date.compare(date2) as ComparisonResult
        return (result1.rawValue * result2.rawValue ) >= 0
    }

    class func getWeekDayOfDate(_ date:Date)->Int{

        var gregorian = Calendar(identifier:Calendar.Identifier.gregorian)
        gregorian.timeZone = TimeZone(identifier: "UTC")!
        let comp: DateComponents = (gregorian as NSCalendar).components(.weekday, from: date)
        return comp.weekday!
    }
}
