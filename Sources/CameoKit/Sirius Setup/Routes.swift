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
        let epoint = nowPlayingLiveX(channelid: userX.channel)
        
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
                artist_song_data["\(i)"] = ["image" : "", "artist" : "StarPlayrX", "song" : "iOS Best SiriusXM Radio Player"]
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
    let returnData = Channels2()
    let jayson = ["data": returnData.data, "message": returnData.message, "success": returnData.success, "categories": returnData.categories] as [String : Any]
    try? _ = response.setBody(json: jayson)
    response.setHeader(.contentType, value:"application/json").completed()
    
    
  /*  func runFailure() {
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
        
    }*/

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
                playlist = playlist.replacingOccurrences(of:
                    "key/1", with: "/key/1")
                
                //add audio and userid prefix
                playlist = playlist.replacingOccurrences(of:
                    channelid, with: "/audio/" + channelid)
                
                playlist = playlist.replacingOccurrences(of:
                    "#EXT-X-TARGETDURATION:10", with: "#EXT-X-TARGETDURATION:9")
                
                //this keeps the PDT in sync
                playlist = playlist.replacingOccurrences(of:
                    "#EXTINF:10,", with: "#EXTINF:1,")
                
                return playlist
            }
            response.setBody(string: processPlaylist( playlist) ).setHeader(.contentType, value:"application/x-mpegURL").completed()
        }
    } else {
        response.setBody(string: "The channel does not exist.\n\r").setHeader(.contentType, value:"text/plain").completed()
    }
}


