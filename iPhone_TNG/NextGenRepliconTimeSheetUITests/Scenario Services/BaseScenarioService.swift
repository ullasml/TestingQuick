
import Foundation

class BaseScenarioService {

    let baseUrl = "http://localhost:8888";

    func requestSynchronousDataWithURLString(_ urlString:String)-> Data?{
        return URLSession.requestSynchronousDataWithURLString(urlString)
    }

}
