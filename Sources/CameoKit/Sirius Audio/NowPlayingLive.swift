//
//  nowPlayingLive.swift
//  COpenSSL
//
//  Created by Todd Bruss on 4/5/20.
//

import Foundation

//https://player.siriusxm.com/rest/v4/experience/modules/tune/now-playing-live?channelId=siriushits1&hls_output_mode=none&marker_mode=all_separate_cue_points&ccRequestType=AUDIO_VIDEO&result-template=web&time=1586139639609

internal func nowPlayingLiveSync(endpoint: String) -> NowPlayingLiveStruct? {
    
    //MARK: for Sync
    let semaphore = DispatchSemaphore(value: 0)
    
    var syncData : NowPlayingLiveStruct? = nil
    let http_method = "GET"
    let time_out = 30
    let decoder = JSONDecoder()

    func getURLRequest() -> URLRequest? {
        if let url = URL(string: endpoint) {
            var urlReq = URLRequest(url: url)
            urlReq.httpMethod = http_method
            urlReq.timeoutInterval = TimeInterval(time_out)
            return urlReq
        }
        return nil
    }
    
    if let urlReq = getURLRequest() {
        let task = URLSession.shared.dataTask(with: urlReq ) { ( data, response, error ) in
            
            
            if let response = response, let result = response as? HTTPURLResponse {
                let status = result.statusCode
                
                if status == 200 {
                    
                    if let data = data {
                        
                        do { let nowPlayingLive = try decoder.decode(NowPlayingLiveStruct.self, from: data)
                            syncData = nowPlayingLive
                        } catch {
                            print(error)
                        }
                        
                    }
                }
                
                //MARK: for Sync
                semaphore.signal()
            }
            
        }
		
        task.resume()
    }
    //MARK: for Sync
    _ = semaphore.wait(timeout: .distantFuture)
        
    return syncData
    
}


public func nowPlayingLive(channelid: String) -> Bool {
    
    let timeInterval = Date().timeIntervalSince1970
    let convert = timeInterval * 1000000 as NSNumber
    let intTime = Int(truncating: convert) / 1000
    let time = String(intTime)
    
    
    let endpoint = "https://player.siriusxm.com/rest/v4/experience/modules/tune/now-playing-live?channelId=\(channelid)&hls_output_mode=none&marker_mode=all_separate_cue_points&ccRequestType=AUDIO_VIDEO&result-template=web&time=" + time
    
    //print(endpoint)
    let data = nowPlayingLiveSync(endpoint: endpoint)
    
    if let markers = data?.moduleListResponse.moduleList.modules.first?.moduleResponse.liveChannelData.markerLists {
        
        for m in markers {
            
            for i in m.markers {
                
                let cut = i.cut
                if let artist = cut?.artists.first?.name, let song = cut?.title, let art = cut?.album?.creativeArts  {
                    for j in art.reversed() {
                        let albumart = j.url
                        if let key = MD5(artist + song) {
                            MemBase[key] = albumart
                        }
                        break
                    }
                }
            }
        }
    }

    return true
}



