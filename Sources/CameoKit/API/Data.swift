//
//  DataAsync.swift
//  CameoKit
//
//  Created by Todd on 4/18/20.
//

import Foundation

//MARK: Data
internal func CommanderData(endpoint: String, method: String, DataHandler: @escaping DataHandler )  {
    guard let url = URL(string: endpoint) else { DataHandler(.none); return}
    
    var urlReq = URLRequest(url: url)
    urlReq.httpMethod = "GET"
    urlReq.timeoutInterval = TimeInterval(15)
    urlReq.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    
    let task = URLSession.shared.dataTask(with: urlReq ) { ( data, _, _ ) in
        
        guard
            let d = data
            else { DataHandler(.none); return }
        
        DataHandler(d)
        
    }
    
    task.resume()
}
