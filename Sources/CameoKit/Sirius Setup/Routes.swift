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


//MARK: Decryption Key for main streams Sirius XM
internal func keyOneRoute(request: HTTPRequest, _ response: HTTPResponse) {
    
    if let data = Data(base64Encoded: userX.key) {
        response.setBody(bytes: [UInt8](data)).setHeader(.contentType, value:"application/octet-stream").completed()
    }
}


internal func PDTRoute(request: HTTPRequest, _ response: HTTPResponse) {
    
    if !userX.channel.isEmpty {
        let epoint = nowPlayingLiveXX(channelid: userX.channel)
        
        nowPlayingLiveAsync(endpoint: epoint) { data in
            if let data = data {
                processNPL(data: data)
            }
        }
    }
    
    func fallback() {
        var artist_song_data = [String : Any ]()
        if userX.channels.count > 1 {
            for ( key, value ) in userX.channels {
                
                let v = value as! [String: Any]
                let name = v["name"] as! String
                
                //Substitute text for when channel guide is offline
                artist_song_data[key] = ["image" : "", "artist": key, "song" : name]
            }
        } else {
            for i in 0...1000 {
                artist_song_data["\(i)"] = ["image" : "", "artist" : "StarPlayrX", "song" : "iOS Best Sat Radio Player"]
            }
        }
        
        let jayson = ["data": artist_song_data, "message": "0000", "success": true] as [String : Any]
        try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
    }
    
    //MARK: RUN PDT
    func runPDT() {
        let endpoint = PDTendpoint()
        
        GetPdtAsyc(endpoint: endpoint, method: "PDT") { pdt in
            guard let pdt = pdt else { fallback(); return }
            
            let artist_song_data = processPDT(data: pdt)
            
            if !artist_song_data.isEmpty {
                let jayson = ["data": artist_song_data, "message": "0001", "success": true] as [String : Any]
                try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
            } else {
                fallback()
            }
        }
    }
    
    runPDT()
    
}

//session
internal func sessionRoute(request: HTTPRequest, _ response: HTTPResponse) {
    
    if let body = request.postBodyString, let json = try? body.jsonDecode() as? [String:String], let channelid = json["channelid"] {
        let returnData = Session(channelid: channelid)
        
        if !returnData.isEmpty { storeCookiesX() }
        
        let jayson = ["data": returnData, "message": "coolbeans", "success": true] as [String : Any]
        try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
    }
}


//MARK: Login Route
internal func LoginRoute(request: HTTPRequest, _ response: HTTPResponse)  {
    
    func runFailure() {
        let jayson = ["data": "Failed to login.", "message": "Login failure.", "success": false] as [String : Any]
        try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
    }
    
    guard
        let body = request.postBodyString,
        let json = try? body.jsonDecode() as? [String:String],
        let u = json["user"],
        let p = json["pass"]
    else { runFailure(); return }
    
    //Login func
    let login = LoginX(username: u, pass: p)
    
    PostAsync(request: login.request, endpoint: login.endpoint, method: login.method) { (result) in
        
        guard let result = result else {runFailure(); return }
        
        let returnData = processLogin(username: u, pass: p, result: result)
        
        if returnData.success {
            
            storeCookiesX()
        }
        
        let jayson = ["data": returnData.data, "message": returnData.message, "success": returnData.success] as [String : Any]
        try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
    }
}



//channels
internal func channelsRoute(request: HTTPRequest, _ response: HTTPResponse) {
    
    let _ = Session(channelid: "siriushits1")
    
    func runFailure() {
        let jayson = ["data": [:], "message": "Login failure.", "success": false] as [String : Any]
        try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
    }
    
    
    let api = Channels()
    
    PostAsync(request: api.request, endpoint: api.endpoint, method: api.method) { (result) in
        guard let result = result else { runFailure(); return }
        
        let returnData = processChannels(result: result)
        
        if returnData.success { storeCookiesX() }
        
        let jayson = ["data": returnData.data, "message": returnData.message, "success": returnData.success, "categories": returnData.categories] as [String : Any]
        try? _ = response.setBody(json: jayson)
        response.setHeader(.contentType, value:"application/json").completed()
        
    }
    
}


//MARK: playlist
internal func playlistRoute(request: HTTPRequest, _ response: HTTPResponse) {
    if let playlistRequest = request.urlVariables[routeTrailingWildcardKey],
       let filename = String?(String(playlistRequest.dropFirst())),
       let channel = String?(String(filename.split(separator: ".")[0])),
       let ch = userX.channels[channel] as? NSDictionary,
       let channelid = ch["channelId"] as? String{
        
        userX.channel = channelid
        
        _ = Session(channelid: channelid)
        
        let source = Playlist(channelid: channelid)
        
        TextAsync(endpoint: source) { (playlist) in
            guard let playlist = playlist else {
                response.setBody(string: "An Error Occurred.\n\r").setHeader(.contentType, value:"text/plain").completed()
                return
            }
            
            func processPlaylist(_ playlist: String) -> String {
                
                var playlist = playlist
                
                //fix key path
                playlist = playlist.replacingOccurrences(of: "key/1", with: "/key/1")
                
                //add audio and userid prefix
                playlist = playlist.replacingOccurrences(of: channelid, with: "/audio/" + channelid)
                
                playlist = playlist.replacingOccurrences(of: "#EXT-X-TARGETDURATION:10", with: "#EXT-X-TARGETDURATION:9")
                
                //this keeps the PDT in sync
                playlist = playlist.replacingOccurrences(of: "#EXTINF:10,", with: "#EXTINF:1,")
                
                return playlist
            }
            response.setBody(string: processPlaylist( playlist) ).setHeader(.contentType, value:"application/x-mpegURL").completed()
        }
    } else {
        response.setBody(string: "The channel does not exist.\n\r").setHeader(.contentType, value:"text/plain").completed()
    }
}


//MARK: ping
internal func pingRoute(request: HTTPRequest, _ response: HTTPResponse) {
    response.setBody(string: "pong").setHeader(.contentType, value:"text/plain").completed()
}

//MARK: Canada/.CA Route
internal func caRoute(request: HTTPRequest, _ response: HTTPResponse) {

    playerDomain = "player.siriusxm.ca"
    root = "\(playerDomain)/rest/v2/experience/modules"
    appRegion = "CA"

    response.setBody(string: appRegion).setHeader(.contentType, value:"text/plain").completed()
}

//MARK: USA/.COM Route
internal func usRoute(request: HTTPRequest, _ response: HTTPResponse) {
    
    playerDomain = "player.siriusxm.com"
    root = "\(playerDomain)/rest/v2/experience/modules"
    appRegion = "US"

    response.setBody(string: appRegion).setHeader(.contentType, value:"text/plain").completed()
}


internal func audioRoute(request: HTTPRequest, _ response: HTTPResponse) {
    let audio = request.urlVariables[routeTrailingWildcardKey]
    
    guard let audi = audio else { response.completed(); return }
    
    let filename = String(audi.dropFirst())
    let endpoint = AudioX(data: filename, channelId: userX.channel )
    
    //MARK: Call back
    CommanderData(endpoint: endpoint, method: "AAC")  { (data) in
        guard let data = data else { response.completed(); return }
        response.setBody( bytes: [UInt8](data)).setHeader(.contentType, value:"audio/aac").completed()
    }
}


//MARK: Extension: Date
extension Date {
    func adding(_ seconds: Int) -> Date {
        if let dat = Calendar.current.date(byAdding: .minute, value: seconds, to: self) {
            return dat
        } else {
            return Date()
        }
    }
}


