//
//  XtraAudio.swift
//  Cameo
//
//  Created by Todd on 3/30/19.
//

import Foundation

func xtraAudio(data: String) -> Data {
    
    var prefix : String? = ""
    
  
    
    if usePrime {
        prefix = "https://priprodtracks.mountain.siriusxm.com"
    } else {
        prefix = "https://priprodtracks.mountain.siriusxm.com"
    }
    
    //let suffix = user[userid]!.consumer  + "&token=" + user[userid]!.token
    let endpoint = prefix! + data 
    let audio = DataSync(endpoint: endpoint, method: "AAC")
    
    //prefix = nil
    return audio
}
