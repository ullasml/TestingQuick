

import Foundation

@objc protocol URLSessionClientProtocol  {
    func addListener(_ observer: URLSessionClientObserver)
    func requestWithURL(_ url: String) -> KSPromise<AnyObject>?
}
