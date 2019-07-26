//
//  ChannelData.swift
//  Cameo
//
//  Created by bruss on 3/22/19.
//

import Foundation

func GetSmallChannelLineUp() {
    let autoUser = "starplayr@icloud.com"
    let autoPass = "AirPlayr$21"
    
    //Auto Login the user
    if ( autoUser != "" && autoPass != "" && autoUser.count > 0 && autoPass.count > 0 ) {
        
        let returnData = Login(username: autoUser, pass: autoPass)
        
        if ( returnData.success ) {
            let userid = returnData.data
            let _ = Session(channelid: "", userid: userid)
            let channels = Channels(channeltype: "number", userid: userid)
            
            var channelData = Dictionary<String, Data>()
            if ( channels.success ) {
                let sortedChannelList = Array(channels.data.keys).sorted {$0.localizedStandardCompare($1) == .orderedAscending}
                for i in sortedChannelList {
                    let channel = channels.data[i]! as! NSDictionary
                    let channelNumber = channel.value( forKeyPath: "channelNumber") as! String
                    let tinyImage = channel.value( forKeyPath: "tinyImage") as! String
                    let d = ImageSync(endpoint: tinyImage, method: "image")
                    channelData[channelNumber] = d
                }
            }
            
            
            smallChannelLineUp = NSKeyedArchiver.archivedData(withRootObject: channelData)
            //let dictionary: Dictionary? = NSKeyedUnarchiver.unarchiveObject(with: dataExample) as! [String : Any]
            print(smallChannelLineUp)
        }
    }
    
}

func GetLargeChannelLineUp() {
    let autoUser = "starplayr@outlook.com"
    let autoPass = "Artdog90"
    
    //Auto Login the user
    if ( autoUser != "" && autoPass != "" && autoUser.count > 0 && autoPass.count > 0 ) {
        
        let returnData = Login(username: autoUser, pass: autoPass)
        
        if ( returnData.success ) {
            let userid = returnData.data
            let _ = Session(channelid: "siriushits1", userid: userid)
            let channels = Channels(channeltype: "number", userid: userid)
            
            var channelData = Dictionary<String, Data>()
            if ( channels.success ) {
                let sortedChannelList = Array(channels.data.keys).sorted {$0.localizedStandardCompare($1) == .orderedAscending}
                for i in sortedChannelList {
                    let channel = channels.data[i]! as! NSDictionary
                    let channelNumber = channel.value( forKeyPath: "channelNumber") as! String
                    let tinyImage = channel.value( forKeyPath: "tinyImage") as! String
                    let d = ImageSync(endpoint: tinyImage, method: "image")
                    channelData[channelNumber] = d
                }
            }
            
            
            largeChannelLineUp = NSKeyedArchiver.archivedData(withRootObject: channelData)
            //let dictionary: Dictionary? = NSKeyedUnarchiver.unarchiveObject(with: dataExample) as! [String : Any]
            print(largeChannelLineUp)
        }
    }
    
}
