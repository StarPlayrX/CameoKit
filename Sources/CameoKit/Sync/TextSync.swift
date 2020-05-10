import Foundation

//MARK: Read a text data Synchronously
internal func TextSync(endpoint: String, method: String ) -> String {
    
    let textsync_error = "textSync-error="
    
    guard let url = URL(string: endpoint) else {return "\(textsync_error)=0" }
    
    //MARK: - for Sync
    let semaphore = DispatchSemaphore(value: 0)
    
    var syncData = String()
    
    var urlReq = URLRequest(url: url)
    urlReq.httpMethod = "GET"
    urlReq.timeoutInterval = TimeInterval(2)
    
    let task = URLSession.shared.dataTask(with: urlReq ) { ( returndata, _, _ ) in
        
        if let d = returndata {
            syncData =  String(data: d, encoding: .utf8) ?? "\(textsync_error)=1"
        } else {
            syncData = "\(textsync_error)=2"
        }
        
        //MARK: - for Sync
        semaphore.signal()
    }
    
    task.resume()
    
    //MARK: - for Sync
    _ = semaphore.wait(timeout: .distantFuture)
    
    return syncData
}

