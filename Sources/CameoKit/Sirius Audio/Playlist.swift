
//
//  Playlist makek
//
//  Created by Todd on 1/16/19.
//

import Foundation

//Cached verison of Playlist
func Playlist(channelid: String) -> String {
    var playlist = ""
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
    var source = user.keyurl
    
    let primary = String(hls_sources["Live_Primary_HLS"] ?? "")
    let secondary = String(hls_sources["Live_Secondary_HLS"] ?? "")
    
    if usePrime {
        source = source.replacingOccurrences(of: "%Live_Primary_HLS%", with: primary)
    } else {
        source = source.replacingOccurrences(of: "%Live_Primary_HLS%", with: secondary)
    }
    
    source = source.replacingOccurrences(of: "32k", with: bitrate)

    
    ///currently using a originating key/1 URL as a base
    ///reduces having to call the Variant
    source = source.replacingOccurrences(of: "key/1", with: tail)
    
    source = source + user.consumer + "&token=" + user.token
    playlist = TextSync(endpoint: source, method: "variant")
    
    //fix key path
    playlist = playlist.replacingOccurrences(of:
        "key/1", with: "/key/1")
    
    //add audio and userid prefix
    //(used for internal multi user or multi service setup)
    playlist = playlist.replacingOccurrences(of:
        channelid, with: "/audio/" + channelid)
    
    playlist = playlist.replacingOccurrences(of:
    "#EXT-X-TARGETDURATION:10", with: "#EXT-X-TARGETDURATION:9") //+ userid)
    
 
    //this keeps the PDF in sync
    playlist = playlist.replacingOccurrences(of:
        "#EXTINF:10,", with: "#EXTINF:1,") //+ userid)
    
    
    return playlist

}
