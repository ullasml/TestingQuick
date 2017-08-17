
import Foundation
class ViewMyTimesheetsAstroUserScenarioService : BaseScenarioService{

    func setup()-> ViewMyTimesheetsAstroUserScenarioModel?{
        let serviceUrl = "\(baseUrl)/scenarios/viewtimesheetforsimplepunchwidgetscenario/setup";
        let data = requestSynchronousDataWithURLString(serviceUrl)
        return ViewMyTimesheetsAstroUserScenarioModel(data: data!)
    }

    func tearDown(_ companyKey : String) {
        let serviceUrl = "\(baseUrl)/scenarios/viewtimesheetforsimplepunchwidgetscenario/teardown?companyKey=\(companyKey)";
        requestSynchronousDataWithURLString(serviceUrl)
    }

}
