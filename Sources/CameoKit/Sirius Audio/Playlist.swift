
//
//  Playlist makek
//
//  Created by Todd on 1/16/19.
//

import Foundation

//Cached verison of Playlist
func Playlist(channelid: String, userid: String ) -> String {
    var playlist : String? = ""
    var bitrate = "64k"
    
    //Get Network Info, so we know what to do with the stream
    if ( CKnetworkIsWiFi && CKnetworkIsConnected ) {
        bitrate = "256k"
    } else if ( !CKnetworkIsWiFi && CKnetworkIsConnected ) {
        bitrate = "64k"
    } else {
        bitrate = "32k"
    }
    
    let size = "medium"
    let underscore = "_"
    let version = "v3"
    let ext = ".m3u8"
    
    let tail = channelid + underscore + bitrate + underscore + size + underscore + version + ext
    var source : String? = user.keyurl

    
    if usePrime {
        source = source!.replacingOccurrences(of: "%Live_Primary_HLS%", with: hls_sources["Live_Primary_HLS"]!)
    } else {
        source = source!.replacingOccurrences(of: "%Live_Primary_HLS%", with: hls_sources["Live_Secondary_HLS"]!)
    }
    
    source = source!.replacingOccurrences(of: "32k", with: bitrate)
    
    
    ///currently using a originating key/1 URL as a base
    ///reduces having to call the Variant
    ///we may start including the Variant call as part of the config in the future
    source = source!.replacingOccurrences(of: "key/1", with: tail)
    
    source = source! + user.consumer + "&token=" + user.token
    playlist = TextSync(endpoint: source!, method: "variant")
    
    //fix key path
    playlist = playlist?.replacingOccurrences(of: "key/1", with: "/key/1/" + userid)
    
    //add audio and userid prefix (used for internal multi user or multi service setup)
    playlist = playlist?.replacingOccurrences(of: channelid, with: "/audio/" + userid + "/" + channelid)
    
    //is insync with PDT
    playlist = playlist?.replacingOccurrences(of: "#EXTINF:10,", with: "#EXTINF:1," + userid)

    source = nil
    
    if let pl = playlist {
        return pl
    }
    
    return ""

}
