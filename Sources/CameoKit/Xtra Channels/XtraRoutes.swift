//
//  XtraRoutes.swift
//  CameoKit
//
//  Created by Todd on 3/31/19.
//

import PerfectHTTP
import PerfectHTTPServer
import Foundation


//Encpytion Key for Xtra Channels Sirius XM
internal func keyFourRoute(request: HTTPRequest, _ response: HTTPResponse) {
    let key = keyData
    response.setBody(bytes: [UInt8](key)).setHeader(.contentType, value:"application/octet-stream").completed()
}



internal func xtraAudioRoute(request: HTTPRequest, _ response: HTTPResponse) {
    let clip = request.urlVariables[routeTrailingWildcardKey]
    print(clip)
    response.setBody( bytes: [UInt8]( xtraAudio( data: clip! ) ) ).setHeader(.contentType, value:"audio/aac").completed()
}


//xtra session
internal func xtraSessionRoute(request: HTTPRequest, _ response: HTTPResponse) {
    
    if let body = request.postBodyString {
        
        do {
            let json = try body.jsonDecode() as? [String:Any]
            let channelid = json?["channelid"] as? String ?? ""
            let userid = json?["userid"] as? String ?? ""
            
            if channelid != "" && userid != "" {
                //Session func
                let returnData = XtraSession(channelid: channelid, userid: userid)
                let jayson = ["data": returnData, "message": "coolbeans", "success": true] as [String : Any]
                try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
            } else {
                let jayson = ["data": "", "message": "Missing channelid, userid or key.", "success": false] as [String : Any]
                try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
            }
        } catch {
            let jayson = ["data": "", "message": "Syntax Error or invalid JSON.", "success": false] as [String : Any]
            try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
        }
        
    } else {
        let jayson = ["data": "", "message": "Session may be invalid, try logging in first.", "success": false] as [String : Any]
        try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
    }
}

//xtra playlist2
internal func xtraPlaylistRoute(request: HTTPRequest, _ response: HTTPResponse) {
    // let playlist = xtraTune(channelid: "", userid: "")
    // response.setBody(string: playlist).setHeader(.contentType, value:"application/x-mpegURL").completed()
}

//xtra Tune Route
internal func xtraTuneRoute(request: HTTPRequest, _ response: HTTPResponse) {
    if let channelGuid = request.urlVariables["channelGuid"] {
        response.setBody( bytes: [UInt8]( xtraTuneData(channelGuid: channelGuid) )).setHeader(.contentType, value:"application/octet-stream").completed()
    } else {
        response.completed()
    }
    response.completed()
}
