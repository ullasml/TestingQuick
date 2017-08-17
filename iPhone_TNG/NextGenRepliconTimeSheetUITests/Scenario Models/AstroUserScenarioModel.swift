
import Foundation



class AstroUserScenarioModel{
    var company:String?
    var companyLoginField:String?
    
    var user:User?
    
    var breakTypeArray = [String]()
    
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
        
        self.breakTypeArray = self.breakTypeArray.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }

        self.companyLoginField = loginCompanyName
        self.company = companyKey
        self.user = User(username: userLoginName, password: password)
        self.punchActions = [PunchType.ClockIn, PunchType.TakeBreak, PunchType.ClockOut]
    }
    
    func getFormattedPunchTime() -> String {
        let hoursAndMinutesDateFormatter: DateFormatter = DateFormatter()
        hoursAndMinutesDateFormatter.timeZone = TimeZone.autoupdatingCurrent
        hoursAndMinutesDateFormatter.dateFormat = "h:mm"
        return hoursAndMinutesDateFormatter.string(from: Date())
    }
}

