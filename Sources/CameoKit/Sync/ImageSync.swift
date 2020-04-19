//
//  DataSync.swift
//  Cameoflage
//
//  Created by Todd on 1/27/19.
//

import Foundation

internal func ImageSync(endpoint: String, method: String ) -> Data {
    
    //MARK - for Sync
    let semaphore = DispatchSemaphore(value: 0)
    
    var syncData = Data()
    
    let http_method = "GET"
    let time_out = 30
    
    func getURLRequest() -> URLRequest? {
        if let url = URL(string: endpoint) {
            var urlReq = URLRequest(url: url)
            urlReq.httpMethod = http_method
            urlReq.timeoutInterval = TimeInterval(time_out)
            urlReq.cachePolicy = .returnCacheDataElseLoad

            return urlReq
        }
        
        return nil
    }
    
    if let request = getURLRequest() {
        let task = URLSession.shared.dataTask(with: request ) { ( data, response, error ) in
        
            if  let result = response as! HTTPURLResponse?, result.statusCode == 200, let data = data  {
                syncData = data
            }
            
            //MARK - for Sync
            semaphore.signal()
        }
        
        task.resume()
    }


    //MARK - for Sync
    _ = semaphore.wait(timeout: .distantFuture)
    

	return syncData
}
