
import Foundation

class TimeDistributionWithApprovalHistoryScenarioService : BaseScenarioService{

    func setup()-> TimeDistributionWithApprovalHistoryScenarioModel?{
        let serviceUrl = "\(baseUrl)/scenarios/gen4timedistributionapprovalhistorywidget/setup";
        let data = requestSynchronousDataWithURLString(serviceUrl)
        return TimeDistributionWithApprovalHistoryScenarioModel(data: data!)
    }

    func tearDown(_ companyKey : String) {
        let serviceUrl = "\(baseUrl)/scenarios/gen4timedistributionapprovalhistorywidget/teardown?companyKey=\(companyKey)";
        requestSynchronousDataWithURLString(serviceUrl)
    }
    
}
