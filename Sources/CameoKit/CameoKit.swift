//routes
import PerfectHTTP
import PerfectHTTPServer
import Foundation


public func routes() -> Routes {
    
    //start networkstr
    CKNetworkability().start()
    
    Config()
    
    //print("Config Success")
    //process cached data in the background
    
    let logindata = (email:"", pass:"", channels: [:], ids: [:], channel: "", token: "", loggedin: false, gupid: "", consumer: "", key: "", keyurl: "" ) as LoginData
    
    //AutoLogin Routine to save time
    //check for cached data
    let autoUser = UserDefaults.standard.string(forKey: "user") ?? ""
    let autoPass = UserDefaults.standard.string(forKey: "pass") ?? ""
    let autoGupid = UserDefaults.standard.string(forKey: "gupid") ?? ""
    let autoChannels = UserDefaults.standard.dictionary(forKey: "channels") ?? Dictionary<String, Any>()
    let autoIds = UserDefaults.standard.dictionary(forKey: "ids")  ?? Dictionary<String, Any>()

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
        user.ids = autoIds
        user.channel = autoChannel
        user.token = autoToken
        user.loggedin = autoLoggedin
        user.gupid = autoGupid
        user.consumer = autoConsumer
        user.key = autoKey
        user.keyurl = autoKeyurl
        user.pass = autoPass
        

    }
    
    restoreCookiesX()
    
    var routes = Routes()
    
    // /key/1/{userid}
    routes.add(method: .get, uri:"/key/1",handler:keyOneRoute)
    
    // /api/v2/login
    routes.add(method: .post, uri:"/api/v2/login",handler:loginRoute)
    
    // /api/v2/session
    routes.add(method: .post, uri:"/api/v2/session",handler:sessionRoute)
    
    // /api/v2/channels
    routes.add(method: .post, uri:"/api/v2/channels",handler:channelsRoute)
    
    // /playlist/{userid}/2.m3u8
    routes.add(method: .get, uri:"/playlist/**",handler:playlistRoute)
    
    // /nowplaying/{channel}/{userid}
    //routes.add(method: .get, uri:"/nowplaying/{channel}",handler:nowPlaying)
    
    // /audio/{userid}/2.m3u8
    routes.add(method: .get, uri:"/audio/**",handler:audioRoute)
    
    // /PDT (artist and song data)
    routes.add(method: .get, uri:"/pdt",handler:PDTRoute)
    
    // /ping (return is pong) This is way of checking if server is running
    routes.add(method: .get, uri:"/ping",handler:pingRoute)
    
    // /api/v2/autologin
    routes.add(method: .post, uri:"/api/v2/autologin",handler:autoLoginRoute)
    
    // Check the console to see the logical structure of what was installed.
    //print("\(routes.navigator.description)")
    
    return routes
    
    
}

func storeCookiesX() {
    let cookiesStorage = HTTPCookieStorage.shared
    let userDefaults = UserDefaults.standard
    
    let serverBaseUrl = "https://player.siriusxm.com"
    var cookieDict = [String : AnyObject]()
    
    for cookie in cookiesStorage.cookies(for: NSURL(string: serverBaseUrl)! as URL)! {
        cookieDict[cookie.name] = cookie.properties as AnyObject?
    }
    
    userDefaults.set(cookieDict, forKey: "siriusxm")
}

func restoreCookiesX() {
    let cookiesStorage = HTTPCookieStorage.shared
    let userDefaults = UserDefaults.standard
    
    if let cookieDictionary = userDefaults.dictionary(forKey: "siriusxm") {
        
        for (_, cookieProperties) in cookieDictionary {
            if let cookie = HTTPCookie(properties: cookieProperties as! [HTTPCookiePropertyKey : Any] ) {
                cookiesStorage.setCookie(cookie)
            }
        }
    }
}
