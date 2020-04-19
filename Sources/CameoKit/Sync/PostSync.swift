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
        
        let task = URLSession.shared.dataTask(with: urlReq ) { ( returndata, resp, error ) in
            
            if let r = resp as! HTTPURLResponse?, r.statusCode == 200, let rdata = returndata {
                
                do { let result =
                    try JSONSerialization.jsonObject(with: rdata, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary<String, Any>
                    
                    syncData = (message: method + " was successful.", success: true, data: result, response: r  as HTTPURLResponse  ) as PostReturnTuple
                } catch {
                    print(error)
                    syncData = (message: method + " failed in do try catch.", success: false, data: ["": ""], response: r as HTTPURLResponse )
                }
            } else {
                //we always require 200 on the post, anything else is a failure
                
                if resp != nil {
                    syncData = (message: method + " failed, see response.", success: false, data: ["": ""], response: resp as! HTTPURLResponse ) as PostReturnTuple
                } else {
                    syncData = (message: method + " failed, no response.", success: false, data: ["": ""], response: HTTPURLResponse() ) as PostReturnTuple
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





