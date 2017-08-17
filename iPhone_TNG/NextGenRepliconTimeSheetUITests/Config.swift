
import Foundation

class Config {
    
    let tags: Array<String>
    var admin: Array<ConfigAdmin>
    var users: Array<ConfigUser>
    
    init(){
        let currentBundle = NSBundle(forClass: self.dynamicType)
        let filePath = currentBundle.pathForResource("config.json", ofType: nil)
        let jsonFileData = NSData(contentsOfFile: filePath!)
        let json = JSON(data: jsonFileData!)
        
        //read tags into array
        tags = json["tags"].stringValue.characters.split(",").map({String($0)})
        
        users = Array<ConfigUser>()
        admin = Array<ConfigAdmin>()
        let userJsonDict = json["type"]["daily"]["user"].dictionaryValue
        users.append(ConfigUser(company: userJsonDict["company"]!.stringValue, name: userJsonDict["name"]!.stringValue,
            password: userJsonDict["password"]!.stringValue))
        let adminJsonDict = json["type"]["daily"]["admin"].dictionaryValue
        admin.append(ConfigAdmin(company: adminJsonDict["company"]!.stringValue, name: adminJsonDict["name"]!.stringValue,
            password: adminJsonDict["password"]!.stringValue))
        let userTDJsonDict = json["type"]["timeDist"]["user"].dictionaryValue
        users.append(ConfigUser(company: userTDJsonDict["company"]!.stringValue, name: userTDJsonDict["name"]!.stringValue,
            password: userTDJsonDict["password"]!.stringValue))
        let adminTDJsonDict = json["type"]["timeDist"]["admin"].dictionaryValue
        admin.append(ConfigAdmin(company: adminTDJsonDict["company"]!.stringValue, name: adminTDJsonDict["name"]!.stringValue,
            password: adminTDJsonDict["password"]!.stringValue))

    }
    
    func tagExists(tag: String)->Bool{
        return tags.contains(tag)
    }
}

struct ConfigUser {
    let company: String
    let name: String
    let password: String
}

struct ConfigAdmin {
    let company: String
    let name: String
    let password: String
}