// MARK: - NowPlayingLiveStruct
struct NowPlayingLiveStruct: Codable {
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
        let liveChannelData: LiveChannelData
    }
    
    // MARK: - LiveChannelData
    struct LiveChannelData: Codable {
        let inactivityTimeOut: Int?
        let channelID: String
        let cuePointList: CuePointList?
        let markerLists: [MarkerList]
        let hlsConsumptionInfo: String
        let aodEpisodeCount: Int?
        let connectInfo: ConnectInfo?
        
        enum CodingKeys: String, CodingKey {
            case inactivityTimeOut
            case channelID = "channelId"
            case cuePointList, markerLists, hlsConsumptionInfo, aodEpisodeCount, connectInfo
        }
    }
    
    // MARK: - ConnectInfo
    struct ConnectInfo: Codable {
        let email, phone, twitter: String?
        let twitterLink: String?
        let facebook: String?
        let facebookLink: String?
    }
    
    // MARK: - CuePointList
    struct CuePointList: Codable {
        let cuePoints: [CuePoint]
    }
    
    // MARK: - CuePoint
    struct CuePoint: Codable {
        let assetGUID: String
        let layer: Layer?
        let timestamp: Timestamp?
        let event: Event?
        let time: Int?
        let markerGUID: String?
        let active: Bool?
        
        enum CodingKeys: String, CodingKey {
            case assetGUID, layer, timestamp, event, time
            case markerGUID = "markerGuid"
            case active
        }
    }
    
    enum Event: String, Codable {
        case end = "END"
        case instantaneous = "INSTANTANEOUS"
        case start = "START"
    }
    
    enum Layer: String, Codable {
        case cut = "cut"
        case episode = "episode"
        case livepoint = "livepoint"
        case segment = "segment"
        case show = "show"
    }
    
    // MARK: - Timestamp
    struct Timestamp: Codable {
        let absolute: String
    }
    
    // MARK: - MarkerList
    struct MarkerList: Codable {
        let layer: String
        let markers: [Marker]
    }
    
    // MARK: - Marker
    struct Marker: Codable {
        let time: Int?
        let layer: Layer?
        let assetGUID: String?
        let duration: Double?
        let episode: Episode?
        let timestamp: Timestamp?
        let containerGUID: String?
        let segment: Segment?
        let cut: Cut?
        let consumptionInfo: String?
    }
    
    // MARK: - Cut
    struct Cut: Codable {
        let cutContentType: CutContentType?
        let galaxyAssetID: String?
        let legacyIDS: CutLegacyIDS?
        let title: String
        let memberOfSpotBlock: Bool?
        let artists: [Artist]
        let mref: String?
        let clipGUID: String?
        let album: Album?
        let externalIDS: [ExternalID]?
        let contentInfo: String?
        
        enum CodingKeys: String, CodingKey {
            case cutContentType
            case galaxyAssetID = "galaxyAssetId"
            case legacyIDS = "legacyIds"
            case title, memberOfSpotBlock, artists, mref, clipGUID, album
            case externalIDS = "externalIds"
            case contentInfo
        }
    }
    
    // MARK: - Album
    struct Album: Codable {
        let creativeArts: [AlbumCreativeArt]?
        let title: String?
    }
    
    // MARK: - AlbumCreativeArt
    struct AlbumCreativeArt: Codable {
        let relativeURL: String
        let size: Size
        let url: String
        let type: TypeEnum
        
        enum CodingKeys: String, CodingKey {
            case relativeURL = "relativeUrl"
            case size, url, type
        }
    }
    
    enum Size: String, Codable {
        case medium = "MEDIUM"
        case small = "SMALL"
        case thumbnail = "THUMBNAIL"
    }
    
    enum TypeEnum: String, Codable {
        case image = "IMAGE"
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
        let id, value: String
    }
    
    // MARK: - CutLegacyIDS
    struct CutLegacyIDS: Codable {
        let siriusXMID: String
        let pid: String?
        
        enum CodingKeys: String, CodingKey {
            case siriusXMID = "siriusXMId"
            case pid
        }
    }
    
    // MARK: - Episode
    struct Episode: Codable {
        let isLiveVideoEligible: Bool?
        let legacyIDS: EpisodeLegacyIDS?
        let longDescription: String?
        let live: Bool?
        let host: [String]?
        let dmcaInfo: DMCAInfo?
        let entities: Entities?
        let featuredTweetCoordinate: FeaturedTweetCoordinate?
        let hot: Bool?
        let keywords: Entities?
        let episodeRepeat: Bool?
        let highlighted: Bool?
        let mref: String?
        let mediumTitle: String?
        let show: Show?
        let longTitle, originalAirDate, shortDescription: String?
        let episodeGUID: String?
        let topics: Entities?
        let dataSiftFilterName: String?
        let valuable: Bool?
        
        enum CodingKeys: String, CodingKey {
            case isLiveVideoEligible
            case legacyIDS = "legacyIds"
            case longDescription, live, host, dmcaInfo, entities, featuredTweetCoordinate, hot, keywords
            case episodeRepeat = "repeat"
            case highlighted, mref, mediumTitle, show, longTitle, originalAirDate, shortDescription, episodeGUID, topics, dataSiftFilterName, valuable
        }
    }
    
    // MARK: - DMCAInfo
    struct DMCAInfo: Codable {
        let fwdSkipDur, maxBackSkips, maxSkipDur, backSkipDur: Int
        let maxFwdSkips: Int
        let playOnSelect, channelContentType: String
        let maxTotalSkips: Int
        let irNavClass: String
    }
    
    // MARK: - Entities
    struct Entities: Codable {
    }
    
    // MARK: - FeaturedTweetCoordinate
    struct FeaturedTweetCoordinate: Codable {
        let handle, hashtag: String
    }
    
    // MARK: - EpisodeLegacyIDS
    struct EpisodeLegacyIDS: Codable {
        let shortID: String
        
        enum CodingKeys: String, CodingKey {
            case shortID = "shortId"
        }
    }
    
    // MARK: - Show
    struct Show: Codable {
        let shortDescription: String?
        let legacyIDS: EpisodeLegacyIDS?
        let vodEpisodeCount: Int
        let futureAirings: [FutureAiring]?
        let isPlaceholderShow: Bool?
        let mediumTitle: String?
        let isLiveVideoEligible: Bool
        let disableRecommendations: [String]?
        let programType: String?
        let connectInfo: ConnectInfo?
        let aodEpisodeCount: Int
        let longDescription, longTitle: String?
        let guid, showGUID: String
        let creativeArts: [ShowCreativeArt]?
        let vodEpisodeCountFamilyFriendly, newVODEpisodeCountFamilyFriendly: Int
        
        enum CodingKeys: String, CodingKey {
            case shortDescription
            case legacyIDS = "legacyIds"
            case vodEpisodeCount, futureAirings, isPlaceholderShow, mediumTitle, isLiveVideoEligible, disableRecommendations, programType, connectInfo, aodEpisodeCount, longDescription, longTitle, guid, showGUID, creativeArts, vodEpisodeCountFamilyFriendly
            case newVODEpisodeCountFamilyFriendly = "newVodEpisodeCountFamilyFriendly"
        }
    }
    
    // MARK: - ShowCreativeArt
    struct ShowCreativeArt: Codable {
        let relativeURL: String
        let width: Int
        let type: TypeEnum
        let name: String
        let url: String
        let height: Int
        
        enum CodingKeys: String, CodingKey {
            case relativeURL = "relativeUrl"
            case width, type, name, url, height
        }
    }
    
    // MARK: - FutureAiring
    struct FutureAiring: Codable {
        let timestamp: String?
        let satelliteOnlyChannel: Bool?
        let channelID: String?
        let duration: Int?
        
        enum CodingKeys: String, CodingKey {
            case timestamp, satelliteOnlyChannel
            case channelID = "channelId"
            case duration
        }
    }
    
    // MARK: - Segment
    struct Segment: Codable {
        let segmentType: SegmentType
        let legacyIDS: EpisodeLegacyIDS
        
        enum CodingKeys: String, CodingKey {
            case segmentType
            case legacyIDS = "legacyIds"
        }
    }
    
    enum SegmentType: String, Codable {
        case soft = "SOFT"
    }

}
