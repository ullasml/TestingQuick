import Foundation

class TimeDistributionWithTimeOffWidgetScenarioService : BaseScenarioService{

    func setup()-> TimeDistributionWithTimeOffWidgetScenarioModel?{
        let serviceUrl = "\(baseUrl)/scenarios/timedistpaytimeoff/setup";
        let data = requestSynchronousDataWithURLString(serviceUrl)
        return TimeDistributionWithTimeOffWidgetScenarioModel(data: data!)
    }

    func tearDown(_ companyKey : String) {
        let serviceUrl = "\(baseUrl)/scenarios/timedistpaytimeoff/teardown?companyKey=\(companyKey)";
        requestSynchronousDataWithURLString(serviceUrl)
    }
    
}
