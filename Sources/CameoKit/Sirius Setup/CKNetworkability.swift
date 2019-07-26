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
            
            //print("network is connected:" + String(CKnetworkIsConnected))
            
            CKnetworkIsWiFi = path.usesInterfaceType(.wifi)
            
            //print("uses wifi:" + String(CKnetworkIsWiFi))
        }
        
        let queue = DispatchQueue(label: "CKmonitor")
        CKmonitor.start(queue: queue)
    }
}
