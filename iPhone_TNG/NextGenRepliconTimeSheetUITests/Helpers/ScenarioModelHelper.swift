

import Foundation

class ScenarioModelHelper{

    func dataFromFile() -> Data {
        let specsBundle: Bundle = Bundle(for: type(of: self))
        let path: String = specsBundle.path(forResource: "simulated_response", ofType: "json")!
        do{
            let data = try Data.init(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            return data
        }catch{
            return Data()
        }
    }


}
