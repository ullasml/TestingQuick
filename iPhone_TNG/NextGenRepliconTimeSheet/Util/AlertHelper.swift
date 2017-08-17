//
//  AlertHelper.swift
//  CloudClock
//
//  Created by Prithiviraj Jayapal on 24/01/17.
//  Copyright © 2017 Replicon Inc. All rights reserved.
//

import UIKit
@objc class AlertHelper: NSObject{
    
    // MARK: Public Methods
    // MARK: Show Alert on Target Controller
    
    /*** Convenience Methods are configured to show only OK button. Use the base method when in need of custom title. ***/
    static func showAlertOnTarget(_ target: UIViewController, message: String?){
        showAlertOnTarget(target, message: message, title: nil, handler: nil)
    }
    
    static func showAlertOnTarget(_ target: UIViewController, message: String?, title: String?){
        showAlertOnTarget(target, message: message, title: title, handler: nil)
    }
    
    static func showAlertOnTarget(_ target: UIViewController, message: String?, title: String?, handler: (() -> Void)?) {
        target.hideAlertIfVisible()
        let alert = configureAlert(message: message, title: title, cancelTitle:ConstStrings.ok, handler: handler)
        target.present(alert, animated: true, completion: nil)
        
    }
    
    /*** Method is configured for two options with its respective handler ***/
    static func showAlertOnTarget(_ target: UIViewController, message: String?, title: String?, cancelButtonTitle: String?, cancelButtonHandler: (() -> Void)? = nil, otherButtonTitle: String?, otherButtonHandler: (() -> Void)? = nil) {
        target.hideAlertIfVisible()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { (alert) in
            print("===== > Outside cancelAction completionHandler")
            if let completionHandler = cancelButtonHandler{
                completionHandler()
                print("===== > Inside cancelAction completionHandler")
            }
        }
        alert.addAction(cancelAction)
        
        let otherAction = UIAlertAction(title: otherButtonTitle, style: .default) { (alert) in
            print("===== > Outside otherAction completionHandler")
            if let completionHandler = otherButtonHandler{
                completionHandler()
                print("===== > Inside otherAction completionHandler")
            }
        }
        alert.addAction(otherAction)
        target.present(alert, animated: true, completion: nil)
        
    }
    
    
    // MARK: Show Alert on TopViewController (Eg: To show from NSObject)
    
    static func showAlert(message: String?){
        hideAlertIfVisible()
        let alert = configureAlert(message: message, title: nil, cancelTitle:ConstStrings.ok, handler: nil)
        alert.show()
    }
    
    static func showAlert(message: String?, title: String?){
        hideAlertIfVisible()
        let alert = configureAlert(message: message, title: title, cancelTitle:ConstStrings.ok, handler: nil)
        alert.show()
    }
    
    static func showAlert(message: String?, title: String?, handler: (() -> Void)?){
        hideAlertIfVisible()
        let alert = configureAlert(message: message, title: title, cancelTitle:ConstStrings.ok, handler: handler)
        alert.show()
    }
    
    static func showAlert(message: String?, title: String?, cancelTitle:String?, handler: (() -> Void)?){
        hideAlertIfVisible()
        let alert = configureAlert(message: message, title: title, cancelTitle:cancelTitle, handler: handler)
        alert.show()
    }
    
    
    // MARK: Show Offline Alert
    
    static func showOfflineAlert(){
        showAlert(message: ConstStrings.deviceOfflineMsg)
    }
    
    static func showOfflineAlertOnTarget(_ target: UIViewController){
        hideAlertIfVisible()
        showAlertOnTarget(target, message: ConstStrings.deviceOfflineMsg, title: "")
    }
    
    // MARK: Private Methods
    
    // MARK: Base Configuration
    
    private static func configureAlert(message: String?, title: String?, cancelTitle:String?, handler: (() -> Void)?) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: cancelTitle, style: .default) { (alert) in
            print("===== > Outside completionHandler")
            if let completionHandler = handler{
                completionHandler()
                print("===== > Inside completionHandler")
            }
        }
        alert.addAction(action)
        return alert
    }
    
    private static func hideAlertIfVisible() {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            hideFromController(controller: rootVC)
        }
    }
    
    private static func hideFromController(controller: UIViewController) {
        if  let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
            hideFromController(controller: visibleVC)
        } else {
            if  let tabVC = controller as? UITabBarController,
                let selectedVC = tabVC.selectedViewController {
                hideFromController(controller: selectedVC)
            } else {
                print("Controller ==> " + "\(controller)")
                controller.hideAlertIfVisible()
            }
        }
    }
    
    
}


// MARK: Extensions

extension UIAlertController {
    
    
    func show() {
        present(animated: true, completion: nil)
    }
    
    func present(animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            presentFromController(controller: rootVC, animated: animated, completion: completion)
        }
    }
    
    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if  let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
            presentFromController(controller: visibleVC, animated: animated, completion: completion)
        } else {
            if  let tabVC = controller as? UITabBarController,
                let selectedVC = tabVC.selectedViewController {
                presentFromController(controller: selectedVC, animated: animated, completion: completion)
            } else {
                print("Controller ==> " + "\(controller)")
                controller.present(self, animated: animated, completion: completion)
            }
        }
    }
}

extension UIViewController {
    func hideAlertIfVisible(){
        if self.presentedViewController != nil {
            
            let thePresentedVC : UIViewController? = self.presentedViewController as UIViewController?
            
            if thePresentedVC != nil {
                if let _ : UIAlertController = thePresentedVC as? UIAlertController {
                    print("Alert already on the screen !")
                    self.dismiss(animated: false, completion: nil)
                }
            }
        }
    }
    
    func getPresentingController()->UIViewController{
        
        let thePresentedVC : UIViewController? = self.presentedViewController as UIViewController?
        
        if let presentedVC = thePresentedVC{
            if let _ : UIAlertController = thePresentedVC as? UIAlertController {
                print("Alert not necessary, already on the screen ! : " + "\(self)")
                return self
            } else {
                //There is another ViewController presented but it is not an UIAlertController, so do your UIAlertController-Presentation with this (presented) ViewController
                print("Alert comes up via another presented VC, e.g. a PopOver : " + "\(presentedVC)")
                return thePresentedVC!
            }
        }
        return self
    }
}


