//PlayList
import Foundation

func Audio(data: String, channelId: String ) -> Data {
    
    var prefix = ""
    var audio = Data()
    var bitrate = "64k"
    
    if ( CKnetworkIsWiFi && CKnetworkIsConnected ) {
        bitrate = "256k"
    } else if ( !CKnetworkIsWiFi && CKnetworkIsConnected ) {
        bitrate = "64k"
    } else {
        bitrate = "32k"
    }

    let rootUrl = "/AAC_Data/" + channelId +
        "/HLS_" + channelId + "_" + bitrate + "_v3/"
    
    if usePrime, let hls = hls_sources["Live_Primary_HLS"] {
        prefix = hls + rootUrl
    } else if let hls = hls_sources["Live_Secondary_HLS"] {
        prefix = hls + rootUrl
    }
    
    let suffix = user.consumer  + "&token=" + user.token
    let endpoint = prefix + data + suffix
    
    audio = DataSyncX(endpoint: endpoint, method: "AAC")

    return audio
}
