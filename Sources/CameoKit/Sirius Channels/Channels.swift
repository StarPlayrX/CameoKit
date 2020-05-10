import Foundation

typealias ChannelsTuple = (success: Bool, message: String, data: Dictionary<String, Any>, categories: Array<String> )

//https://player.siriusxm.com/rest/v4/experience/carousels?page-name=np_aic_restricted&result-template=everest%7Cweb&channelGuid=86d52e32-09bf-a02d-1b6b-077e0aa05200&cutGuid=50be2dfa-e278-a608-5f0d-9a23db6c45c4&cacheBuster=1550883990670
internal func Channels() -> ChannelsTuple {
    var recordCategories = Array<String>()
    
    var success : Bool = false
    var message : String = "Something's not right."
    
    let endpoint = "https://player.siriusxm.com/rest/v2/experience/modules/get"
    let method = "channels"
    let request =  ["moduleList":["modules":[["moduleArea":"Discovery","moduleType":"ChannelListing","moduleRequest":["resultTemplate":""]]]]] as Dictionary
    
    let result = PostSync(request: request, endpoint: endpoint, method: method )
    
    if (result.response.statusCode) == 403 {
        success = false
        message = "Too many incorrect logins, Sirius XM has blocked your IP for 24 hours."
    }
    
    if result.success {
        let result = result.data as NSDictionary
        if let r = result.value(forKeyPath: "ModuleListResponse.moduleList.modules"),
            let m = r as? NSArray,
            let o = m[0] as? NSDictionary,
            let d = o.value( forKeyPath: "moduleResponse.contentData.channelListing.channels") as? NSArray {
           
            var ChannelDict : Dictionary = Dictionary<String, Any>()
            var ChannelIdDict : Dictionary = Dictionary<String, Any>()
            
            for i in d {
                if let dict = i as? NSDictionary,
                    let channelId = dict.value( forKeyPath: "channelId") as? String {
                    
                    //let channelGuid = dict.value( forKeyPath: "channelGuid") as? String
                    
                    let categories = dict.value( forKeyPath: "categories.categories") as? NSArray
                    
                    if let cats = categories?.firstObject as? NSDictionary,
                        let channelNumber = dict.value( forKeyPath: "channelNumber") as? String,
                        var category = cats.value( forKeyPath: "name") as? String {
                        
                        switch category {
                            case "MLB Play-by-Play":
                                category = "MLB"
                            case "NBA Play-by-Play":
                                category = "NBA"
                            case "NFL Play-by-Play":
                                category = "NFL"
                            case "NHL Play-by-Play":
                                category = "NHL"
                            case "Sports Play-by-Play":
                                category = "Play-by-Play"
                            default:
                                _ = category
                        }
                        
                        let chNumber = Int(channelNumber)
                        switch chNumber {
                            case 20,18,19,22,23,24,31,29,30,38,176,700,711:
                                category = "Artists"
                            case 11,12:
                                category = "Pop"
                            case 4,7,8,28,301,302:
                                category = "Rock"
                            case 13:
                                category = "Dance/Electronic"
                            case 9,21,33,34,35,36,173,359,714,758:
                                category = "Alternative"
                            case 37,39,40,41:
                                category = "Metal"
                            case 5,6,701,703,776:
                                category = "Oldies"
                            case 314,712,713:
                                category = "Punk"
                            case 165,169:
                                category = "Canadian"
                            case 172:
                                category = "Sports"
                            case 171:
                                category = "Country"
                            case 141, 142, 706:
                                category = "Jazz/Standards/Classical"
                            case 152, 158:
                                category = "Latino"
                            default:
                                _ = category
                            //category = category
                        }
                        
                        // append it to the categorieshit
                        if !recordCategories.contains(category) {
                            recordCategories.append(category)
                        }
                        
                        var mediumImage = ""
                        
                        if let images = dict.value( forKeyPath: "images.images") as? NSArray,
                            let name = dict.value( forKeyPath: "name") as? String {
                            
                            let a = 4 //low
                            let b = 8 //high
                            
                            for img in images.reversed()[a...b] {
                                
                                if let g = img as? NSDictionary, let height = g["height"] as? Int, let name = g["name"] as? String {
                                    
                                    if height == 720 && name == "color channel logo (on dark)" {
                                        if let mi = g["url"] as? String {
                                            mediumImage = mi
                                            
                                            break
                                        }
                                    }
                                }
                            }
                            
                            let cl = [ "channelId": channelId, "channelNumber": channelNumber, "name": name,
                                       "mediumImage": mediumImage, "category": category, "preset": false ] as [String : Any]
                            let ids = ["channelNumber": channelNumber] as [String : String]
                            
                            ChannelDict[channelNumber] = cl
                            ChannelIdDict[channelId] = ids
                            
                        }
                    }
                }
            }
            
            user.channels = ChannelDict
            user.ids = ChannelIdDict
            
            if !user.channels.isEmpty {
                
                UserDefaults.standard.set(ChannelDict, forKey: "channels")
                UserDefaults.standard.set(ChannelIdDict, forKey: "ids")

                success = true
                message = "Read the channels in."
                
                return (success: success, message: message, data: ChannelDict, recordCategories)
            }
        }
    }
    
    return (success: success, message: message, data: Dictionary<String, Any>(), categories: recordCategories)
    
}
