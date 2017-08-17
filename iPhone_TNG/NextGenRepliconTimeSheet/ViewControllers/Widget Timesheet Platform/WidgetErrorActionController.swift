
import UIKit

// MARK: <WidgetErrorActionControllerInterface>

@objc protocol WidgetErrorActionControllerInterface{
    func setupWithWidgetWithUri(_ widgetUri:String!,delegate:WidgetErrorActionControllerDelegate!)
}

// MARK: <WidgetErrorActionControllerDelegate>

@objc protocol WidgetErrorActionControllerDelegate{
    func widgetErrorActionController(_ controller:WidgetErrorActionController, intendsToReloadWidgetWithUri uri:String!)
}

class WidgetErrorActionController: UIViewController,WidgetErrorActionControllerInterface {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupWithWidgetWithUri(_ widgetUri:String!,delegate:WidgetErrorActionControllerDelegate!){
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
