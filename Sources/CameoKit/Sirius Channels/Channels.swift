import Foundation

typealias ChannelsTuple = (success: Bool, message: String, data: Dictionary<String, Any>, categories: Array<String> )

//https://player.siriusxm.com/rest/v4/experience/carousels?page-name=np_aic_restricted&result-template=everest%7Cweb&channelGuid=86d52e32-09bf-a02d-1b6b-077e0aa05200&cutGuid=50be2dfa-e278-a608-5f0d-9a23db6c45c4&cacheBuster=1550883990670
internal func Channels(channeltype: String, userid: String) -> ChannelsTuple {
    var recordCategories = Array<String>()
    
    
 
    
    var success : Bool? = false
    var message : String? = "Something's not right."
    
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
        let r = result.value(forKeyPath: "ModuleListResponse.moduleList.modules")
        
        if r != nil {
            let m = r as? NSArray
            let o = m![0] as! NSDictionary
            let d = o.value( forKeyPath: "moduleResponse.contentData.channelListing.channels") as! NSArray
            
            var ChannelDict : Dictionary? = Dictionary<String, Any>()
            
            for i in d {
                let dict = i as! NSDictionary
                
                
                let channelGuid = dict.value( forKeyPath: "channelGuid")! as! String
                let channelId = dict.value( forKeyPath: "channelId")! as! String
                let channelNumber = dict.value( forKeyPath: "channelNumber")! as! String
                
                let categories = dict.value( forKeyPath: "categories.categories")! as! NSArray
                
                let cats = categories.firstObject as! NSDictionary
                
                var category = cats.value( forKeyPath: "name")! as! String
                
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
                    //category = category
                }
                
                let chNumber = Int(channelNumber)
                switch chNumber {
                case 20,18,19,22,23,24,31,700,711:
                    category = "Artists"
                case 11,12:
                    category = "Pop"
                case 4,7,8,302:
                    category = "Rock"
                case 13:
                    category = "Dance/Electronic"
                case 9,21,28,33,34,35,36,165,173,359,714,758:
                    category = "Alternative"
                case 37,38,39,40,41:
                    category = "Hard Rock / Heavy Metal"
                case 5,6,701,703,776:
                    category = "Oldies"
                case 314,712,713:
                    category = "Punk"
                case 169:
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
                
                
              
                 // append it to the categories
                 if !recordCategories.contains(category) {
                    recordCategories.append(category)
                 }
                
                
                
                let images = dict.value( forKeyPath: "images.images")! as! NSArray
                
            
                let streamingName = dict.value( forKeyPath: "streamingName")! as! String
                let name = dict.value( forKeyPath: "name")! as! String
                
                var mediumImage = "" as String
                var smallImage = ""
                var tinyImage = ""
                for img in images {
                    let g = img as! NSDictionary
                    
                    let height = g["height"]! as! Int
                    let width = g["height"]! as! Int
                    
                    if height == 720 {
                        mediumImage = g["url"] as! String
                    } else if height == 360 {
                        smallImage = g["url"] as! String
                    } else if height == 80 && width == 80  {
                        tinyImage = g["url"] as! String
                    }
                }
                
                let cl = [ "channelId": channelId, "channelNumber": channelNumber, "streamingName": streamingName, "name": name, "mediumImage": mediumImage, "smallImage": smallImage, "tinyImage": tinyImage, "channelGuid": channelGuid, "category": category ]
                if channeltype == "id" {
                    ChannelDict![channelId] = cl
                } else if channeltype == "name" {
                    ChannelDict![name] = cl
                } else if channeltype == "number" {
                    ChannelDict![channelNumber] = cl
                } else {
                    ChannelDict![channelId] = cl
                }
            }
            
            user.channels = ChannelDict!
            
            if user.channels.count > 1 {
                
                UserDefaults.standard.set(ChannelDict, forKey: "channels")
                
                success = true
                message = "Read the channels in."
                return (success: success!, message: message!, data: ChannelDict!, recordCategories)
            }
        } else {
            success = false
            message = "Error, receiving channels. You are probably not logged in."
        }
        
    }
    


    return (success: success!, message: message!, data: result.data as! Dictionary<String, Any>, categories: recordCategories)

}
