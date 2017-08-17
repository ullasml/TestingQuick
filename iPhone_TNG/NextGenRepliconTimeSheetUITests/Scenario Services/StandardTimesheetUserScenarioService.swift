
import Foundation

class StandardTimesheetUserScenarioService : BaseScenarioService{

    func setup()-> StandardTimesheetUserScenarioModel?{
        let serviceUrl = "\(baseUrl)/scenarios/timesheet/setup";
        let data = requestSynchronousDataWithURLString(serviceUrl)
        return StandardTimesheetUserScenarioModel(data: data!)
    }

    func tearDown(_ companyKey : String) {
        let serviceUrl = "\(baseUrl)/scenarios/timesheet/teardown?companyKey=\(companyKey)";
        requestSynchronousDataWithURLString(serviceUrl)
    }

}
