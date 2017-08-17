
import Foundation

class StandardTimesheetWithUDFUserScenarioService : BaseScenarioService{
    
    func setup()-> StandardTimesheetWithUDFUserScenarioModel?{
        let serviceUrl = "\(baseUrl)/scenarios/gen3standardtimesheetwithudf/setup";
        let data = requestSynchronousDataWithURLString(serviceUrl)
        return StandardTimesheetWithUDFUserScenarioModel(data: data!)
    }
    
    func tearDown(_ companyKey : String) {
        let serviceUrl = "\(baseUrl)/scenarios/gen3standardtimesheetwithudf/teardown?companyKey=\(companyKey)";
        requestSynchronousDataWithURLString(serviceUrl)
    }
    
}
