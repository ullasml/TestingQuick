
import Foundation

class ExtendedInOutTimesheetWithUDFScenarioService : BaseScenarioService{

    func setup()-> ExtendedInOutTimesheetWithUDFScenarioModel?{
        let serviceUrl = "\(baseUrl)/scenarios/gen3extendedinouttimesheetwithudf/setup";
        let data = requestSynchronousDataWithURLString(serviceUrl)
        return ExtendedInOutTimesheetWithUDFScenarioModel(data: data!)
    }

    func tearDown(_ companyKey : String) {
        let serviceUrl = "\(baseUrl)/scenarios/gen3extendedinouttimesheetwithudf/teardown?companyKey=\(companyKey)";
        requestSynchronousDataWithURLString(serviceUrl)
    }
    
}
