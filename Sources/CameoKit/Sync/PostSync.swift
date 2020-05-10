//
//  PostSync.swift
//  Camouflage
//
//  Created by Todd on 1/25/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation

typealias PostReturnTuple = (message: String, success: Bool, data: Dictionary<String, Any>, response: HTTPURLResponse )


internal func PostSync(request: Dictionary<String, Any>, endpoint: String, method: String) -> PostReturnTuple  {
    
    //MARK - for Sync
    let semaphore = DispatchSemaphore(value: 0)
    var syncData : PostReturnTuple = (message: "", success: false, data: [:], response: HTTPURLResponse() )
    let http_method = "POST"
    let time_out = 10
    
    func getURLRequest() -> URLRequest? {
        if let url = URL(string: endpoint) {
            var urlReq = URLRequest(url: url)
            urlReq.httpBody = try? JSONSerialization.data(withJSONObject: request, options: .prettyPrinted)
            urlReq.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlReq.httpMethod = http_method
            urlReq.timeoutInterval = TimeInterval(time_out)
            urlReq.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0.2 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
            return urlReq
        }
        
        return nil
    }
    
  
    
    if let urlReq = getURLRequest() {
        
        let task = URLSession.shared.dataTask(with: urlReq ) { ( data, response, _ ) in
            
            //MARK: Here we are chaining multiple if lets, you can also be lazy with names one time only for each one
            if let response = response, let data = data, let http_url_response = response as? HTTPURLResponse {
                
                //MARK: Here we are unwrapping the result directly in the try statement
                do { if let result =
                   
                    try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String, Any> {
                     syncData = (message: method + " was successful.", success: true, data: result, response: http_url_response ) as PostReturnTuple
                    }
                } catch {
                    print(error)
                    syncData = (message: method + " failed in do try catch.", success: false, data: ["": ""], response: http_url_response ) as PostReturnTuple
                }
            }
            
            //MARK - for Sync
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: .distantFuture)
    }
    
    return syncData
    
}





