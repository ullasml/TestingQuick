
import Foundation

class SimplePunchOEFScenarioModel{
    var company:String?
    var companyLoginField:String?
    
    var user:User?
    
    var breakTypeArray = [String]()
    
    var clockInOEFsArray = [OefType]()
    var clockOutOEFsArray = [OefType]()
    var breakOEFsArray = [OefType]()
    var resumeOEFsArray = [OefType]()
    
    var oefsTag = [String : String]()

    var punchActions = [PunchType]()
    
    init(data:Data){
        let json = JSON(data: data)
        
        let password = "Password123"
        let companyKey = json["tenant"]["companyKey"].stringValue
        let userLoginName = json["user"]["loginName"].stringValue
        let loginCompanyName = json["endpoint"]["mobileLogin"].stringValue
        
        let breakType = json["breaks"].array
        
        let count = breakType?.count
        for i in 0...count!-1 {
            let breakTypeText = String(describing: breakType![i]["displayText"])
            self.breakTypeArray.append(breakTypeText)
        }
        
        let clockInOefsType = json["objectextensionsclockin"].array
        let clockOutOefsType = json["objectextensionsclockout"].array
        let breakOefsType = json["objectextensionsbreaks"].array
        let resumeOefsType = json["objectextensionstransfer"].array
        
        let clockFirstInDropDownOefs = json["objectextensiontagoptionsclockin"]["tags"].array
        let clockInFirstDropDownOefType = String(describing: clockFirstInDropDownOefs![0]["name"])
        let clockInFirstDropDownOefTag = (String(describing: json["objectextensiontagoptionsclockin"]["name"]))
        self.oefsTag[clockInFirstDropDownOefTag] = clockInFirstDropDownOefType
        
        let clockInSecondDropDownOefs = json["objectextensiontag1optionsclockin"]["tags"].array
        let clockInSecondDropDownOefType = String(describing: clockInSecondDropDownOefs![0]["name"])
        let clockInSecondDropDownOefTag = (String(describing: json["objectextensiontag1optionsclockin"]["name"]))
        self.oefsTag[clockInSecondDropDownOefTag] = clockInSecondDropDownOefType

        let clockOutFirstDropDownOefs = json["objectextensiontagoptionsclockout"]["tags"].array
        let clockOutFirstDropDownOefType = String(describing: clockOutFirstDropDownOefs![0]["name"])
        let clockOutFirstDropDownOefTag = (String(describing: json["objectextensiontagoptionsclockout"]["name"]))
        self.oefsTag[clockOutFirstDropDownOefTag] = clockOutFirstDropDownOefType

        let clockSecondOutDropDownOefs = json["objectextensiontag1optionsclockout"]["tags"].array
        let clockOutSecondDropDownOefType = String(describing: clockSecondOutDropDownOefs![0]["name"])
        let clockOutSecondDropDownOefTag = (String(describing: json["objectextensiontag1optionsclockout"]["name"]))
        self.oefsTag[clockOutSecondDropDownOefTag] = clockOutSecondDropDownOefType

        let breakFirstDropDownOefs = json["objectextensiontagoptionsbreak"]["tags"].array
        let breakFirstDropDownOefType = String(describing: breakFirstDropDownOefs![0]["name"])
        let breakFirstDropDownOefTag = (String(describing: json["objectextensiontagoptionsbreak"]["name"]))
        self.oefsTag[breakFirstDropDownOefTag] = breakFirstDropDownOefType

        let breakSecondDropDownOefs = json["objectextensiontag1optionsbreak"]["tags"].array
        let breakSecondDropDownOefType = String(describing: breakSecondDropDownOefs![0]["name"])
        let breakSecondDropDownOefTag = (String(describing: json["objectextensiontag1optionsbreak"]["name"]))
        self.oefsTag[breakSecondDropDownOefTag] = breakSecondDropDownOefType

        let resumeFirstDropDownOefs = json["objectextensiontagoptionstransfer"]["tags"].array
        let resumeFirstDropDownOefType = String(describing: resumeFirstDropDownOefs![0]["name"])
        let resumeFirstDropDownOefTag = (String(describing: json["objectextensiontagoptionstransfer"]["name"]))
        self.oefsTag[resumeFirstDropDownOefTag] = resumeFirstDropDownOefType

        let resumeSecondDropDownOefs = json["objectextensiontag1optionstransfer"]["tags"].array
        let resumeSecondDropDownOefType = String(describing: resumeSecondDropDownOefs![0]["name"])
        let resumeSecondDropDownOefTag = (String(describing: json["objectextensiontag1optionstransfer"]["name"]))
        self.oefsTag[resumeSecondDropDownOefTag] = resumeSecondDropDownOefType

        self.breakTypeArray = self.breakTypeArray.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }

        self.companyLoginField = loginCompanyName
        self.company = companyKey
        self.user = User(username: userLoginName, password: password)
        self.punchActions = [PunchType.ClockIn, PunchType.TakeBreak, PunchType.ResumeWork, PunchType.ClockOut]
        
        self.clockInOEFsArray =  serializedOefsForOefObjects(clockInOefsType!)
        self.clockOutOEFsArray =  serializedOefsForOefObjects(clockOutOefsType!)
        self.breakOEFsArray =  serializedOefsForOefObjects(breakOefsType!)
        self.resumeOEFsArray =  serializedOefsForOefObjects(resumeOefsType!)
    }
    
    func getFormattedPunchTime() -> String {
        let hoursAndMinutesDateFormatter: DateFormatter = DateFormatter()
        hoursAndMinutesDateFormatter.timeZone = TimeZone.autoupdatingCurrent
        hoursAndMinutesDateFormatter.dateFormat = "h:mm"
        return hoursAndMinutesDateFormatter.string(from:Date())
    }
    
    fileprivate func serializedOefsForOefObjects(_ entryOefs : [JSON]) -> [OefType] {
        
        var allOefArray = [OefType]()
        var entryOefsIndex = 0
        while entryOefsIndex < entryOefs.count {
            let oefType = String(describing: entryOefs[entryOefsIndex]["definitionTypeUri"])
            var oefValue = ""
            let oefTitle = String(describing: entryOefs[entryOefsIndex]["displayText"])
            if oefType == Constants.dropDownOefUri {
                oefValue =  self.oefsTag[oefTitle]!
            }
            else if oefType == Constants.numericOefUri{
                oefValue =  "123"
            }
            else{
                oefValue =  "Oef Text"
            }
            
            let oefUri = String(describing: entryOefs[entryOefsIndex]["uri"])

            let oefObject = OefType(oefValue : oefValue, oefTitle: oefTitle , oefType: oefType, oefUri: oefUri)
            allOefArray.append(oefObject)
            entryOefsIndex += 1
        }
        return allOefArray
    }

}
