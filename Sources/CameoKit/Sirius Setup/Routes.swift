import PerfectHTTP
import PerfectHTTPServer
import Foundation


//SmallChannelArt as Data Stream (0.8 Megs)
internal func smallChannelArt(request: HTTPRequest, _ response: HTTPResponse) {
    response.setBody(bytes: [UInt8](smallChannelLineUp)).setHeader(.contentType, value:"application/octet-stream").completed()
}

//LargeChannelArt as Data Stream (1.24 Megs)
internal func largeChannelArt(request: HTTPRequest, _ response: HTTPResponse) {
    response.setBody(bytes: [UInt8](largeChannelLineUp)).setHeader(.contentType, value:"application/octet-stream").completed()
}

//Encryption Key for main streams Sirius XM
internal func keyOneRoute(request: HTTPRequest, _ response: HTTPResponse) {
    var key : String? = "" //default to empty string
    let userid = request.urlVariables["userid"]
    
    if  userid != nil && user.key.count > 1 {
        key = user.key
    }
    
    response.setBody(bytes: [UInt8](Data(base64Encoded: key!)!)).setHeader(.contentType, value:"application/octet-stream").completed()
    key = nil
}

internal func PDTRoute(request: HTTPRequest, _ response: HTTPResponse) {
    let userid = request.urlVariables["userid"]  
    let artistSongData = PDT(MemBase: MemBase)
    let jayson = ["data": artistSongData, "message": "0000", "success": true] as [String : Any]
    try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
}

//login
internal func loginRoute(request: HTTPRequest, _ response: HTTPResponse)  {
    
    var returnData : (success: Bool, message: String, data: String) = (success: false, message: "", data: "")
    
    if let body = request.postBodyString {
        
        do {
            let json = try body.jsonDecode() as? [String:Any]
            let user = json?["user"] as? String ?? ""
            let pass = json?["pass"] as? String ?? ""
            
            if user != "" || pass != "" {
                //Login func
                returnData = Login(username: user, pass: pass)
                
                let jayson = ["data": returnData.data, "message": returnData.message, "success": returnData.success] as [String : Any]
                try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
            } else {
                let jayson = ["data": "", "message": "Missing username or password / 'user' or 'pass' key.", "success": false] as [String : Any]
                try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
            }
            
        } catch {
            let jayson = ["data": "", "message": "Syntax Error or invalid JSON", "success": false] as [String : Any]
            try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
        }
        
    } else {
        let jayson = ["data": "", "message": returnData.message, "success": false] as [String : Any]
        try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
    }
}

