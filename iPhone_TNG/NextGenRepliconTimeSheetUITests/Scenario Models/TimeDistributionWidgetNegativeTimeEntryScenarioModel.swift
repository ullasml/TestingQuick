
import Foundation
class TimeDistributionWidgetNegativeTimeEntryScenarioModel {
    var company:String?
    var companyLoginField:String?
    
    var user:User?
    var supervisor:User?
    var hours:String?
    var standardTimesheetRowAttributes:StandardTimesheetRowAttributes?
    init(data:Data){
        let json = JSON(data: data)
        
        let password            = "Password123"
        let companyKey          = json["tenant"]["companyKey"].stringValue
        let userLoginName       = json["user"]["loginName"].stringValue
        let supervisorLoginName = json["supervisor"]["loginName"].stringValue
        let clientName          = json["client"]["name"].stringValue
        let projectName         = json["project"]["name"].stringValue
        let taskName            = json["tasks"][0]["name"].stringValue
        let loginCompanyName    = json["endpoint"]["mobileLogin"].stringValue
        
        self.companyLoginField = loginCompanyName
        self.company = companyKey
        self.user = User(username: userLoginName, password: password)
        self.supervisor = User(username: supervisorLoginName, password: password)
        self.hours = "-8.00"
        self.standardTimesheetRowAttributes = StandardTimesheetRowAttributes(client: clientName,project: projectName,task: taskName, taskAllowed: false)
        
    }
}
