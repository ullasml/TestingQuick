//
//  Presenter.swift
//  Replicon
//
//  Created by Ullas ML on 2017-07-07.
//  Copyright © 2017 Ullas ML. All rights reserved.
//

import UIKit

@objc protocol PresenterProtocol  {
    func fetchTimesheet(_ url: String) -> KSPromise<AnyObject>?
}

class Presenter: NSObject,PresenterProtocol {
    
    func fetchTimesheet(_ url: String) -> KSPromise<AnyObject>? {
        let deferred = KSDeferred<AnyObject>()
        return deferred.promise
    }

}
