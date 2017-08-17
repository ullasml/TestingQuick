import Foundation

class SimplePunchOEFScenarioService: BaseScenarioService {
        
    func setup()-> SimplePunchOEFScenarioModel?{
        let serviceUrl = "\(baseUrl)/scenarios/simplepunchwidgetwithoefs/setup";
        let data = requestSynchronousDataWithURLString(serviceUrl)
        return SimplePunchOEFScenarioModel(data:data!)
    }
    
    func tearDown(_ companyKey : String) {
        let serviceUrl = "\(baseUrl)/scenarios/simplepunchwidgetwithoefs/teardown?companyKey=\(companyKey)";
        requestSynchronousDataWithURLString(serviceUrl)
    }
    
}
