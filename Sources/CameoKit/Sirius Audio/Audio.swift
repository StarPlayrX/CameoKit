//PlayList
import Foundation

func Audio(data: String, channelId: String, userid: String) -> Data {
    
    var prefix : String? = ""
    var audio : Data?
    var bitrate = "64k"
    //Get Network Info, so we know what to do with the stream
    
    if ( CKnetworkIsWiFi && CKnetworkIsConnected ) {
        bitrate = "256k"
    } else if ( !CKnetworkIsWiFi && CKnetworkIsConnected ) {
        bitrate = "64k"
    } else {
        bitrate = "32k"
    }

    let rootUrl = "/AAC_Data/" + channelId + "/HLS_" + channelId + "_" + bitrate + "_v3/"
    
    if usePrime {
        prefix = hls_sources["Live_Primary_HLS"]! + rootUrl
    } else {
        prefix = hls_sources["Live_Secondary_HLS"]! + rootUrl
    }
    
    let suffix = user.consumer  + "&token=" + user.token
    let endpoint = prefix! + data + suffix
    audio = DataSync(endpoint: endpoint, method: "AAC")

    prefix = nil
    return audio!
}
