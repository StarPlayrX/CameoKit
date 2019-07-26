//
//  Cookies.swift
//  Camouflage
//
//  Created by Todd Bruss on 1/20/19.
//

import Foundation


internal func Session(channelid: String, userid: String) -> String {
    lock = true;
    var channelLineUpId = "350" //default to large channel and image set

    let timeInterval = NSDate().timeIntervalSince1970
    let convert = timeInterval * 1000000 as NSNumber
    let intTime = (Int(truncating: convert) / 1000) - 1000
    let time = String(intTime)
    //https://player.siriusxm.com/rest/v2/experience/modules/resume?OAtrial=false&channelId=siriushits1&contentType=live&timestamp=1557180322254&cacheBuster=1557180714423
    let endpoint = http + root + "/resume?channelId=" + channelid + "&contentType=live&timestamp=" + time + "&cacheBuster=" + time
    let request =  ["moduleList": ["modules": [["moduleRequest": ["resultTemplate": "web", "deviceInfo": ["osVersion": "Mac", "platform": "Web", "clientDeviceType": "web", "sxmAppVersion": "3.1802.10011.0", "browser": "Safari", "browserVersion": "11.0.3", "appRegion": "US", "deviceModel": "K2WebClient", "player": "html5", "clientDeviceId": "null"]]]]]] as Dictionary
    
    //MARK - for Sync
    let semaphore = DispatchSemaphore(value: 0)
    let http_method = "POST"
    let time_out = 30
    let url = URL(string: endpoint)
    var urlReq : URLRequest? = URLRequest(url: url!)
    
    urlReq!.httpBody = try? JSONSerialization.data(withJSONObject: request, options: .prettyPrinted)
    urlReq!.addValue("application/json", forHTTPHeaderField: "Content-Type")
    urlReq!.httpMethod = http_method
    
    urlReq!.timeoutInterval = TimeInterval(time_out)
    urlReq!.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0.2 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
    
    let task = URLSession.shared.dataTask(with: urlReq! ) { ( rData, resp, error ) in
    
        if let r = resp as? HTTPURLResponse {
            if r.statusCode == 200 {
                
                do { let result =
                    try JSONSerialization.jsonObject(with: rData!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any]
                    
                    let fields = r.allHeaderFields as? [String : String]
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields!, for: r.url!)
                    HTTPCookieStorage.shared.setCookies(cookies, for: r.url!, mainDocumentURL: nil)
                    
                    for cookie in cookies {
                        
                        //This token changes on every pull and expires in about 480 seconds or less
                        if cookie.name == "SXMAKTOKEN" {
                            
                            let t = cookie.value as String
                            let startIndex = t.index(t.startIndex, offsetBy: 3)
                            let endIndex = t.index(t.startIndex, offsetBy: 45)
                            user.token = String(t[startIndex...endIndex])
                            break
                        }
                    }
                    
                    let dict = result as NSDictionary?
                
                    
                    /* get patterns and encrpytion keys */
                    let s = dict?.value( forKeyPath: "ModuleListResponse.moduleList.modules" )
                    let p = s as? NSArray
                    let x = p?.firstObject as? NSDictionary
                    
                    //New return the channel lineup Id
                    if let cid = x?.value( forKeyPath: "clientConfiguration.channelLineupId" ) as? String {
                        channelLineUpId = String(cid)
                    }
                    
                    if let customAudioInfos = x?.value( forKeyPath: "moduleResponse.liveChannelData.customAudioInfos" ) as? NSArray {
                        let c = customAudioInfos[0] as? NSDictionary
                        let chunk = c!.value( forKeyPath: "chunks.chunks") as? NSArray
                        let d = chunk![0] as? NSDictionary
                        
                        user.key = d!.value( forKeyPath: "key") as! String
                        user.keyurl = d!.value( forKeyPath: "keyUrl") as! String
                        user.consumer = x!.value( forKeyPath: "moduleResponse.liveChannelData.hlsConsumptionInfo" ) as! String
                        
                        UserDefaults.standard.set(user.key, forKey: "key")
                        UserDefaults.standard.set(user.keyurl, forKey: "keyurl")
                        UserDefaults.standard.set(user.consumer, forKey: "consumer")

                    }
                    
                    if let markerLists = x!.value( forKeyPath: "moduleResponse.liveChannelData.markerLists" )  as? NSArray {
                        
                        let markerDict = markerLists.lastObject as? NSDictionary
                        let cutLayer = markerDict!.value( forKeyPath: "layer") as? String
                        
                        if cutLayer == "cut" {
                            if let markers = markerDict!.value( forKeyPath: "markers") as? NSArray {
                                let mark = Array(markers.suffix(2))
                                for g in mark {
                                    if let gather = g as? NSDictionary {
                                        //grabs the album art code number
                                        if let art = gather.value( forKeyPath: "cut.album.creativeArts" ) as? NSArray {
                                            
                                            let thumbnail = art.firstObject as? NSDictionary
                                            let thumb = thumbnail?.value( forKeyPath: "url" ) as? String ?? ""
                                            
                                            let large = art.lastObject as? NSDictionary
                                            let image = large?.value( forKeyPath: "url" ) as? String ?? ""
                                            
                                            if let cut = gather.value( forKeyPath: "cut" ) as? NSDictionary {
                                                
                                                let song = cut.value( forKeyPath: "title" ) as? String ?? ""
                                                
                                                if let artists = cut.value( forKeyPath: "artists" ) as? NSArray {
                                                    if let a = artists.firstObject as? NSDictionary {
                                                        
                                                        let artist = a.value( forKeyPath: "name" ) as? String ?? ""
                                                        
                                                        if let key = MD5(artist + song)  {
                                                            
                                                            if image != "" {
                                                                MemBase[key] = ["thumb": thumb, "image" : image, "artist": artist, "song" : song]
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                        
                    }
                    
                    //moduleResponse.liveChannelData.markerLists
                    
                } catch {
                    //fail on any errors
                    print(error)
                }
            }
            
        }
        
  
        //MARK - for Sync
        semaphore.signal()
    }
    
    task.resume()
    _ = semaphore.wait(timeout: .distantFuture)
    
    urlReq = nil
    
    UserDefaults.standard.set(user.token, forKey: "token")
    
    lock = false
    return String(channelLineUpId)
}
