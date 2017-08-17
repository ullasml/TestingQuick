import Foundation


class TimeDistConfig {
    
    let entryData: EntryData
    
    init(){
        let currentBundle = NSBundle(forClass: self.dynamicType)
        let filePath = currentBundle.pathForResource("timedistconfig.json", ofType: nil)
        let jsonFileData = NSData(contentsOfFile: filePath!)
        let json = JSON(data: jsonFileData!)
        
        // read OEF element
        entryData = EntryData(client: json["entryData"]["client"].stringValue,
            project: json["entryData"]["project"].stringValue,
            task: json["entryData"]["task"].stringValue,
            activity: json["entryData"]["activity"].stringValue,
            time: json["entryData"]["time"].stringValue)
    }
}

struct EntryData {
    let client: String
    let project: String
    let task: String
    let activity: String
    let time: String
}