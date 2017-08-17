

import UIKit

// MARK: <ViewHelperInterface>

@objc protocol ViewHelperInterface{
    func isViewControllerCurrentlyOnWindow(_ controller: UIViewController) -> Bool
}

class ViewHelper: NSObject,ViewHelperInterface {
    
    func isViewControllerCurrentlyOnWindow(_ controller: UIViewController) -> Bool{
        return (controller.isViewLoaded && (controller.view.window != nil))
    }

}
