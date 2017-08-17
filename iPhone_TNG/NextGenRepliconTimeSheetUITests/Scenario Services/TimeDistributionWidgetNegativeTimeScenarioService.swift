
import Foundation

class TimeDistributionWidgetNegativeTimeScenarioService : BaseScenarioService {
    
    func setup()-> TimeDistributionWidgetNegativeTimeEntryScenarioModel?{
        let serviceUrl = "\(baseUrl)/scenarios/gen4timedistnegentrypay/setup";
        let data = requestSynchronousDataWithURLString(serviceUrl)
        return TimeDistributionWidgetNegativeTimeEntryScenarioModel(data: data!)
    }
    
    func tearDown(_ companyKey : String) {
        let serviceUrl = "\(baseUrl)/scenarios/gen4timedistnegentrypay/teardown?companyKey=\(companyKey)";
        requestSynchronousDataWithURLString(serviceUrl)
    }
}
