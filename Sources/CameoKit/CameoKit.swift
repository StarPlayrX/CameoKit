//routes
import PerfectHTTP
import PerfectHTTPServer
import Foundation


public func routes() -> Routes {
    
    let net = Network.ability

    //start networkstr
    net.start()
    
    Config()
    
    //process cached data in the background
    
    let logindata = (email:"", pass:"", channels: [:], ids: [:], channel: "", token: "", loggedin: false, gupid: "", consumer: "", key: "", keyurl: "" ) as LoginData
    
    //AutoLogin Routine to save time
    //check for cached data
    let autoUser = UserDefaults.standard.string(forKey: "user") 			?? ""
    let autoPass = UserDefaults.standard.string(forKey: "pass") 			?? ""
    let autoGupid = UserDefaults.standard.string(forKey: "gupid") 			?? ""
    let autoChannels = UserDefaults.standard.dictionary(forKey: "channels") ?? Dictionary<String, Any>()
    let autoIds = UserDefaults.standard.dictionary(forKey: "ids")  			?? Dictionary<String, Any>()
    
    if autoGupid != "" && autoChannels.count > 1 {
        
        let autoLoggedin = UserDefaults.standard.bool(forKey: "loggedin")
        
        let autoChannel = UserDefaults.standard.string(forKey: "channel") 		?? ""
        let autoToken = UserDefaults.standard.string(forKey: "token") 			?? ""
        let autoConsumer = UserDefaults.standard.string(forKey: "consumer")		?? ""
        let autoKey = UserDefaults.standard.string(forKey: "key") 				?? ""
        let autoKeyurl = UserDefaults.standard.string(forKey: "keyurl")			?? ""
        
        userX = logindata
        userX.email = autoUser
        userX.channels = autoChannels
        userX.ids = autoIds
        userX.channel = autoChannel
        userX.token = autoToken
        userX.loggedin = autoLoggedin
        userX.gupid = autoGupid
        userX.consumer = autoConsumer
        userX.key = autoKey
        userX.keyurl = autoKeyurl
        userX.pass = autoPass
    }
    
    restoreCookiesX()
    
    var routes = Routes()
    
    // /key/1/{userid}
    routes.add(method: .get, uri:"/key/1",handler:keyOneRoute)
    
    // /api/v2/login
    routes.add(method: .post, uri:"/api/v2/login",handler:LoginRoute)
    
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
    routes.add(method: .post, uri:"/api/v2/autologin",handler:LoginRoute)
    
    // Check the console to see the logical structure of what was installed.
    //print("\(routes.navigator.description)")
    
    return routes
    
    
}

func storeCookiesX() {
    
    let cookiesStorage = HTTPCookieStorage.shared
    let userDefaults = UserDefaults.standard
    let serverBaseUrl = "https://player.siriusxm.com"
    
    guard
        let url = URL(string: serverBaseUrl),
        let c = cookiesStorage.cookies(for: url)
        else { return }
    
    var cookieDict = [String : AnyObject]()
    
    for cookie in c {
        cookieDict[cookie.name] = cookie.properties as AnyObject?
    }
    
    userDefaults.set(cookieDict, forKey: "siriusxm")
}

func restoreCookiesX() {
    let cookiesStorage = HTTPCookieStorage.shared
    let userDefaults = UserDefaults.standard
    
    if let cookieDictionary = userDefaults.dictionary(forKey: "siriusxm") {
        
        for (_, cookieProperties) in cookieDictionary {
            if let cp = cookieProperties as? [HTTPCookiePropertyKey : Any],
                let cookie = HTTPCookie(properties: cp) {
                cookiesStorage.setCookie(cookie)
            }
        }
    }
}