//ping
internal func pingRoute(request: HTTPRequest, _ response: HTTPResponse) {
    response.setBody(string: "pong").setHeader(.contentType, value:"text/plain").completed()
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




//https://player.siriusxm.com/rest/v4/experience/carousels?page-name=np_aic_restricted&result-template=everest%7Cweb&channelGuid=86d52e32-09bf-a02d-1b6b-077e0aa05200&cutGuid=50be2dfa-e278-a608-5f0d-9a23db6c45c4&cacheBuster=1550883990670
internal func Channels2() -> ChannelsTuple {
    var recordCategories = Array<String>()
    
    var success : Bool = false
    var message : String = "Something's not right."
    
    let endpoint = "https://player.siriusxm.com/rest/v2/experience/modules/get"
    let method = "channels"
    let request =  ["moduleList":["modules":[["moduleArea":"Discovery","moduleType":"ChannelListing","moduleRequest":["resultTemplate":""]]]]] as Dictionary
    
    let result = PostSync(request: request, endpoint: endpoint, method: method )
    
    if (result.response?.statusCode) == 403 {
        success = false
        message = "Too many incorrect logins, Sirius XM has blocked your IP for 24 hours."
    }
    
    if result.success {
        let result = result.data as NSDictionary
        if let r = result.value(forKeyPath: "ModuleListResponse.moduleList.modules") {
            let m = r as? NSArray
            let o = m![0] as! NSDictionary
            let d = o.value( forKeyPath: "moduleResponse.contentData.channelListing.channels") as! NSArray
            
            var ChannelDict : Dictionary = Dictionary<String, Any>()
            var ChannelIdDict : Dictionary = Dictionary<String, Any>()
            
            
            for i in d {
                if let dict = i as? NSDictionary,
                    let channelId = dict.value( forKeyPath: "channelId") as? String {
                    
                    //let channelGuid = dict.value( forKeyPath: "channelGuid") as? String
                    
                    let categories = dict.value( forKeyPath: "categories.categories") as? NSArray
                    
                    if let cats = categories?.firstObject as? NSDictionary,
                        let channelNumber = dict.value( forKeyPath: "channelNumber") as? String,
                        var category = cats.value( forKeyPath: "name") as? String {
                        
                        switch category {
                            case "MLB Play-by-Play":
                                category = "MLB"
                            case "NBA Play-by-Play":
                                category = "NBA"
                            case "NFL Play-by-Play":
                                category = "NFL"
                            case "NHL Play-by-Play":
                                category = "NHL"
                            case "Sports Play-by-Play":
                                category = "Play-by-Play"
                            default:
                                _ = category
                        }
                        
                        let chNumber = Int(channelNumber)
                        switch chNumber {
                            case 20,18,19,22,23,24,31,29,30,38,176,700,711:
                                category = "Artists"
                            case 11,12:
                                category = "Pop"
                            case 4,7,8,28,301,302:
                                category = "Rock"
                            case 13:
                                category = "Dance/Electronic"
                            case 9,21,33,34,35,36,173,359,714,758:
                                category = "Alternative"
                            case 37,39,40,41:
                                category = "Heavy Metal"
                            case 5,6,701,703,776:
                                category = "Oldies"
                            case 314,712,713:
                                category = "Punk"
                            case 165,169:
                                category = "Canadian"
                            case 172:
                                category = "Sports"
                            case 171:
                                category = "Country"
                            case 141, 142, 706:
                                category = "Jazz/Standards/Classical"
                            case 152, 158:
                                category = "Latino"
                            default:
                                _ = category
                            //category = category
                        }
                        
                        // append it to the categorieshit
                        if !recordCategories.contains(category) {
                            recordCategories.append(category)
                        }
                        
                        var mediumImage = ""
                        
                        if let images = dict.value( forKeyPath: "images.images") as? NSArray,
                            let name = dict.value( forKeyPath: "name") as? String {
                            
                            let a = 4 //low
                            let b = 8 //high
                            
                            for img in images.reversed()[a...b] {
                                
                                if let g = img as? NSDictionary, let height = g["height"] as? Int, let name = g["name"] as? String {
                                    
                                    if height == 720 && name == "color channel logo (on dark)" {
                                        if let mi = g["url"] as? String {
                                            mediumImage = mi
                                            
                                            break
                                        }
                                    }
                                }
                            }
                            
                            let cl = [ "channelId": channelId, "channelNumber": channelNumber, "name": name,
                                       "mediumImage": mediumImage, "category": category, "preset": false ] as [String : Any]
                            
                            
                            let ids = ["channelNumber": channelNumber] as [String : String]
                            
                           
                            ChannelDict[channelNumber] = cl
                            ChannelIdDict[channelId] = ids
                            
                        }
                        
                        
                    }
                }
            }
            
            userX.channels = ChannelDict
            userX.ids = ChannelIdDict
            
            if !userX.channels.isEmpty {
                
                UserDefaults.standard.set(ChannelDict, forKey: "channels")
                UserDefaults.standard.set(ChannelIdDict, forKey: "ids")
                
                success = true
                message = "Read the channels in."
                
                return (success: success, message: message, data: ChannelDict, recordCategories)
            }
            
        }
    }
    
    return (success: success, message: message, data: Dictionary<String, Any>(), categories: recordCategories)
    
}


//
//  PostSync.swift
//  Camouflage
//
//  Created by Todd on 1/25/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//



internal func PostSync(request: Dictionary<String, Any>, endpoint: String, method: String) -> PostReturnTuple  {
    
    //MARK - for Sync
    let semaphore = DispatchSemaphore(value: 0)
    var syncData : PostReturnTuple? = (message: "", success: false, data: Dictionary<String, Any>(), response: HTTPURLResponse() )
    let http_method = "POST"
    let time_out = 30
    let url = URL(string: endpoint)
    var urlReq : URLRequest? = URLRequest(url: url!)
    
    if urlReq != nil {
        urlReq!.httpBody = try? JSONSerialization.data(withJSONObject: request, options: .prettyPrinted)
        urlReq!.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlReq!.httpMethod = http_method
        urlReq!.timeoutInterval = TimeInterval(time_out)
        urlReq!.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0.2 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        let task = URLSession.shared.dataTask(with: urlReq! ) { ( rData, resp, error ) in
            
            if resp != nil && (resp as? HTTPURLResponse)!.statusCode == 200 {
                
                var result : Dictionary? = Dictionary<String, Any>()
                var myData : Data? = Data()
                myData = rData
                
                do {
                    result = try? JSONSerialization.jsonObject(with: myData!, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String, Any> ?? nil
                }
                
                
                syncData = ((message: method + " was successful.", success: true, data: result, response: resp as! HTTPURLResponse ) as! PostReturnTuple)
                
                myData = nil
                result = nil
            } else {
                //we always require 200 on the post, anything else is a failure
                
                if resp != nil {
                    syncData = (message: method + " failed, see response.", success: false, data: ["": ""], response: resp as? HTTPURLResponse ) as PostReturnTuple
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
    
    urlReq = nil
    
    if syncData != nil {
        return syncData!
    }
    
    return (message: method + " failed!", success: false, data: ["Error": "Fatal Error"], response: HTTPURLResponse() ) as PostReturnTuple
}


