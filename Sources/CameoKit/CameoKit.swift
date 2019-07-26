//routes
import PerfectHTTP
import PerfectHTTPServer
import Foundation


public func routes() -> Routes {
    
    //start networkstr
    CKNetworkability().start()

    Config()

    print("Config Success")
    //process cached data in the background
    
    let logindata = (email:"", pass:"", channels: [:], channel: "", token: "", loggedin: false, gupid: "", consumer: "", key: "", keyurl: "" ) as LoginData
    
    //AutoLogin Routine to save time
    //check for cached data
    let autoUser = UserDefaults.standard.string(forKey: "user") ?? ""
    let autoPass = UserDefaults.standard.string(forKey: "pass") ?? ""
    let autoGupid = UserDefaults.standard.string(forKey: "gupid") ?? ""
    let autoChannels = UserDefaults.standard.dictionary(forKey: "channels") ?? Dictionary<String, Any>()
    
    if autoGupid != "" && autoChannels.count > 1 {
        
        let autoChannel = UserDefaults.standard.string(forKey: "channel") ?? ""
        let autoToken = UserDefaults.standard.string(forKey: "token") ?? ""
        let autoLoggedin = UserDefaults.standard.bool(forKey: "loggedin")
        let autoConsumer = UserDefaults.standard.string(forKey: "consumer") ?? ""
        let autoKey = UserDefaults.standard.string(forKey: "key") ?? ""
        let autoKeyurl = UserDefaults.standard.string(forKey: "keyurl") ?? ""

        user = logindata
        user.email = autoUser
        user.channels = autoChannels
        user.channel = autoChannel
        user.token = autoToken
        user.loggedin = autoLoggedin
        user.gupid = autoGupid
        user.consumer = autoConsumer
        user.key = autoKey
        user.keyurl = autoKeyurl
        user.pass = autoPass
        print("Refresh Success")
    }

        
        var routes = Routes()
        
        // /key/1/{userid}
        routes.add(method: .get, uri:"/key/1/{userid}",handler:keyOneRoute)
        
        // /key/4/{userid}
        routes.add(method: .get, uri:"/key/4/{userid}",handler:keyFourRoute)
        
        // /api/v2/login
        routes.add(method: .post, uri:"/api/v2/login",handler:loginRoute)
        
        // /api/v2/session
        routes.add(method: .post, uri:"/api/v2/session",handler:sessionRoute)
        
        // /api/v2/channels
        routes.add(method: .post, uri:"/api/v2/channels",handler:channelsRoute)
        
        // /playlist/{userid}/2.m3u8
        routes.add(method: .get, uri:"/playlist/{userid}/**",handler:playlistRoute)
        
        // /audio/{userid}/2.m3u8
        routes.add(method: .get, uri:"/audio/{userid}/**",handler:audioRoute)
        
        // /PDT (artist and song data)
        routes.add(method: .get, uri:"/pdt/{userid}",handler:PDTRoute)
        
        // /ping (return is pong) This is way of checking if server is running
        routes.add(method: .get, uri:"/ping",handler:pingRoute)
        
        // /api/v2/autologin
        routes.add(method: .post, uri:"/api/v2/autologin",handler:autoLoginRoute)
        
        
        /* Extra Routers Start Here */
        // /api/v2/xtrasession
        //routes.add(method: .post, uri:"/api/v2/xtras",handler:xtraSessionRoute)
        
        //xtraTuneRoute /api/xtras/tune/{channelGuid}
        routes.add(method: .get, uri:"/api/xtras/tune/{channelGuid}",handler:xtraTuneRoute)
        
        // /clips/**
        routes.add(method: .get, uri:"/xtraAudio/**",handler:xtraAudioRoute)
        /* Xtra Routes End Here*/
        // Check the console to see the logical structure of what was installed.
        //  print("\(routes.navigator.description)")
        
        return routes
        
    }

