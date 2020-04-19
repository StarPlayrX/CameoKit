//
//  XtraAudio.swift
//  Cameo
//
//  Created by Todd on 3/30/19.
//

import Foundation

func xtraAudio(data: String) -> Data {
    
    var prefix = ""

    if usePrime {
        prefix = "https://priprodtracks.mountain.siriusxm.com"
    } else {
        prefix = "https://priprodtracks.mountain.siriusxm.com"
    }
    
    let endpoint = prefix + data
    let audio = DataSyncX(endpoint: endpoint, method: "AAC")
    
    return audio
}
