//
//  PDT.swift
//  CameoKit
//
//  Created by Todd Bruss on 1/27/19.
//

import Foundation
import CommonCrypto

var lock = false;
internal func PDT(MemBase: Dictionary<String, Any>) -> [String: Any] {
    lock = true
    var ArtistSongData = [String : Any ]()

    var localMemBase = Dictionary<String, Any>()
    
    if MemBase.count > 0 {
        localMemBase = MemBase
    }
    
    let timeInterval = NSDate().timeIntervalSince1970
    let convert = timeInterval * 1000000 as NSNumber
    let intTime = ((Int(truncating: convert) / 1000) - 1000) + 10000
    let time = String(intTime)

    //print (time)
    // let dateFormatter = DateFormatter()
    // let timeZone = TimeZone(identifier: "EST")
    // dateFormatter.dateFormat =   "yyyy-MM-dd'T'HH:mm.sss+SSSS"
    // dateFormatter.timeZone = timeZone
    // let timeStamp = dateFormatter.string(from: Date())
    // print(timeStamp)
    
    //             https://player.siriusxm.com/rest/v2/experience/modules/get/discover-channel-list?type=2&batch-mode=true&format=json&request-option=discover-channel-list-withpdt&result-template=web&time=1556584493540
    let endoint = "https://player.siriusxm.com/rest/v2/experience/modules/get/discover-channel-list?type=2&batch-mode=true&format=json&request-option=discover-channel-list-withpdt&result-template=web&time=" + time
    
    let data = GetSync(endpoint: endoint, method: "PDT")
    
    if let s = data.value( forKeyPath: "ModuleListResponse.moduleList.modules" ) {
        let p = s as? NSArray
        let x = p?[0] as? NSDictionary
        if let liveChannelResponses = x?.value( forKeyPath: "moduleResponse.moduleDetails.liveChannelResponse.liveChannelResponses" ) as? NSArray {
            for j in liveChannelResponses {
                
                let i = j as? NSDictionary
                let channelid = i?.value( forKeyPath: "channelId" ) as? String
                let markerLists = i?.value( forKeyPath: "markerLists" ) as? NSArray
                let cutlayer = markerLists?.firstObject as? NSDictionary
                if let markers = cutlayer?.value( forKeyPath: "markers" ) as? NSArray {

                    for g in markers {
                        if let gather = g as? NSDictionary {
                            //grabs the album art code number
                            if let art = gather.value( forKeyPath: "cut.album.creativeArts" ) as? NSArray {
                                
                                let thumbnail = art.firstObject as? NSDictionary
                                let thumb = thumbnail?.value( forKeyPath: "url" ) as? String ?? ""
                                let large = art.lastObject as? NSDictionary
                                let image = large?.value( forKeyPath: "url" ) as? String ?? ""
                                if let cut = gather.value( forKeyPath: "cut" ) as? NSDictionary {
                                    var song = cut.value( forKeyPath: "title" ) as? String ?? ""
                                    
                                    song = song.replacingOccurrences(of: "SiriusXM", with: "Sirius") // We do not allow XM to be mentioned in text.
                                    
                                    let artists = cut.value( forKeyPath: "artists" ) as? NSArray
                                    if let a = artists?[0] as? NSDictionary {
                                        if let artiste = a.value( forKeyPath: "name" ) as? String  {
                                            let artist = artiste.replacingOccurrences(of: "SiriusXM", with: "Sirius") // We do not allow XM to be mentioned in text.
                                            
                                            if let key = MD5(artist + song) {
                                                if image != "" {
                                                    localMemBase[key] = ["thumb": thumb, "image" : image, "artist": artist, "song" : song]
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            
                if let markers = cutlayer?.value( forKeyPath: "markers" ) as? NSArray {
                    let item = markers.firstObject as? NSDictionary

                    if let cut = item?.value( forKeyPath: "cut" ) as? NSDictionary {
                        var song = cut.value( forKeyPath: "title" ) as? String ?? ""
                        
                        song = song.replacingOccurrences(of: "SiriusXM", with: "Sirius") // We do not allow XM to be mentioned in text.
                        
                        let artists = cut.value( forKeyPath: "artists" ) as? NSArray
                        let a = artists?.firstObject as? NSDictionary
                        var artist = a?.value( forKeyPath: "name" ) as? String ?? ""
                        
                        artist = artist.replacingOccurrences(of: "SiriusXM", with: "Sirius") // We do not allow XM to be mentioned in text.
                        
                        
                        if let key = MD5(artist + song) {
                            var image = ""
                            var thumb = ""
                            
                            do {
                                if localMemBase.keys.contains(key) {
                                    if let art = localMemBase[key] as? NSDictionary  {
                                        image = art["image"] as? String ?? ""
                                        thumb = art["thumb"] as? String ?? ""
                                    }
                                }
                                
                            }
                            
                            // let episodelayer = markerLists[1]
                            
                            for i in user.channels {
                                let k = i.value as? [String: String]
                                let j = k?["channelId"]
                                
                                if j == channelid {
                                    if let n = k?["channelNumber"] {
                                        ArtistSongData[n] = ["thumb": thumb, "image" : image, "artist": artist, "song" : song]
                                    }
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    lock = false
    return ArtistSongData
    
}

//MD5 hash
fileprivate func extractedFunc(_ d: Data, _ digest: inout [UInt8]) {
    _ = d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
        CC_MD5(body, CC_LONG(d.count), &digest)
    }
}

func MD5(_ string: String) -> String? {
    let length = Int(CC_MD5_DIGEST_LENGTH)
    var digest = [UInt8](repeating: 0, count: length)
    
    if let d = string.data(using: String.Encoding.utf8) {
        
        extractedFunc(d, &digest)
    }
    
    return (0..<length).reduce("") {
        $0 + String(format: "%02x", digest[$1])
    }
}
