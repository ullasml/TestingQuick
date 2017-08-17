
import Foundation

class TimeDistributionWidgetScenarioService : BaseScenarioService {
    
    func setup()-> TimeDistributionWidgetScenarioModel?{
        let serviceUrl = "\(baseUrl)/scenarios/timedistribution/setup";
        let data = requestSynchronousDataWithURLString(serviceUrl)
        return TimeDistributionWidgetScenarioModel(data: data!)
    }

    func tearDown(_ companyKey : String) {
        let serviceUrl = "\(baseUrl)/scenarios/timedistribution/teardown?companyKey=\(companyKey)";
        requestSynchronousDataWithURLString(serviceUrl)
    }
}
