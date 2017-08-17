
import Foundation

class AstroUserScenarioService : BaseScenarioService{
    
    func setup()-> AstroUserScenarioModel?{
        let serviceUrl = "\(baseUrl)/scenarios/simplepunchwidget/setup";
        let data = requestSynchronousDataWithURLString(serviceUrl)
        return AstroUserScenarioModel(data:data!)
    }
    
    func tearDown(_ companyKey : String) {
        let serviceUrl = "\(baseUrl)/scenarios/simplepunchwidget/teardown?companyKey=\(companyKey)";
        requestSynchronousDataWithURLString(serviceUrl)
    }
    
}
