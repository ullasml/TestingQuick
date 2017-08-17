
import Foundation

@objc protocol URLSessionClientObserver:AnyObject{
    func URLSessionClientDidRequestData()
}

@objc class URLSessionClient:NSObject,URLSessionClientProtocol {

    func addListener(_ observer: URLSessionClientObserver) {
    }
    func requestWithURL(_ url: String) -> KSPromise<AnyObject>?{

        let deferred = KSDeferred<AnyObject>()

        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) -> Void in
            if error != nil {

                OperationQueue.main.addOperation({ 
                    deferred.rejectWithError(error);
                })
            }
            else{
                OperationQueue.main.addOperation({
                    deferred.resolve(withValue: data as AnyObject);
                })
            }
        })
        task.resume()
        return deferred.promise;
    }
}
