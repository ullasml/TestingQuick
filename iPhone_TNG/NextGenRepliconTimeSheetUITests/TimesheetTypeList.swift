import Foundation

class TimesheetTypeList {
    
    let widgetTimesheet: UInt
    let pendingDailyWidget: UInt
    
    init(){
        let currentBundle = NSBundle(forClass: self.dynamicType)
        let filePath = currentBundle.pathForResource("timesheetTypeList.json", ofType: nil)
        let jsonFileData = NSData(contentsOfFile: filePath!)
        let json = JSON(data: jsonFileData!)
        
        // read TimesheetType
        widgetTimesheet =  json["timesheetType"]["widgetTimesheet"].uIntValue
        pendingDailyWidget =  json["timesheetType"]["pendingDailyWidget"].uIntValue
    }
}


