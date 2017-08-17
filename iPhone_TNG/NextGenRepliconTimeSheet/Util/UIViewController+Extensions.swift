//
//  UIViewController+Extensions.swift
//  NextGenRepliconTimeSheet
//
//  Created by Ravikumar Duvvuri on 02/06/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import Foundation

extension UIViewController {
    var isModal: Bool {
        return self.presentingViewController?.presentedViewController == self
            || (self.navigationController != nil && self.navigationController?.presentingViewController?.presentedViewController == self.navigationController)
            || self.tabBarController?.presentingViewController is UITabBarController
    }
}
