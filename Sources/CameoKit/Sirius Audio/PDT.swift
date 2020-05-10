//
//  PDT.swift
//  CameoKit
//
//  Created by Todd Bruss on 1/27/19.
//

import Foundation
import CryptoKit

var lock = false;
internal func PDT_() -> [String: Any] {
    lock = true
    var ArtistSongData = [String : Any ]()
    
    if !user.channel.isEmpty {
        _ = nowPlayingLive(channelid: user.channel)
    } else {
        _ = nowPlayingLive(channelid: "siriushits1")

    }

    let timeInterval = Date().timeIntervalSince1970
    let convert = timeInterval * 1000 as NSNumber
    let intTime = (Int(truncating: convert))
    let time = String(intTime)
    
    let endpoint = "https://player.siriusxm.com/rest/v2/experience/modules/get/discover-channel-list?type=2&batch-mode=true&format=json&request-option=discover-channel-list-withpdt&result-template=web&time=" + time
    let data = GetPDT(endpoint: endpoint, method: "PDT")
        
    if data == nil {
        return ArtistSongData
    }
    
    let status = data?.moduleListResponse.status
    if status == 100 {
        
        if let live = data?.moduleListResponse.moduleList.modules.first?.moduleResponse.moduleDetails.liveChannelResponse.liveChannelResponses {
            for i in live {
                let channelid = i.channelID
                let markerLists = i.markerLists
                let cutlayer = markerLists.first
                
                if let markers = cutlayer?.markers {
                    let item = markers.first
                   
                    if let song = item?.cut?.title, let artist = item?.cut?.artists.first?.name, let getchannelbyId = user.ids[channelid] as? [String: Any],
                       let channelNo = getchannelbyId["channelNumber"] as? String {
                        
                        if let key = MD5(artist + song), let image = MemBase[key] {
                            ArtistSongData[channelNo] = ["image" : image, "artist": artist, "song" : song]
                        } else {
                            ArtistSongData[channelNo] = ["image" : "", "artist": artist, "song" : song]
                        }
                        
                        
                    }
                }
            }
        }
    }
    
    return ArtistSongData

}

//MARK: New and Improved MD5
func MD5(_ d: String) -> String? {
    
    var str = String()
    
    for byte in Insecure.MD5.hash(data: d.data(using: .utf8) ?? Data() ) {
         str += String(format: "%02x", byte)
    }
    
    return str
}



// MARK: - NewPDT
struct NewPDT: Codable {
    let moduleListResponse: ModuleListResponse
    
    enum CodingKeys: String, CodingKey {
        case moduleListResponse = "ModuleListResponse"
    }
    
    // MARK: - ModuleListResponse
    struct ModuleListResponse: Codable {
        let status: Int
        let moduleList: ModuleList
        let messages: [Message]
    }
    
    // MARK: - Message
    struct Message: Codable {
        let message: String
        let code: Int
    }
    
    // MARK: - ModuleList
    struct ModuleList: Codable {
        let modules: [Module]
    }
    
    // MARK: - Module
    struct Module: Codable {
        let wallClockRenderTime, moduleArea, moduleType: String
        let updateFrequency: Int
        let moduleResponse: ModuleResponse
    }
    
    // MARK: - ModuleResponse
    struct ModuleResponse: Codable {
        let moduleDetails: ModuleDetails
    }
    
    // MARK: - ModuleDetails
    struct ModuleDetails: Codable {
        let liveChannelResponse: ModuleDetailsLiveChannelResponse
    }
    
    // MARK: - ModuleDetailsLiveChannelResponse
    struct ModuleDetailsLiveChannelResponse: Codable {
        let liveChannelResponses: [LiveChannelResponseElement]
    }
    
    // MARK: - LiveChannelResponseElement
    struct LiveChannelResponseElement: Codable {
        let channelID: String
        let markerLists: [MarkerList]
        let aodEpisodeCount: Int
        
        enum CodingKeys: String, CodingKey {
            case channelID = "channelId"
            case markerLists, aodEpisodeCount
        }
    }
    
    // MARK: - MarkerList
    struct MarkerList: Codable {
        let layer: Layer?
        let markers: [Marker]
    }
    
    enum Layer: String, Codable {
        case cut = "cut"
        case episode = "episode"
    }
    
    // MARK: - Marker
    struct Marker: Codable {
        let cut: Cut?
        let time: Int?
        let layer: Layer?
        let assetGUID: String?
        let consumptionInfo: String?
        let duration: Double?
        let timestamp: Timestamp?
        let containerGUID: String?
        let episode: Episode?
    }
    
    // MARK: - Cut
    struct Cut: Codable {
        let cutContentType: CutContentType?
        let galaxyAssetID: String?
        let legacyIDS: LegacyIDS?
        let title: String?
        let memberOfSpotBlock: Bool?
        let artists: [Artist]
        let mref: String?
        let externalIDS: [ExternalID]?
        let clipGUID: String?
        let album: Album?
        let firstCutOfSpotBlock: Bool?
        let spotBlockID, contentInfo: String?
        
        enum CodingKeys: String, CodingKey {
            case cutContentType
            case galaxyAssetID = "galaxyAssetId"
            case legacyIDS = "legacyIds"
            case title, memberOfSpotBlock, artists, mref
            case externalIDS = "externalIds"
            case clipGUID, album, firstCutOfSpotBlock
            case spotBlockID = "spotBlockId"
            case contentInfo
        }
    }
    
    // MARK: - Album
    struct Album: Codable {
        let title: String?
    }
    
    // MARK: - Artist
    struct Artist: Codable {
        let name: String
    }
    
    enum CutContentType: String, Codable {
        case exp = "Exp"
        case fill = "Fill"
        case link = "Link"
        case link_ = "Link "
        case mpds = "mpds"
        case pgmSegement = "PGM_Segement"
        case pgmSegment = "PGM_Segment"
        case promo = "Promo"
        case song = "Song"
        case spot = "Spot"
        case talk = "Talk"
    }
    
    // MARK: - ExternalID
    struct ExternalID: Codable {
        let id: ID
        let value: String
    }
    
    enum ID: String, Codable {
        case iTunes = "iTunes"
    }
    
    // MARK: - LegacyIDS
    struct LegacyIDS: Codable {
        let siriusXMID: String
        let pid: String?
        
        enum CodingKeys: String, CodingKey {
            case siriusXMID = "siriusXMId"
            case pid
        }
    }
    
    // MARK: - Episode
    struct Episode: Codable {
        let show: Show
        let isLiveVideoEligible: Bool
    }
    
    // MARK: - Show
    struct Show: Codable {
        let aodEpisodeCount, vodEpisodeCount: Int
        let isPlaceholderShow: Bool
        let showGUID: String
        let isLiveVideoEligible: Bool
        let programType: String
        let newVODEpisodeCountFamilyFriendly: Int
        let guid: String
        let vodEpisodeCountFamilyFriendly: Int
        let longTitle: String
        
        enum CodingKeys: String, CodingKey {
            case aodEpisodeCount, vodEpisodeCount, isPlaceholderShow, showGUID, isLiveVideoEligible, programType
            case newVODEpisodeCountFamilyFriendly = "newVodEpisodeCountFamilyFriendly"
            case guid, vodEpisodeCountFamilyFriendly, longTitle
        }
    }
    
    // MARK: - Timestamp
    struct Timestamp: Codable {
        let absolute: String
    }
}


