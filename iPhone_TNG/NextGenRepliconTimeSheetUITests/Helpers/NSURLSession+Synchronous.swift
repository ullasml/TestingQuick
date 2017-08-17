
// Ref: https://gist.github.com/erica/baa8a187a5b4796dab27

import Foundation


/// NSURLSession synchronous behavior
/// Particularly for playground sessions that need to run sequentially
public extension URLSession {

    /// Return data from synchronous URL request
    public static func requestSynchronousData(_ request: URLRequest) -> Data? {
        var data: Data? = nil
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            taskData, _, error -> () in
            data = taskData
            if data == nil, let error = error {print(error)}
            semaphore.signal();
        })
        task.resume()
        semaphore.wait(timeout: DispatchTime.distantFuture)
        return data
    }

    /// Return data synchronous from specified endpoint
    public static func requestSynchronousDataWithURLString(_ requestString: String) -> Data? {
        guard let url = URL(string:requestString) else {return nil}
        let request = URLRequest(url: url,cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,timeoutInterval: 1200)
        return URLSession.requestSynchronousData(request)
    }

    /// Return JSON synchronous from URL request
    public static func requestSynchronousJSON(_ request: URLRequest) -> AnyObject? {
        guard let data = URLSession.requestSynchronousData(request) else {return nil}
        return try! JSONSerialization.jsonObject(with: data, options: []) as AnyObject?
    }

    /// Return JSON synchronous from specified endpoint
    public static func requestSynchronousJSONWithURLString(_ requestString: String) -> AnyObject? {
        guard let url = URL(string: requestString) else {return nil}
        let request = NSMutableURLRequest(url:url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return URLSession.requestSynchronousJSON(request as URLRequest)
    }
}
