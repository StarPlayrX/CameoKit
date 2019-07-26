import Foundation

//Future
//URL: https://player.siriusxm.com/rest/v2/experience/modules/get/discover-channel-list?type=2&batch-mode=true&format=json&request-option=discover-channel-list-withpdt&result-template=web&time=1548615083793

//On Ice
//URL: https://player.siriusxm.com/rest/v4/experience/modules/tune/now-playing-live?channelId=thepulse&hls_output_mode=none&marker_mode=all_separate_cue_points&ccRequestType=AUDIO_VIDEO&result-template=web&time=1548615098681


    //streaming flag
    public var streaming: Bool = false
    
    //local
    public let ipaddress: String = "127.0.0.1"
    public var port: UInt16 = 9999
    //source
    public var usePrime: Bool = false
    public let http: String = "https://"
    public let root: String = "player.siriusxm.com/rest/v2/experience/modules"
    
    public var connectionType = "wifi"
    public var connectionInt = 1

    public var hls_sources = Dictionary<String, String>()
    public var MemBase = Dictionary<String, Any>()
    public var largeChannelLineUp = Data()
    public var smallChannelLineUp = Data()

    public typealias LoginData = ( email:String, pass:String, channels:  Dictionary<String, Any>, channel: String, token: String, loggedin: Bool,  gupid: String, consumer: String, key: String, keyurl: String )
    public var user = ( email:"", pass:"", channels:  [:], channel: "", token: "", loggedin: false,  gupid: "", consumer: "", key: "", keyurl: "" ) as LoginData
 
    internal var lastChannel = ""