//session
internal func sessionRoute(request: HTTPRequest, _ response: HTTPResponse) {
    
    if let body = request.postBodyString {
        
        do {
            let json = try body.jsonDecode() as? [String:Any]
            let channelid = json?["channelid"] as? String ?? ""
            let userid = json?["userid"] as? String ?? ""

            if channelid != "" && userid != "" {
                //Session func
                let returnData = Session(channelid: channelid, userid: userid)
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


internal func autoLoginRoute(request: HTTPRequest, _ response: HTTPResponse)  {
    
    var returnData : (success: Bool, message: String, data: String) = (success: false, message: "", data: "")
    
    if let body = request.postBodyString {
        
        do {
            let json = try body.jsonDecode() as? [String:Any]
            let user = json?["user"] as? String ?? ""
            let pass = json?["pass"] as? String ?? ""
            
            if user != "" || pass != "" {
                //Login func
                returnData = Login(username: user, pass: pass)
                
                if returnData.success {
                    let sessionData = Session(channelid: "siriushits1", userid: returnData.data)
                    print(sessionData)
                    let channelData = Channels(channeltype: "numbers", userid: returnData.data)
                    print(channelData.success)
                }
         
                let jayson = ["data": returnData.data, "message": returnData.message, "success": returnData.success] as [String : Any]
                try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
            } else {
                let jayson = ["data": "", "message": "Missing username or password / 'user' or 'pass' key.", "success": false] as [String : Any]
                try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
            }
            
        } catch {
            let jayson = ["data": "", "message": "Syntax Error or invalid JSON", "success": false] as [String : Any]
            try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
        }
        
    } else {
        let jayson = ["data": "", "message": returnData.message, "success": false] as [String : Any]
        try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
    }
}



//channels
internal func channelsRoute(request: HTTPRequest, _ response: HTTPResponse) {
    
    if let body = request.postBodyString {
        
        do {
            let json = try body.jsonDecode() as? [String:Any]
            let channeltype = json?["channeltype"] as? String ?? ""
            let userid = json?["userid"] as? String ?? ""

        
            if channeltype != "" && userid != "" {
                //Session func
                let returnData = Channels(channeltype: channeltype, userid: userid)
                
                let jayson = ["data": returnData.data, "message": "Returning data.", "success": true, "categories": returnData.categories] as [String : Any]
                try? _ = response.setBody(json: jayson)
                response.setHeader(.contentType, value:"application/json")
                .completed()
            } else {
                let jayson = ["data": "", "message": "Missing a ChannelType, or key. Try SiriusXM", "success": false] as [String : Any]
                try! response.setBody(json: jayson)
                response.setHeader(.contentType, value:"application/json")
                .completed()
            }
        } catch {
            let jayson = ["data": "", "message": "Syntax Error, invalid JSON.", "success": true] as [String : Any]
            try? _ = response.setBody(json: jayson)
            response.setHeader(.contentType, value:"application/json")
                .completed()
        }
       
    } else {
        let jayson = ["data": "", "message": "Session may be invalid, try logging in first.", "success": false] as [String : Any]
        try? _ = response.setBody(json: jayson)
        response.setHeader(.contentType, value:"application/json")
        .completed()
    }
}

//playlist
internal func playlistRoute(request: HTTPRequest, _ response: HTTPResponse) {
    let playlistRequest = request.urlVariables[routeTrailingWildcardKey]
    let userid = request.urlVariables["userid"]
    let filename = String(playlistRequest!.dropFirst())
    let channelArray = filename.split(separator: ".")
    
    var channel : String? = ""
    
    if channelArray.count > 1 {
        channel = String(channelArray[0])
    }
    
    if channel != "" && userid != nil && playlistRequest != nil && user.channels.count > 1 {
        let ch = user.channels[channel!] as? NSDictionary
        
        if ch != nil {
            let channelid = ch!["channelId"] as? String
            user.channel = channelid!
            
            if channelid != nil && userid != nil {
                
                if channel != lastChannel && !lock {
                    //clear MemBase on channel change
                    //MemBase = Dictionary<String, Any>()
                } else {
                    lock = true
                }
                
                lastChannel = channel!

                _ = Session(channelid: channelid!, userid: userid!)
                
                let playlist = Playlist(channelid: channelid!, userid: userid!)
                response.setBody(string: playlist).setHeader(.contentType, value:"application/x-mpegURL").completed()

               

            } else {
                response.setBody(string: "Channel is missing.\n\r").setHeader(.contentType, value:"text/plain").completed()
            }
            
           
        } else {
            response.setBody(string: "The channel does not exist.\n\r").setHeader(.contentType, value:"text/plain").completed()
        }
    } else {
        response.setBody(string: "Incorrect Parameter.\n\r").setHeader(.contentType, value:"text/plain").completed()
    }
}

//ping
internal func pingRoute(request: HTTPRequest, _ response: HTTPResponse) {
    response.setBody(string: "pong").setHeader(.contentType, value:"text/plain").completed()
}


internal func audioRoute(request: HTTPRequest, _ response: HTTPResponse) {
    let audio = request.urlVariables[routeTrailingWildcardKey]
    let userid = request.urlVariables["userid"]

    if audio != nil && userid != nil {
        let filename = String(audio!.dropFirst())
        response.setBody( bytes: [UInt8]( Audio( data: filename, channelId: user.channel, userid: userid! ) )).setHeader(.contentType, value:"audio/aac")
            .completed()
    } else {
        response.completed()
    }
    
}


