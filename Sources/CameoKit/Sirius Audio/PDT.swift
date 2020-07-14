//
//  PDT.swift
//  CameoKit
//
//  Created by Todd Bruss on 1/27/19.
//

import Foundation
import CryptoKit


internal func PDTendpoint() -> String {
    
    let timeInterval = Date().timeIntervalSince1970
    let convert = timeInterval * 1000 as NSNumber
    let intTime = (Int(truncating: convert))
    let time = String(intTime)
    
    let endpoint = "https://player.siriusxm.com/rest/v2/experience/modules/get/discover-channel-list?type=2&batch-mode=true&format=json&request-option=discover-channel-list-withpdt&result-template=web&time=" + time
    
    print(endpoint)
    return endpoint
}

//MARK: Process Artist and Song Data
internal func processPDT(data: DiscoverChannelList) -> [String:Any] {
    var ArtistSongData = [String : Any ]()
    
    //let status = data.moduleListResponse.status //100
    if let live = data.moduleListResponse?.moduleList?.modules?.first?.moduleResponse?.moduleDetails?.liveChannelResponse?.liveChannelResponses {
        
        for i in live {
            
            let channelid = i.channelID
            let markerLists = i.markerLists
            let cutlayer = markerLists?.first
            
            if let markers = cutlayer?.markers, let item = markers.first, let song = item.cut?.title, let artist = item.cut?.artists?.first?.name, let getchannelbyId = userX.ids[channelid ?? ""] as? [String: Any], let channelNo = getchannelbyId["channelNumber"] as? String {
                
                if let key = MD5(artist + song), let image = MemBase[key] {
                    ArtistSongData[channelNo] = ["image" : image, "artist" : artist, "song" : song]
                } else {
                    ArtistSongData[channelNo] = ["image" : "", "artist" : artist, "song" : song]
                }
            } else if let getchannelbyId = userX.ids[channelid ?? ""] as? [String: Any], let channelNo = getchannelbyId["channelNumber"] as? String {
                ArtistSongData[channelNo] = ["image" : "", "artist" : "Don't be a Slacker", "song" : "Be a Star Player. StarPlayrX"]
            }
        }
        
    } else {
        if userX.channels.count > 1 {
            for ( key, value ) in userX.channels {
                
                let v = value as! [String: Any]
                let name = v["name"] as! String
                
                //Substitute text for when channel guide is offline
                ArtistSongData[key] = ["image" : "", "artist": key, "song" : name]
            }
        } else {
            for i in 0...1000 {
                ArtistSongData["\(i)"] = ["image" : "", "artist" : "StarPlayrX", "song" : "iOS Best SiriusXM Radio Player"]
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



// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let discoverChannelList = try DiscoverChannelList(json)


// MARK: - DiscoverChannelList
@objcMembers class DiscoverChannelList: NSObject, Codable {
    var moduleListResponse: ModuleListResponse?
    
    enum CodingKeys: String, CodingKey {
        case moduleListResponse = "ModuleListResponse"
    }
    
    init(moduleListResponse: ModuleListResponse?) {
        self.moduleListResponse = moduleListResponse
    }
}

// MARK: DiscoverChannelList convenience initializers and mutators

extension DiscoverChannelList {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(DiscoverChannelList.self, from: data)
        self.init(moduleListResponse: me.moduleListResponse)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        moduleListResponse: ModuleListResponse?? = nil
    ) -> DiscoverChannelList {
        return DiscoverChannelList(
            moduleListResponse: moduleListResponse ?? self.moduleListResponse
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - ModuleListResponse
@objcMembers class ModuleListResponse: NSObject, Codable {
    var messages: [Message]?
    var status: Int?
    var moduleList: ModuleList?
    
    init(messages: [Message]?, status: Int?, moduleList: ModuleList?) {
        self.messages = messages
        self.status = status
        self.moduleList = moduleList
    }
}

// MARK: ModuleListResponse convenience initializers and mutators

extension ModuleListResponse {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(ModuleListResponse.self, from: data)
        self.init(messages: me.messages, status: me.status, moduleList: me.moduleList)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        messages: [Message]?? = nil,
        status: Int?? = nil,
        moduleList: ModuleList?? = nil
    ) -> ModuleListResponse {
        return ModuleListResponse(
            messages: messages ?? self.messages,
            status: status ?? self.status,
            moduleList: moduleList ?? self.moduleList
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Message
@objcMembers class Message: NSObject, Codable {
    var code: Int?
    var message: String?
    
    init(code: Int?, message: String?) {
        self.code = code
        self.message = message
    }
}

// MARK: Message convenience initializers and mutators

extension Message {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(Message.self, from: data)
        self.init(code: me.code, message: me.message)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        code: Int?? = nil,
        message: String?? = nil
    ) -> Message {
        return Message(
            code: code ?? self.code,
            message: message ?? self.message
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - ModuleList
@objcMembers class ModuleList: NSObject, Codable {
    var modules: [Module]?
    
    init(modules: [Module]?) {
        self.modules = modules
    }
}

// MARK: ModuleList convenience initializers and mutators

extension ModuleList {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(ModuleList.self, from: data)
        self.init(modules: me.modules)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        modules: [Module]?? = nil
    ) -> ModuleList {
        return ModuleList(
            modules: modules ?? self.modules
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Module
@objcMembers class Module: NSObject, Codable {
    var moduleResponse: ModuleResponse?
    var moduleArea, moduleType: String?
    var updateFrequency: Int?
    var wallClockRenderTime: String?
    
    init(moduleResponse: ModuleResponse?, moduleArea: String?, moduleType: String?, updateFrequency: Int?, wallClockRenderTime: String?) {
        self.moduleResponse = moduleResponse
        self.moduleArea = moduleArea
        self.moduleType = moduleType
        self.updateFrequency = updateFrequency
        self.wallClockRenderTime = wallClockRenderTime
    }
}

// MARK: Module convenience initializers and mutators

extension Module {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(Module.self, from: data)
        self.init(moduleResponse: me.moduleResponse, moduleArea: me.moduleArea, moduleType: me.moduleType, updateFrequency: me.updateFrequency, wallClockRenderTime: me.wallClockRenderTime)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        moduleResponse: ModuleResponse?? = nil,
        moduleArea: String?? = nil,
        moduleType: String?? = nil,
        updateFrequency: Int?? = nil,
        wallClockRenderTime: String?? = nil
    ) -> Module {
        return Module(
            moduleResponse: moduleResponse ?? self.moduleResponse,
            moduleArea: moduleArea ?? self.moduleArea,
            moduleType: moduleType ?? self.moduleType,
            updateFrequency: updateFrequency ?? self.updateFrequency,
            wallClockRenderTime: wallClockRenderTime ?? self.wallClockRenderTime
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - ModuleResponse
@objcMembers class ModuleResponse: NSObject, Codable {
    var moduleDetails: ModuleDetails?
    
    init(moduleDetails: ModuleDetails?) {
        self.moduleDetails = moduleDetails
    }
}

// MARK: ModuleResponse convenience initializers and mutators

extension ModuleResponse {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(ModuleResponse.self, from: data)
        self.init(moduleDetails: me.moduleDetails)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        moduleDetails: ModuleDetails?? = nil
    ) -> ModuleResponse {
        return ModuleResponse(
            moduleDetails: moduleDetails ?? self.moduleDetails
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - ModuleDetails
@objcMembers class ModuleDetails: NSObject, Codable {
    var liveChannelResponse: ModuleDetailsLiveChannelResponse?
    
    init(liveChannelResponse: ModuleDetailsLiveChannelResponse?) {
        self.liveChannelResponse = liveChannelResponse
    }
}

// MARK: ModuleDetails convenience initializers and mutators

extension ModuleDetails {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(ModuleDetails.self, from: data)
        self.init(liveChannelResponse: me.liveChannelResponse)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        liveChannelResponse: ModuleDetailsLiveChannelResponse?? = nil
    ) -> ModuleDetails {
        return ModuleDetails(
            liveChannelResponse: liveChannelResponse ?? self.liveChannelResponse
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - ModuleDetailsLiveChannelResponse
@objcMembers class ModuleDetailsLiveChannelResponse: NSObject, Codable {
    var liveChannelResponses: [LiveChannelResponseElement]?
    
    init(liveChannelResponses: [LiveChannelResponseElement]?) {
        self.liveChannelResponses = liveChannelResponses
    }
}

// MARK: ModuleDetailsLiveChannelResponse convenience initializers and mutators

extension ModuleDetailsLiveChannelResponse {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(ModuleDetailsLiveChannelResponse.self, from: data)
        self.init(liveChannelResponses: me.liveChannelResponses)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        liveChannelResponses: [LiveChannelResponseElement]?? = nil
    ) -> ModuleDetailsLiveChannelResponse {
        return ModuleDetailsLiveChannelResponse(
            liveChannelResponses: liveChannelResponses ?? self.liveChannelResponses
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - LiveChannelResponseElement
@objcMembers class LiveChannelResponseElement: NSObject, Codable {
    var channelID: String?
    var aodEpisodeCount: Int?
    var markerLists: [MarkerList]?
    
    enum CodingKeys: String, CodingKey {
        case channelID = "channelId"
        case aodEpisodeCount, markerLists
    }
    
    init(channelID: String?, aodEpisodeCount: Int?, markerLists: [MarkerList]?) {
        self.channelID = channelID
        self.aodEpisodeCount = aodEpisodeCount
        self.markerLists = markerLists
    }
}

// MARK: LiveChannelResponseElement convenience initializers and mutators

extension LiveChannelResponseElement {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(LiveChannelResponseElement.self, from: data)
        self.init(channelID: me.channelID, aodEpisodeCount: me.aodEpisodeCount, markerLists: me.markerLists)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        channelID: String?? = nil,
        aodEpisodeCount: Int?? = nil,
        markerLists: [MarkerList]?? = nil
    ) -> LiveChannelResponseElement {
        return LiveChannelResponseElement(
            channelID: channelID ?? self.channelID,
            aodEpisodeCount: aodEpisodeCount ?? self.aodEpisodeCount,
            markerLists: markerLists ?? self.markerLists
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - MarkerList
@objcMembers class MarkerList: NSObject, Codable {
    var layer: Layer?
    var markers: [Marker]?
    
    init(layer: Layer?, markers: [Marker]?) {
        self.layer = layer
        self.markers = markers
    }
}

// MARK: MarkerList convenience initializers and mutators

extension MarkerList {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(MarkerList.self, from: data)
        self.init(layer: me.layer, markers: me.markers)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        layer: Layer?? = nil,
        markers: [Marker]?? = nil
    ) -> MarkerList {
        return MarkerList(
            layer: layer ?? self.layer,
            markers: markers ?? self.markers
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

enum Layer: String, Codable {
    case cut = "cut"
    case episode = "episode"
}

// MARK: - Marker
@objcMembers class Marker: NSObject, Codable {
    var assetGUID, consumptionInfo: String?
    var layer: Layer?
    var time: Int?
    var timestamp: Timestamp?
    var containerGUID: String?
    var liveGame: Bool?
    var cut: Cut?
    var duration: Double?
    var episode: Episode?
    
    init(assetGUID: String?, consumptionInfo: String?, layer: Layer?, time: Int?, timestamp: Timestamp?, containerGUID: String?, liveGame: Bool?, cut: Cut?, duration: Double?, episode: Episode?) {
        self.assetGUID = assetGUID
        self.consumptionInfo = consumptionInfo
        self.layer = layer
        self.time = time
        self.timestamp = timestamp
        self.containerGUID = containerGUID
        self.liveGame = liveGame
        self.cut = cut
        self.duration = duration
        self.episode = episode
    }
}

// MARK: Marker convenience initializers and mutators

extension Marker {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(Marker.self, from: data)
        self.init(assetGUID: me.assetGUID, consumptionInfo: me.consumptionInfo, layer: me.layer, time: me.time, timestamp: me.timestamp, containerGUID: me.containerGUID, liveGame: me.liveGame, cut: me.cut, duration: me.duration, episode: me.episode)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        assetGUID: String?? = nil,
        consumptionInfo: String?? = nil,
        layer: Layer?? = nil,
        time: Int?? = nil,
        timestamp: Timestamp?? = nil,
        containerGUID: String?? = nil,
        liveGame: Bool?? = nil,
        cut: Cut?? = nil,
        duration: Double?? = nil,
        episode: Episode?? = nil
    ) -> Marker {
        return Marker(
            assetGUID: assetGUID ?? self.assetGUID,
            consumptionInfo: consumptionInfo ?? self.consumptionInfo,
            layer: layer ?? self.layer,
            time: time ?? self.time,
            timestamp: timestamp ?? self.timestamp,
            containerGUID: containerGUID ?? self.containerGUID,
            liveGame: liveGame ?? self.liveGame,
            cut: cut ?? self.cut,
            duration: duration ?? self.duration,
            episode: episode ?? self.episode
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Cut
@objcMembers class Cut: NSObject, Codable {
    var legacyIDS: LegacyIDS?
    var title: String?
    var artists: [Artist]?
    var album: Album?
    var clipGUID, galaxyAssetID: String?
    var cutContentType: CutContentType?
    var memberOfSpotBlock: Bool?
    var mref: String?
    var externalIDS: [ExternalID]?
    var spotBlockID: String?
    var firstCutOfSpotBlock: Bool?
    var contentInfo: String?
    
    enum CodingKeys: String, CodingKey {
        case legacyIDS = "legacyIds"
        case title, artists, album, clipGUID
        case galaxyAssetID = "galaxyAssetId"
        case cutContentType, memberOfSpotBlock, mref
        case externalIDS = "externalIds"
        case spotBlockID = "spotBlockId"
        case firstCutOfSpotBlock, contentInfo
    }
    
    init(legacyIDS: LegacyIDS?, title: String?, artists: [Artist]?, album: Album?, clipGUID: String?, galaxyAssetID: String?, cutContentType: CutContentType?, memberOfSpotBlock: Bool?, mref: String?, externalIDS: [ExternalID]?, spotBlockID: String?, firstCutOfSpotBlock: Bool?, contentInfo: String?) {
        self.legacyIDS = legacyIDS
        self.title = title
        self.artists = artists
        self.album = album
        self.clipGUID = clipGUID
        self.galaxyAssetID = galaxyAssetID
        self.cutContentType = cutContentType
        self.memberOfSpotBlock = memberOfSpotBlock
        self.mref = mref
        self.externalIDS = externalIDS
        self.spotBlockID = spotBlockID
        self.firstCutOfSpotBlock = firstCutOfSpotBlock
        self.contentInfo = contentInfo
    }
}

// MARK: Cut convenience initializers and mutators

extension Cut {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(Cut.self, from: data)
        self.init(legacyIDS: me.legacyIDS, title: me.title, artists: me.artists, album: me.album, clipGUID: me.clipGUID, galaxyAssetID: me.galaxyAssetID, cutContentType: me.cutContentType, memberOfSpotBlock: me.memberOfSpotBlock, mref: me.mref, externalIDS: me.externalIDS, spotBlockID: me.spotBlockID, firstCutOfSpotBlock: me.firstCutOfSpotBlock, contentInfo: me.contentInfo)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        legacyIDS: LegacyIDS?? = nil,
        title: String?? = nil,
        artists: [Artist]?? = nil,
        album: Album?? = nil,
        clipGUID: String?? = nil,
        galaxyAssetID: String?? = nil,
        cutContentType: CutContentType?? = nil,
        memberOfSpotBlock: Bool?? = nil,
        mref: String?? = nil,
        externalIDS: [ExternalID]?? = nil,
        spotBlockID: String?? = nil,
        firstCutOfSpotBlock: Bool?? = nil,
        contentInfo: String?? = nil
    ) -> Cut {
        return Cut(
            legacyIDS: legacyIDS ?? self.legacyIDS,
            title: title ?? self.title,
            artists: artists ?? self.artists,
            album: album ?? self.album,
            clipGUID: clipGUID ?? self.clipGUID,
            galaxyAssetID: galaxyAssetID ?? self.galaxyAssetID,
            cutContentType: cutContentType ?? self.cutContentType,
            memberOfSpotBlock: memberOfSpotBlock ?? self.memberOfSpotBlock,
            mref: mref ?? self.mref,
            externalIDS: externalIDS ?? self.externalIDS,
            spotBlockID: spotBlockID ?? self.spotBlockID,
            firstCutOfSpotBlock: firstCutOfSpotBlock ?? self.firstCutOfSpotBlock,
            contentInfo: contentInfo ?? self.contentInfo
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Album
@objcMembers class Album: NSObject, Codable {
    var title: String?
    
    init(title: String?) {
        self.title = title
    }
}

// MARK: Album convenience initializers and mutators

extension Album {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(Album.self, from: data)
        self.init(title: me.title)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        title: String?? = nil
    ) -> Album {
        return Album(
            title: title ?? self.title
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Artist
@objcMembers class Artist: NSObject, Codable {
    var name: String?
    
    init(name: String?) {
        self.name = name
    }
}

// MARK: Artist convenience initializers and mutators

extension Artist {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(Artist.self, from: data)
        self.init(name: me.name)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        name: String?? = nil
    ) -> Artist {
        return Artist(
            name: name ?? self.name
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

enum CutContentType: String, Codable {
    case exp = "Exp"
    case interstitial = "Interstitial"
    case link = "Link"
    case mpds = "mpds"
    case pgmSegement = "PGM_Segement"
    case pgmSegment = "PGM_Segment"
    case promo = "Promo"
    case song = "Song"
    case spot = "Spot"
    case talk = "Talk"
    case fill = "Fill"

}

// MARK: - ExternalID
@objcMembers class ExternalID: NSObject, Codable {
    var id: ID?
    var value: String?
    
    init(id: ID?, value: String?) {
        self.id = id
        self.value = value
    }
}

// MARK: ExternalID convenience initializers and mutators

extension ExternalID {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(ExternalID.self, from: data)
        self.init(id: me.id, value: me.value)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        id: ID?? = nil,
        value: String?? = nil
    ) -> ExternalID {
        return ExternalID(
            id: id ?? self.id,
            value: value ?? self.value
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

enum ID: String, Codable {
    case iTunes = "iTunes"
}

// MARK: - LegacyIDS
@objcMembers class LegacyIDS: NSObject, Codable {
    var siriusXMID, pid: String?
    
    enum CodingKeys: String, CodingKey {
        case siriusXMID = "siriusXMId"
        case pid
    }
    
    init(siriusXMID: String?, pid: String?) {
        self.siriusXMID = siriusXMID
        self.pid = pid
    }
}

// MARK: LegacyIDS convenience initializers and mutators

extension LegacyIDS {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(LegacyIDS.self, from: data)
        self.init(siriusXMID: me.siriusXMID, pid: me.pid)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        siriusXMID: String?? = nil,
        pid: String?? = nil
    ) -> LegacyIDS {
        return LegacyIDS(
            siriusXMID: siriusXMID ?? self.siriusXMID,
            pid: pid ?? self.pid
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Episode
@objcMembers class Episode: NSObject, Codable {
    var isLiveVideoEligible: Bool?
    var show: Show?
    
    init(isLiveVideoEligible: Bool?, show: Show?) {
        self.isLiveVideoEligible = isLiveVideoEligible
        self.show = show
    }
}

// MARK: Episode convenience initializers and mutators

extension Episode {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(Episode.self, from: data)
        self.init(isLiveVideoEligible: me.isLiveVideoEligible, show: me.show)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        isLiveVideoEligible: Bool?? = nil,
        show: Show?? = nil
    ) -> Episode {
        return Episode(
            isLiveVideoEligible: isLiveVideoEligible ?? self.isLiveVideoEligible,
            show: show ?? self.show
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Show
@objcMembers class Show: NSObject, Codable {
    var longTitle: String?
    var isLiveVideoEligible: Bool?
    var guid, showGUID: String?
    var vodEpisodeCountFamilyFriendly, newVODEpisodeCountFamilyFriendly, aodEpisodeCount: Int?
    var programType: String?
    var vodEpisodeCount: Int?
    var isPlaceholderShow: Bool?
    
    enum CodingKeys: String, CodingKey {
        case longTitle, isLiveVideoEligible, guid, showGUID, vodEpisodeCountFamilyFriendly
        case newVODEpisodeCountFamilyFriendly = "newVodEpisodeCountFamilyFriendly"
        case aodEpisodeCount, programType, vodEpisodeCount, isPlaceholderShow
    }
    
    init(longTitle: String?, isLiveVideoEligible: Bool?, guid: String?, showGUID: String?, vodEpisodeCountFamilyFriendly: Int?, newVODEpisodeCountFamilyFriendly: Int?, aodEpisodeCount: Int?, programType: String?, vodEpisodeCount: Int?, isPlaceholderShow: Bool?) {
        self.longTitle = longTitle
        self.isLiveVideoEligible = isLiveVideoEligible
        self.guid = guid
        self.showGUID = showGUID
        self.vodEpisodeCountFamilyFriendly = vodEpisodeCountFamilyFriendly
        self.newVODEpisodeCountFamilyFriendly = newVODEpisodeCountFamilyFriendly
        self.aodEpisodeCount = aodEpisodeCount
        self.programType = programType
        self.vodEpisodeCount = vodEpisodeCount
        self.isPlaceholderShow = isPlaceholderShow
    }
}

// MARK: Show convenience initializers and mutators

extension Show {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(Show.self, from: data)
        self.init(longTitle: me.longTitle, isLiveVideoEligible: me.isLiveVideoEligible, guid: me.guid, showGUID: me.showGUID, vodEpisodeCountFamilyFriendly: me.vodEpisodeCountFamilyFriendly, newVODEpisodeCountFamilyFriendly: me.newVODEpisodeCountFamilyFriendly, aodEpisodeCount: me.aodEpisodeCount, programType: me.programType, vodEpisodeCount: me.vodEpisodeCount, isPlaceholderShow: me.isPlaceholderShow)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        longTitle: String?? = nil,
        isLiveVideoEligible: Bool?? = nil,
        guid: String?? = nil,
        showGUID: String?? = nil,
        vodEpisodeCountFamilyFriendly: Int?? = nil,
        newVODEpisodeCountFamilyFriendly: Int?? = nil,
        aodEpisodeCount: Int?? = nil,
        programType: String?? = nil,
        vodEpisodeCount: Int?? = nil,
        isPlaceholderShow: Bool?? = nil
    ) -> Show {
        return Show(
            longTitle: longTitle ?? self.longTitle,
            isLiveVideoEligible: isLiveVideoEligible ?? self.isLiveVideoEligible,
            guid: guid ?? self.guid,
            showGUID: showGUID ?? self.showGUID,
            vodEpisodeCountFamilyFriendly: vodEpisodeCountFamilyFriendly ?? self.vodEpisodeCountFamilyFriendly,
            newVODEpisodeCountFamilyFriendly: newVODEpisodeCountFamilyFriendly ?? self.newVODEpisodeCountFamilyFriendly,
            aodEpisodeCount: aodEpisodeCount ?? self.aodEpisodeCount,
            programType: programType ?? self.programType,
            vodEpisodeCount: vodEpisodeCount ?? self.vodEpisodeCount,
            isPlaceholderShow: isPlaceholderShow ?? self.isPlaceholderShow
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Timestamp
@objcMembers class Timestamp: NSObject, Codable {
    var absolute: String?
    
    init(absolute: String?) {
        self.absolute = absolute
    }
}

// MARK: Timestamp convenience initializers and mutators

extension Timestamp {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(Timestamp.self, from: data)
        self.init(absolute: me.absolute)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        absolute: String?? = nil
    ) -> Timestamp {
        return Timestamp(
            absolute: absolute ?? self.absolute
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}
