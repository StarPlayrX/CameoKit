//
//  CKNetworkability.swift
//  CameoKit
//
//  Created by Todd Bruss on 5/4/19.
//

import Network
let CKmonitor = NWPathMonitor()
var CKnetworkIsConnected = Bool()
var CKnetworkIsWiFi = Bool()

public class CKNetworkability {
    
    func start() {
        
        CKmonitor.pathUpdateHandler = { path in
            
            CKnetworkIsConnected = (path.status == .satisfied)
            
            CKnetworkIsWiFi = path.usesInterfaceType(.wifi)
            
        }
   
        let queue = DispatchQueue(label: "CKmonitor")
        CKmonitor.start(queue: queue)
    }
}
