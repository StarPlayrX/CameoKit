//
//  DataSync.swift
//  CameoKit
//
//  Created by Todd on 4/18/20.
//

import Foundation

internal func DataSyncX(endpoint: String, method: String ) -> Data {
    guard let url = URL(string: endpoint) else {return Data() }

    //MARK: for Sync
    let semaphore = DispatchSemaphore(value: 0)
    
    var syncData : Data? = Data()

    var urlReq = URLRequest(url: url)
    urlReq.httpMethod = "GET"
    urlReq.timeoutInterval = TimeInterval(10)
    
    let task = URLSession.shared.dataTask(with: urlReq ) { ( data, response, error ) in
        
        if let data = data { syncData = data }
        
        //MARK: for Sync
        semaphore.signal()
    }
    
    task.resume()
    
    //MARK: for Sync
    _ = semaphore.wait(timeout: .distantFuture)
    
    if let data = syncData {
        return data
    }
    
    return Data()
}
