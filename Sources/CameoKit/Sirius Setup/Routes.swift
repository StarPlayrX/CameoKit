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


//Decryption Key for main streams Sirius XM
internal func keyOneRoute(request: HTTPRequest, _ response: HTTPResponse) {
    
    if let data = Data(base64Encoded: user.key) {
        response.setBody(bytes: [UInt8](data)).setHeader(.contentType, value:"application/octet-stream").completed()
    }
}


internal func PDTRoute(request: HTTPRequest, _ response: HTTPResponse) {
    let artistSongData = PDT_()
    let jayson = ["data": artistSongData, "message": "0000", "success": true] as [String : Any]
    try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
}


//login
internal func loginRoute(request: HTTPRequest, _ response: HTTPResponse)  {
    
    if let body = request.postBodyString, let json = try? body.jsonDecode() as? [String:String], let u = json["user"], let p = json["pass"] {
        
        //Login func
        let returnData = Login(username: u, pass: p)
        
        if returnData.success {
            storeCookiesX()
        }
        
        let jayson = ["data": returnData.data, "message": returnData.message, "success": returnData.success] as [String : Any]
        try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
    } else {
        let jayson = ["data": "", "message": "failure", "success": false] as [String : Any]
        try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
    }
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


internal func autoLoginRoute(request: HTTPRequest, _ response: HTTPResponse)  {
    
    var returnData : (success: Bool, message: String, data: String) = (success: false, message: "", data: "")
    
    if let body = request.postBodyString,  let json = try? body.jsonDecode() as? [String : String], let userX = json["user"], let passX = json["pass"] {
        
        returnData = Login(username: userX, pass: passX)
        
        if returnData.success { storeCookiesX() }
        
        let jayson = ["data": returnData.data, "message": returnData.message, "success": returnData.success] as [String : Any]
        try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
        
    } else {
        let jayson = ["data": "", "message": "Syntax Error or invalid JSON", "success": false] as [String : Any]
        try? _ = response.setBody(json: jayson).setHeader(.contentType, value:"application/json").completed()
    }
}


//channels
internal func channelsRoute(request: HTTPRequest, _ response: HTTPResponse) {
    //Session func
    let returnData = Channels()
  
    if returnData.success { storeCookiesX()}
    
    let jayson = ["data": returnData.data, "message": returnData.message, "success": returnData.success, "categories": returnData.categories] as [String : Any]
    try? _ = response.setBody(json: jayson)
    response.setHeader(.contentType, value:"application/json").completed()
}


//playlist
internal func playlistRoute(request: HTTPRequest, _ response: HTTPResponse) {
    if let playlistRequest = request.urlVariables[routeTrailingWildcardKey],
        let filename = String?(String(playlistRequest.dropFirst())),
        let channel = String?(String(filename.split(separator: ".")[0])),
        let ch = user.channels[channel] as? NSDictionary,
        let channelid = ch["channelId"] as? String{
        
        user.channel = channelid
        
        //let now = Date()
       // let then = Date().adding(3)
        
        _ = Session(channelid: channelid)

            
        response.setBody(string:  Playlist(channelid: channelid) ).setHeader(.contentType, value:"application/x-mpegURL").completed()
        
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
    
    if let audio = audio {
        
        let now = Date()
      
        let filename = String(audio.dropFirst())
        
        var data = [UInt8]()
        
        let then = Date().adding(5)
        
        //check and make sure we have some data
        while (data.isEmpty && now < then) {
            data = [UInt8]( Audio(data: filename, channelId: user.channel ) )
        }
        
        response.setBody( bytes: data).setHeader(.contentType, value:"audio/aac").completed()
    } else {
        response.completed()
    }
}

extension Date {
    func adding(_ seconds: Int) -> Date {
        if let dat = Calendar.current.date(byAdding: .minute, value: seconds, to: self) {
            return dat
        } else {
            return Date()
        }
    }
}
