//
//  CKNetworkability.swift
//  CameoKit
//
//  Created by Todd Bruss on 5/4/19.
//

import Network
@available(OSX 10.14, *)
let CKmonitor = NWPathMonitor()
var CKnetworkIsConnected = Bool()
var CKnetworkIsWiFi = Bool()

public class CKNetworkability {
    
    func start() {
        
        if #available(OSX 10.14, *) {
            CKmonitor.pathUpdateHandler = { path in
                
                CKnetworkIsConnected = (path.status == .satisfied)
                
                CKnetworkIsWiFi = path.usesInterfaceType(.wifi)
                
            }
        } else {
            // Fallback on earlier versions
        }
        
        let queue = DispatchQueue(label: "CKmonitor")
        if #available(OSX 10.14, *) {
            CKmonitor.start(queue: queue)
        } else {
            // Fallback on earlier versions
        }
    }
}
